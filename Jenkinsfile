pipeline {
    agent any
    environment {
        SQLCL_PATH = '/opt/sqlcl/bin/sql'
        // Connection for your test-21c environment
        PROD_CONN  = 'test-21c.maxapex.net:1521/xepdb1' 
        // Matches your Production Workspace Name exactly
        WORKSPACE_NAME = 'MAXPRINT_DEMO' 
    }
    stages {
        stage('Checkout') {
            steps {
                // Pulls the clean, regenerated folders from your GitHub repository
                checkout scm
            }
        }
        stage('Deploy DB Changes') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'prod_db_creds', 
                                 passwordVariable: 'DB_PASS', 
                                 usernameVariable: 'DB_USER')]) {
                    echo 'Starting Database Schema Update via Liquibase...'
                    sh """
                        ${SQLCL_PATH} ${DB_USER}/${DB_PASS}@${PROD_CONN} <<EOF
                        cd db
                        -- Ensures a clean run after your manual deletions of triggers
                        lb clear-checksums
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
                    echo 'Initiating APEX Application Deployment...'
                    sh """
                        ${SQLCL_PATH} ${DB_USER}/${DB_PASS}@${PROD_CONN} <<EOF
                        set serveroutput on
                        declare
                            l_workspace_id number;
                            -- CRITICAL: Force uppercase to prevent ORA-44001 invalid schema error
                            l_schema varchar2(100) := upper('${DB_USER}'); 
                        begin
                            -- 1. Dynamically find the Workspace ID on this specific server
                            select workspace_id into l_workspace_id 
                              from apex_workspaces 
                             where workspace = '${WORKSPACE_NAME}';
                            
                            -- 2. Force the session to the correct Workspace context
                            apex_util.set_security_group_id(p_security_group_id => l_workspace_id);
                            
                            -- 3. THE FIX: Overrides the hardcoded IDs inside the export files
                            apex_application_install.set_workspace_id(l_workspace_id);
                            apex_application_install.generate_offset;
                            apex_application_install.set_schema(l_schema);
                            
                            dbms_output.put_line('Target Workspace ID forced to: ' || l_workspace_id);
                            dbms_output.put_line('Target Schema set to: ' || l_schema);
                        end;
                        /
                        
                        -- Execute the fresh split-export install script
                        @apex/f103/install.sql
                        exit
EOF
                    """
                }
            }
        }
    }
    post {
        success {
            echo 'Deployment completed successfully for MaxPrint V2.'
        }
        failure {
            echo 'Deployment failed. Please check the SQLcl logs for dependency issues.'
        }
    }
}
