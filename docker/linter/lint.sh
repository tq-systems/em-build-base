#!/bin/bash
# Copyright (c) 2024 TQ-Systems GmbH <license@tq-group.com>
# D-82229 Seefeld, Germany. All rights reserved.
# Author:
#   Christoph Krutz

SCRIPT_NAME="$(basename "$0")"
MODE="$1"; shift
RETURN_CODE=0

declare -a TARGET_FILES

SHELL="shell"
PYTHON="python"

OPT_GIVEN=0

usage() {
	echo "This script runs a linter on files with typical extensions.
Files without typical extension need to be specified. If no file or
directory is specified, all files in the current directory and
subdirectories are checked.

Usage:
    $SCRIPT_NAME <mode>
    $SCRIPT_NAME <mode> [-d directory] [-f file]

Modes:
    $SHELL
    $PYTHON

Examples:
    $SCRIPT_NAME $SHELL
    $SCRIPT_NAME $PYTHON
    $SCRIPT_NAME $SHELL  -d scripts
    $SCRIPT_NAME $PYTHON -f scripts/test.py
"
}

found_error() {
	RETURN_CODE=1

	# print a separator on every finding
	printf %"$COLUMNS"s |tr " " "-"
}

run_linter() {
	local file="$1"

	if [ ! -f "$file" ]; then
		echo "File does not exist: $file"
		return
	fi

	echo "Run linter on $file"
	case "$MODE" in
	"$SHELL")
		# shellcheck disable=SC2086
		shellcheck ${TQEM_SHELLCHECK_OPTIONS} "$file" || found_error
		;;
	"$PYTHON")
		# shellcheck disable=SC2086
		pylint ${TQEM_PYLINT_OPTIONS} "$file" || found_error
		;;
	esac
}

parse_options() {
	while getopts ':d:f:h' option; do
		case "$option" in
			d)
				OPT_GIVEN=1
				while IFS= read -r -d '' file; do
					TARGET_FILES+=("$file")
				done < <(find "$OPTARG" -type f -print0)
				;;
			f)
				OPT_GIVEN=1
				TARGET_FILES+=("$OPTARG")
				;;
			h)
				usage
				exit 0
				;;
			:|?)
				usage
				exit 1
				;;
		esac
	done
}

set_target_files() {
	local ext="$1"

	if [ "$OPT_GIVEN" -eq 0 ]; then
		while IFS= read -r -d '' file; do
			TARGET_FILES+=("$file")
		done < <(find . -type f -name "$ext" -print0)
	fi
}

parse_options "$@"

case "$MODE" in
"$SHELL")
	set_target_files "*.sh"
	;;
"$PYTHON")
	set_target_files "*.py"
	;;
*)
	echo "Unknown mode: $MODE"
	usage
	exit 1
	;;
esac

for file in "${TARGET_FILES[@]}"; do
	run_linter "$file"
done

exit "$RETURN_CODE"
