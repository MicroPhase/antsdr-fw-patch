echo "Reset git "


cd plutosdr-fw
git reset --hard cbe7306055828ce0a12a9da35efc6685c86f811f
git clean -xf
git clean -df
cd ..

cd plutosdr-fw/hdl
git reset --hard 43cdc6263baf3edb166a3def6fab15bc81c4c729
git clean -xf
git clean -df
cd ../..

cd plutosdr-fw/linux
git reset --hard 9c04de11ae53e7c48b57e6153b4a0df241e094ad
git clean -xf
git clean -df
cd ../..

cd plutosdr-fw/u-boot-xlnx
git reset --hard a2c2013a86231af6a61d6e7dca6c1e28a3bc57bf
git clean -xf
git clean -df
cd ../..

cd plutosdr-fw/buildroot
git reset --hard 35af596319b86d4e8fe266330cc0b00340d9f584
git clean -xf
git clean -df
cd ../..

echo "Reset git finish"