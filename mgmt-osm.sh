#!/bin/bash

export OSM_HOSTNAME=127.0.0.1
export OSM_SOL005=True

action=$1
nsd_pkg=$2

arr=( "$@" )
vnfd_pkg=("${arr[@]:2}")

if [ $action = "upload" ]; then

  for vnfd_pkg in "${vnfd_pkg[@]}"
  do

    if [ "$(osm vnfpkg-show $vnfd_pkg)" = "vnfd $vnfd_pkg not found" ] > /dev/null 2>&1; then
     
      echo "Uploading VNF package:$vnfd_pkg"
      osm vnfd-create /home/patricia/packages_PFG/packages_vnf/$vnfd_pkg"_vnfd.tar.gz"
      rm /home/patricia/packages_PFG/packages_vnf/$vnfd_pkg"_vnfd.tar.gz" > /dev/null 2>&1; #Borrar paquete de local (.5) una vez subido


    else

      echo "VNF package:$vnfd_pkg already exists"

    fi

  done

  #Coge el nombre del nsd package y lo corta: Ej A_nsd.tar.gz --> A
  nsd_name=`echo "$nsd_pkg" | rev | cut -d"_" -f2-  | rev`

  if osm nspkg-list | grep $nsd_name > /dev/null 2>&1; then

    echo "NS package:$nsd_name already exists"

  else

    echo "Uploading NS package:$nsd_pkg"
    osm nsd-create /home/patricia/packages_PFG/packages_ns/$nsd_pkg
    rm /home/patricia/packages_PFG/packages_ns/$nsd_pkg > /dev/null 2>&1; #Borrar paquete de local (.5) una vez subido

  fi
  
  #Instantiate
  osm ns-create --nsd_name $nsd_name --ns_name $nsd_name --vim_account pfg-openstack

elif [ $action = "delete" ]; then

  #Coge el nombre del nsd package y lo corta: Ej A_nsd.tar.gz --> A
  nsd_name=`echo "$nsd_pkg" | rev | cut -d"_" -f2-  | rev`
  
  #Delete scenario
  osm ns-delete $nsd_name

  if osm nspkg-list | grep $nsd_name > /dev/null 2>&1; then
    echo "Deleting NS package:$nsd_pkg"
    osm nsd-delete $nsd_name  # cuidado "_nsd"

  else
    echo "NS package:$nsd_pkg does not exist"
  fi

  for vnfd_pkg in "${vnfd_pkg[@]}"
  do

    if osm vnfpkg-list | grep $vnfd_pkg > /dev/null 2>&1; then

      echo "Deleting VNF package:$vnfd_pkg"
      osm vnfd-delete $vnfd_pkg

    else

      echo "VNF package:$vnfd_pkg does not exist"

    fi

  done

fi



#osm nspkg-delete $nsd_name

#for vnfd_pkg in "${vnfd_pkg[@]}"

#do
#    vnf_name=`echo "$vnfd_pkg" | rev | cut -d"_" -f2-  | rev`
#    osm vnfpkg-delete $vnf_name
#done
