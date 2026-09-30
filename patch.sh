#!/bin/sh
# Apply the selected board patch set only after every preflight check succeeds.
set -eu

case "${1-}" in
ant | e200 | e310v2) target=$1 ;;
*)
    echo "Usage: $0 {ant|e200|e310v2}" >&2
    exit 2
    ;;
esac
[ "$#" -eq 1 ] || {
    echo "Expected exactly one target" >&2
    exit 2
}
root=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
fw="$root/plutosdr-fw"

check_or_apply() {
    operation=$1
    component=$2
    patch=$3
    directory="$fw/$component"
    [ -f "$patch" ] || {
        echo "Missing patch: $patch" >&2
        exit 1
    }
    [ -e "$directory/.git" ] || {
        echo "Missing source checkout: $directory; initialize recursive submodules" >&2
        exit 1
    }
    if [ "$operation" = check ]; then
        git -C "$directory" apply --check "$patch"
    else
        git -C "$directory" apply "$patch"
    fi
}

for operation in check apply; do
    check_or_apply "$operation" hdl "$root/patch/0001-add-three-ant-hdl-support-bump-to-v0.39-v1.patch"
    check_or_apply "$operation" u-boot-xlnx "$root/patch/$target/0001-add-support-uboot.patch"
    check_or_apply "$operation" linux "$root/patch/$target/0001-add-support-linux.patch"
    check_or_apply "$operation" buildroot "$root/patch/$target/0001-add-support-buildroot.patch"
    check_or_apply "$operation" . "$root/patch/$target/0001-add-support-makefile-scripts.patch"
done
printf 'Patch set applied successfully for %s\n' "$target"
