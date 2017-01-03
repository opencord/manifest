node ('host-master') {
    input id: 'Release-build', message: 'Should I perform a release?', parameters: [booleanParam(defaultValue: true, description: 'Build and release onos applications', name: 'build_onos_apps'), string(defaultValue: '', description: '', name: 'release_version')], submitter: 'ash'

    println params.release_version
    println params.build_onos_apps
}

