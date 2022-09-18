#!/bin/sh

#https://assafmo.github.io/2019/05/02/ppa-repo-hosted-on-github.html

EMAIL=dmytro.shcherbatiuk@netstalker.io
PPA_GPG_PASSPHRASE=Scherb@tyuk1986
GITHUB_USERNAME=net-stalker

echo "::info::Creating the KEY.gpg file"
gpg --armor --export "$EMAIL" >./KEY.gpg

echo "::info::Creating the Packages and Packages.gz files"
dpkg-scanpackages --multiversion . >Packages
gzip -k -f Packages

echo "::info::Creating the Release, Release.gpg and InRelease files"
apt-ftparchive release . >Release
gpg --default-key "${EMAIL}" --passphrase $PPA_GPG_PASSPHRASE -abs -o - Release >Release.gpg
gpg --default-key "${EMAIL}" --passphrase $PPA_GPG_PASSPHRASE --clearsign -o - Release >InRelease

echo "::info::Creating the my_list_file.list file"
echo "deb https://$GITHUB_USERNAME.github.io/monitor-ppa ./" >my_list_file.list

echo "::info::Commit and push to GitHub and your PPA is ready to go:"
git add -A
git commit -m "add ppa repo"
git push -u origin main
