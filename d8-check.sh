#!/usr/bin/env bash

set -eu -o pipefail

d8Status="$(drush status --fields=drupal-version 2> /dev/null)"
d8RestInfo="$(drush pm-info --fields=status,version rest 2> /dev/null)"
d8JsonapiInfo="$(drush pm-info --fields=status,version jsonapi 2> /dev/null)"

function uninstallingContrib() {
  d8fontawesomeInfo="$(drush pm-info --fields=status,version fontawesome 2> /dev/null)"
  if [[ $d8fontawesomeInfo == *enabled* ]] && [[ $d8fontawesomeInfo != *8.x-2.12* ]]
  then
    echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: fontawesome is not version 8.x-2.12, is vulnerable"
    # drush pm-uninstall -y fontawesome
  fi

  d8tmgmtInfo="$(drush pm-info --fields=status,version tmgmt 2> /dev/null)"
  if [[ $d8tmgmtInfo == *enabled* ]] && [[ $d8tmgmtInfo != *8.x-1.7* ]]
  then
    echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: tmgmt is not version 8.x-1.7, is vulnerable"
    # drush pm-uninstall -y tmgmt
  fi

  d8paragraphsInfo="$(drush pm-info --fields=status,version paragraphs 2> /dev/null)"
  if [[ $d8paragraphsInfo == *enabled* ]] && [[ $d8paragraphsInfo != *8.x-1.6* ]]
  then
    echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: paragraphs is not version 8.x-1.6, is vulnerable"
    # drush pm-uninstall -y paragraphs
  fi

  d8videoInfo="$(drush pm-info --fields=status,version video 2> /dev/null)"
  if [[ $d8videoInfo == *enabled* ]] && [[ $d8videoInfo != *8.x-1.4* ]]
  then
    echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: video is not version 8.x-1.4, is vulnerable"
    # drush pm-uninstall -y video
  fi

  d8metatagInfo="$(drush pm-info --fields=status,version metatag 2> /dev/null)"
  if [[ $d8metatagInfo == *enabled* ]] && [[ $d8metatagInfo != *8.x-1.8* ]]
  then
    echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: metatag is not version 8.x-1.8, is vulnerable"
    # drush pm-uninstall -y metatag
  fi
}

# Check for vulnerable rest module
if [[ $d8RestInfo == *enabled* ]]
then
  if [[ $d8RestInfo != *8.6.10* ]]
  then
    echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: rest module is not version 8.6.10, is vulnerable";
    # drush pm-uninstall -y rest
  else
    echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: rest module is 8.6.10, checking contrib";
    uninstallingContrib
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
    echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: Drupal core is not upgraded, jsonapi is vulnerable";
    # drush pm-uninstall -y jsonapi
  else

    # Drupal core is up to date, but jsonapi must also be either 8.x-2.3 or
    # 8.x-1.25
    if [[ $d8JsonapiInfo != *8.x-2.3* ]] && [[ $d8JsonapiInfo != *8.x-1.25* ]]
    then
      echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: jsonapi module is not version 8.x-2.3 or 8.x-1.25, is vulnerable";
      # drush pm-uninstall -y jsonapi
    else
      echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: jsonapi module is up to date, checking contrib";
      echo $d8JsonapiInfo;
      uninstallingContrib
    fi

  fi

else
  echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: jsonapi is not enabled";
fi
