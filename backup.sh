#!/bin/bash
# usage:
# ./hamwan_routers.sh | ./backup.sh

DIR=backup

mkdir -p "$DIR"
cd "$DIR"

while read router
do
	echo Backing up "$router"...
	ssh -n "$router" '/export hide-sensitive' > "$router"
done

git init
git add -A
git commit -m "Auto commit."
