import os
import json
from dotenv import load_dotenv
from urllib.parse import quote_plus


class Students:
    def __init__(self):
        load_dotenv()
        self.student_file = os.getenv("STUDENT_DB")

    def insert(self, student_info):
        student_data = {}
        with open(self.student_file, "r") as file:
            student_data = json.load(file)
        if not student_data.get("student_info") :
            student_data["student_info"] = []
        else:
            for student in student_data["student_info"]:
                if student["id"] == student_info["stud_id"]:
                    print("Student information already exists")
                    return
        student_data["student_info"].append({
            "id" : student_info["stud_id"],
            "name" : student_info["stud_name"],
            "grades" : student_info["stud_grades"]
        })
        with open(self.student_file, "w") as file:
            json.dump(student_data, file)
        print("Student information added successfully")

    def get_data(self):
        with open(self.student_file, "r") as file:
            student_data = json.load(file)
        return student_data["student_info"]