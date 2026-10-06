stage('Deploy Services') {
    steps {
        sh '''
            pwd
            ls -la
            cd /home/sani/DevOps/Jenkins_CICD_Sani_Rajesh_Lokhande/
            ls -la

            echo "Deploying backend"
            sudo systemctl daemon-reload
            sudo systemctl restart student_flask_app.service
            sudo systemctl status student_flask_app.service --no-pager

            echo "deploying frontend"
            pm2 start student_app.js --name 'express-frontend'
        '''
    }
}
