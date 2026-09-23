FROM python:3.11-slim

ADD requirements.txt /app/requirements.txt

ADD . /app

WORKDIR /app

RUN pip install -r requirements.txt

CMD ["python3", "student_app.py"]