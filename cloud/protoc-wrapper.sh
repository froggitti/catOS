#!/usr/bin/env bash

SCRIPT_PATH="$(dirname $([ -L $0 ] && echo "$(dirname $0)/$(readlink -n $0)" || echo $0))"

TOPLEVEL="$(cd "${SCRIPT_PATH}/.." && pwd)"

PATH="$PATH:${TOPLEVEL}/cloud/go/bin" $1 ${@:2}