source ./writeLogLine.sh
function removeFolder(){
  folder=$1
  if [ -d $folder ]; then 
    writeLogLine "$_color_yellow_ Removing temporal local $folder"
    sudo rm -r $folder
  fi
}
#================================================================================
function createFolder(){
  folder=$1
  if [ ! -d $folder ]; then 
    writeLogLine "$_color_yellow_ Creating temporal local $folder"
    sudo mkdir -p $folder
    sudo chown -R $USER:$USER $folder
  fi
}
#================================================================================
