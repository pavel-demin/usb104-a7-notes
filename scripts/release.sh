source /opt/Xilinx/Vitis/2020.2/settings64.sh

JOBS=`nproc 2> /dev/null || echo 1`

make -j $JOBS cores

make NAME=template xpr

PRJS="mcpha sdr_receiver sdr_receiver_hpsdr"

printf "%s\n" $PRJS | xargs -n 1 -P $JOBS -I {} make NAME={} bit

tag=`date +%Y%m%d`

mkdir -p $tag/usb104-a7-apps-win32 $tag/gnuradio $tag/template

dir=$tag/usb104-a7-apps-win32

tar -zxf dist-python38-win32.tgz --strip-components=1 --directory=$dir

cp zadig-2.8.exe $dir
cp tmp/mcpha.bit tmp/sdr_receiver.bit tmp/sdr_receiver_hpsdr.bit $dir
cp projects/mcpha/ui/mcpha.py $dir
cp projects/mcpha/ui/*.ui $dir
cp projects/sdr_receiver/server/sdr-receiver.py $dir
cp projects/sdr_receiver/server/sdr-receiver.ui $dir
cp projects/sdr_receiver_hpsdr/server/sdr-receiver-hpsdr.py $dir
cp projects/sdr_receiver_hpsdr/server/sdr-receiver-hpsdr.ui $dir
cp $dir/exec.exe $dir/mcpha.exe
cp $dir/exec.exe $dir/sdr-receiver.exe
cp $dir/exec.exe $dir/sdr-receiver-hpsdr.exe
rm -f $dir/exec.exe

dir=$tag/gnuradio

cp tmp/sdr_receiver.bit $dir
cp projects/sdr_receiver/gnuradio/fm_usb.grc $dir
cp projects/sdr_receiver/gnuradio/fm_zmq.grc $dir

dir=$tag/template

cp -a cfg $dir
cp -a tmp/cores $dir
rm -rf $dir/cores/*.*
cp -a cores/common_modules $dir/cores
cp -a tmp/template.gen $dir
cp -a tmp/template.ip_user_files $dir
cp -a tmp/template.srcs $dir
cp tmp/template.xpr $dir
sed -i 's|Path=".*\.xpr"|Path="template.xpr"|;s|\.\./||' $dir/template.xpr

cd $tag

zip -r usb104-a7-notes-$tag.zip usb104-a7-apps-win32 gnuradio template

cd -
