node ('host-master') {
    input id: 'Release-build', message: 'Should I perform a release?', parameters: [booleanParam(defaultValue: true, description: 'Build and release onos applications', name: 'build-onos-apps'), string(defaultValue: '', description: '', name: 'release-version')], submitter: 'ash'



    println params.release-version
    println params.build-onos-apps
}

