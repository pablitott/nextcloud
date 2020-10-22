output_red="\e[31m"
output_green="\e[32m"
output_yellow="\e[33m"
output_blue="\e[34m"
output_reset="\e[0m"

#=================================================
function writeLogLine(){
  message=$1
  echo -e "$(date +"%Y-%m-%d %T") $message" | tee -a $logfile
}
#=================================================
