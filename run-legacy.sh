
#!/bin/bash

set -eu -o pipefail

for dir in /var/www/*
do
  user=${dir#/var/www/}
  if id -u $user &> /dev/null; then
    su $user bash -c "cd \$AMAZEEIO_WEBROOT; drush status"
  fi
done