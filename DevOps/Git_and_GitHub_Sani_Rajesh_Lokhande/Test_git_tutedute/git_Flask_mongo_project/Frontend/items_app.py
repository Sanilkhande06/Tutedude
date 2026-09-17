from flask import Flask, render_template, request
import json
import requests
app = Flask(__name__)
backend_url = "http://localhost:8901/items"
@app.route("/")
def home():
    return render_template('index.html')

@app.route("/items", methods=["POST"])
def save_item_info():
    if request.method == "POST":
        item_info = dict(request.form)
        print(f"item_name = {item_info}")
        requests.post(backend_url, item_info)
    return render_template('save_item.html')

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8900)
