#!/usr/bin/env bash

set -eu -o pipefail

d7Status="$(drush status --fields=drupal-version 2> /dev/null)"
d7RestwsInfo="$(drush pm-info --fields=status,version restws 2> /dev/null)"
d7ServicesInfo="$(drush pm-info --fields=status,version services 2> /dev/null)"

function disableContrib() {
  d7LinkInfo="$(drush pm-info --fields=version link 2> /dev/null)"
  if [[ $d7LinkInfo == *enabled* ]] && [[ $d7LinkInfo != *7.x-1.6* ]]
  then
    echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: link is not version 7.x-1.6, is vulnerable"
    # drush pm-disable -y link
  fi
}

# Services itself is not vulnerable, but if it's enabled, we need to check
# contrib modules
if [[ $d7ServicesInfo == *enabled* ]]
then
  echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: services enabled, checking contrib modules"
  disableContrib
else
  echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: services is not enabled"
fi

# Check for enabled or vulnerable version of restws
if [[ $d7RestwsInfo == *enabled* ]]
then
  # RestWS should be disabled if vulnerable, but if fixed we still need to check
  # contrib modules
  if [[ $d7RestwsInfo != *7.x-2.8* ]]
  then
    echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: restws is not version 7.x-2.8, is vulnerable"
    # drush pm-disable -y restws
  else
    echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: restws is version 7.x-2.8, checking contrib modules"
    disableContrib
  fi

else
  echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: restws is not enabled"
fi
