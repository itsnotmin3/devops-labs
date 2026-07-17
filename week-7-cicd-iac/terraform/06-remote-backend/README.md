# 06 — remote state & locking

Everything so far kept `terraform.tfstate` on your laptop. That is fine for
exactly one person doing exactly one thing at a time.

| Local state problem | Consequence |
|---|---|
| Only on your machine | Nobody else can apply. Bus factor: 1. |
| Laptop dies | State is gone. Terraform no longer knows it owns anything. |
| Two people apply at once | Both read the old state, both write. One overwrites the other. |
| Plaintext secrets on disk | Every password in the config, unencrypted. |
| Committed to git "to share it" | Now the secrets are in the repo. Forever. |

## Step 1 — create the backend by hand, once

Chicken and egg: Terraform needs the bucket *before* it can manage anything.
This is the one acceptable piece of click-ops.

```bash
BUCKET="acme-tfstate-4471"     # <- globally unique, change it

aws s3api create-bucket \
  --bucket "$BUCKET" \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1

# NON-NEGOTIABLE. Versioning is your undo button when state gets corrupted.
aws s3api put-bucket-versioning \
  --bucket "$BUCKET" \
  --versioning-configuration Status=Enabled

# State holds secrets in plaintext. Encrypt it.
aws s3api put-bucket-encryption \
  --bucket "$BUCKET" \
  --server-side-encryption-configuration \
  '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

# It should never be public. Belt and braces.
aws s3api put-public-access-block \
  --bucket "$BUCKET" \
  --public-access-block-configuration \
  "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
```

## Step 2 — migrate

Edit `backend.tf` with your bucket name, then:

```bash
cp ../04-full-environment/*.tf .          # bring a real config with you
cp backend.tf.example backend.tf          # and edit the bucket name

terraform init -migrate-state             # Terraform offers to move it. Say yes.
ls terraform.tfstate                      # gone — it lives in S3 now
```

## What to notice

**Locking.** `use_lockfile = true` uses S3 conditional writes so two applies
cannot run at once — whoever gets there first takes the lock, the second fails
fast.

> Older configs (and most tutorials) use `dynamodb_table = "terraform-locks"`
> with a small DynamoDB table keyed on `LockID`. Both work. If you inherit a
> repo with the DynamoDB version, leave it alone. **Do not run without either.**

**Test it.** Open two terminals and run `terraform apply` in both:
```
Error: Error acquiring the state lock
Lock Info:
  ID:        8f2e...
  Who:       asif@laptop
  Created:   2 minutes ago
```
That error **is the feature working.** The correct response is to *wait*.

`terraform force-unlock <ID>` exists for genuinely orphaned locks — a killed
CI job, a closed laptop. Using it because you are impatient, while a
colleague's apply is mid-flight, is how state gets corrupted. **Ask the person
first. Every time.**

**One state file per environment.** The `key` is what separates them:
```
prod/network/terraform.tfstate
staging/network/terraform.tfstate
```
Different files, same bucket. A mistake in staging can never touch prod state.

## Never hand-edit state

The temptation arrives the first time state and reality disagree. Resist it.
There is a command for every legitimate case:

| Need | Command |
|---|---|
| Rename a resource | `terraform state mv` |
| Forget without deleting | `terraform state rm` |
| Adopt something that exists | `terraform import` |
| Force a re-create | `terraform apply -replace=ADDR` |

Hand-editing the JSON corrupts `serial` and `lineage`, and the failure
surfaces days later as a plan that wants to destroy production.
