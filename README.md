# valheim server

## Deployment

### Setup

```
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/creds.json
export PROJECT_NAME=$(gcloud config get-value project)

export VALHEIM_SERVER_DISPLAY_NAME=...
export VALHEIM_SERVER_PASSWORD=...
export VALHEIM_WORLD_NAME=...
```

### Build and push docker image

```
docker tag valheim-server us.gcr.io/${PROJECT_NAME}/valheim-server
docker push us.gcr.io/${PROJECT_NAME}/valheim-server
```

### Terraform

```
export TF_VAR_valheim_server_display_name=$VALHEIM_SERVER_DISPLAY_NAME
export TF_VAR_valheim_server_password=$VALHEIM_SERVER_PASSWORD
export TF_VAR_valheim_world_name=$VALHEIM_WORLD_NAME

terraform init
terraform plan
terraform apply
```

