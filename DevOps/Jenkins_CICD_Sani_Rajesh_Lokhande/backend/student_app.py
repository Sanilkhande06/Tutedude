from flask import Flask, render_template, request, jsonify
import json
from student_db import Students
import dotenv
import os
dotenv.load_dotenv()
app = Flask(__name__)
student = Students()
PORT = int(os.getenv("BACKEND_PORT", 5000))

@app.route("/") 
def home():
    return render_template('studen_form.html')

@app.route("/students", methods=["POST"])
def save_student_info():
    if request.method == "POST":
        student_data = request.get_json()
        print(student_data)
        student.insert(student_data)
        return jsonify({"message": "data saved successfully", "status": "success"})

@app.route("/students", methods=["GET"])
def list_students_info():
    student_info = student.get_data()
    print(student_info)
    return student_info

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=PORT)
