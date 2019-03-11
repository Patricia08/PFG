#!/usr/bin/python3

"""
Usage:
  generate_descriptor.py
  generate_descriptor.py options

Options:
  -h, --help                    # Show this message
  -t <text>, --template <text>  #Template name
  -c <num>, --clients <num>     #Number clients [default: 1]
  -s <num>, --servers <num>     #Number servers [default: 1]
  -p <num>, --proxy <num>       #Number proxies [default: 1]
  -r <num>, --ram <num>         #Memory RAM for the vnf [default: 2048]
  -v <num>, --vcpu <num>        #Number cpus [default: 1]
  -d <num>, --storage <num>     #Disk [default: 20]
"""

from docopt import docopt, DocoptExit

#Import necessary functions from Jinja2 module
from jinja2 import Environment, FileSystemLoader
import pprint
#Import YAML module
import yaml
import subprocess

#Load Jinja2 template
def load_template(template, templatetype):
    if templatetype == 'nsd':
      env = Environment(loader = FileSystemLoader('templates'), trim_blocks=True, lstrip_blocks=True)
    if templatetype == 'vnfd':
      env = Environment(loader = FileSystemLoader('templates/vnf_templates'), trim_blocks=True, lstrip_blocks=True)
    
    return env.get_template(template)


#####
#Coger las variables del usuario
arguments = docopt(__doc__)

#Load templates
init_template=load_template("template-"+arguments['--template']+".yaml", 'nsd')
descriptor_template=load_template('nsd.yaml', 'nsd')


#Write data from arguments into YAML template
scenario_content = init_template.render(clients=int(arguments['--clients']),servers=int(arguments['--servers']),proxy=int(arguments['--proxy']))

#Load data from init YAML into Python dictionary
config_data = yaml.load(scenario_content)


vnfs=[]
images=[]
#set resources vnf. Esto lleva un for que recorre las vnfs que participan en el escenario, leyendo de template-X.yaml
for i in range(len(config_data['vnfs'])):
  vnfs.append(config_data['vnfs'][i]['type']) #Lista de vnfs para luego pasarlas al ssh_access.sh
  images.append(config_data['vnfs'][i]['image']) #Lista de imagenes para luego pasarlas al ssh_access.sh

  vnftype = config_data['vnfs'][i]['type']
  
  #Write resources data from arguments into vnf YAML template
  vnf_template=load_template(vnftype+".yaml", 'vnfd')
  descriptor_file=open("/home/osm/vnf_descriptors/"+vnftype+".yaml", "w+")
  descriptor_file.write(vnf_template.render(vcpu_count=int(arguments['--vcpu']),memory_mb=int(arguments['--ram']),storage_gb=int(arguments['--storage'])))
  descriptor_file.close()
  
  #generar paquetes vnf
  subprocess.call(["./generate_packages.sh", "vnfd", vnftype, "packages_vnf"])


#Render the template with data and write the output in the descriptor file
descriptor_file=open("/home/osm/ns_descriptors/"+arguments['--template']+".yaml", "w+")
descriptor_file.write(descriptor_template.render(config_data))
descriptor_file.close()

#Generar paquete ns
subprocess.call(["./generate_packages.sh", "nsd", arguments['--template'], "packages_ns"])

#Subir imagenes necesarias a openstack y los paquetes a osm.
subprocess.call(["./ssh_access.sh", "PFG-Patricia", "upload", arguments['--template']+"_nsd.tar.gz", ' '.join(vnfs), ' '.join(images)])
vnfs.clear()
images.clear()
