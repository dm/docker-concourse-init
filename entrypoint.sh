#!/bin/bash -e

set -o pipefail

# Simple logging function that displays to stdout
log() {
  echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ"): $*"
}

# Simple die function, every command should be followed by this!
die() {
  >&2 log "ERROR: $*"
  exit 1
}

aws configure set region eu-west-1 || die "failed to set AWS region"

decrypt() {
  if [ -z "$1" ]; then
    die "Cannot decrypt secret. $2 variable is unset or empty."
  fi

  aws kms decrypt --ciphertext-blob=fileb://<(echo $1 | base64 -d) --output text --query Plaintext | base64 -d > /concourse-keys/$2 || die "failed to decrypt env var: $2"
}

# we set this in the task, but we should just run it as an arg.
CONCOURSE_COMPONENT="${CONCOURSE_COMPONENT:-$1}"

if [ "$CONCOURSE_COMPONENT" == "web" ]; then
  log "decrypting keys for web"
  decrypt "$tsa_host_key" tsa_host_key
  decrypt "$session_signing_key" session_signing_key
  decrypt "$authorized_worker_keys" authorized_worker_keys

  # secrets for the daemon
  decrypt "$github_auth_client_secret" github_auth_client_secret
  decrypt "$basic_auth_password" basic_auth_password

elif [ "$CONCOURSE_COMPONENT" == "worker" ]; then
  log "decrypting keys for worker"
  decrypt "$worker_key" worker_key
  decrypt "$tsa_host_key_pub" tsa_host_key.pub

else
  die "Environment variable CONCOURSE_COMPONENT not set."
fi

log "finished setup"
