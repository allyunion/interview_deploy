#!/bin/bash
REPO=interview_webapp
VERSION=1.0
wget https://github.com/allyunion/${REPO}/archive/v${VERSION}.tar.gz -O /tmp/v${VERSION}.tar.gz
tar xvfz /tmp/v${VERSION}.tar.gz -C /tmp
mv /tmp/${REPO}-${VERSION} /tmp/${REPO}
