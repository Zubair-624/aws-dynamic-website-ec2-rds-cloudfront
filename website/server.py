import os
import sys
import boto3 
import pymysql
from flask import Flask, render_template, request, redirect, url_for, jsonify

app = Flask(__name__)

#----------Step 1: Read secrets from SSM Parameter Store----------
# App never stores passwords in code or environment variables
# Everything comes from SSM at startup

def get_ssm_parameter(name):
    """Read a single parameter from AWS SSM Parameter Store"""
    client = boto3.client("ssm", region_name="us-east-1")
    response = client.get_parameter(Name=name, WithDecryption=True)
    return response["Parameter"]["Value"]

PROJECT = "aws-dynamic-website-ec2-rds-cloudfront"

DB_HOST     = get_ssm_parameter(f"/web/{PROJECT}/db/host")
DB_NAME     = get_ssm_parameter(f"/web/{PROJECT}/db/name")
DB_USER     = get_ssm_parameter(f"/web/{PROJECT}/db/username")
DB_PASSWORD = get_ssm_parameter(f"/web/{PROJECT}/db/password")
DB_PORT     = 3306


#----------Step 2: Database connection helper----------

def get_db_connection():
    """Open a fresh connection to RDS MySQL"""
    return pymysql.connect(
        host     = DB_HOST,
        user     = DB_USER,
        password = DB_PASSWORD,
        database = DB_NAME,
        port     = DB_PORT,
        cursorclass = pymysql.cursors.DictCursor
    )


#----------Step 3: Routes----------

@app.route("/", methods=["GET", "POST"])
def index():
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:

            # Increment visit counter
            cursor.execute("UPDATE visitors SET count = count + 1 WHERE id = 1")
            conn.commit()

            # Get current visit count
            cursor.execute("SELECT count FROM visitors WHERE id = 1")
            visit_count = cursor.fetchone()["count"]

            # Handle new message submission
            if request.method == "POST":
                name    = request.form.get("name", "Anonymous")
                message = request.form.get("message", "")
                if message.strip():
                    cursor.execute(
                        "INSERT INTO messages (name, message) VALUES (%s, %s)",
                        (name, message)
                    )
                    conn.commit()
                return redirect(url_for("index"))

            # Get last 10 messages
            cursor.execute(
                "SELECT name, message, created_at FROM messages ORDER BY created_at DESC LIMIT 10"
            )
            messages = cursor.fetchall()

    finally:
        conn.close()

    return render_template("index.html", visit_count=visit_count, messages=messages)


@app.route("/health")
def health():
    """Health check endpoint for GitHub Actions and CloudFront"""
    return jsonify({"status": "ok"}), 200


@app.errorhandler(404)
def page_not_found(e):
    return render_template("404.html"), 404


#----------Step 4: Start the app----------

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)