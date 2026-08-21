#!/bin/sh

# Apply the firmware patches in filename order. Stop at the first failure so
# a successful exit always means that every requested patch was applied.
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
target=${1-}

if [ -z "$target" ] || [ ! -d "$SCRIPT_DIR/patch/$target" ]; then
	echo "Usage: $0 <target>" >&2
	exit 2
fi

apply_patch_group() {
	repository=$1
	shift
	found=0

	for patch in "$@"; do
		[ -f "$patch" ] || continue
		found=1
		echo "Checking $(basename "$patch")"
		git -C "$repository" apply --check "$patch"
		git -C "$repository" apply --stat "$patch"
		git -C "$repository" apply "$patch"
	done

	if [ "$found" -eq 0 ]; then
		echo "No patches found for $repository" >&2
		exit 1
	fi
}

echo "Applying patches for $target..."
apply_patch_group "$SCRIPT_DIR/plutosdr-fw/hdl" \
	"$SCRIPT_DIR"/patch/*v0.38.patch
apply_patch_group "$SCRIPT_DIR/plutosdr-fw/u-boot-xlnx" \
	"$SCRIPT_DIR"/patch/"$target"/*uboot.patch
apply_patch_group "$SCRIPT_DIR/plutosdr-fw/linux" \
	"$SCRIPT_DIR"/patch/"$target"/*linux.patch
apply_patch_group "$SCRIPT_DIR/plutosdr-fw/buildroot" \
	"$SCRIPT_DIR"/patch/"$target"/*buildroot.patch
apply_patch_group "$SCRIPT_DIR/plutosdr-fw" \
	"$SCRIPT_DIR"/patch/"$target"/*scripts.patch

echo "Patch application finished successfully"
