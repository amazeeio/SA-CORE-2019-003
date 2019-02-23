#!/usr/bin/env bash

set -eu -o pipefail

drupalStatus="$(drush status --fields=drupal-version 2> /dev/null)"

if [[ "$drupalStatus" =~ 8\.[0-9]+\.[0-9]+ ]]
then
  echo "drupal8"
fi

if [[ "$drupalStatus" =~ 7\.[0-9]+ ]]
then
  echo "drupal7"
fi
