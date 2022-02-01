# Obsolete
# Now this script is integrated in dpService.sh
function dms(){ docker images --format "table {{.ID}}\t{{.Repository}}\t{{.Tag}}\t{{.Size}}"; }