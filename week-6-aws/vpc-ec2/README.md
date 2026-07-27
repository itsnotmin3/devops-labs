# Scripted VPC + EC2 — build the network, then a server in it

Session 16, live. Two scripts build the whole picture from the session and tear
it back down, so you can show every piece being created in order and then prove
it is all gone.

```
vpc-ec2/
├── up.sh           builds: VPC -> subnet -> gateway -> route table -> SG -> EC2
├── down.sh         deletes everything up.sh made, in reverse
├── user-data.sh    the boot script the instance runs (installs NGINX)
└── .lab-state      (created by up.sh) the resource IDs, so down.sh can clean up
```

---

## Before you start

- **AWS CLI configured** — `aws sts get-caller-identity` must work.
- That is it. The script creates its own key pair and finds the latest Ubuntu
  AMI for you.

## Run it

```bash
cd week-6-aws/vpc-ec2
chmod +x up.sh down.sh
./up.sh                      # default region ap-south-1
# or:  REGION=us-east-1 ./up.sh
```

Watch it narrate each step — VPC, subnet, internet gateway, the route table
(the line that makes the subnet public), the security group, the key pair, and
the instance. At the end it prints:

```
  URL:  http://13.234.1.9        (give NGINX ~30s on first boot)
  SSH:  ssh -i bootcamp-vpc-lab.pem ubuntu@13.234.1.9
```

Open the URL in a browser, and SSH in if you like — the security group allows
port 22 from **your IP only**.

## Tear it down (do this after class!)

```bash
./down.sh
```

It terminates the instance, deletes the security group, route table, gateway,
subnet and VPC in the right order, and removes the key pair it created. A left
instance bills by the second, so always run this when you are done.

---

## What each piece is (map it to the session)

| The script creates | Which is | Why |
|--------------------|----------|-----|
| VPC `10.0.0.0/16` | your private network | everything lives inside it |
| Subnet `10.0.1.0/24` | a slice of the VPC in one AZ | where the server sits |
| Internet gateway | the door to the internet | attached to the VPC |
| Route table `0.0.0.0/0 -> IGW` | the signpost | **this line is what makes the subnet public** |
| Security group | the per-server firewall | 80 from anyone, 22 from you only |
| EC2 instance | the rented server | boots Ubuntu, installs NGINX via user_data |

## Things worth pointing out while it runs

- **The AMI is not hard-coded.** `up.sh` asks SSM for the current Ubuntu 24.04
  image, so the same script works in any region — the exact lesson from the
  session (and from Terraform in Week 7).
- **The route table is the whole trick.** Comment out the `create-route` line
  and re-run: the identical subnet becomes private and the URL stops loading.
- **SSH is locked to your IP.** The script reads your public IP and allows 22
  from `${YOUR_IP}/32` only — never `0.0.0.0/0`.
- **Everything is tagged** `Project=bootcamp-vpc-lab`, so you can find it all in
  the console under one filter.

## The IaC connection (Week 7)

This script does by hand, step by step, exactly what the Terraform lab in Week 7
does declaratively — same VPC, subnet, gateway, route table, security group and
instance. Run both and compare: the shell script is a list of *actions*;
Terraform is a description of the *desired result*. That difference is the whole
point of Infrastructure as Code.
