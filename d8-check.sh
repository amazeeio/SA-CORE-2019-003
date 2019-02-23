#!/usr/bin/env bash

set -eu -o pipefail

d8Status="$(drush status --fields=drupal-version 2> /dev/null)"
d8RestInfo="$(drush pm-info --fields=status,version rest 2> /dev/null)"
d8JsonapiInfo="$(drush pm-info --fields=status,version jsonapi 2> /dev/null)"

# Check for vulnerable rest module
if [[ $d8RestInfo == *enabled* ]]
then
  if [[ $d8RestInfo != *8.6.10* ]]
  then
    echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: rest module is not version 8.6.10, uninstalling";
    drush pm-uninstall -y rest
  else
    echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: rest module is 8.6.10, doing nothing";
  fi
else
  echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: rest is not enabled";
fi

# Check for vulnerable jsonapi module
if [[ $d8JsonapiInfo == *enabled* ]]
then
  # If Drupal core isn't updated, it doesn't matter what version jsonapi is
  if [[ $d8Status != *8.6.10* ]]
  then
    echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: Drupal core is not upgraded, uninstalling jsonapi";
    drush pm-uninstall -y jsonapi
  else

    # Drupal core is up to date, but jsonapi must also be either 8.x-2.3 or
    # 8.x-1.25
    if [[ $d8JsonapiInfo != *8.x-2.3* ]] && [[ $d8JsonapiInfo != *8.x-1.25* ]]
    then
      echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: jsonapi module is not version 8.x-2.3 or 8.x-1.25, uninstalling";
      drush pm-uninstall -y jsonapi
    else
      echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: jsonapi module is up to date, doing nothing";
      echo $d8JsonapiInfo;
    fi

  fi

else
  echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: jsonapi is not enabled";
fi
