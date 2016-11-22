#!/bin/bash

dp0="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

ONE_BASE="$( cd "${dp0}/.." && pwd )"
PROJECT_BASE="$( cd "${dp0}/../../.." && pwd )"
ONE_CONFIG_BASE="$( cd "${dp0}/../../../config/one" && pwd )"

if [ "$(uname)" == "Darwin" ]; then 
    PLATFROM="OSX"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    PLATFROM="Linux"
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    PLATFROM="Windows"
fi
