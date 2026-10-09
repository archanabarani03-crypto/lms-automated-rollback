
FROM python:3.12-slim

WORKDIR /app

COPY app/app.py /app/app.py

ENV APP_VERSION=unknown
ENV FAIL_HEALTH=false
ENV PYTHONDONTWRITEBYTECODE=1

EXPOSE 8080

USER 10001

CMD ["python", "-u", "/app/app.py"]
