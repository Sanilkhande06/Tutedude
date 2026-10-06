const express = require('express');
const path = require('path');
const app = express();
require('dotenv').config();
const PORT = 3000;
const BACKEND_HOST = process.env.BACKEND_HOST;
const BACKEND_PORT = process.env.BACKEND_PORT;
console.log(BACKEND_HOST);
console.log(BACKEND_PORT);
const BACKEND_URL = `http://${BACKEND_HOST}:${BACKEND_PORT}/students`;
console.log(BACKEND_URL);
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});

app.use(express.urlencoded({ extended: true })); 
app.use(express.json());
app.post('/students', async (req, res) => {
  console.log(req.body);
  student_data = {
    stud_id: req.body.Sid,
    stud_name: req.body.Sname,  
    stud_grades: req.body.Sgrades
  };
  console.log(student_data);
  response = await fetch(BACKEND_URL, {
    method: 'POST',
    body: JSON.stringify(student_data),
    headers: {
      'Content-Type': 'application/json'
    }
  })
  data = await response.json();
  console.log(data);
  if (data.status == "success") {
    res.send("data saved successfully");
  } else {
    res.send("data not saved");
  }
});

app.listen(PORT, () => {
  console.log(`Server is running at http://0.0.0.0:${PORT}`);
});