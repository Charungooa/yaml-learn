# python app based on Flask API with /health, /info, /ready
import os
import socket
from datetime import datetime, timezone

from flask import Flask, jsonify

app = Flask(__name__)


@app.route("/health")
def health():
    """Liveness probe endpoint.
    Returns 200 if the application process is alive and responsive.
    Kubernetes restarts the pod if this fails.
    """
    return jsonify({"status": "healthy"}), 200


@app.route("/ready")
def ready():
    """Readiness probe endpoint.
    Returns 200 if the application is ready to accept traffic.
    Kubernetes removes the pod from service endpoints if this fails.
    In a real app, you'd check database connections, cache availability, etc.
    """
    # Simulate a readiness check — in production, verify dependencies here
    ready_status = True

    if ready_status:
        return jsonify({"status": "ready"}), 200
    else:
        return jsonify({"status": "not ready"}), 503


@app.route("/info")
def info():
    """Returns basic info about the running instance.
    Useful for verifying which pod is serving the request.
    """
    return jsonify({
        "hostname": socket.gethostname(),
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "app_env": os.environ.get("APP_ENV", "unknown"),
        "api_key_loaded": bool(os.environ.get("API_KEY")),
        "version": "1.0.0"
    }), 200


@app.route("/")
def root():
    """Root endpoint — simple welcome message."""
    return jsonify({
        "message": "Welcome to Amit's Flask Microservice",
        "endpoints": ["/health", "/ready", "/info"]
    }), 200


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port)