#!/bin/bash
# usage:
# ./hamwan_routers.sh | ./backup.sh

DIR=$(dirname "${BASH_SOURCE[0]}")/backup
LIMIT=8
COMMON_OPTS="-o ConnectTimeout=10 -o BatchMode=yes"
SCP_OPTS="$COMMON_OPTS"
SSH_OPTS="$COMMON_OPTS -n"

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
	SSH_CMD="ssh ${SSH_OPTS} $router"

	$SSH_CMD '/export hide-sensitive' \
	| sed 's![a-z]*/[0-3][0-9]/20[0-9][0-9] [0-2][0-9]:[0-5][0-9]:[0-5][0-9]!mm/dd/yyyy hh:mm:ss!' \
	| write_if_not_empty "$router" &

	$SSH_CMD "/system backup save name=$router " \
	&& scp ${SCP_OPTS} "$router":"$router".backup . &

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
