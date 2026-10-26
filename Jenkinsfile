pipeline {
  agent {
    docker {
      image 'node:20.18.0-alpine'
      args '--network=host -e HOME=/tmp -e npm_config_cache=/tmp/.npm'
    }
  }

  options { timeout(time: 10, unit: 'MINUTES'); timestamps() }

  environment {
    NEXUS_URL    = 'http://localhost:8081'
    NEXUS_REPO   = 'npm-hosted'
    BASE_VERSION = '1.0.0'
  }

  stages {
    stage('Lint') { steps { sh 'npm ci && npm run lint' } }
    stage('Build') { steps { sh 'npm run build' } }

    stage('Verify') {
      parallel {
        stage('Test')           { steps { sh 'npm test' } }
        stage('Security Audit') { steps { sh 'npm audit --audit-level=high' } }
      }
    }

    stage('Archive') {
      steps {
        script { env.APP_VERSION = "${env.BASE_VERSION}-${env.GIT_COMMIT.take(7)}" }
        sh 'npm pkg set version="$APP_VERSION" && npm pack'
        archiveArtifacts artifacts: '*.tgz', fingerprint: true
      }
    }

    stage('Publish') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'wrong-id',
                         usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
          sh '''
            set -e
            trap 'rm -f .npmrc' EXIT
            AUTH=$(printf '%s:%s' "$NEXUS_USER" "$NEXUS_PASS" | base64 | tr -d '\\n')
            HOSTPATH="${NEXUS_URL#http://}/repository/${NEXUS_REPO}/"
            printf 'registry=%s/repository/%s/\\n//%s:_auth=%s\\nalways-auth=true\\n' \
              "$NEXUS_URL" "$NEXUS_REPO" "$HOSTPATH" "$AUTH" > .npmrc
            npm publish *.tgz
          '''
        }
      }
    }
  }

  post {
    always  { junit allowEmptyResults: true, testResults: '**/junit*.xml'; cleanWs() }
    success { echo "Published kijanikiosk-payments@${env.APP_VERSION} to ${env.NEXUS_URL}/#browse/browse:${env.NEXUS_REPO}" }
    failure { echo "FAILED in stage: ${env.STAGE_NAME}. No artifact was published." }
    changed { echo "Status changed to ${currentBuild.currentResult}" }
  }
}
