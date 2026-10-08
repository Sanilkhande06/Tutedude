pipeline {
    agent any
    stages {
        stage('Deploy Services') {
            steps {
                sh '''
                    pwd
                    ls -la
                    cd DevOps/Jenkins_CICD_Sani_Rajesh_Lokhande/frontend
                    ls -la

                    echo "Deploying backend"
                    sudo systemctl daemon-reload
                    sudo systemctl restart student_flask_app.service
                    sudo systemctl status student_flask_app.service

                    echo "deploying frontend 5nd time"
                    pm2 start student_app.js --name 'express-frontend'
                '''
            }
        }
    }
}
