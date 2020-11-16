#!/bin/bash
cd "$(dirname "$0")"
set -e
sed -i~ -e '/# Meetings/,$ d' README.md

exec 3>> README.md
echo "# Meetings" 1>&3
echo 1>&3

for d in $(find . -maxdepth 1 -mindepth 1 -type d -print | sort); do
    if [[ "${d#./}" != ".${d#./.}" ]]; then
        echo "* [${d##*/}]($d/)" 1>&3
		exec 4> "$d"/index.md
		echo "# ${d##*/}" 1>&4
		echo 1>&4
		for f in $(find "$d" -maxdepth 1 -mindepth 1 -type f \! -name index.md -print | sort); do
            echo "* [${f##*/}](./${f##*/})" 1>&4
		done
		exec 4>&-
		git add "$d"/index.md
    fi
done
exec 3>&-
git add README.md
