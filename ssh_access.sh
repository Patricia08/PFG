#!/bin/bash

# ARGUMENTOS NECESARIOS
# 
project=$1
action=$2
nsd_pkg=$3  #tar.gz
vnfd_pkg=($4)
images=($5)


# action depende de si se ejecuta generate_scenario o delete_scenario
# images es un vector con las imagenes del escenario escogido
# project, es el proyecto de openstack sobre el que instanciamos


if [ $action = "upload" ]; then

#Pasar el paquete VNF de la maquina local a OSM 
sshpass -p patricia scp -o StrictHostKeyChecking=no /home/osm/packages_vnf/* patricia@192.168.159.5:/home/patricia/packages_PFG/packages_vnf/ > /dev/null 2>&1;
rm /home/osm/packages_vnf/*  #Borra los paquetes en local .19

#Pasar el paquete NSD de la maquina local a OSM
sshpass -p patricia scp -o StrictHostKeyChecking=no /home/osm/packages_ns/$nsd_pkg patricia@192.168.159.5:/home/patricia/packages_PFG/packages_ns/ > /dev/null 2>&1;
rm /home/osm/packages_ns/$nsd_pkg  #Borra los paquetes en local .19

fi

#Conexion con Openstack para subir o borrar las imagenes necesarias
sshpass -p openstack ssh -o StrictHostKeyChecking=no openstack@192.168.159.10 'bash -s' < /home/osm/mgmt-img.sh "$project" "$action" "${images[@]}"

#Conexion con OSM para subir o borrar los paquetes
sshpass -p patricia ssh -o StrictHostKeyChecking=no patricia@192.168.159.5 'bash -s' < /home/osm/mgmt-osm.sh "$action" "$nsd_pkg" "${vnfd_pkg[@]}" 

#BORRAR PAQUETES DE LA .5 UNA VEZ SUBIDOS
#sshpass -p patricia ssh -o StrictHostKeyChecking=no patricia@192.168.159.5 "rm /home/patricia/packages_PFG/packages_vnf/*" > /dev/null 2>&1;
#sshpass -p patricia ssh -o StrictHostKeyChecking=no patricia@192.168.159.5 "rm /home/patricia/packages_PFG/packages_ns/$nsd_pkg" > /dev/null 2>&1;

#Instanciar en OSM