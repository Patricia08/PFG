#!/bin/bash

source admin-openrc

project=$1
action=$2

arr=( "$@" )
all_vnf_images=("${arr[@]:2}")

#Crea un array de imagenes sin imagenes repetidas para que no intente subir dos veces la misma imagen.
eval images=($(for i in  "${all_vnf_images[@]}" ; do  echo "\"$i\"" ; done | sort -u))

#Coge las imagenes del NFS montado en la .10

for image_name in "${images[@]}"
do
  #corta el nombre de la imagen si es tipo example.img para quitar la extension
  image_shortname=`echo "$image_name" | rev | cut -d"." -f2-  | rev`

  if [ $action = "upload" ]; then
  	if openstack image list --name $image_shortname | grep $image_shortname > /dev/null 2>&1; then
      		echo "Image:$image_shortname already exists"
  	else
      		echo "Uploading image:$image_shortname"
      		openstack image create --project $project --disk-format qcow2 --container-format bare --file /home/openstack/imagesPFG/$image_name $image_shortname
    fi

  elif [ $action = "delete" ]; then
  	if openstack image list --name $image_shortname | grep $image_shortname > /dev/null 2>&1; then
          echo "Deleting image:$image_shortname"
  	openstack image delete $image_shortname

    else
          echo "Cannot delete image: $image_shortname. It does not exist"
    fi
  fi
  
done
