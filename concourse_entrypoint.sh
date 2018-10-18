#!/bin/bash -e

set -o pipefail

# Simple logging function that displays to stdout
log() {
  echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ"): $*"
}

# set the number of secrets required by the daemon
if [ "$1" == "web" ]; then
  NUM_OF_SECRETS=5
else
  NUM_OF_SECRETS=2
fi

for i in {1..5}; do
  if [ "$(ls -1A /concourse-keys/ | wc -l)" -lt "$NUM_OF_SECRETS" ]; then
    log "not enough secrets found on the mapped volume. Waiting for the init container to decrypt secrets."
    sleep 10
  else
    log "found secrets! $(ls -1A /concourse-keys/)"
    break
  fi
done

if [ "$1" == "web" ]; then
  if [ -f /concourse-keys/concourse_github_client_secret ]; then
    CONCOURSE_GITHUB_CLIENT_SECRET="$(cat concourse-keys/concourse_github_client_secret)"
    log "setting concourse github auth client secret"
    export CONCOURSE_GITHUB_CLIENT_SECRET
  fi

  if [ -f /concourse-keys/concourse_add_local_user ]; then
    CONCOURSE_ADD_LOCAL_USER="$(cat concourse-keys/concourse_add_local_user)"
    log "setting concourse basic auth bcrypted user/password combinations"
    export CONCOURSE_ADD_LOCAL_USER
  fi
fi

/usr/local/bin/dumb-init /usr/local/bin/concourse $*
