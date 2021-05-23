function dps() { docker ps $1 --format "table {{.ID}}\t{{.Names}}\t{{.Size}}\t{{.Image}}\t{{.State}}"; }
