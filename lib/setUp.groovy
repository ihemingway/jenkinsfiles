def setUp() {
    stage('Notify Teams, Pull Repos') {
        parallel{
            stage('Notify Teams') {
                steps{
                    office365ConnectorSend color: '05b222',
                        message: "Started build. Branch: ${BRANCH} :: Environment: ${ENVIRONMENT} :: Repo: ${CODE_URL} :: Node: ${NODE}",
                        webhookUrl: "${TEAMS_HOOK}"
                }
            }
            stage('Pull Product Code') {
                steps {
                    ws(CODE_WS) {
                        checkout(
                            [$class: 'GitSCM',
                            branches: [[name: "${BRANCH}"]],
                            doGenerateSubmoduleConfigurations: false,
                            extensions: [[$class: 'CloneOption', depth: 1, noTags: true, reference: '', shallow: true]],
                            submoduleCfg: [],
                            userRemoteConfigs: [[credentialsId: 'StashKey', url: "${CODE_URL}"]]
                            ]
                        )
                    }
                }
            }
            stage('Pull Manifest Code') {
                steps {
                    ws(MANIFEST_WS) {
                        checkout(
                            [$class: 'GitSCM',
                            branches: [[name: "*/master"]],
                            doGenerateSubmoduleConfigurations: false,
                            extensions: [[$class: 'CloneOption', depth: 1, noTags: true, reference: '', shallow: true]],
                            submoduleCfg: [],
                            userRemoteConfigs: [[credentialsId: 'StashKey', url: "${MANIFEST_URL}"]]
                            ]
                        )
                    }
                }
            }
        }
    }
}