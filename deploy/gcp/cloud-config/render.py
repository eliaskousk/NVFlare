import argparse
import yaml
from jinja2 import Environment, FileSystemLoader

parser = argparse.ArgumentParser(description="Cloud Config Generator")
parser.add_argument("--partyconfig", default="parties.yml", type=str, help="party config")
parser.add_argument("--partyname", default="vt", type=str, help="party name")
parser.add_argument("--serverip", default="10.164.15.1", type=str, help="server ip")
parser.add_argument("--demoscript", default="run_experiments_s1.sh", type=str, help="demo script")
parser.add_argument("--demoargs", default="cifar10", type=str, help="demo script arguments")
parser.add_argument("--gpu", "-g", action="store_true", help="use GPU")
args = parser.parse_args()

if args.partyname == "vt":
    if args.gpu:
        template_file = "vt-gpu.tpl"
    else:
        template_file = "vt-cpu.tpl"
else:
    if args.gpu:
        template_file = "site-gpu.tpl"
    else:
        template_file = "site-cpu.tpl"

env = Environment(loader=FileSystemLoader("."))
template = env.get_template(template_file)

with open(args.partyconfig) as f:
    party_yml = yaml.safe_load(f)

for party in party_yml["parties"]:
    if party["name"] == args.partyname:
        party["server_ip"] = args.serverip
        party["demo_script"] = args.demoscript
        party["demo_args"] = args.demoargs
        party_config_file = f"{party['name']}.cfg"
        with open(party_config_file, "w") as f:
            f.write(template.render(party))
