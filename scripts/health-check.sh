
#!/usr/bin/env bash
set -u

URL="${1:-http://127.0.0.1:8081/health}"
RETRIES="${2:-10}"
DELAY="${3:-3}"

for attempt in $(seq 1 "$RETRIES"); do
    echo "Health check attempt $attempt/$RETRIES: $URL"

    if curl --fail --silent --show-error \
        --max-time 3 "$URL"; then
        echo
        echo "HEALTH CHECK PASSED"
        exit 0
    fi

    echo "Health check failed."

    if [ "$attempt" -lt "$RETRIES" ]; then
        sleep "$DELAY"
    fi
done

echo "HEALTH CHECK FAILED after $RETRIES attempts"
exit 1
