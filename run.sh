#!/bin/bash

OC="oc --insecure-skip-tls-verify --token=${OPENSHIFT_TOKEN} --server=${OPENSHIFT_CONSOLE}"

oc get projects --no-headers -o custom-columns=name:.metadata.name | while read project; do
  PROJECT=$project
  . run-in-cli.sh
done