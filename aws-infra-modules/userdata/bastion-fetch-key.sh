#!/bin/bash
# Fetch private key from Secrets Manager (JSON secret: key SECRET_JSON_KEY holds the key)
# and write to /opt/id_rsa on bastion. Pure shell, no Python/jq.
# Terraform passes: SECRET_NAME, SECRET_REGION, SECRET_JSON_KEY

set -e

OUTPUT_FILE="/opt/id_rsa"

mkdir -p /opt
json=$(aws secretsmanager get-secret-value \
  --secret-id "${SECRET_NAME}" \
  --region "${SECRET_REGION}" \
  --query SecretString \
  --output text)

# Extract value of SECRET_JSON_KEY from {"KEY": "value"} using parameter expansion
val="${json#*\"${SECRET_JSON_KEY}\": \"}"
val="${val%\"*}"
# Expand \n to real newlines and write
printf '%b' "$val" > "${OUTPUT_FILE}"

chmod 600 "${OUTPUT_FILE}"
chown ec2-user:ec2-user "${OUTPUT_FILE}"
