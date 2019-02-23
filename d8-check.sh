#!/usr/bin/env bash

d8RestInfo="$(drush pm-info --fields=status,version rest)"

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
