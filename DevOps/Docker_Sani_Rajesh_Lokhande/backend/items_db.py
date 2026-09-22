import os
from dotenv import load_dotenv
from pymongo import MongoClient
from urllib.parse import quote_plus


class Items:
    def __init__(self):
        load_dotenv()
        uri = os.getenv("MONGO_URI")
        username = os.getenv("MONGO_USERNAME")
        password = quote_plus(os.getenv("MONGO_PASSWORD"))
        host = os.getenv("MONGO_HOST")
        MONGO_URI = f"{uri}{username}:{password}@{host}"
        client = MongoClient(MONGO_URI)

        db = client["Tutedude_assignments"]
        self.items_col = db["Items"]
        print(self.items_col)

    def insert(self, item_info):
        result = self.items_col.insert_one(item_info)
        print(result)

    def get_data(self):
        data = self.items_col.find()
        item_data = []
        for item in data:
            item_data.append({
            "id": str(item["_id"]),
            "name": item.get("name"),
            "des": item.get("description")
        })
        print(item_data)
        return item_data