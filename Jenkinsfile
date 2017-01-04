import groovy.json.JsonSlurperClassic 

env.IGNORE_LIST = ["All-Users"]

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

def checkBranchExists(def proj) {
    if (env.IGNORE_LIST.contains(proj)) {
        return
    }
    url = 'https://gerrit.opencord.org/projects/' + proj + '/branches/' + env.BRANCH_NAME
    response = httpRequest url: url, validResponseCodes: '200,404'
    if (response.status == 404) {
        createBranch(proj, env.BRANCH_NAME, 'master')
    }
}

node ('master') {
    stage 'Release?'
    mail to: 'ali@onlab.us',
        subject: "Job '${JOB_NAME}' is waiting up for promotion",
        body: "Please go to ${BUILD_URL}input and promote or abort the release"
    def metadata = input id: 'release-build', message: 'Should I perform a release?', parameters: [booleanParam(defaultValue: true, description: 'Build and release onos applications', name: 'build_onos_apps'), string(defaultValue: 'None', description: '', name: 'release_version')], submitter: 'ash'

    if (metadata['release_version'] == 'None') {
        error 'Release version cannot be None'
    }

    stage 'Check and create support branches'
    def url = 'https://gerrit.opencord.org/projects/?type=CODE'
    def response = httpRequest url: url, validResponseCodes: '200'
    def info = jsonParseList(response.content)
    for (index = 0; index < info.size(); index++) {
        checkBranchExists(info[index])
    }

    stage 'Create new manifest branch'
    createBranch('manifest', metadata['release_version'], env.BRANCH_NAME)
    checkout changelog: false, poll: false, scm: [$class: 'GitSCM', branches: [[name: metadata['release_version'] ]], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'dd9d4677-2415-4f82-8e79-99dcd530f023', url: 'ssh://jenkins@gerrit.opencord.org:29418/manifest']]]
    sh returnStdout: true, script: 'git checkout ' + metadata['release_version']
    sh returnStdout: true, script: 'mv ' + env.JENKINS_HOME + '/tmp/manifest-' + env.BRANCH_NAME + '.xml default.xml' 
    sh returnStdout: true, script: 'git push origin ' + metadata['release_version']
    
    //TODO build and release onos apps
}
