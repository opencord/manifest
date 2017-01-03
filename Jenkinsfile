node ('host-master') {
    def metadata = input id: 'release-build', message: 'Should I perform a release?', parameters: [booleanParam(defaultValue: true, description: 'Build and release onos applications', name: 'build_onos_apps'), string(defaultValue: '', description: '', name: 'release_version')], submitter: 'ash'

    println metadata['release_version']
    println metadata['build_onos_apps']
    
    echo env.BRANCH_NAME

    httpRequest consoleLogResponseBody: true, url: 'https://gerrit.opencord.org/projects/?type=CODE&b=$BRANCH_NAME', validResponseCodes: '200'
}

