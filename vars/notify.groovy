def call() {
    office365ConnectorSend color: '05b222',
        message: "Started build. Branch: ${BRANCH} :: Environment: ${ENVIRONMENT} :: Repo: ${CODE_URL} :: Node: ${NODE}",
        webhookUrl: "${TEAMS_HOOK}"
}