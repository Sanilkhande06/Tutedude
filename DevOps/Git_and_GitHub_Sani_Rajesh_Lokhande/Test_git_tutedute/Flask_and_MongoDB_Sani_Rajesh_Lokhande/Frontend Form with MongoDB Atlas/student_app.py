from flask import Flask, render_template, request
import json
from student_db import Students
app = Flask(__name__)
student = Students()

@app.route("/")
def home():
    return render_template('studen_form.html')

@app.route("/students", methods=["POST"])
def save_student_info():
    if request.method == "POST":
        stud_name = request.form.get("name")
        stud_grades = request.form.get("grades")
        print(f"student_name = {stud_name}")
    
        student_info = student.get_data()
        stud = [row for row in student_info if stud_name in row["name"]]
        if stud:
            return render_template('studen_form.html', result="student already present")
        if stud_grades not in ["A", "B", "C", "D", "F"]:
            return render_template('studen_form.html', result="invalid grades entered")

        student.insert({"name" : stud_name, "grades": stud_grades})
    return "data saved successfully"

@app.route("/students", methods=["GET"])
def list_students_info():
    student_info = student.get_data()
    print(student_info)
    return student_info

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8900)


