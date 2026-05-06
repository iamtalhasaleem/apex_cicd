pipeline {
    agent any
    environment {
        SQLCL_PATH = '/opt/sqlcl/bin/sql'
        // Production Connection (Target)
        PROD_CONN  = 'test-21c.maxapex.net:1521/xepdb1'
        // Development JDBC (Source of Truth for Deletions)
        DEV_JDBC   = 'jdbc:oracle:thin:@test-23ai.maxapex.net:1521/xepdb1'
        WORKSPACE_NAME = 'MAXPRINT_DEMO'
    }
    stages {
        stage('Checkout') {
            steps {
                // Pulls your 'db' and 'apex' folders from GitHub
                checkout scm
            }
        }

        stage('Auto-Sync Database') {
            steps {
                withCredentials([
                    usernamePassword(credentialsId: 'prod_db_creds', passwordVariable: 'PROD_PASS', usernameVariable: 'PROD_USER'),
                    usernamePassword(credentialsId: 'dev_db_creds', passwordVariable: 'DEV_PASS', usernameVariable: 'DEV_USER')
                ]) {
                    echo 'Automatically syncing Deletions and New Objects...'
                    sh """
                        ${SQLCL_PATH} ${PROD_USER}/${PROD_PASS}@${PROD_CONN} <<EOF
                        whenever sqlerror exit failure
                        
                        -- STEP 1: Generate deletion logic by comparing Prod to Dev
                        -- This catches anything you DELETED in Dev
                        lb diff-changelog -reference-url ${DEV_JDBC} -reference-username ${DEV_USER} -reference-password ${DEV_PASS} -exclude-objects "DATABASECHANGELOG,DATABASECHANGELOGLOCK,DATABASECHANGELOG_ACTIONS,DATABASECHANGELOG_DETAILS" -output-file auto_cleanup.xml
                        
                        -- STEP 2: Apply Deletions (ignore error if file is empty/no deletions)
                        lb update -changelog-file auto_cleanup.xml
                        
                        -- STEP 3: Apply New Changes from GitHub (controller.xml)
                        -- This catches anything you ADDED in Dev
                        cd db
                        lb update -changelog-file controller.xml
                        exit
EOF
                    """
                }
            }
        }

        stage('Auto-Deploy APEX') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'prod_db_creds', passwordVariable: 'DB_PASS', usernameVariable: 'DB_USER')]) {
                    echo 'Deploying APEX Application Split-Export...'
                    sh """
                        ${SQLCL_PATH} ${DB_USER}/${DB_PASS}@${PROD_CONN} <<EOF
                        whenever sqlerror exit failure
                        set serveroutput on
                        declare
                            l_workspace_id number;
                        begin
                            -- Dynamically find workspace on Prod
                            select workspace_id into l_workspace_id from apex_workspaces where workspace = '${WORKSPACE_NAME}';
                            
                            -- Set installation context
                            apex_application_install.set_workspace_id(l_workspace_id);
                            apex_application_install.generate_offset;
                            apex_application_install.set_schema(upper('${DB_USER}'));
                        end;
                        /
                        
                        -- Since you used 'apex export -split', run the master install script
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
            echo 'Pipeline Finished: Production is now a mirror of Development.'
        }
        failure {
            echo 'Pipeline Failed: Check the SQLcl logs above for ORA-errors.'
        }
    }
}
