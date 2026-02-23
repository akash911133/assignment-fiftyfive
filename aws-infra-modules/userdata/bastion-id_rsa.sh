#!/bin/bash
# Write EC2 private key to ec2-user home as id_rsa (for SSH to frontend/backend).
# Terraform passes: PRIVATE_KEY_B64 (base64-encoded private key). If empty, skip.
set -e

ID_RSA_PATH="/home/ec2-user/id_rsa"

if [ -n "${PRIVATE_KEY_B64}" ]; then
  echo "${PRIVATE_KEY_B64}" | base64 -d > "${ID_RSA_PATH}"
  chmod 600 "${ID_RSA_PATH}"
  chown ec2-user:ec2-user "${ID_RSA_PATH}"
fi
