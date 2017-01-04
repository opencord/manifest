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

def createBranch(def proj, def branch) {
    cmd = 'ssh -p 29418 gerrit.opencord.org gerrit create-branch ' + proj + " " + branch + " master"
    sh returnStdout: true, script: cmd 
}

def checkBranchExists(def proj) {
    println proj
    if (env.IGNORE_LIST.contains(proj)) {
        return
    }
    url = 'https://gerrit.opencord.org/projects/' + proj + '/branches/' + env.BRANCH_NAME
    response = httpRequest url: url, validResponseCodes: '200,404'
    if (response.status == 404) {
        createBranch(proj, env.BRANCH_NAME)
    }
}

node ('master') {
    stage 'Release?'
    def metadata = input id: 'release-build', message: 'Should I perform a release?', parameters: [booleanParam(defaultValue: true, description: 'Build and release onos applications', name: 'build_onos_apps'), string(defaultValue: 'None', description: '', name: 'release_version')], submitter: 'ash'

    //println metadata['release_version']
    //println metadata['build_onos_apps']

    stage 'Check and create support branches'
    def url = 'https://gerrit.opencord.org/projects/?type=CODE'
    def response = httpRequest url: url, validResponseCodes: '200'
    def info = jsonParseList(response.content)
    for (index = 0; index < info.size(); index++) {
        checkBranchExists(info[index])
    }

    
}
