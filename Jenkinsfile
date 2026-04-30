pipeline {
    agent any
    environment {
        SQLCL_PATH = '/opt/sqlcl/bin/sql'
        // Verified connection string for your production server
        PROD_CONN  = 'test-21c.maxapex.net:1521/xepdb1' 
        // Ensure this matches your Production Workspace Name exactly
        WORKSPACE_NAME = 'MAXPRINT_DEMO' 
    }
    stages {
        stage('Checkout') {
            steps {
                // Pulls the latest code from your GitHub repository
                checkout scm
            }
        }
        stage('Deploy DB Changes') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'prod_db_creds', 
                                 passwordVariable: 'DB_PASS', 
                                 usernameVariable: 'DB_USER')]) {
                    echo 'Running Liquibase Update for Database Objects...'
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
                        set serveroutput on
                        declare
                            l_workspace_id number;
                        begin
                            -- Find the local Workspace ID by name
                            select workspace_id into l_workspace_id 
                              from apex_workspaces 
                             where workspace = '${WORKSPACE_NAME}';
                            
                            -- Set the security group ID so the import recognizes the workspace
                            apex_util.set_security_group_id(p_security_group_id => l_workspace_id);
                            dbms_output.put_line('Security Group ID set to: ' || l_workspace_id);
                        end;
                        /
                        
                        -- Run the APEX installation script
                        @apex/f103/install.sql
                        exit
EOF
                    """
                }
            }
        }
    }
}
