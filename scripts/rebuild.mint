#!/bin/bash

export ENV=$1

if [ ! "$ENV" = "test" ] && [ ! "$ENV" = "production" ]; then
    echo Usage: `basename $0` ENV
    echo Expected ENV: "test" or "production"
    echo
    exit
fi


service mint stop

# Compile Mint
cd /opt/researchdata/institution-build/mint
mvn -s settings.xml -P mint-$ENV -X clean install
service mint start

# Copy initial data


# Restart HTTPD
service httpd restart

cd -
