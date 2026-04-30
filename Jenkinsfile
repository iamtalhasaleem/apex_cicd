pipeline {
    agent any
    environment {
        SQLCL_PATH = '/opt/sqlcl/bin/sql'
        PROD_CONN  = 'test-21c.maxapex.net:1521/xepdb1' 
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Deploy DB Changes') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'prod_db_creds', 
                                 passwordVariable: 'DB_PASS', 
                                 usernameVariable: 'DB_USER')]) {
                    echo 'Running Liquibase Update...'
                    sh """
                        ${SQLCL_PATH} ${DB_USER}/${DB_PASS}@${PROD_CONN} <<EOF
                        cd db
                        lb update -changelog-file controller.xml
                        exit
EOF
                    """
                }
            }
        }
        stage('Deploy APEX App') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'prod_db_creds', 
                                 passwordVariable: 'DB_PASS', 
                                 usernameVariable: 'DB_USER')]) {
                    echo 'Importing APEX Application...'
                    sh """
                        ${SQLCL_PATH} ${DB_USER}/${DB_PASS}@${PROD_CONN} <<EOF
                        @apex/f103/install.sql
                        exit
EOF
                    """
                }
            }
        }
    }
}
