
#!/bin/bash

set -eu -o pipefail

check=$(<d8-check.sh)
for dir in /var/www/*
do
  user=${dir#/var/www/}
  if id -u $user &> /dev/null; then
    su $user bash -c "cd \$AMAZEEIO_WEBROOT; $check"
  fi
done