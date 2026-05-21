#!/bin/bash
# Copyright (c) 2026 TQ-Systems GmbH <license@tq-group.com>, D-82229 Seefeld, Germany. All rights reserved.
# Author: Robert Schütt and the Energy Manager development team

# This software is licensed under the TQ-Systems Product Software License Agreement Version 1.0.3 or any later version.
# You can obtain a copy of the License Agreement in the TQS (TQ-Systems Software Licenses) folder on the following website:
# https://www.tq-group.com/en/support/downloads/tq-software-license-conditions/
# In case of any license issues please contact license@tq-group.com.


# Integration tests for lint.sh

SCRIPT_DIR="$(realpath "$(dirname "$0")")"
LINT_SH="${SCRIPT_DIR}/lint.sh"

TMPDIR="$(mktemp -d)"
RETURN_CODE=0

# shellcheck disable=SC2317  # Don't warn about unreachable commands in cleanup()
cleanup() {
	rm -rf "$TMPDIR"
}
trap cleanup EXIT

pass() { echo "PASS: $*"; }
fail() { echo >&2 "FAIL: $*"; RETURN_CODE=1; }

assert_exit_zero() {
	local desc="$1"; shift
	local rc
	"$@"; rc=$?
	if [[ $rc -eq 0 ]]; then pass "$desc"; else fail "$desc"; fi
}

assert_exit_nonzero() {
	local desc="$1"; shift
	local rc
	"$@"; rc=$?
	if [[ $rc -ne 0 ]]; then pass "$desc"; else fail "$desc"; fi
}

# --- Create fixture files ---
# Keep shell and Python files in separate dirs so -d mode does not feed
# .sh files to pylint or .py files to shellcheck.

mkdir -p "$TMPDIR/sh_clean" "$TMPDIR/sh_bad" "$TMPDIR/py_clean" "$TMPDIR/py_bad"

# Valid shell script
cat > "$TMPDIR/sh_clean/good.sh" << 'EOF'
#!/bin/bash
echo "hello"
EOF

# Invalid shell script (SC2086: unquoted variable)
cat > "$TMPDIR/sh_bad/bad.sh" << 'EOF'
#!/bin/bash
VAR="hello world"
echo $VAR
EOF

# Valid Python file
cat > "$TMPDIR/py_clean/good.py" << 'EOF'
"""A valid Python module."""
EOF

# Invalid Python file (E0602: undefined-variable)
cat > "$TMPDIR/py_bad/bad.py" << 'EOF'
"""A Python module with an undefined variable."""
print(undefined_variable)
EOF

# --- Tests: -f (single file) ---

assert_exit_zero    "shell:  -f good.sh"            "$LINT_SH" shell  -f "$TMPDIR/sh_clean/good.sh"
assert_exit_nonzero "shell:  -f bad.sh"             "$LINT_SH" shell  -f "$TMPDIR/sh_bad/bad.sh"
assert_exit_zero    "python: -f good.py"            "$LINT_SH" python -f "$TMPDIR/py_clean/good.py"
assert_exit_nonzero "python: -f bad.py"             "$LINT_SH" python -f "$TMPDIR/py_bad/bad.py"

# --- Tests: -d (directory) ---

assert_exit_zero    "shell:  -d sh_clean"           "$LINT_SH" shell  -d "$TMPDIR/sh_clean"
assert_exit_nonzero "shell:  -d sh_bad"             "$LINT_SH" shell  -d "$TMPDIR/sh_bad"
assert_exit_zero    "python: -d py_clean"           "$LINT_SH" python -d "$TMPDIR/py_clean"
assert_exit_nonzero "python: -d py_bad"             "$LINT_SH" python -d "$TMPDIR/py_bad"

# --- Tests: no-args (full scan of cwd by extension) ---

pushd "$TMPDIR/sh_clean" > /dev/null || exit 1
assert_exit_zero    "shell:  no-args good dir"      "$LINT_SH" shell
popd > /dev/null || exit 1

pushd "$TMPDIR/sh_bad" > /dev/null || exit 1
assert_exit_nonzero "shell:  no-args has bad"       "$LINT_SH" shell
popd > /dev/null || exit 1

pushd "$TMPDIR/py_clean" > /dev/null || exit 1
assert_exit_zero    "python: no-args good dir"      "$LINT_SH" python
popd > /dev/null || exit 1

pushd "$TMPDIR/py_bad" > /dev/null || exit 1
assert_exit_nonzero "python: no-args has bad"       "$LINT_SH" python
popd > /dev/null || exit 1

# --- Tests: TQEM_PYLINT_OPTIONS ---
# Disabling E0602 should make the bad.py pass
assert_exit_zero    "python: -f bad.py with E0602 disabled" \
	env TQEM_PYLINT_OPTIONS="--disable=E0602" "$LINT_SH" python -f "$TMPDIR/py_bad/bad.py"
# Without the option the bad.py must still fail
assert_exit_nonzero "python: -f bad.py without options" \
	env TQEM_PYLINT_OPTIONS="" "$LINT_SH" python -f "$TMPDIR/py_bad/bad.py"

# --- Tests: -h (help) ---

assert_exit_zero    "help flag"                     "$LINT_SH" shell -h

# --- Tests: unknown mode ---

assert_exit_nonzero "unknown mode"                  "$LINT_SH" badmode

exit "$RETURN_CODE"
