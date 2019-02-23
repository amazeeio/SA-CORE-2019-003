#!/usr/bin/env bash

echo 'Drupal SA-CORE-2019-003 auto disable script for 8.x'

d8Status="$(drush status --fields=drupal-version)"
d8RestInfo="$(drush pm-info --fields=status,version rest)"
d8JsonapiInfo="$(drush pm-info --fields=status,version jsonapi)"

# Check for vulnerable rest module
if [[ $d8RestInfo == *enabled* ]]
then
  echo 'rest module is enabled, checking version';

  if [[ $d8RestInfo != *8.6.10* ]]
  then
    echo 'rest module is not version 8.6.10, uninstalling';
    drush pm-uninstall -y rest
  else
    echo 'rest module is 8.6.10, doing nothing';
  fi
else
  echo 'rest is not enabled';
fi

# Check for vulnerable jsonapi module
if [[ $d8JsonapiInfo == *enabled* ]]
then
  echo 'jsonapi module is enabled, checking version';

  # If Drupal core isn't updated, it doesn't matter what version jsonapi is
  if [[ $d8Status != *8.6.10* ]]
  then
    echo 'Drupal core is not upgraded, uninstalling jsonapi';
    drush pm-uninstall -y jsonapi
  else

    # Drupal core is up to date, but jsonapi must also be either 8.x-2.3 or
    # 8.x-1.25
    if [[ $d8JsonapiInfo != *8.x-2.3* ]] && [[ $d8JsonapiInfo != *8.x-1.25* ]]
    then
      echo 'jsonapi module is not version 8.x-2.3 or 8.x-1.25, uninstalling';
      drush pm-uninstall -y jsonapi
    else
      echo 'jsonapi module is up to date, doing nothing';
      echo $d8JsonapiInfo;
    fi

  fi

else
  echo 'jsonapi is not enabled';
fi
