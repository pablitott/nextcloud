# Docker nextCloud custom scripts
## conventions
words among &lt; &gt; means an mandatory argument  
words among [ ] means optional argument  


## Docker Scripts
### dpService.sh
* dps:      Show the status for all containers
    * no arguments

* dms:      Show status for all active images
    * no arguments

* dpCoreTurn:   Turns up/down the core container nginx
    * dpCore up/down/stop/restart

* dpTurn:   turn up/down/pause/unpause/stop/restart specific container
    * dpTurn &lt;Server Name&gt; &lt;action&gt;

* dpStatus: Same as dps but for a specific container 
    * Syntax:  dpStatus [&lt;Server Name&gt;]

* dpStart:  Turn up/down whole services locally or production
    * dpStart &lt;action&gt; &lt;environment&gt;  
    where:
    action = up/down  
    environment = local/production
    * file services store the list of services to control, use # to ignore a line

* dpRestore  Restore service backed up using dpBackup
    * dpRestore &lt;Service Name&gt;
        - Service Name: is the name of the docker container

* dpBackup  Backup service
    * dpRestore &lt;Service Name&gt;
        - Service Name: is the name of the docker container

* dpKill:   Kills all containers, images and volumes in a all services 
     USE WITH EXTREME CAUTION
    * Syntax:  dpKill &lt;Service Name&gt;
## NextCloud Scripts

## Maintenance Scripts
* docker-compose-start.sh  : Up/Down all services
    syntax: docker-compose-start.sh &lt;action&gt; &lt;environment&gt;
    &gt;obsolete&lt; replaced by dpStart  function
* docker-rebuild.sh        : Stop/remove/start containers adn images associated


