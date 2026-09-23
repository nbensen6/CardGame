#!/bin/sh
# One run of an agent at a time.
#
# 2026-09-23 12:19 EDT: the hourly artist fire and a manual one overlapped.
# Both rewrote design/agents/status/artist.md, and the second spent its whole
# run untangling a merge instead of making anything. The runs cannot see each
# other — separate sandboxes, separate machines — so the only thing they share
# is the git remote, which is where the lease lives.
#
#   tools/agents/lease.sh claim artist    # 0 = it is yours, 3 = someone else is running, STOP
#   tools/agents/lease.sh release artist  # at the end of your run, whatever happened
#   tools/agents/lease.sh selftest        # the staleness rule, no git, no network
#
# A lease is one line: the unix second it was taken, the same time in ISO for a
# human reading the file, and who took it. An empty file means free.
set -e

cmd="${1:-}"
agent="${2:-}"
stale="${LEASE_STALE:-2400}"   # 40 min. A run that dies mid-flight must not wedge
                               # its agent forever; a normal run is under 25.

lease_file() { echo "design/agents/status/$1.lease"; }

# True when the file names a holder whose lease has not yet gone stale.
held_recently() {
	f="$1"
	[ -s "$f" ] || return 1
	taken=$(cut -d' ' -f1 "$f" 2>/dev/null || echo 0)
	case "$taken" in ''|*[!0-9]*) return 1 ;; esac
	[ $(( $(date -u +%s) - taken )) -lt "$stale" ]
}

sync_to_remote() {
	git fetch -q origin main
	git checkout -q -B main FETCH_HEAD
}

push_lease() {
	git add "$1"
	git commit -q -m "$agent: $2 the run lease, $(TZ=America/New_York date +%Y-%m-%dT%H:%M) ET" || true
	git push -q origin HEAD:main
}

case "$cmd" in
claim)
	[ -n "$agent" ] || { echo "usage: lease.sh claim <agent>" >&2; exit 2; }
	f=$(lease_file "$agent")
	# Claiming happens before any work, so there is nothing local to lose and a
	# hard sync to the remote is the honest way to read the current lease.
	sync_to_remote
	if held_recently "$f"; then
		echo "BUSY $agent — $(cat "$f")"
		exit 3
	fi
	printf '%s %s %s\n' "$(date -u +%s)" "$(TZ=America/New_York date +%Y-%m-%dT%H:%M)" "${LEASE_TAG:-run}" > "$f"
	if push_lease "$f" claim 2>/dev/null; then
		exit 0
	fi
	# Lost the push race: someone claimed between our read and our write. Re-read
	# the remote and believe it. One retry, then give up — the safe direction for
	# a guard is to stop, never to run anyway.
	sync_to_remote
	if held_recently "$f"; then
		echo "BUSY $agent — $(cat "$f") (lost the push race)"
		exit 3
	fi
	printf '%s %s %s\n' "$(date -u +%s)" "$(TZ=America/New_York date +%Y-%m-%dT%H:%M)" "${LEASE_TAG:-run}" > "$f"
	push_lease "$f" claim
	;;
release)
	[ -n "$agent" ] || { echo "usage: lease.sh release <agent>" >&2; exit 2; }
	f=$(lease_file "$agent")
	# Your own work is already pushed by now (COMMON.md section 5), so a rebase
	# here only picks up what the others did.
	git pull --rebase -q origin main
	: > "$f"
	push_lease "$f" release
	;;
selftest)
	t=$(mktemp)
	: > "$t"
	held_recently "$t" && { echo "FAIL: an empty lease must read as free"; exit 1; }
	printf '%s %s %s\n' "$(date -u +%s)" now mine > "$t"
	held_recently "$t" || { echo "FAIL: a lease taken this second must read as held"; exit 1; }
	printf '%s %s %s\n' "$(( $(date -u +%s) - stale - 1 ))" old mine > "$t"
	held_recently "$t" && { echo "FAIL: a lease older than LEASE_STALE must read as free, or a dead run wedges its agent forever"; exit 1; }
	echo "not-a-number x y" > "$t"
	held_recently "$t" && { echo "FAIL: a corrupt lease must read as free rather than blocking every future run"; exit 1; }
	rm -f "$t"
	echo "LEASE SELFTEST OK"
	;;
*)
	echo "usage: lease.sh claim|release <agent> | selftest" >&2
	exit 2
	;;
esac
