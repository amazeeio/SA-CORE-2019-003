#!/bin/bash

OC="oc --insecure-skip-tls-verify --token=${OPENSHIFT_TOKEN} --server=${OPENSHIFT_CONSOLE}"

echo "${PROJECT}: starting"

# If there is a deploymentconfig for the given service
if ${OC} -n ${PROJECT} get deploymentconfig cli &> /dev/null; then
  DEPLOYMENTCONFIG=$(${OC} -n ${PROJECT} get deploymentconfigs -l service=cli -o name)
  SCALED=false
  # If the deploymentconfig is scaled to 0, scale to 1
  if [[ $(${OC} -n ${PROJECT} get ${DEPLOYMENTCONFIG} -o go-template --template='{{.status.replicas}}') == "0" ]]; then

    ${OC} -n ${PROJECT} scale --replicas=1 ${DEPLOYMENTCONFIG} >/dev/null 2>&1
    printf "${PROJECT}: scaling cli to 1 replica"
    # Wait until the scaling is done
    while [[ ! $(${OC} -n ${PROJECT} get ${DEPLOYMENTCONFIG} -o go-template --template='{{.status.readyReplicas}}') == "1" ]]
    do
      sleep 1
      printf "."
    done
    SCALED=true
  fi
else
  echo "${PROJECT}: no deploymentconfig for cli found, assuming this is not a drupal site"
  continue
fi

POD=$(${OC} -n ${PROJECT} get pods -l service=cli -o json | jq -r '.items[] | select(.metadata.deletionTimestamp == null) | select(.status.phase == "Running") | .metadata.name' | head -n 1)

if [[ ! $POD ]]; then
  echo "${PROJECT}: No running pod found for service cli"
  exit 1
fi

# If no container defined, load the name of the first container
if [[ -z ${CONTAINER} ]]; then
  CONTAINER=$(${OC} -n ${PROJECT} get pod ${POD} -o json | jq --raw-output '.spec.containers[0].name')
fi

printf "\n"
check=$(<d8-check.sh)
${OC} -n ${PROJECT} exec ${POD} -c ${CONTAINER} -- bash -c "$check"


if [[ "$SCALED" == 'true' ]]; then
    ${OC} -n ${PROJECT} scale --replicas=0 ${DEPLOYMENTCONFIG} >/dev/null 2>&1
fi

echo "${PROJECT}: finished"