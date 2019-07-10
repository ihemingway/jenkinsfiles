#!/bin/bash

DOMAIN=$1
AD=$2

if [[ -z ${AD} ]]
then
    echo "Usage: ${0} <DOMAIN> <YOUR AD USERNAME>"
    exit 1
fi

#git pull https://${AD}@stash.mgcorp.co/scm/lt/jenkinsfiles.git
#cd jenkinsfiles
cp jenkinsfile-template-cpan cpan/Jenkinsfile-${DOMAIN}
sed -i -e "s/DOMAIN/${DOMAIN}/g" cpan/Jenkinsfile-${DOMAIN}
git add -A .
git commit -m "Autogen by ${0} on `hostname` by ${AD}"
git push origin master
