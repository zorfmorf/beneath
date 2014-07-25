#!/bin/bash

# settings
PROJECT_NAME="Beneath"
VERSION="-0.1.love"
LOVE="love-0.9.1"

# make sure we execute the script in the repo's root folder
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR 

# make sure bin exists
mkdir bin

# create love file
rm bin/$PROJECT_NAME$VERSION
cd src
zip -r ../bin/$PROJECT_NAME$VERSION *

cd ../bin

# get latest love version
if [ ! -f "$LOVE-win64.zip" ]
then
    wget "https://bitbucket.org/rude/love/downloads/"$LOVE"-win32.zip"
    wget "https://bitbucket.org/rude/love/downloads/"$LOVE"-win64.zip"
fi

rm $PROJECT_NAME*.zip

unzip -j "*64.zip" -d x64
unzip -j "*32.zip" -d x32
cat x64/love.exe $PROJECT_NAME$VERSION > x64/$PROJECT_NAME".exe"
cat x32/love.exe $PROJECT_NAME$VERSION > x32/$PROJECT_NAME".exe"
rm x64/love.exe
rm x32/love.exe

cd x64
zip -r ../$PROJECT_NAME"_Win64.zip" *
cd ..
cd x32
zip -r ../$PROJECT_NAME"_Win32.zip" *
cd ..

rm -rf x32
rm -rf x64
