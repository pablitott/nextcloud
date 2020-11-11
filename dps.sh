function dps() { docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Size}}\t{{.Image}}"; }
