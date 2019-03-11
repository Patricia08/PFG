#!/usr/bin/python3

"""
Usage:
  delete_scenario.py
  delete_scenario.py options

Options:
  -h, --help                    # Show this message
  -t <text>, --template <text>  # Template name

"""

from docopt import docopt, DocoptExit
#Import necessary functions from Jinja2 module
from jinja2 import Environment, FileSystemLoader
#Import YAML module
import yaml
import pprint
import subprocess

#Load Jinja2 template
def load_template(template):
    env = Environment(loader = FileSystemLoader('templates'), trim_blocks=True, lstrip_blocks=True)
    return env.get_template(template)

#Coger las variables del usuario
arguments = docopt(__doc__)

init_template=load_template("template-"+arguments['--template']+".yaml")

scenario_content = init_template.render(clients=1,servers=1,proxy=1)

#Load data from init YAML into Python dictionary
config_data = yaml.load(scenario_content)

vnfs=[]
images=[]
#for que recorre las vnfs que participan en el escenario, leyendo de template-X.yaml y almacenandolas en un array (vnfs). Lo mismo con las imagenes
for i in range(len(config_data['vnfs'])):
  vnfs.append(config_data['vnfs'][i]['type']) #Lista de vnfs para luego pasarlas al ssh_access.sh
  images.append(config_data['vnfs'][i]['image']) #Lista de imagenes para luego pasarlas al ssh_access.sh

subprocess.call(["./ssh_access.sh", "PFG-Patricia", "delete", arguments['--template']+"_nsd.tar.gz", ' '.join(vnfs), ' '.join(images)])