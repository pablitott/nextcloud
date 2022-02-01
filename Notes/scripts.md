# Docker nextCloud custom scripts
## conventions
words among &lt; &gt; means an mandatory argument  
words among [ ] means optional argument  


## Docker Scripts
### dpService.sh
* dps:      Show the status for all containers
    * no arguments
* dpTurn:   turn up/down/pause/unpause/stop specific container
    * dpTurn &lt;Server Name&gt; &lt;action&gt;
* dpStatus: Same as dps but for a specific container 
    * Syntax:  dpStatus [&lt;Server Name&gt;]
* dpStart:  Turn up/down whole services loally or production
    * dpStart &lt;action&gt; &lt;<environment&gt;  
    where:
    action = up/down  
    environment = local/production
    * file services store the list of services to control, use # to ignore a line

## NextCloud Scripts

## Maintenance Scripts
* docker-compose-start.sh  : Up/Down all services
    syntax: docker-compose-start.sh &lt;action&gt; &lt;environment&gt;
* docker-rebuild.sh        : Stop/remove/start containers adn images associated


todo: include in .bashrc 
    export WORKINGDIR=$HOME/nextcloud