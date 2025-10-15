## 1. Prepare

```bash
cp terraform.tfvars.template terraform.tfvars
```

Create a service user.

Fill out `terraform.tfvars`.

## 2. Set up

```bash
tofu init
tofu apply
```

## 3. Prepare a manifest

```bash
cat << EOF > manifest.yaml
workloads:
  demo-app:
    resources:
      db:
        type: $(tofu output -json | jq -r ".resource_type_postgres.value")
EOF
```

## 4. Deploy

```bash
hctl login
```

```bash
hctl deploy $(tofu output -json | jq -r ".project_id.value") development manifest.yaml
```

## 5. Verify

Check Humanitec console.

## 6. Clean up

Remove the environment:

```bash
tofu destroy -target="module.project.platform-orchestrator_environment.development"
```

Remove everything else:

```bash
tofu destroy
```