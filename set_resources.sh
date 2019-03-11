#!/bin/bash


vcpu=$1
ram=$2
storage=$3
vnf=$4


resources=($vcpu $ram $storage)
resources_name=(vcpu-count: memory-mb: storage-gb:)


cp /home/osm/vnf_descriptors/$vnf.yaml /home/osm/packages_vnf

file="/home/osm/packages_vnf/$vnf.yaml"


#for i in "${resources[@]}"
#do
#sed -i "s/\(${resources_name[j]}* *\).*/\1$[$i]/" $file
#echo $i
#j=$[$j+1] 

#done


