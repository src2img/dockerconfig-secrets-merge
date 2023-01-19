# k8s-dockerconfig-secrets-merge

This project providers a helper tool to merge multiple Kubernetes secrets of type `kubernetes.io/dockerconfigjson` into a new single one.

## Usage

You can create your Kubernetes secrets as usual:

```bash
$ kubectl create secret docker-registry icr-de --docker-server=de.icr.io --docker-username=iamapikey --docker-password=some-apikey
secret/icr-de created
$ kubectl create secret docker-registry dockerhub --docker-server=https://index.docker.io/v1/ --docker-username=dockerhubuser --docker-password=some-apikey
secret/dockerhub created
```

To create a combined secret, run:

```bash
$ ./k8s-dockerconfig-secrets-merge --source icr-de --source dockerhub --target combined
[INFO] Processing secret icr-de
[INFO] Found credentials for de.icr.io
[INFO] Processing secret dockerhub
[INFO] Found credentials for https://index.docker.io/v1/
[INFO] Creating secret combined
secret/combined created
```

You can provide as many source secrets as you want. The nature of such secrets imply that a single host can only be referenced once in the target secret.

## Dependencies

You need bash, and the `base64`, `jq`, and `kubectl` commands.
