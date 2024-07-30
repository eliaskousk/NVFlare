import argparse
import yaml
from jinja2 import Environment, FileSystemLoader

parser = argparse.ArgumentParser(description="Cloud Config Generator")
parser.add_argument("--partyconfig", default="parties.yml", type=str, help="party config")
parser.add_argument("--partyname", default="vt", type=str, help="party name")
parser.add_argument("--serverip", default="10.164.15.1", type=str, help="server ip")
parser.add_argument("--serveripcl", default="10.164.15.1", type=str, help="server ip")
parser.add_argument("--demoscript", default="run_experiments_s1.sh", type=str, help="demo script")
parser.add_argument("--demoargs", default="cifar10", type=str, help="demo script arguments")
parser.add_argument("--container", "-c", action="store_true", help="use container")
parser.add_argument("--gpu", "-g", action="store_true", help="use GPU")
args = parser.parse_args()

container_suffix = "-container" if args.container else ""

if args.partyname == "vt":
    template_file = f"vt{container_suffix}.tpl"
else:
    template_file = f"site{container_suffix}.tpl"

env = Environment(loader=FileSystemLoader("."))
template = env.get_template(template_file)

with open(args.partyconfig) as f:
    party_yml = yaml.safe_load(f)

for party in party_yml["parties"]:
    if party["name"] == args.partyname:
        party["server_ip"] = args.serverip
        party["server_ip_client"] = args.serveripcl
        party["demo_script"] = args.demoscript
        party["demo_args"] = args.demoargs.replace("\"", "\\\"").replace(",", "\\,")
        party_config_file = f"{party['name']}.sh"
        with open(party_config_file, "w") as f:
            f.write(template.render(party))
