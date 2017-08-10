# TODO

VRAC
* on peut pas "scoper" la discovery exposée aux containers que l'on run (ou alors j'ai pas trouvé comment..), donc par exemple, mon nginx qui sert une app statique peut énumérer les backends redis d'un autre job à coté
* j'ai pas trouvé comment on fait de l'authn et de l'authz sur l'API qu'il expose.. du coup pour le faire piloter par une CI publique, c'est laid.. on peut bien tricher en collant un LB devant et en bricolant de l'auth basic, mais c'est laid je trouve..
* on peut pas facilement (ou alors, j'ai pas trouvé comment) avoir un réseau par job que l'on run, ou assigner des jobs à des réseaux (comme swarm mode le fait via VXLAN).. du coup on a soit tous les dockers qui peuvent se contacter en direct, soit personne ne peut se contacter ..

si qqun a des idées ou des réponses, je prends.. j'aime bien le reste de l'outil, mais ces limitations sur l'authz/authn et la partie réseau me genent beaucoup trop pour proposer nomad


* puit de log sur ES unique avec kibana sur même instance
* configuration rsyslog général pour pointer tout chez puit de log
* ELB unique vers multi-instances traefik
* traefik internal ?
* gérer les mappings regionaws=>region_consul/nomad
* gérer les mappings aws-az => dc_consul/nomad
* gérer le multi-region avec awareness

assainir les security group, regrouper pour faire des ranges

faire LB les masters nomad via traefik

hashiUI


by node type
    dashboard agrégé uniquement health checks
    capacité restante Nomad Workers
    capacité consommé Nomad Workers

2nd entry points pour admin services

Stockage distribué: Bastien
Sébastien cas appli

Testers: Micka & Maxence

