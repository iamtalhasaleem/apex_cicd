pipeline {
    agent any
    environment {
        SQLCL_PATH = '/opt/sqlcl/bin/sql'
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Deploy DB Changes') {
            steps {
                echo 'Deploying database objects via Liquibase...'
                // We will add the specific 'lb update' command here
            }
        }
        stage('Deploy APEX App') {
            steps {
                echo 'Deploying APEX Application...'
                // We will add the 'apex import' command here
            }
        }
    }
}
