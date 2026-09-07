from flask import Flask

app = Flask(__name__)

print(__name__)

@app.route("/")
def get_student_info():
    student_info = {}
    with open("student_info.json", "r") as stud_file:
        student_info = stud_file.read()
    return student_info

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8900)


