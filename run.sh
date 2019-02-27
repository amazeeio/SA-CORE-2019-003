#!/bin/bash

set -eu -o pipefail

OC="oc"

oc get projects --no-headers -o custom-columns=name:.metadata.name | while read project; do
  PROJECT=$project
  REGEX=${REGEX:-.*}
  if [[ $PROJECT =~ $REGEX ]]; then
    . exec-in-cli.sh
  fi
done