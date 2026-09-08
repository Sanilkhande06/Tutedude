import os
from dotenv import load_dotenv
from pymongo import MongoClient
from urllib.parse import quote_plus


class Students:
    def __init__(self):
        load_dotenv()
        uri = os.getenv("MONGO_URI")
        username = os.getenv("MONGO_USERNAME")
        password = quote_plus(os.getenv("MONGO_PASSWORD"))
        host = os.getenv("MONGO_HOST")
        MONGO_URI = f"{uri}{username}:{password}@{host}"
        client = MongoClient(MONGO_URI)

        db = client["Tutedude_assignments"]
        self.student_col = db["Students"]
        print(self.student_col)

    def insert(self, student_info):
        result = self.student_col.insert_one(student_info)
        print(result)

    def get_data(self):
        data = self.student_col.find()
        student_data = []
        for stud_data in data:
            student_data.append({
            "id": str(stud_data["_id"]),
            "name": stud_data.get("name"),
            "grades": stud_data.get("grades")
        })
        print(student_data)
        return student_data