# 02 — variables, locals, outputs

One configuration, two environments. This is the promise Session 21 made:
staging must be generated from the same source as production, or it is not a
rehearsal — it is a coincidence.

```bash
cp staging.tfvars.example staging.tfvars   # then edit `suffix`
cp prod.tfvars.example prod.tfvars

terraform init
terraform apply -var-file=staging.tfvars
terraform output
```

> `*.tfvars` is git-ignored on purpose — real ones hold real values.
> The `.example` files are the committed templates.

## What to notice

**Variables vs locals:**

| | Variable | Local |
|---|---|---|
| Set by | the caller, at run time | you, in the code |
| Overridable | yes — that is the point | never |
| Use for | anything that differs per environment | anything derived or repeated |

**Try breaking the validation:**
```bash
terraform apply -var="environment=production"    # not in the allowed list
```
It fails at plan time with your error message — before a single API call.
That is what `type` and `validation` buy you.

**Watch the conditional:**
`local.is_prod` flips versioning on for prod and off for staging. There is no
`if` statement in HCL — only the ternary `cond ? a : b`.

**Deploy both, then compare:**
```bash
terraform apply -var-file=staging.tfvars   # versioning Suspended
terraform apply -var-file=prod.tfvars      # versioning Enabled
```

> ⚠️ **Both applies share ONE state file**, so the second REPLACES the first —
> it is not two environments side by side, it is one environment being
> reconfigured. That is exactly the problem `05-modules` and workspaces solve.
> Notice the plan says `-/+ must be replaced`. Read it before you say yes.

## Variable precedence (highest wins)

1. `-var="environment=prod"` on the command line
2. `-var-file=prod.tfvars`
3. `*.auto.tfvars` (loaded automatically)
4. `terraform.tfvars` (loaded automatically)
5. `TF_VAR_environment=prod` in the environment ← how CI passes secrets in
6. `default` in the variable block

## Clean up
```bash
terraform destroy -var-file=prod.tfvars
```
