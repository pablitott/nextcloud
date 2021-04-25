#service name for testing mydeskweb.local 
# script unfinished
serviceName=$1
serverName="${serviceName%.*}"

#download latest upgrade
wget -O ./temp/nextcloud-20.0.9.zip https://download.nextcloud.com/server/releases/nextcloud-20.0.9.zip
#backup curent server
#./backup_nextcloud.sh $serviceName
#stop web server
workingdir=$PWD 
cd $serverName
docker-compose --env-file $serviceName.env stop

cd $workingdir
if [ ! -d "/nextcloud/upgrade" ];
then
    echo "deleting upgrade... "
    sudo rm -r $/nextcloud/upgrade
    sudo mkdir /nextcloud/upgrade
fi
echo "exploding upgrade tar.bz2 file"
sudo tar -xpf ./temp/nextcloud-21.0.1.tar.bz2 -C /nextcloud/upgrade
if [ -d "/nextcloud/backup" ];
then
    echo "deleting backup... "
    sudo rm -r /nextcloud/backup
fi

sudo mkdir -p /nextcloud/$serviceName/html /nextcloud/backup/html
sudo mv /nextcloud/$serviceName/html /nextcloud/backup/html

echo "moving  /nextcloud/upgrade/nextcloud to /nextcloud/$serviceName... "
sudo rm -r /nextcloud/$serviceName/html
sudo mv  /nextcloud/upgrade/nextcloud/ /nextcloud/$serviceName/html

sudo cp /nextcloud/backup/config/config.php /nextcloud/$serviceName/config/config.php
sudo cp -r /nextcloud/backup/data/ /nextcloud/$serviceName/data/
sudo diff -r /nextcloud/$serviceName /nextcloud/backup/data

sudo chown -R www-data:www-data /nextcloud/$serviceName
sudo find /nextcloud/$serviceName/ -type d -exec chmod 750 {} \;
sudo find /nextcloud/$serviceName/ -type f -exec chmod 640 {} \;

cd $serverName
docker-compose --env-file mydeskweb/$serviceName.env start 
docker exec -it --user www-data $serviceName php occ upgrade

