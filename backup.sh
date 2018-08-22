#!/bin/bash
# usage:
# ./hamwan_routers.sh | ./backup.sh

DIR=$(dirname "${BASH_SOURCE[0]}")/backup
LIMIT=8

write_if_not_empty () {
	head=$(dd bs=1 count=1 2>/dev/null; echo a)
	head=${head%a}
	if [ "x$head" != x"" ]; then
		{ printf %s "$head"; cat; } > "$@"
	fi
}

mkdir -p "$DIR"
cd "$DIR"

while read router
do
	echo Backing up "$router"... 1>&2
	ssh -n "$router" '/export hide-sensitive' | write_if_not_empty "$router" &
	ssh -n "$router" "/system backup save name=$router " && scp "$router":"$router".backup . &

	# only allow $LIMIT concurrent jobs
	until [ $(jobs -p | wc -l) -lt $LIMIT ]
	do
		sleep 1
	done
done

# wait for all jobs to complete
for job in $(jobs -p)
do
	wait $job
done

git init
git add -A
git commit -m "Auto commit."
