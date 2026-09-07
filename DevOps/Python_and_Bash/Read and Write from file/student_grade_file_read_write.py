import json

with open("student_info.txt", "a+") as file:
    file.seek(0)
    student_info = file.read()
    student_info = student_info.replace("'", '"')
    print(f"student_info : {student_info} type : {type(student_info)}")
    if student_info and "{}" not in student_info:
        student_info = json.loads(student_info)
    else:
        student_info = {}

for i in range(10):
    print("***********************************")
    print("add : add new student")
    print("update : update student details")
    print("get : print all student details")
    print("exit : exit")
    ops = input("choose operation  ")
    if ops == "add":
        stud_name = input("enter student name  ")
        if stud_name in student_info:
            print(f"student {stud_name}\'s details already present")
            continue
        grade = input("enter student grade  ")
        if stud_name and grade and grade in ["A", "B", "C", "D", "F"]:
            student_info[stud_name] = grade
            print(f"added student details: {stud_name} : {grade}")
        else:
            print("invalid student details provided. please retry ...")
    elif ops == "update":
        stud_name = input("enter student name  ")
        if stud_name not in student_info:
            print(f"student {stud_name}\'s details not present to update")
            continue
        grade = input("enter student grade  ")
        if grade and grade in ["A", "B", "C", "D", "F"]:
            student_info[stud_name] = grade
            print(f"updated student details: {stud_name} : {grade}")
        else:
            print("invalid student details provided. please retry ...")
    elif ops == "get":
        print(f"sudent details : {student_info}")
    elif ops == "exit":
        with open("student_info.txt", "w+") as file:
            file.write(str(student_info))
            #json.dump(student_info, file, indent=4)
        exit()
    else:
        print("invalid operation")
with open("student_info.txt", "w+") as file:
    file.write(str(student_info))
    #json.dump(student_info, file, indent=4)