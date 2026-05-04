pipeline {
    agent any
    environment {
        SQLCL_PATH = '/opt/sqlcl/bin/sql'
        // Connection for your test-21c (Production) environment
        PROD_CONN  = 'test-21c.maxapex.net:1521/xepdb1'
        // Connection for your test-23ai (Development) environment
        DEV_URL    = 'jdbc:oracle:thin:@//test-23ai.maxapex.net:1521/xepdb1'
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
                    echo 'Generating Difference and Updating Production DB (Ignoring Metadata Tables)...'
                    sh """
                        ${SQLCL_PATH} ${DB_USER}/${DB_PASS}@${PROD_CONN} <<EOF
                        -- 1. Compare Prod to Dev and generate the 'prod_sync.xml'
                        -- We exclude Liquibase internal tables to avoid ORA-00955 errors
                        lb diff-changelog \
                          -reference-url ${DEV_URL} \
                          -reference-username ${DB_USER} \
                          -reference-password ${DB_PASS} \
                          -diff-types "tables,views,columns,indexes,foreignkeys,primarykeys,uniqueconstraints,data" \
                          -exclude-objects "DATABASECHANGELOG,DATABASECHANGELOGLOCK,DATABASECHANGELOG_ACTIONS" \
                          -output-file db/prod_sync.xml
                        
                        -- 2. Apply the generated changes (including the Drop commands)
                        lb update -changelog-file db/prod_sync.xml
                        
                        -- 3. Run the standard controller to ensure structural alignment
                        cd db
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
                            l_schema varchar2(100) := upper('${DB_USER}');
                        begin
                            -- 1. Dynamically find the Workspace ID on this specific server
                            select workspace_id into l_workspace_id
                              from apex_workspaces
                             where workspace = '${WORKSPACE_NAME}';

                            -- 2. Force the session to the correct Workspace context
                            apex_util.set_security_group_id(p_security_group_id => l_workspace_id);

                            -- 3. Overrides the hardcoded IDs inside the export files
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
            echo 'Deployment completed successfully. All additions and deletions applied.'
        }
        failure {
            echo 'Deployment failed. Check SQLcl logs for dependency or connection errors.'
        }
    }
}
