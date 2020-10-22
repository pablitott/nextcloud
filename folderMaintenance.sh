source ./writeLogLine.sh
function removeFolder(){
  folder=$1
  if [ -d $folder ]; then 
    writeLogLine "$output_blue Removing temporal local $folder $output_reset"
    sudo rm -r $folder
  fi
}
#================================================================================
function createFolder(){
  folder=$1
  if [ ! -d $folder ]; then 
    writeLogLine "$output_blue Creating temporal local $folder $output_reset"
    sudo mkdir -p $folder
    sudo chown -R $USER:$USER $folder
  fi
}
#================================================================================
