#!/bin/bash

if [[ "$OSTYPE" == "msys" ]]; then
    QUESTA="/c/intelFPGA/23.1std"
    BIN="$QUESTA/questa_fse/win64"
else
    QUESTA="$(realpath ~/intelFPGA/23.1std)"
    BIN="$QUESTA/questa_fse/bin"
fi

OLD_LICENSE=$(find "~/intelFPGA_pro/23.4/license" -name 'LR-*_License.dat')
if [ $? -eq 0 ]; then
    OLD_NAME=$(basename $OLD_LICENSE)
    cp $OLD_LICENSE "$QUESTA/license/$OLD_NAME"
fi

LICENSE=$(find "$QUESTA/license/" -name 'LR-*_License.dat')
echo "Using $LICENSE"

export LM_LICENSE_FILE="${LICENSE}"
${BIN}/$@

