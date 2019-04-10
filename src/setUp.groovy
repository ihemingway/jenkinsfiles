def notify() {
    office365ConnectorSend color: '05b222',
        message: "Started build. Branch: ${BRANCH} :: Environment: ${ENVIRONMENT} :: Repo: ${CODE_URL} :: Node: ${NODE}",
        webhookUrl: "${TEAMS_HOOK}"
}

def pullCode() {
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

def pullManifest() {
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
