# app.py

from flask import Flask
from config import Config
from blueprints.auth import auth_bp

app = Flask(__name__)
app.config.from_object(Config)

# Register the authentication blueprint
app.register_blueprint(auth_bp)

if __name__ == '__main__':
    app.run(debug=True)
