TMPDIR="/opt"
cd $TMPDIR

#Download utf-8 encoding capability on the omsagent container.

apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y locales

sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

wget https://github.com/Microsoft/OMS-Agent-for-Linux/releases/download/OMSAgent_v1.10.0-1/omsagent-1.10.0-1.universal.x64.sh

#create file to disable omi service startup script
touch /etc/.omi_disable_service_control

wget https://github.com/microsoft/Docker-Provider/releases/download/10.0.0-3/docker-cimprov-10.0.0-3.universal.x86_64.sh

chmod 775 $TMPDIR/*.sh

#Extract omsbundle
$TMPDIR/omsagent-*.universal.x64.sh --extract
mv $TMPDIR/omsbundle* $TMPDIR/omsbundle
#Install omi
/usr/bin/dpkg -i $TMPDIR/omsbundle/110/omi*.deb

#Install scx
/usr/bin/dpkg -i $TMPDIR/omsbundle/110/scx*.deb
#$TMPDIR/omsbundle/bundles/scx-1.6.*-*.universal.x64.sh --install

#Install omsagent

/usr/bin/dpkg -i $TMPDIR/omsbundle/110/omsagent*.deb
#/usr/bin/dpkg -i $TMPDIR/omsbundle/100/omsconfig*.deb

#Assign permissions to omsagent user to access docker.sock
sudo apt-get install acl

#download inotify tools for watching configmap changes
sudo apt-get update
sudo apt-get install inotify-tools -y

#used to parse response of kubelet apis
sudo apt-get install jq -y

#used to setcaps for ruby process to read /proc/env
echo "installing libcap2-bin"
sudo apt-get install libcap2-bin -y
#/$TMPDIR/omsbundle/oss-kits/docker-cimprov-1.0.0-*.x86_64.sh --install
#Use downloaded docker-provider instead of the bundled one

#download and install telegraf
#wget https://dl.influxdata.com/telegraf/releases/telegraf_1.10.1-1_amd64.deb
#sudo dpkg -i telegraf_1.10.1-1_amd64.deb

#service telegraf stop

wget https://github.com/microsoft/Docker-Provider/releases/download/5.0.0.0/telegraf

chmod 777 /opt/telegraf

/$TMPDIR/docker-cimprov-10.0.0-*.x86_64.sh --install

#download and install fluent-bit(td-agent-bit)
wget -qO - https://packages.fluentbit.io/fluentbit.key | sudo apt-key add -
sudo echo "deb https://packages.fluentbit.io/ubuntu/xenial xenial main" >> /etc/apt/sources.list
sudo apt-get update
sudo apt-get install td-agent-bit=1.4.2 -y

rm -rf $TMPDIR/omsbundle
rm -f $TMPDIR/omsagent*.sh
rm -f $TMPDIR/docker-cimprov*.sh
