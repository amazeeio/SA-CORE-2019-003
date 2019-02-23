#!/usr/bin/env bash

set -o pipefail

drupalStatus="$(drush status --fields=drupal-version 2> /dev/null)"

if [[ "$drupalStatus" =~ 8\.[0-9]+\.[0-9]+ ]]
then
  echo "$LAGOON_PROJECT$AMAZEEIO_SITE_GROUP-$LAGOON_GIT_SAFE_BRANCH$AMAZEEIO_SITE_BRANCH: found Drupal 8"
  pmlist=$(drush pm-list)
  d8RestInfo="$(echo "$pmlist" | grep \(rest\))"
  d8JsonapiInfo="$(echo "$pmlist" | grep \(jsonapi\))"


  function uninstallingContrib() {
    d8fontawesomeInfo="$(echo "$pmlist" | grep \(fontawesome\))"
    if [[ $d8fontawesomeInfo == *Enabled* ]] && [[ $d8fontawesomeInfo != *8.x-2.12* ]]
    then
      echo "$LAGOON_PROJECT$AMAZEEIO_SITE_GROUP-$LAGOON_GIT_SAFE_BRANCH$AMAZEEIO_SITE_BRANCH: fontawesome is not version 8.x-2.12, is vulnerable"
    fi

    d8tmgmtInfo="$(echo "$pmlist" | grep \(tmgmt\))"
    if [[ $d8tmgmtInfo == *Enabled* ]] && [[ $d8tmgmtInfo != *8.x-1.7* ]]
    then
      echo "$LAGOON_PROJECT$AMAZEEIO_SITE_GROUP-$LAGOON_GIT_SAFE_BRANCH$AMAZEEIO_SITE_BRANCH: tmgmt is not version 8.x-1.7, is vulnerable"
    fi

    d8paragraphsInfo="$(echo "$pmlist" | grep \(paragraphs\))"
    if [[ $d8paragraphsInfo == *Enabled* ]] && [[ $d8paragraphsInfo != *8.x-1.6* ]]
    then
      echo "$LAGOON_PROJECT$AMAZEEIO_SITE_GROUP-$LAGOON_GIT_SAFE_BRANCH$AMAZEEIO_SITE_BRANCH: paragraphs is not version 8.x-1.6, is vulnerable"
    fi

    d8videoInfo="$(echo "$pmlist" | grep \(video\))"
    if [[ $d8videoInfo == *Enabled* ]] && [[ $d8videoInfo != *8.x-1.4* ]]
    then
      echo "$LAGOON_PROJECT$AMAZEEIO_SITE_GROUP-$LAGOON_GIT_SAFE_BRANCH$AMAZEEIO_SITE_BRANCH: video is not version 8.x-1.4, is vulnerable"
    fi

    d8metatagInfo="$(echo "$pmlist" | grep \(metatag\))"
    if [[ $d8metatagInfo == *Enabled* ]] && [[ $d8metatagInfo != *8.x-1.8* ]]
    then
      echo "$LAGOON_PROJECT$AMAZEEIO_SITE_GROUP-$LAGOON_GIT_SAFE_BRANCH$AMAZEEIO_SITE_BRANCH: metatag is not version 8.x-1.8, is vulnerable"
    fi
  }

  # Check for vulnerable rest module
  if [[ $d8RestInfo == *Enabled* ]]
  then
    if [[ $d8RestInfo != *8.6.10* ]]
    then
      echo "$LAGOON_PROJECT$AMAZEEIO_SITE_GROUP-$LAGOON_GIT_SAFE_BRANCH$AMAZEEIO_SITE_BRANCH: rest module is not version 8.6.10, is vulnerable";
    else
      echo "$LAGOON_PROJECT$AMAZEEIO_SITE_GROUP-$LAGOON_GIT_SAFE_BRANCH$AMAZEEIO_SITE_BRANCH: rest module is 8.6.10, checking contrib";
      uninstallingContrib
    fi
  else
    echo "$LAGOON_PROJECT$AMAZEEIO_SITE_GROUP-$LAGOON_GIT_SAFE_BRANCH$AMAZEEIO_SITE_BRANCH: rest is not enabled";
  fi

  # Check for vulnerable jsonapi module
  if [[ $d8JsonapiInfo == *Enabled* ]]
  then
    # If Drupal core isn't updated, it doesn't matter what version jsonapi is
    if [[ $drupalStatus != *8.6.10* ]]
    then
      echo "$LAGOON_PROJECT$AMAZEEIO_SITE_GROUP-$LAGOON_GIT_SAFE_BRANCH$AMAZEEIO_SITE_BRANCH: Drupal core is not upgraded, jsonapi is vulnerable";
    else

      # Drupal core is up to date, but jsonapi must also be either 8.x-2.3 or
      # 8.x-1.25
      if [[ $d8JsonapiInfo != *8.x-2.3* ]] && [[ $d8JsonapiInfo != *8.x-1.25* ]]
      then
        echo "$LAGOON_PROJECT$AMAZEEIO_SITE_GROUP-$LAGOON_GIT_SAFE_BRANCH$AMAZEEIO_SITE_BRANCH: jsonapi module is not version 8.x-2.3 or 8.x-1.25, is vulnerable";
      else
        echo "$LAGOON_PROJECT$AMAZEEIO_SITE_GROUP-$LAGOON_GIT_SAFE_BRANCH$AMAZEEIO_SITE_BRANCH: jsonapi module is up to date, checking contrib";
        uninstallingContrib
      fi

    fi

  else
    echo "$LAGOON_PROJECT$AMAZEEIO_SITE_GROUP-$LAGOON_GIT_SAFE_BRANCH$AMAZEEIO_SITE_BRANCH: jsonapi is not enabled";
  fi

fi

if [[ "$drupalStatus" =~ 7\.[0-9]+ ]]
then
  echo "$LAGOON_PROJECT$AMAZEEIO_SITE_GROUP-$LAGOON_GIT_SAFE_BRANCH$AMAZEEIO_SITE_BRANCH: found Drupal 7"
  pmlist=$(drush pm-list)
  d7RestwsInfo="$(echo "$pmlist" | grep \(restws\))"
  d7ServicesInfo="$(echo "$pmlist" | grep \(services\))"

  function checkD7Contrib() {
    d7LinkInfo="$(echo "$pmlist" | grep \(link\))"
    if [[ $d7LinkInfo == *Enabled* ]] && [[ $d7LinkInfo != *7.x-1.6* ]]
    then
      echo "$LAGOON_PROJECT$AMAZEEIO_SITE_GROUP-$LAGOON_GIT_SAFE_BRANCH$AMAZEEIO_SITE_BRANCH: link is not version 7.x-1.6, is vulnerable"
      # drush pm-disable -y link
    fi
  }

  # Services itself is not vulnerable, but if it's enabled, we need to check
  # contrib modules
  if [[ $d7ServicesInfo == *Enabled* ]]
  then
    echo "$LAGOON_PROJECT$AMAZEEIO_SITE_GROUP-$LAGOON_GIT_SAFE_BRANCH$AMAZEEIO_SITE_BRANCH: services enabled, checking contrib modules"
    checkD7Contrib
  else
    echo "$LAGOON_PROJECT$AMAZEEIO_SITE_GROUP-$LAGOON_GIT_SAFE_BRANCH$AMAZEEIO_SITE_BRANCH: services is not enabled"
  fi

  # Check for enabled or vulnerable version of restws
  if [[ $d7RestwsInfo == *Enabled* ]]
  then
    # RestWS should be disabled if vulnerable, but if fixed we still need to check
    # contrib modules
    if [[ $d7RestwsInfo != *7.x-2.8* ]]
    then
      echo "$LAGOON_PROJECT$AMAZEEIO_SITE_GROUP-$LAGOON_GIT_SAFE_BRANCH$AMAZEEIO_SITE_BRANCH: restws is not version 7.x-2.8, is vulnerable"
      # drush pm-disable -y restws
    else
      echo "$LAGOON_PROJECT$AMAZEEIO_SITE_GROUP-$LAGOON_GIT_SAFE_BRANCH$AMAZEEIO_SITE_BRANCH: restws is version 7.x-2.8, checking contrib modules"
      checkD7Contrib
    fi

  else
    echo "$LAGOON_PROJECT$AMAZEEIO_SITE_GROUP-$LAGOON_GIT_SAFE_BRANCH$AMAZEEIO_SITE_BRANCH: restws is not enabled"
  fi

fi
