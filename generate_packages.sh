#!/bin/bash
# From https://osm.etsi.org/wikipub/index.php/Release_0_Data_Model_Details
# Supported folders for VNFD
# cloud_init - Rel 4.3, not yet part of OSM
VNFD_FOLDERS=(images scripts icons charms cloud_init)

# Supported folders for NSD
# OSM document specifies (ns|vnf)-config folder, while Rel 4.3
# is using (ns|vnf)_config.
NSD_FOLDERS=(scripts icons ns_config vnf_config)

CHKSUM='checksums.txt'

function add_chksum() {

  file=${dir}/$CHKSUM
  echo "INFO: Add file $yaml to $CHKSUM"

  md5sum $dir/$yaml >> $file

}

function write_readme() {

    file=${dir}/README
    date=$(date)

    cat >$file <<EOF
Descriptor created by OSM descriptor package generated
Created on $date
EOF

}

function generate_package(){

    # Create the folders for the descriptor

    echo "INFO: Creating folders for $yaml in $dir"

    # Remove any existing directory
    if [ -d $dir ]; then
        rm -rf $dir >/dev/null 2>&1
    fi

    mkdir -p $dir && cd $dir

    if [ $? -ne 0 ]; then
        rc=$?
        echo "ERROR: creating directory $dir ($rc)" >&2
        exit $rc
    fi

    cd /home/osm #solucion rapida. MIRARLO

    if [ $type == 'nsd' ]; then
        folders=("${NSD_FOLDERS[@]}")
        cp /home/osm/ns_descriptors/$yaml $dir
    elif [ $type == 'vnfd' ]; then
        folders=("${VNFD_FOLDERS[@]}")
        mv /home/osm/vnf_descriptors/$yaml $dir
    fi

    for d in ${folders[@]}; do
        mkdir -p $dir/$d
    done

    add_chksum
    write_readme

    cd $dest_dir
    tar -zcf ${name}.tar.gz ${name} --remove-files
    echo "Created package ${name}.tar.gz in $dest_dir"
}

    type=$1
    yaml="${2}.yaml"
    name="${2}_${type}"
    vnfd="${2}_vnfd" # Required for NSD
    dest_dir=$3
    dir="${dest_dir}/${name}"

generate_package
