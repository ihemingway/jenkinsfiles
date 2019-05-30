#!/bin/bash

PROJECT=$1
PRODUCT=$2
AD=$3

if [[ -z ${AD} ]]
then
    echo "Usage: ${0} <PROJECT ID> <PRODUCT ID> <YOUR AD USERNAME>"
    exit 1
fi

#git pull https://${AD}@stash.mgcorp.co/scm/lt/jenkinsfiles.git
#cd jenkinsfiles
mkdir -p ${PROJECT}
cp jenkinsfile-template ${PROJECT}/Jenkinsfile-${PRODUCT}
sed -i -e "s/%%PRODUCT%%/'''${PRODUCT}'''/g" -e "s/%%PROJECT%%/'''${PROJECT}'''/g" ${PROJECT}/Jenkinsfile-${PRODUCT}
git add -A .
git commit -m "Autogen by ${0} on `hostname` by ${AD}"
git push origin master
