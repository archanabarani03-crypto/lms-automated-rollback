
#!/usr/bin/env bash
set -Eeuo pipefail

NEW_IMAGE="${1:?Usage: deploy.sh IMAGE_TAG [FAIL_HEALTH]}"
FAIL_HEALTH="${2:-false}"

CONTAINER="lms-app"
PORT="8081"
STATE_DIR="/var/lib/jenkins/lms-rollback-state"
STATE_FILE="$STATE_DIR/last-good-image"

mkdir -p "$STATE_DIR"

OLD_IMAGE=""
if [ -s "$STATE_FILE" ]; then
    OLD_IMAGE="$(cat "$STATE_FILE")"
fi

echo "Previous known-good image: ${OLD_IMAGE:-none}"
echo "Requested image: $NEW_IMAGE"
echo "Failure injection enabled: $FAIL_HEALTH"

# Ensure the requested image exists before changing the service.
docker image inspect "$NEW_IMAGE" >/dev/null

# Remove the previous running container. Its image remains available.
docker rm -f "$CONTAINER" >/dev/null 2>&1 || true

start_container() {
    local image="$1"
    local version="$2"
    local fail_health="$3"

    docker run -d \
        --name "$CONTAINER" \
        --restart unless-stopped \
        -p "${PORT}:8080" \
        -e "APP_VERSION=${version}" \
        -e "FAIL_HEALTH=${fail_health}" \
        "$image"
}

if ! start_container "$NEW_IMAGE" "$NEW_IMAGE" "$FAIL_HEALTH"; then
    echo "New container failed to start."
else
    if bash scripts/health-check.sh \
        "http://127.0.0.1:${PORT}/health" 10 3; then

        printf '%s\n' "$NEW_IMAGE" > "$STATE_FILE"
        echo "DEPLOYMENT SUCCESS: $NEW_IMAGE"
        exit 0
    fi
fi

echo "NEW VERSION UNHEALTHY: starting rollback"

docker logs "$CONTAINER" 2>&1 || true
docker rm -f "$CONTAINER" >/dev/null 2>&1 || true

if [ -z "$OLD_IMAGE" ]; then
    echo "ROLLBACK IMPOSSIBLE: no previous known-good image is recorded."
    exit 1
fi

if ! docker image inspect "$OLD_IMAGE" >/dev/null 2>&1; then
    echo "ROLLBACK FAILED: previous image $OLD_IMAGE is unavailable."
    exit 2
fi

if ! start_container "$OLD_IMAGE" "$OLD_IMAGE" false; then
    echo "ROLLBACK FAILED: previous container could not start."
    exit 2
fi

if bash scripts/health-check.sh \
    "http://127.0.0.1:${PORT}/health" 10 3; then
    echo "ROLLBACK SUCCESS: restored $OLD_IMAGE"
    exit 1
fi

echo "CRITICAL: rollback version is also unhealthy."
docker logs "$CONTAINER" 2>&1 || true
exit 2
