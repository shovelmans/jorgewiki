FROM python:3.11-slim

# instalar dependencias
RUN apt-get update && \
    apt-get install -y curl ca-certificates && \
    curl -LO https://dl.k8s.io/release/v1.30.0/bin/linux/amd64/kubectl && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

# instalar librerías python
RUN pip install flask

WORKDIR /app

COPY healthcheck.py .

CMD ["python", "healthcheck.py"]