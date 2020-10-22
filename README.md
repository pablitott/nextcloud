# nextcloud in docker 

## Main docker scripts
Goal: create a Nextcloud website using docker 
* docker-compose.yml: main script to create the nextcloud
* docker-rebuild.sh: Used to rebuild the entire docker infraestructure
    * Stop containers
    * Remove Containers
    * Remove Images
    * Remove Volumes
    * Restore Containers

## Maintenance scripts
* saveScripts.sh: Save all the current scripts to AWS S3
* backup_nextcloud.sh: Backup nextcloud project files and database to aws s3

## Documentation (notes)
* DockerInAWs.md: Instructions to push/pull docker images to AWS ECS
* Docker-notes.md: Instructions and commands used in scripts 

## bash functions
* folderMaintenance.sh
    * removeFolder(folder): remove folder specified as argument 
    * createFolder(): remove folder specified as argument
* writeLogLine.sh: print out a colored to std output and a  log file **needs improvement**
