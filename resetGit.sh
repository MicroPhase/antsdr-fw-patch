echo "Reset git v0.39 "


cd plutosdr-fw
git reset --hard 9e90bce43f849882cd43c20a08effca132790fb3
git clean -xf
git clean -df
cd ..

cd plutosdr-fw/hdl
git reset --hard 065c8f186ef87ff049d279ed5859ee8d97d91808
git clean -xf
git clean -df
rm ./library/axi_vcxo_ctrl/ -rf
cd ../..

cd plutosdr-fw/linux
git reset --hard f3da30df60047dc5a0b8fa8c640be774e0f784d9
git clean -xf
git clean -df
cd ../..

cd plutosdr-fw/u-boot-xlnx
git reset --hard 90401ce9ce029e5563f4dface63914d42badf5bc
git clean -xf
git clean -df
cd ../..

cd plutosdr-fw/buildroot
git reset --hard e783aadccebad3413b3d60fcfe98a25eb395d839
git clean -xf
git clean -df
cd ../..

echo "Reset git finish"
