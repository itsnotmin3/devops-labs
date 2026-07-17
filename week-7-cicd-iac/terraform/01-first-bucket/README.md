# 01 — your first resource

```bash
terraform init
terraform plan
terraform apply     # type: yes
```

## What to notice

**In the plan:** every line marked `(known after apply)`. Terraform does not
know the ARN yet — AWS assigns it. Those are *attributes*; `bucket` is an
*argument*. You set arguments. AWS decides attributes.

**Run `terraform apply` a second time:**
```
No changes. Your infrastructure matches the configuration.
```
That is **idempotency**, and it is not a party trick — it is the property that
makes it safe to run Terraform from a pipeline on every single merge.

**Look at the state file:**
```bash
cat terraform.tfstate | head -30
```
Find the bucket's `id`. That is the whole idea of state: *"the block I call
`aws_s3_bucket.demo` is the real bucket named bootcamp-tf-demo-4471."*
Without it, Terraform would create a second bucket every run.

**Now change the bucket name and re-plan:**
```bash
terraform plan
```
It says `-/+ must be replaced`, not `~ update`. A bucket name cannot be
changed on a live bucket, so Terraform must destroy and re-create. On a
database, that would be your data. **This is why you read the plan.**

## Clean up
```bash
terraform destroy
```

## If it fails with `BucketAlreadyExists`
Nothing is broken. Someone owns that name. Add random digits and try again.
