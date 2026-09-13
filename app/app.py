import os

from flask import Flask, jsonify


def create_app() -> Flask:
    application = Flask(__name__)

    @application.get("/")
    def index():
        return jsonify(
            message="Hello from the multi-region GKE reference application",
            region=os.getenv("DEPLOYMENT_REGION", "local"),
        )

    @application.get("/healthz")
    def healthz():
        return jsonify(status="ok"), 200

    return application


app = create_app()


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
