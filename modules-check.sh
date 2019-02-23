#!/usr/bin/env bash

set -eu -o pipefail

drupalStatus="$(drush status --fields=drupal-version 2> /dev/null)"

if [[ $drupalStatus =~ \s8\.\d+\.\d+ ]]
then
  # run d8-check.sh or copy inline
fi

if [[ $drupalStatus =~ \s7\.\d+ ]]
then
  # run d8-check.sh or copy inline
fi
