#!/bin/bash

mydir=~/git

if [ -d $mydir ]
then
cd $mydir
else
mkdir $mydir
cd $mydir
fi

git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
puma -d

