#!/usr/bin/env bash

scriptdir="$(dirname "$(readlink -f "$0")")"
legacycompat="${scriptdir}/legacycompat"
steambase="${scriptdir}/../.."

[ -d "${legacycompat}" ] || mkdir -p "${legacycompat}"

"${scriptdir}/download.py" vcrun2015 dotnet40
"${scriptdir}/createvdf.py" 359320 vcrun2015 "${steambase}/steam/steamapps/common/Steamworks Shared/_CommonRedist/vcredist/2015" dotnet40 "${steambase}/steam/steamapps/common/Steamworks Shared/_CommonRedist/DotNet/4.0"
