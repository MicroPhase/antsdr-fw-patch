target=$1

cp ./patch/${target}/*hdl-support*.patch ./plutosdr-fw/hdl
cp ./patch/${target}/*linux-support.patch	./plutosdr-fw/linux
cp ./patch/${target}/*buildroot-support.patch	./plutosdr-fw/buildroot
cp ./patch/${target}/*makefile-script-support.patch ./plutosdr-fw/
cp ./patch/${target}/*uboot-support.patch	./plutosdr-fw/u-boot-xlnx

echo "Patch check..."
cd ./plutosdr-fw/hdl
git apply --stat *.patch
git apply --check *.patch
cd ../..

cd ./plutosdr-fw/u-boot-xlnx
git apply --stat *.patch
git apply --check *.patch
cd ../..

cd ./plutosdr-fw/linux
git apply --stat *.patch
git apply --check *.patch
cd ../..

cd ./plutosdr-fw/buildroot
git apply --stat *.patch
git apply --check *.patch
cd ../..

cd ./plutosdr-fw/
git apply --stat *.patch
git apply --check *.patch
cd ../

echo "Patch..."
cd ./plutosdr-fw/hdl
git apply *.patch
rm -rf *.patch
cd ../..

cd ./plutosdr-fw/u-boot-xlnx
git apply *.patch
rm -rf *.patch
cd ../..

cd ./plutosdr-fw/linux
git apply *.patch
rm -rf *.patch
cd ../..

cd ./plutosdr-fw/buildroot
git apply *.patch
rm -rf *.patch
cd ../..

cd ./plutosdr-fw/
git apply *.patch
rm -rf *.patch
cd ../

echo "patch finish"

