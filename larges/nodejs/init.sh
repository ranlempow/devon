#!/bin/bash

BINDIR=${PROJECT_BASE}/bin
if [ ! -d "${BINDIR}" ]; then
    mkdir "${BINDIR}" 
fi

APPSDIR=${BINDIR}/apps
if [ ! -d "${APPSDIR}" ]; then
    mkdir "${APPSDIR}"
    echo '#!/bin/bash'                                               > "${APPSDIR}/set-env.sh"
    echo 'dp0="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"'  >> "${APPSDIR}/set-env.sh"
    echo 'for FILE in ${dp0}/*/set-env.sh'                          >> "${APPSDIR}/set-env.sh"
    echo 'do'                                                       >> "${APPSDIR}/set-env.sh"
    echo '  if [ -f $FILE ]; then'                                  >> "${APPSDIR}/set-env.sh"
    echo '    source $FILE'                                         >> "${APPSDIR}/set-env.sh"
    echo '  fi'                                                     >> "${APPSDIR}/set-env.sh"
    echo 'done'                                                     >> "${APPSDIR}/set-env.sh"

fi

NODEDIR=${APPSDIR}/node
if [ ! -d "${NODEDIR}" ]; then
    mkdir "${NODEDIR}"
fi

if [ -z "$NODE_VERSION" ]; then
    NODE_VERSION="5.7.1"
fi

if [ ! -d ${NODEDIR}/node ]; then
    if [ "$PLATFROM" == "OSX" ]; then
        NODEURL=https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-darwin-x64.tar.gz
    elif [ "$PLATFROM" == "Linux" ]; then
        NODEURL=https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz
    fi
    NODEFILE=${NODEURL##*/}
    if [ -f ${NODEFILE} ]; then
        rm ${NODEFILE}
    fi
    wget ${NODEURL}
    tar -Jpxvf ${NODEFILE} -C ${NODEDIR}
    mv ${NODEDIR}/${NODEFILE%.tar.xz} ${NODEDIR}/node
    rm ${NODEFILE}
    echo '#!/bin/bash'                                               > "${NODEDIR}/set-env.sh"
    echo 'dp0="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"'  >> "${NODEDIR}/set-env.sh"
    echo 'PATH=${dp0}/node:${PATH}'                                 >> "${NODEDIR}/set-env.sh"
    echo 'PATH=${PROJECT_BASE}/node_modules/.bin:${PATH}'           >> "${NODEDIR}/set-env.sh"
    
fi

npm install
bower install