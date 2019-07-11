@Library('shared@dev') _

pipeline {
    agent {
        kubernetes {
            cloud 'kubernetes-prod'
            label 'slave'
            namespace 'jenkins'
            defaultContainer 'primary'
            yaml """
apiVersion: v1
kind: Pod
metadata:
  name: slave
  labels:
    name: slave
spec:
  activeDeadlineSeconds: 600
  containers:
  - name: primary
    image: harbor.mgcorp.co/devops/primarybuild
    command:
    - cat
    tty: true
"""
        }
    }
    environment {
        VAULT_ADDR = "https://mtl-devops-vault.mgcorp.co:8200"
        BRANCH = "${params.BRANCH}"
        ENVIRONMENT = "${params.ENVIRONMENT}"
        PRODUCT = "rxbluepills.com"
        PROJPROD = "cpan.${PRODUCT}"
        //PRODUCT = "spartan-brazzers-v3" //sed this
        //PROJPROD = "paybz.${PRODUCT}" //and this
        VAULT_TOKEN = "${PROJPROD}_vault_token"
        CODE_URL = "${params.REPO}"
    }
    stages {
        stage("Set up environment") {
            parallel {
                stage("Pull Manifest") {
                    steps {
                        ws(WORKSPACE + "/deployment-manifests"){
                            pullManifests()
                        }
                    }
                }
                stage("Pull Code") {
                   steps{
                        ws(WORKSPACE + "/" + PRODUCT) {
                            pullCode(repo: "${CODE_URL}", branch: "${BRANCH}")
                        }
                        ws(WORKSPACE +"/build") {
                            pullCode(repo: "ssh://git@stash.mgcorp.co:7999/cpan/build.git", branch: "master")
                        }
                    }
                }
                stage("Install Cicada") {
                    steps{
                        ws(WORKSPACE + "/cicada") {
                            pullCicada()
                        }
                    }
                }
            }
        }
        stage("Build"){
            steps{
                cicadaBuild(
                    debug: false
                )
            }
        }
        stage("Package"){
            steps{
                cicadaPackage()
            }
        }
        stage("Deploy"){
            steps{
                cicadaDeploy()
            }
        }
    }
    /*post {
        success {
            notifyDevOps(
                status: "Success!",
                color: "7CFC00"
            )
            notifyUsers(
                status: "Success!",
                color: "7CFC00"
            )
        }
        failure {
            notifyDevOps(
                status: "Failed!",
                color: "FF0000"
            )
            notifyUsers(
                status: "Failed!",
                color: "FF0000"
            )
        }
        always {
            sh "echo Done."
        }
    }*/
}