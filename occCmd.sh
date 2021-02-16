# example of use:
# occCmd quenchinnovations.local maintenance:mode --off
# occCmd mydeskweb.local user:list
# occCmd mydeskweb.local user:resetpassword admin
function occCmd() { docker exec -it --user www-data $1 php occ $2 $3 $4 $5; }
