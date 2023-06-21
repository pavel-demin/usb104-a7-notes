source /opt/Xilinx/Vitis/2023.1/settings64.sh

JOBS=`nproc 2> /dev/null || echo 1`

make -j $JOBS cores

PRJS="led_blinker mcpha playground sdr_receiver sdr_receiver_hpsdr template"

printf "%s\n" $PRJS | xargs -n 1 -P $JOBS -I {} make NAME={} bit

tag=`date +%Y%m%d`

mkdir -p $tag/usb104-a7-apps-win32 $tag/gnuradio
mkdir -p $tag/notebooks $tag/playground $tag/template

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

dir=$tag/notebooks

cp tmp/led_blinker.bit $dir
cp tmp/playground.bit $dir
cp tmp/template.bit $dir
cp notebooks/01-led-blinker.ipynb $dir
cp notebooks/02-playground.ipynb $dir
cp notebooks/03-benchmarks.ipynb $dir
cp notebooks/04-zmod-template.ipynb $dir
cp notebooks/environment.yml $dir

dir=$tag/playground

cp -a cfg $dir
cp -a tmp/cores $dir
rm -rf $dir/cores/*.*
cp -a cores/common_modules $dir/cores
cp -a tmp/playground.gen $dir
cp -a tmp/playground.ip_user_files $dir
cp -a tmp/playground.srcs $dir
cp tmp/playground.xpr $dir
sed -i 's|Path=".*\.xpr"|Path="playground.xpr"|;s|\.\./||' $dir/playground.xpr

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

zip -r usb104-a7-notes-$tag.zip usb104-a7-apps-win32 gnuradio notebooks playground template

cd -
