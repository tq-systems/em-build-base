#!/bin/bash
# Copyright (c) 2024 TQ-Systems GmbH <license@tq-group.com>
# D-82229 Seefeld, Germany. All rights reserved.
# Author:
#   Christoph Krutz

SCRIPT_NAME="$(basename "$0")"
MODE="$1"; shift
RETURN_CODE=0

SHELL="shell"
PYTHON="python"

usage() {
	echo "This script runs a linter on files with typical extensions.
Files without typical extension need to be specified.

Usage:
    $SCRIPT_NAME <mode>
    $SCRIPT_NAME <mode> <optional: -f folder> <optional: -f file>

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
	local mode="$1"
	local file="$2"

	if [ ! -f "$file" ]; then
		echo "File does not exist: $file"
		return
	fi

	echo "Run linter on $file"
	case "$mode" in
	"$SHELL")
		shellcheck "$file" || found_error
		;;
	"$PYTHON")
		pylint "$file" || found_error
		;;
	esac
}

# run linter for files with extension
# shellcheck disable=SC2044
# Use fragile for-find loop here because the other solutions are even more awful
case $MODE in
"$SHELL")
	for file in $(find . -type f -name '*.sh'); do
		run_linter "$MODE" "$file"
	done
	;;
"$PYTHON")
	for file in $(find . -type f -name '*.py'); do
		run_linter "$MODE" "$file"
	done
	;;
*)
	echo "Unkown mode: $MODE"
	usage
	exit 1
	;;
esac

# handle optional arguments
while getopts 'd:f:h' option; do
	case "$option" in
		d)
			# shellcheck disable=SC2044
			for file in $(find "$OPTARG" -type f); do
				run_linter "$MODE" "$file"
			done
			;;
		f)
			run_linter "$MODE" "$OPTARG"
			;;
		:|?)
			usage
			exit 1
			;;
	esac
done

exit "$RETURN_CODE"
