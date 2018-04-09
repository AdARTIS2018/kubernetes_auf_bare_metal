export WLAN0_IP=`/bin/ifconfig wlp3s0b1 | grep 'inet ' | awk '{ print $2}'`
export ETH0_IP=` /bin/ifconfig enp1s0   | grep 'inet ' | awk '{ print $2}'`
export ETH1_IP=` /bin/ifconfig enp2s0   | grep 'inet ' | awk '{ print $2}'`

echo 'export HTTP_PROXY=http://dns:3128
export HTTPS_PROXY=https://dns:3128'>/etc/profile.d/PROXY.sh
echo 'export NO_PROXY='`echo ${ETH0_IP}`','`echo ${ETH1_IP}`','`echo ${WLAN0_IP}`',127.0.0.1,localhost'>>/etc/profile.d/PROXY.sh
