#!/usr/bin/env bash
# Deletes everything up.sh created, in the REVERSE order it was made.
# Reads the IDs from .lab-state.
#
#   ./down.sh

set -euo pipefail

STATE_FILE=".lab-state"
if [ ! -f "$STATE_FILE" ]; then
  echo "No .lab-state here — nothing to tear down (or you are in the wrong folder)." >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$STATE_FILE"

say() { echo -e "\n\033[1;36m==>\033[0m $*"; }

say "Terminating the instance ($INSTANCE_ID)"
aws ec2 terminate-instances --region "$REGION" --instance-ids "$INSTANCE_ID" >/dev/null
aws ec2 wait instance-terminated --region "$REGION" --instance-ids "$INSTANCE_ID"

say "Deleting the security group ($SG_ID)"
aws ec2 delete-security-group --region "$REGION" --group-id "$SG_ID"

say "Removing the route table ($RT_ID)"
aws ec2 disassociate-route-table --region "$REGION" --association-id "$ASSOC_ID"
aws ec2 delete-route-table --region "$REGION" --route-table-id "$RT_ID"

say "Detaching and deleting the internet gateway ($IGW_ID)"
aws ec2 detach-internet-gateway --region "$REGION" --internet-gateway-id "$IGW_ID" --vpc-id "$VPC_ID"
aws ec2 delete-internet-gateway --region "$REGION" --internet-gateway-id "$IGW_ID"

say "Deleting the subnet ($SUBNET_ID)"
aws ec2 delete-subnet --region "$REGION" --subnet-id "$SUBNET_ID"

say "Deleting the VPC ($VPC_ID)"
aws ec2 delete-vpc --region "$REGION" --vpc-id "$VPC_ID"

if [ "${CREATED_KEY:-no}" = "yes" ]; then
  say "Deleting the key pair we created ($KEY_NAME)"
  aws ec2 delete-key-pair --region "$REGION" --key-name "$KEY_NAME"
  rm -f "${KEY_NAME}.pem"
fi

rm -f "$STATE_FILE"
say "All gone. The account is back to how it started."
