from flask import Flask, request
from items_db import Items
app = Flask(__name__)
items = Items()

@app.route("/")
def home():
    return "backend for items"

@app.route("/items", methods=["POST"])
def save_item_info():
    if request.method == "POST":
        item_details = {
            "name" : request.form.get("name"),
            "description" : request.form.get("des"),
            "item_id" : request.form.get("i_id"),
            "uuid" : request.form.get("uuid"),
            "hash" : request.form.get("hash")
        }
        print(f"item info received from frontend = {item_details}")
        items.insert(item_details)
        data = {
            "status_code" : 200,
            "message" : "data saved successfully"
        }
    return data

@app.route("/items/list", methods=["GET"])
def list_items():
    item_info = items.get_data()
    print(item_info)
    items_list = {
        "data" : item_info
    }
    return items_list

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8901)


