echo "Reset git "


cd plutosdr-fw
git reset --hard d9f8f24a28212b9e1e523d277820093301cea1a0
git clean -xf
git clean -df
cd ..

cd plutosdr-fw/hdl
git reset --hard d09fc920792c2c67ce5f28179d8263172d46fbdd
git clean -xf
git clean -df
cd ../..

cd plutosdr-fw/linux
git reset --hard b0ed105e9ab6c60ffd2ddafdfff6890b5cc46ed8
git clean -xf
git clean -df
cd ../..

cd plutosdr-fw/u-boot-xlnx
git reset --hard 90401ce9ce029e5563f4dface63914d42badf5bc
git clean -xf
git clean -df
cd ../..

cd plutosdr-fw/buildroot
git reset --hard b0ed105e9ab6c60ffd2ddafdfff6890b5cc46ed8
git clean -xf
git clean -df
cd ../..

echo "Reset git finish"