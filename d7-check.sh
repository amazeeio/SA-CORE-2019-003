#!/usr/bin/env bash

set -o pipefail

pmlist=$(drush pm-list)
d7RestwsInfo="$(echo "$pmlist" | grep \(restws\))"
d7ServicesInfo="$(echo "$pmlist" | grep \(services\))"

function checkD7Contrib() {
  d7LinkInfo="$(echo "$pmlist" | grep \(link\))"
  if [[ $d7LinkInfo == *Enabled* ]] && [[ $d7LinkInfo != *7.x-1.6* ]]
  then
    echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: link is not version 7.x-1.6, is vulnerable"
    # drush pm-disable -y link
  fi
}

# Services itself is not vulnerable, but if it's enabled, we need to check
# contrib modules
if [[ $d7ServicesInfo == *Enabled* ]]
then
  echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: services enabled, checking contrib modules"
  checkD7Contrib
else
  echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: services is not enabled"
fi

# Check for enabled or vulnerable version of restws
if [[ $d7RestwsInfo == *Enabled* ]]
then
  # RestWS should be disabled if vulnerable, but if fixed we still need to check
  # contrib modules
  if [[ $d7RestwsInfo != *7.x-2.8* ]]
  then
    echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: restws is not version 7.x-2.8, is vulnerable"
    # drush pm-disable -y restws
  else
    echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: restws is version 7.x-2.8, checking contrib modules"
    checkD7Contrib
  fi

else
  echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: restws is not enabled"
fi
