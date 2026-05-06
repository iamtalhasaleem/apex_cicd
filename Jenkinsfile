pipeline {
    agent any
    environment {
        SQLCL_PATH = '/opt/sqlcl/bin/sql'
        PROD_CONN  = 'test-21c.maxapex.net:1521/xepdb1'
        DEV_JDBC   = 'jdbc:oracle:thin:@test-23ai.maxapex.net:1521/xepdb1'
        WORKSPACE_NAME = 'MAXPRINT_DEMO'
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Sync Schema Deletions') {
            steps {
                withCredentials([
                    usernamePassword(credentialsId: 'prod_db_creds', passwordVariable: 'PROD_PASS', usernameVariable: 'PROD_USER'),
                    usernamePassword(credentialsId: 'dev_db_creds', passwordVariable: 'DEV_PASS', usernameVariable: 'DEV_USER')
                ]) {
                    echo 'Identifying objects deleted in Dev...'
                    sh """
                        ${SQLCL_PATH} ${PROD_USER}/${PROD_PASS}@${PROD_CONN} <<EOF
                        lb diff-changelog -reference-url ${DEV_JDBC} -reference-username ${DEV_USER} -reference-password ${DEV_PASS} -exclude-objects "DATABASECHANGELOG,DATABASECHANGELOGLOCK,DATABASECHANGELOG_ACTIONS,DATABASECHANGELOG_DETAILS" -output-file auto_cleanup.xml
                        exit
EOF
                    """
                }
            }
        }

        stage('Deploy DB Changes') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'prod_db_creds', passwordVariable: 'DB_PASS', usernameVariable: 'DB_USER')]) {
                    echo 'Applying Schema Updates...'
                    sh """
                        ${SQLCL_PATH} ${DB_USER}/${DB_PASS}@${PROD_CONN} <<EOF
                        -- 1. Run the auto-generated deletions first
                        lb update -changelog-file auto_cleanup.xml
                        
                        -- 2. Run the main project changelog from Git
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
                withCredentials([usernamePassword(credentialsId: 'prod_db_creds', passwordVariable: 'DB_PASS', usernameVariable: 'DB_USER')]) {
                    echo 'Deploying APEX Application...'
                    sh """
                        ${SQLCL_PATH} ${DB_USER}/${DB_PASS}@${PROD_CONN} <<EOF
                        set serveroutput on
                        declare
                            l_workspace_id number;
                        begin
                            select workspace_id into l_workspace_id from apex_workspaces where workspace = '${WORKSPACE_NAME}';
                            apex_application_install.set_workspace_id(l_workspace_id);
                            apex_application_install.generate_offset;
                            apex_application_install.set_schema(upper('${DB_USER}'));
                        end;
                        /
                        @apex/f103.sql
                        exit
EOF
                    """
                }
            }
        }
    }
}
