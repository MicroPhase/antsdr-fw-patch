echo "Reset git "


cd plutosdr-fw
git reset --hard 0359a0b9a474567ab658619f3edf53ac65594f5a
git clean -xf
git clean -df
cd ..

cd plutosdr-fw/hdl
git reset --hard 1978df2985ce230f3a50b717accd7066609866ec
git clean -xf
git clean -df
cd ../..

cd plutosdr-fw/linux
git reset --hard e14e351533f934047ba0473e836e561682ec67fe
git clean -xf
git clean -df
cd ../..

cd plutosdr-fw/u-boot-xlnx
git reset --hard 90401ce9ce029e5563f4dface63914d42badf5bc
git clean -xf
git clean -df
cd ../..

cd plutosdr-fw/buildroot
git reset --hard f70f4aff40bcc16e3d9a920984d034ad108f4993
git clean -xf
git clean -df
cd ../..

echo "Reset git finish"