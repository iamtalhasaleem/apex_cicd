pipeline {
    agent any
    environment {
        // Path to the updated SQLcl 25.4
        SQLCL_PATH = '/opt/sqlcl/bin/sql'
        
        // Production Connection (Target)
        PROD_CONN  = 'test-21c.maxapex.net:1521/xepdb1'
        
        // Your APEX Workspace Name
        WORKSPACE_NAME = 'MAXPRINT_DEMO'
    }
    stages {
        stage('Checkout') {
            steps {
                // Pulls the fresh db_sync.xml, db/ folder, and apex/ folder from GitHub
                checkout scm
            }
        }

        stage('Sync Database') {
            steps {
                withCredentials([
                    usernamePassword(credentialsId: 'prod_db_creds', passwordVariable: 'PROD_PASS', usernameVariable: 'PROD_USER')
                ]) {
                    echo 'Applying Database Changes from GitHub...'
                    sh """
                        ${SQLCL_PATH} ${PROD_USER}/${PROD_PASS}@${PROD_CONN} <<EOF
                        whenever sqlerror exit failure

                        -- 1. Apply the manually generated sync file (handles deletions/updates)
                        lb update -changelog-file db_sync.xml

                        -- 2. Apply the full schema objects (Source of Truth)
                        cd db
                        lb update -changelog-file controller.xml
                        exit
EOF
                    """
                }
            }
        }

        stage('Deploy APEX') {
            steps {
                withCredentials([
                    usernamePassword(credentialsId: 'prod_db_creds', passwordVariable: 'DB_PASS', usernameVariable: 'DB_USER')
                ]) {
                    echo 'Deploying APEX Application Split-Export...'
                    sh """
                        ${SQLCL_PATH} ${DB_USER}/${DB_PASS}@${PROD_CONN} <<EOF
                        whenever sqlerror exit failure
                        set serveroutput on
                        
                        declare
                            l_workspace_id number;
                        begin
                            -- Find workspace on Production
                            select workspace_id into l_workspace_id 
                            from apex_workspaces 
                            where workspace = '${WORKSPACE_NAME}';

                            -- Set context for installation
                            apex_application_install.set_workspace_id(l_workspace_id);
                            apex_application_install.generate_offset;
                            apex_application_install.set_schema(upper('${DB_USER}'));
                        end;
                        /

                        -- Run the master install script from the repo
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
            echo 'Deployment Successful: Production is now updated with GitHub artifacts.'
        }
        failure {
            echo 'Deployment Failed: Please check the SQLcl logs for specific ORA-errors.'
        }
    }
}
