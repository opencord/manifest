node ('host-master') {
    input id: 'metadata', message: 'Should I perform a release?', parameters: [booleanParam(defaultValue: true, description: 'Build and release onos applications', name: 'build_onos_apps'), string(defaultValue: '', description: '', name: 'release_version')], submitter: 'ash'

    println metadata['release_version']
    println metadata['build_onos_apps']
}

