# Obsolete
# Now this script is integrated in dpService.sh
function dps() { docker ps --format "table {{.ID}}\t{{.Names}}\t{{.State}}\t{{.Size}}\t{{.Image}}"; }
