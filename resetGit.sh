echo "Reset git "


cd plutosdr-fw
git reset --hard 714cd8aaeadfa30aecd6d8235d5076a3f7b8e5e3
git clean -xf
git clean -df
cd ..

cd plutosdr-fw/hdl
git reset --hard d09fc920792c2c67ce5f28179d8263172d46fbdd
git clean -xf
git clean -df
cd ../..

cd plutosdr-fw/linux
git reset --hard 9dfba10b795d0004ae90f2ab29dac0197c8a3b3e
git clean -xf
git clean -df
cd ../..

cd plutosdr-fw/u-boot-xlnx
git reset --hard 90401ce9ce029e5563f4dface63914d42badf5bc
git clean -xf
git clean -df
cd ../..

cd plutosdr-fw/buildroot
git reset --hard 6d681cb26d2722608e8d90c9a530b518a90a502c
git clean -xf
git clean -df
cd ../..

echo "Reset git finish"