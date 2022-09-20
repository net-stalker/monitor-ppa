#!/bin/bash

#https://assafmo.github.io/2019/05/02/ppa-repo-hosted-on-github.html

export GPG_TTY=$(tty)

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
assert_non_empty "EMAIL" "$EMAIL"

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

gpg --default-key "$EMAIL" --passphrase "$GPG_PASSPHRASE" --pinentry-mode loopback -abs -o - Release >Release.gpg
gpg --default-key "$EMAIL" --passphrase "$GPG_PASSPHRASE" --clearsign --pinentry-mode loopback -o - Release >InRelease

echo "::info::Creating the $GITHUB_USERNAME.list file"
echo "deb https://$GITHUB_USERNAME.github.io/monitor-ppa ./" >$GITHUB_USERNAME.list
