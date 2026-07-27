#!/usr/bin/env bash
# Builds the whole Session 16 picture from scratch, in order:
#   VPC -> public subnet -> internet gateway -> route table -> security group
#       -> a key pair -> an EC2 instance running NGINX
#
# Every resource ID is saved to .lab-state so down.sh can delete it all.
#
#   ./up.sh                 # uses ap-south-1 and creates its own key pair
#   REGION=us-east-1 ./up.sh
#
# Needs: AWS CLI configured (aws sts get-caller-identity must work).

set -euo pipefail

REGION="${REGION:-ap-south-1}"
PROJECT="bootcamp-vpc-lab"
VPC_CIDR="10.0.0.0/16"
SUBNET_CIDR="10.0.1.0/24"
KEY_NAME="${KEY_NAME:-bootcamp-vpc-lab}"
STATE_FILE=".lab-state"

tag() { aws ec2 create-tags --region "$REGION" --resources "$1" --tags "Key=Project,Value=$PROJECT"; }
say() { echo -e "\n\033[1;36m==>\033[0m $*"; }

if [ -f "$STATE_FILE" ]; then
  echo "A .lab-state already exists — run ./down.sh first, or delete it if it is stale." >&2
  exit 1
fi

say "Region: $REGION   Project tag: $PROJECT"

say "Finding the latest Ubuntu 24.04 AMI (via SSM — never hard-code an AMI)"
AMI=$(aws ssm get-parameters --region "$REGION" \
  --names /aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id \
  --query 'Parameters[0].Value' --output text)
echo "AMI: $AMI"

say "Your public IP (for the SSH rule)"
MY_IP="$(curl -s https://checkip.amazonaws.com | tr -d '[:space:]')"
echo "SSH will be allowed from: ${MY_IP}/32"

# ---- VPC ----
say "Creating VPC ($VPC_CIDR)"
VPC_ID=$(aws ec2 create-vpc --region "$REGION" --cidr-block "$VPC_CIDR" \
  --query 'Vpc.VpcId' --output text)
tag "$VPC_ID"
aws ec2 modify-vpc-attribute --region "$REGION" --vpc-id "$VPC_ID" --enable-dns-hostnames Value=true
echo "VPC: $VPC_ID"

# ---- public subnet ----
say "Creating public subnet ($SUBNET_CIDR)"
SUBNET_ID=$(aws ec2 create-subnet --region "$REGION" --vpc-id "$VPC_ID" \
  --cidr-block "$SUBNET_CIDR" --query 'Subnet.SubnetId' --output text)
tag "$SUBNET_ID"
# give instances launched here a public IP automatically
aws ec2 modify-subnet-attribute --region "$REGION" --subnet-id "$SUBNET_ID" --map-public-ip-on-launch
echo "Subnet: $SUBNET_ID"

# ---- internet gateway ----
say "Creating and attaching an internet gateway (the door to the internet)"
IGW_ID=$(aws ec2 create-internet-gateway --region "$REGION" \
  --query 'InternetGateway.InternetGatewayId' --output text)
tag "$IGW_ID"
aws ec2 attach-internet-gateway --region "$REGION" --internet-gateway-id "$IGW_ID" --vpc-id "$VPC_ID"
echo "IGW: $IGW_ID"

# ---- route table (THIS is what makes the subnet public) ----
say "Creating a route table with 0.0.0.0/0 -> the gateway (this makes it PUBLIC)"
RT_ID=$(aws ec2 create-route-table --region "$REGION" --vpc-id "$VPC_ID" \
  --query 'RouteTable.RouteTableId' --output text)
tag "$RT_ID"
aws ec2 create-route --region "$REGION" --route-table-id "$RT_ID" \
  --destination-cidr-block 0.0.0.0/0 --gateway-id "$IGW_ID" >/dev/null
ASSOC_ID=$(aws ec2 associate-route-table --region "$REGION" \
  --route-table-id "$RT_ID" --subnet-id "$SUBNET_ID" --query 'AssociationId' --output text)
echo "Route table: $RT_ID (assoc $ASSOC_ID)"

# ---- security group ----
say "Creating a security group: 80 from anywhere, 22 from your IP only"
SG_ID=$(aws ec2 create-security-group --region "$REGION" \
  --group-name "${PROJECT}-sg" --description "web + ssh-from-me" \
  --vpc-id "$VPC_ID" --query 'GroupId' --output text)
tag "$SG_ID"
aws ec2 authorize-security-group-ingress --region "$REGION" --group-id "$SG_ID" \
  --protocol tcp --port 80 --cidr 0.0.0.0/0 >/dev/null
aws ec2 authorize-security-group-ingress --region "$REGION" --group-id "$SG_ID" \
  --protocol tcp --port 22 --cidr "${MY_IP}/32" >/dev/null
echo "Security group: $SG_ID"

# ---- key pair (only create one if the caller did not bring their own) ----
CREATED_KEY="no"
if aws ec2 describe-key-pairs --region "$REGION" --key-names "$KEY_NAME" >/dev/null 2>&1; then
  say "Using existing key pair: $KEY_NAME"
else
  say "Creating key pair: $KEY_NAME (saving ${KEY_NAME}.pem)"
  aws ec2 create-key-pair --region "$REGION" --key-name "$KEY_NAME" \
    --query 'KeyMaterial' --output text > "${KEY_NAME}.pem"
  chmod 400 "${KEY_NAME}.pem"
  CREATED_KEY="yes"
fi

# ---- the instance ----
say "Launching a t3.micro instance running NGINX on first boot"
INSTANCE_ID=$(aws ec2 run-instances --region "$REGION" \
  --image-id "$AMI" --instance-type t3.micro \
  --key-name "$KEY_NAME" --security-group-ids "$SG_ID" --subnet-id "$SUBNET_ID" \
  --user-data file://user-data.sh \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Project,Value=$PROJECT}]" \
  --query 'Instances[0].InstanceId' --output text)
echo "Instance: $INSTANCE_ID — waiting for it to start..."
aws ec2 wait instance-running --region "$REGION" --instance-ids "$INSTANCE_ID"

PUBLIC_IP=$(aws ec2 describe-instances --region "$REGION" --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

# ---- save state for teardown ----
cat > "$STATE_FILE" <<STATE
REGION=$REGION
VPC_ID=$VPC_ID
SUBNET_ID=$SUBNET_ID
IGW_ID=$IGW_ID
RT_ID=$RT_ID
ASSOC_ID=$ASSOC_ID
SG_ID=$SG_ID
KEY_NAME=$KEY_NAME
CREATED_KEY=$CREATED_KEY
INSTANCE_ID=$INSTANCE_ID
PUBLIC_IP=$PUBLIC_IP
STATE

say "Done."
echo "  URL:  http://$PUBLIC_IP   (give NGINX ~30s to install on first boot)"
echo "  SSH:  ssh -i ${KEY_NAME}.pem ubuntu@$PUBLIC_IP"
echo "  Tear it all down with:  ./down.sh"
