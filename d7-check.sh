#!/usr/bin/env bash

echo 'Drupal SA-CORE-2019-003 auto disable script for 7x.x'

d7Status="$(drush status --fields=drupal-version)"
d7RestwsInfo="$(drush pm-info --fields=status,version restws)"
d7ServicesInfo="$(drush pm-info --fields=status,version services)"

function disableContrib() {
  d7LinkInfo="$(drush pm-info --fields=version link)"
  if [[ $d7LinkInfo != *7.x-1.6* ]]
  then
    echo 'link is not version 7.x-1.6, disabling'
    drush pm-disable -y link
  fi
}

# Only need to disable modules if services or rest are installed and vulnerable
if [[ $d7RestwsInfo == *enabled* ]] || [[ $d7Servicesinfo == *enabled* ]]
then
  echo 'services or restws enabled, checking versions'

  # Services itself is not vulnerable, but if it's enabled, we need to check
  # contrib modules
  if [[ $d7Servicesinfo == *enabled* ]]
  then
    echo 'services enabled, checking contrib modules'
    disableContrib
  fi

  # RestWS should be disabled if vulnerable, but if fixed we still need to check
  # contrib modules
  if [[ $d7RestwsInfo != *7.x-2.8* ]]
  then
    echo 'restws is not version 7.x-2.8, disabling'
    drush pm-disable -y restws
  else
    echo 'restws is version 7.x-2.8, checking contrib modules'
    disableContrib
  fi

else
  echo 'services and restws are disabled, doing nothing'
fi
