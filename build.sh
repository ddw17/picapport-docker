#!/usr/bin/env bash
if [ -z "$1" ] || [ ! -z "$2" ] ; then
  echo "Please call with only the version to be built as parameter, like this:"
  echo "$0 9-1-07"
  echo "Note that the version parameter must match the version string in the download path at picapport.de"
  exit 1
fi
docker build --build-arg VERSION="$1" . -t picapport:"$(echo $1| sed -e 's/-/\./g')"

