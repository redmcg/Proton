#!/usr/bin/env bash

scriptdir="$(dirname "$(readlink -f "$0")")"
legacycompat="${scriptdir}/legacycompat"

[ -d "${legacycompat}" ] || mkdir -p "${legacycompat}"

XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
DOWNLOADLOC="${DOWNLOADLOC:-$XDG_CACHE_HOME/createvdf}"

"${scriptdir}/download.py" "${DOWNLOADLOC}" dotnet40
"${scriptdir}/createvdf.py" 359320 dotnet40 "${DOWNLOADLOC}/DotNet/4.0"
