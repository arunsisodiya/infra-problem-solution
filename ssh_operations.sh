#!/usr/bin/env bash
# Script to add AWS ec2 private key to ssh and update ansible_inventory

ENV=${1:-dev}
SSH_KEY_LOCATION=${2:-~/.ssh/id_rsa}

function main() {
  if [[ -z ${ENV} ]] || [[ -z ${SSH_KEY_LOCATION} ]]; then
    echo "Please enter correct options."
    exit 1
  fi
  echo "${ENV} : ${SSH_KEY_LOCATION}"
  echo "Adding ssh key to SSH Authentication agent"
  SSH_ADD_EXEC=$(which ssh-add)
  "${SSH_ADD_EXEC}" "${SSH_KEY_LOCATION}"
  echo "Verify SSH Authentication agent"
  "${SSH_ADD_EXEC}" -L
  echo "Updating ansible_inventory generated from terraform"
  SED_EXEC=$(which sed)
  FILE="env-config/${ENV}/${ENV}-inventory"
  OS=$(uname)
  if [[ "${OS}" == "Darwin" ]]; then
    "${SED_EXEC}" -i "" -e "s|ssh_key_location|${SSH_KEY_LOCATION}|g" "${FILE}"
  else
    "${SED_EXEC}" -i "s|ssh_key_location|${SSH_KEY_LOCATION}|g" "${FILE}"
  fi
}

main