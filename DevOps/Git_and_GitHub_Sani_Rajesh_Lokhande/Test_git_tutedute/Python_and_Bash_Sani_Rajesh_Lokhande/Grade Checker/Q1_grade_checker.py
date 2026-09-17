import sys

if len(sys.argv)<2:
    print("please provide marks")
    exit()
score = int(sys.argv[1])
grade = None

if score >= 90 and score <=100:
    grade = "A"
elif score >=80 and score < 90:
    grade = "B"
elif score >=70 and score < 80:
    grade = "C"
elif score >=60 and score < 70:
    grade = "D"
elif score < 60:
    grade = "F"
else:
    print("invalid score provided")
if grade:
    print(f"Grade is {grade}")
