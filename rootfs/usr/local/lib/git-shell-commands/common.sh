# Common library for git-shell-commands

set -uo pipefail

# Imports the container env var file
# shellcheck disable=SC1091
test -r /var/run/env && source /var/run/env

# Global settings
GIT_BASE_DIR=/srv/git

# Convenience styling vars
reset="[m"
bold="[1m"
error="[31m[1m"
warn="[33m[1m"
cmd="[2m[1m[36m"

function error {
	echo "${error}Error:${reset} $*" 1>&2
}

function warn {
	echo "${warn}Warning:${reset} $*" 1>&2
}

function fail {
	error "$*"
	exit 1
}

function status {
	echo "$*"
}

function input {
	local question=$1
	local variable=$2

	# shellcheck disable=SC2059
	echo "${bold}${question}${reset}"
	read -rp "> " "${variable?}"
	echo
}

# This function will wait on user input to do some action. It returns failure when the user chooses
# a negative answer.
#
# Arguments
#   1 - The string of the question you want to ask.
#   2 - The default answer when none is given (default: Y, options: Y/N)
function ask {
	local question=$1
	local default=${2:-Y}

	if [ "$default" == "Y" ]; then
		local answer_hint="[Yn]"
	else
		local answer_hint="[yN]"
	fi

	# shellcheck disable=SC2059
	printf "${bold}${question}${reset} ${answer_hint} "

	read -rp "" answer
	echo
	answer=${answer:-$default}

	case ${answer:0:1} in
		n|N) return 1 ;;
		y|Y) return 0 ;;
		*) fail "You need to type either Y or N" ;;
	esac
}
