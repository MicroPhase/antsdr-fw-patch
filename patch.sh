target=$1

cp ./patch/*v0.39.patch ./plutosdr-fw/hdl
cp ./patch/${target}/*linux.patch	./plutosdr-fw/linux
cp ./patch/${target}/*buildroot.patch	./plutosdr-fw/buildroot
cp ./patch/${target}/*scripts.patch ./plutosdr-fw/
cp ./patch/${target}/*uboot.patch	./plutosdr-fw/u-boot-xlnx

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

