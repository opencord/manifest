import groovy.json.JsonSlurperClassic

env.IGNORE_LIST = ["All-Users"]

env.approvers = 'andy@opennetworking.org,llp@opennetworking.org'
env.recipients = 'cord-discuss@opencord.org'

@NonCPS
def jsonParseList(def json) {
    j = json.minus(")]}'")
    resp = new groovy.json.JsonSlurperClassic().parseText(j)
    list = []
    for (i in resp.keySet()) {
        list << i
    }
    return list
}

@NonCPS
def jsonParseMap(def json) {
    def j = json.minus(")]}'")
    return new groovy.json.JsonSlurperClassic().parseText(j)
}

def createBranch(def proj, def branch, def parent) {
    cmd = 'ssh -p 29418 gerrit.opencord.org gerrit create-branch ' + proj + " " + branch + " " + parent
    sh returnStdout: true, script: cmd
}

int checkBranchExists(def proj) {
    if (env.IGNORE_LIST.contains(proj)) {
        return 0
    }
    url = 'https://gerrit.opencord.org/projects/' + proj + '/branches/' + env.BRANCH_NAME
    response = httpRequest url: url, validResponseCodes: '200,404'
    if (response.status == 404) {
        createBranch(proj, env.BRANCH_NAME, 'master')
        return 1
    }
    return 0
}

node ('master') {

    stage 'Check and create support branches'
    def url = 'https://gerrit.opencord.org/projects/?type=CODE'
    def response = httpRequest url: url, validResponseCodes: '200'
    def info = jsonParseList(response.content)
    int created = 0
    for (index = 0; index < info.size(); index++) {
        created += checkBranchExists(info[index])
    }

    if (created == 0) {

        def now = new Date()
        def metadata = 'None'
        branch = 'cord-' + now.format("yyyyMMddHHmm", TimeZone.getTimeZone('UTC'))

        stage 'Release?'
        timeout(time: 12, unit: 'HOURS') {
            mail to: env.approvers,
                subject: "Job '${JOB_NAME}' is waiting up for promotion",
                body: "Please go to ${BUILD_URL}input and promote or abort the release. It will timeout after 12 hours."
            metadata = input id: 'release-build', message: 'Should I perform a release?',
                parameters: [booleanParam(defaultValue: true,
                description: 'Release onos applications (assumes versions have been updated)', name: 'build_onos_apps'),
                string(defaultValue: branch, description: 'Release version', name: 'release_version')], submitter: 'llp,acb'
        }

        if (metadata['release_version'] == 'None') {
            error 'Release version cannot be None'
        }

        stage 'Create new manifest branch'
        createBranch('manifest', metadata['release_version'], env.BRANCH_NAME)
        checkout changelog: false, poll: false, scm: [$class: 'GitSCM', branches: [[name: metadata['release_version'] ]], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'WipeWorkspace'], [$class: 'CleanBeforeCheckout']], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'dd9d4677-2415-4f82-8e79-99dcd530f023', url: 'ssh://jenkins@gerrit.opencord.org:29418/manifest']]]
        sh returnStdout: true, script: 'git checkout ' + metadata['release_version']
        sh returnStdout: true, script: 'git pull origin ' + metadata['release_version']
        sh returnStdout: true, script: 'cp ' + env.JENKINS_HOME + '/tmp/manifest-' + env.BRANCH_NAME + '.xml default.xml'

        sh returnStdout: true, script: 'git commit -a -m "JENKINS: Updating manifest"'
        sh returnStdout: true, script: 'git push origin ' + metadata['release_version']

        stage 'Build and Release ONOS applications'

        if (metadata['build_onos_apps']) {
            checkout changelog: false, poll: false, scm: [$class: 'RepoScm', currentBranch: true,
                manifestBranch: env.BRANCH_NAME, manifestGroup: 'onos',
                manifestRepositoryUrl: 'https://gerrit.opencord.org/manifest', quiet: true]
            if (env.BRANCH_NAME == 'master') {
                sh returnStdout: true, script: 'cd onos-apps/apps && mvn clean deploy'
            } else {
                sh returnStdout: true, script: 'cd onos-apps/apps && mvn -Prelease clean deploy'
            }
        }

        mail to: env.recipients,
            subject: 'Nightly bleeding edge ' + metadata['release_version'] + ' released',
            replyTo: 'cord-dev@opencord.org',
            body: '''Hi CORD Community,

                        |A new bleeding edge version of cord is available, feel free to test it.
                        |You can obtain it using the following commands:

                        |repo init -u https://gerrit.opencord.org/manifest -b '''.stripMargin() + metadata['release_version'] + '''
                        |repo sync

                        |Have fun!

                        |--
                        |CORD Automated Release
                    '''.stripMargin()
    }
}
