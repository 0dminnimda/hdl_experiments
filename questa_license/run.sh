#!/bin/bash

if [[ "$OSTYPE" == "msys" ]]; then
  QUESTA="/c/intelFPGA/23.1std"
  LICENSE="$QUESTA/license/LR-176611_License.dat"
  BIN="$QUESTA/questa_fse/win64"
else
  QUESTA="$(realpath ~/intelFPGA/23.1std)"
  LICENSE="$(realpath ~/intelFPGA_pro/23.4/license/LR-166687_License.dat)"
  BIN="$QUESTA/questa_fse/bin"
fi

export LM_LICENSE_FILE="${LICENSE}"
${BIN}/$@

