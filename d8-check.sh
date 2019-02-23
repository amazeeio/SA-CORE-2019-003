#!/usr/bin/env bash

set -o pipefail

d8Status="$(drush status --fields=drupal-version)"
pmlist=$(drush pm-list)
d8RestInfo="$(echo "$pmlist" | grep \(rest\))"
d8JsonapiInfo="$(echo "$pmlist" | grep \(jsonapi\))"


function uninstallingContrib() {
  d8fontawesomeInfo="$(echo "$pmlist" | grep \(fontawesome\))"
  if [[ $d8fontawesomeInfo == *Enabled* ]] && [[ $d8fontawesomeInfo != *8.x-2.12* ]]
  then
    echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: fontawesome is not version 8.x-2.12, is vulnerable"
  fi

  d8tmgmtInfo="$(echo "$pmlist" | grep \(tmgmt\))"
  if [[ $d8tmgmtInfo == *Enabled* ]] && [[ $d8tmgmtInfo != *8.x-1.7* ]]
  then
    echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: tmgmt is not version 8.x-1.7, is vulnerable"
  fi

  d8paragraphsInfo="$(echo "$pmlist" | grep \(paragraphs\))"
  if [[ $d8paragraphsInfo == *Enabled* ]] && [[ $d8paragraphsInfo != *8.x-1.6* ]]
  then
    echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: paragraphs is not version 8.x-1.6, is vulnerable"
  fi

  d8videoInfo="$(echo "$pmlist" | grep \(video\))"
  if [[ $d8videoInfo == *Enabled* ]] && [[ $d8videoInfo != *8.x-1.4* ]]
  then
    echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: video is not version 8.x-1.4, is vulnerable"
  fi

  d8metatagInfo="$(echo "$pmlist" | grep \(metatag\))"
  if [[ $d8metatagInfo == *Enabled* ]] && [[ $d8metatagInfo != *8.x-1.8* ]]
  then
    echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: metatag is not version 8.x-1.8, is vulnerable"
  fi
}

# Check for vulnerable rest module
if [[ $d8RestInfo == *Enabled* ]]
then
  if [[ $d8RestInfo != *8.6.10* ]]
  then
    echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: rest module is not version 8.6.10, is vulnerable";
  else
    echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: rest module is 8.6.10, checking contrib";
    uninstallingContrib
  fi
else
  echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: rest is not enabled";
fi

# Check for vulnerable jsonapi module
if [[ $d8JsonapiInfo == *Enabled* ]]
then
  # If Drupal core isn't updated, it doesn't matter what version jsonapi is
  if [[ $d8Status != *8.6.10* ]]
  then
    echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: Drupal core is not upgraded, jsonapi is vulnerable";
  else

    # Drupal core is up to date, but jsonapi must also be either 8.x-2.3 or
    # 8.x-1.25
    if [[ $d8JsonapiInfo != *8.x-2.3* ]] && [[ $d8JsonapiInfo != *8.x-1.25* ]]
    then
      echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: jsonapi module is not version 8.x-2.3 or 8.x-1.25, is vulnerable";
    else
      echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: jsonapi module is up to date, checking contrib";
      uninstallingContrib
    fi

  fi

else
  echo "$LAGOON_PROJECT-$LAGOON_GIT_SAFE_BRANCH: jsonapi is not enabled";
fi
