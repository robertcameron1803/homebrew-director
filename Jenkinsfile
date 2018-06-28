#!/usr/bin/env groovy

/*
 * Copyright 2012-2018 Robot Locomotion Group @ CSAIL. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 *  1. Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *  3. Neither the name of the copyright holder nor the names of its
 *     contributors may be used to endorse or promote products derived from
 *     this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 * IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 * Copyright 2009-2018 Homebrew contributors.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 *  1. Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

def setup() {
  withEnv(['HOMEBREW_DEVELOPER=1', 'PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin']) {
    sh 'brew update'
    sh 'brew upgrade'
    sh 'brew tap homebrew/test-bot'
  }
  dir('/usr/local/Homebrew/Library/Taps/robotlocomotion/homebrew-director') {
    checkout scm
  }
}

def build(stash_name) {
  setup()
  try {
    withEnv(['HOMEBREW_DEVELOPER=1', 'PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin']) {
      sh 'brew test-bot --ci-auto --tap=robotlocomotion/director'
    }
  } catch (e) {
    currentBuild.result = 'FAILURE'
  } finally {
    junit allowEmptyResults: true, testResults: 'brew-test-bot.xml'
    stash allowEmpty: true, includes: "*.${stash_name}.bottle.tar.gz", name: stash_name
  }
}

stage('build') {
  parallel (
    high_sierra: {
      node('mac_highsierra_unprovisioned') {
        build('high_sierra')
      }
    },
    sierra: {
      node('mac_sierra_unprovisioned') {
        build('sierra')
      }
    },
  )
}

stage('upload') {
  node('mac_highsierra_unprovisioned') {
    setup()
    unstashed = false
    try {
      unstash 'high_sierra'
      unstash 'sierra'
      unstashed = true
    } catch (e) {
      unstashed = false
    }
    if (unstashed) {
      try {
        withCredentials([[
            $class: 'UsernamePasswordMultiBinding',
            credentialsId: '5ad6b519-be6b-4b29-928d-49e92b529f36',
            passwordVariable: 'HOMEBREW_BINTRAY_KEY',
            usernameVariable: 'HOMEBREW_BINTRAY_USER',
        ]]) {
          withEnv(['HOMEBREW_DEVELOPER=1', 'PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin']) {
            sh 'brew test-bot --ci-upload --bintray-org=homebrew-director --tap=robotlocomotion/director'
          }
        }
      }
    }
  }
}
