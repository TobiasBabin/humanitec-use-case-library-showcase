1. Prepare

```bash
cp terraform.tfvars.template terraform.tfvars
```

Create a service user.

Fill out `terraform.tfvars`.

2. Set up

```bash
terraform init
terraform apply
```

3. Prepare manifest:

```bash
cat << EOF > manifest.yaml
workloads:
  # The name you assign to the workload in the context of the manifest
  demo-app:
    resources:
      # The name you the assign to this resource in the context of the manifest
      demo-workload:
        # The resource type of the resource you wish to provision
        type: $(terraform output -json | jq -r ".resource_type_workload.value")
        # The resource parameters. They are mapped to the module_params of the module
        params:
          image: ghcr.io/astromechza/demo-app:latest
          variables:
            OVERRIDE_POSTGRES: postgres://\${resources.db.outputs.username}:\${resources.db.outputs.password}@\${resources.db.outputs.host}:\${resources.db.outputs.port}/\${resources.db.outputs.database}
      db:
        type: $(terraform output -json | jq -r ".resource_type_postgres.value")
EOF
```

4. Deploy

```bash
hctl login
```

```bash
hctl deploy $(terraform output -json | jq -r ".project_id.value") development manifest.yaml
```

5. Verify

Check Humanitec console.

Add kube context:

```bash
terraform output -json | jq -r ".k8s_connect_command.value"
```

Connect to workload:

```bash
kubectl port-forward pod/$(kubectl get pods -o json \
  -l app=$(terraform output -json | jq -r ".workload_name.value") \
  | jq -r ".items[0].metadata.name") 8080:8080
```

Open [http://localhost:8080](http://localhost:8080)
