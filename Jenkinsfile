pipeline {
    agent any
    environment {
        SQLCL_PATH = '/opt/sqlcl/bin/sql'
        PROD_CONN  = 'test-21c.maxapex.net:1521/xepdb1' 
        // Ensure this matches your Production Workspace Name exactly
        WORKSPACE_NAME = 'MAXPRINT_DEMO' 
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
                        -- This block fixes the Workspace ID mismatch
                        set serveroutput on
                        declare
                            l_workspace_id number;
                        begin
                            select workspace_id into l_workspace_id 
                              from apex_workspaces 
                             where workspace = '${WORKSPACE_NAME}';
                            
                            wwv_flow_imp.set_workspace(p_workspace_id => l_workspace_id);
                            dbms_output.put_line('Workspace ID set to: ' || l_workspace_id);
                        end;
                        /
                        
                        -- Now run the install
                        @apex/f103/install.sql
                        exit
EOF
                    """
                }
            }
        }
    }
}
