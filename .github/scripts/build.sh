#!/bin/bash

#https://assafmo.github.io/2019/05/02/ppa-repo-hosted-on-github.html

EMAIL=dmytro.shcherbatiuk@netstalker.io
#GPG_PASSPHRASE=Scherb@tyuk1986
GITHUB_USERNAME=net-stalker

assert_non_empty() {
  name=$1
  value=$2
  if [[ -z "$value" ]]; then
    echo "::error::Invalid Value: $name is empty." >&2
    exit 1
  fi
}

assert_non_empty "GPG_PRIVATE_KEY" "$GPG_PRIVATE_KEY"
assert_non_empty "GPG_PASSPHRASE" "$GPG_PASSPHRASE"

echo "::info::Importing GPG private key"
GPG_KEY_ID=$(echo "$GPG_PRIVATE_KEY" | gpg --import-options show-only --import | sed -n '2s/^\s*//p')
echo $GPG_KEY_ID
echo "$GPG_PRIVATE_KEY" | gpg --batch --passphrase "$GPG_PASSPHRASE" --import

echo "::info::Creating the KEY.gpg file"
gpg --armor --export "$EMAIL" >./KEY.gpg

echo "::info::Creating the Packages and Packages.gz files"
dpkg-scanpackages --multiversion . >Packages
gzip -k -f Packages

echo "::info::Creating the Release, Release.gpg and InRelease files"
apt-ftparchive release . >Release
gpg --default-key "$EMAIL" --passphrase "$GPG_PASSPHRASE" -abs -o - Release >Release.gpg
gpg --default-key "$EMAIL" --passphrase "$GPG_PASSPHRASE" --clearsign -o - Release >InRelease

echo "::info::Creating the my_list_file.list file"
echo "deb https://$GITHUB_USERNAME.github.io/monitor-ppa ./" >$GITHUB_USERNAME.list

echo "::info::Commit and push to GitHub and your PPA is ready to go:"
git add -A
git commit -m "add ppa repo"
git push -u origin main
