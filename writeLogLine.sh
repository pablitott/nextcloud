set _color_grey_="\e[30m"
set _color_red_="\e[31m"
set _color_green_="\e[32m"
set _color_yellow_="\e[33m"
set _color_blue_="\e[0;34m"
set _color_purple_="\e[35m"
set _color_cyan_="\e[36m"
set _color_white_="\e[37m"
set _color_reset_="\e[0m"
#=================================================
function writeLogLine(){
  message=$1
  _color_message_=$_color_reset
  [ ! -z $2 ] && _color_message_=$2
      echo -e "$(date +"%Y-%m-%d %T") $_color_message_ $message $_color_reset_" | tee -a $logfile
}
#=================================================
