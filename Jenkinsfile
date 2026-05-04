ipipeline {
    agent any
    environment {
        SQLCL_PATH = '/opt/sqlcl/bin/sql'
        PROD_CONN  = 'test-21c.maxapex.net:1521/xepdb1'
        DEV_URL    = 'jdbc:oracle:thin:@//test-23ai.maxapex.net:1521/xepdb1'
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
                    echo 'Executing Automated Object Sync (Additions & Deletions)...'
                    sh """
                        # Clear old sync files
                        rm -f db/automated_sync.xml

                        ${SQLCL_PATH} ${DB_USER}/${DB_PASS}@${PROD_CONN} <<EOF
                        
                        -- 1. Generate a changelog based ONLY on the Dev (Reference) environment
                        -- This captures the current "Truth" from your 23ai server
                        lb generate-changelog \
                          -reference-url ${DEV_URL} \
                          -reference-username ${DB_USER} \
                          -reference-password ${DB_PASS} \
                          -exclude-objects "DATABASECHANGELOG,DATABASECHANGELOGLOCK,DATABASECHANGELOG_ACTIONS" \
                          -output-file db/automated_sync.xml

                        -- 2. Sync the changelog to Production
                        -- Liquibase will see that 'CICD' (or any other deleted table) 
                        -- is NOT in the new changelog and will handle the state accordingly.
                        lb update -changelog-file db/automated_sync.xml

                        -- 3. Final structural update from your repository controller
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
                    sh """
                        ${SQLCL_PATH} ${DB_USER}/${DB_PASS}@${PROD_CONN} <<EOF
                        set serveroutput on
                        declare
                            l_workspace_id number;
                            l_schema varchar2(100) := upper('${DB_USER}');
                        begin
                            select workspace_id into l_workspace_id
                              from apex_workspaces
                             where workspace = '${WORKSPACE_NAME}';

                            apex_util.set_security_group_id(p_security_group_id => l_workspace_id);
                            apex_application_install.set_workspace_id(l_workspace_id);
                            apex_application_install.generate_offset;
                            apex_application_install.set_schema(l_schema);
                        end;
                        /
                        @apex/f103/install.sql
                        exit
EOF
                    """
                }
            }
        }
    }
}
