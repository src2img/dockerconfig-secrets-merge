#!/bin/bash

set -euo pipefail

REPODIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

export KUBECONFIG=/tmp/kind-secretsmerge.yaml

if [ -f "${KUBECONFIG}" ] && kind get clusters | grep kind-secretsmerge > /dev/null ; then
  echo "[INFO] Reusing the existing KinD cluster. If you want a fresh one, please run 'rm -f ${KUBECONFIG}'"
else
  # Check if we have a remote Docker host
  cp -f "${REPODIR}/test/cluster.yaml" /tmp/cluster.yaml
  if [ -n "${DOCKER_HOST+set}" ] && [[ ${DOCKER_HOST} == tcp* ]]; then
    DOCKER_IP="${DOCKER_HOST/tcp:\/\//}"
    DOCKER_IP="${DOCKER_IP/:2375/}"

    echo "[INFO] Using remote Docker host on ${DOCKER_IP}"
    goml set -f /tmp/cluster.yaml -p networking.apiServerAddress -v "${DOCKER_IP}"
    goml set -f /tmp/cluster.yaml -p networking.apiServerPort -v 43211
  fi

  kind delete cluster --name kind-secretsmerge
  kind create cluster --config /tmp/cluster.yaml --name kind-secretsmerge --kubeconfig "${KUBECONFIG}"
fi

NAMESPACE="$(md5sum <<<"${RANDOM}" | head -c 25)"

kubectl create namespace "${NAMESPACE}"

kubectl -n "${NAMESPACE}" create secret docker-registry source1 --docker-server=de.icr.io --docker-username=iamapikey --docker-password=some-password
kubectl -n "${NAMESPACE}" create secret docker-registry source2 --docker-server=https://index.docker.io/v1/ --docker-username=some-user --docker-password=some-password
kubectl -n "${NAMESPACE}" create secret docker-registry source3 --docker-server=de.icr.io --docker-username=iamapikey --docker-password=some-password1

"${REPODIR}/k8s-dockerconfig-secrets-merge" --namespace "${NAMESPACE}" --source source1 --source source2 --target target --source source3
