#!/usr/bin/env bash
# validate_manifest.sh
#
# Validates the repo manifest, per the DTD format given here:
# https://gerrit.googlesource.com/git-repo/+/master/docs/manifest-format.txt

echo "Verifying default.xml using manifest.dtd"

# check that xmllint is available
if ! [ -x "$(command -v xmllint)" ]
then
  echo "Please install 'xmllint' to use this script"
  exit 1
fi

# run the verification
xmllint --noout --dtdvalid manifest.dtd default.xml
status=$?

if [ $status -ne 0 ]
then
  echo "FAILURE: default.xml isn't valid - exit status: $status"
  exit $status
else
  echo "SUCCESS: default.xml validated correctly"
  exit 0
fi
