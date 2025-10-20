#!/usr/bin/env python3
import json, sys, yaml, pathlib, jinja2

# Read terraform output JSON
tf_json_path = pathlib.Path(__file__).with_name("tf.json")
data = json.loads(tf_json_path.read_text())

vm_ips = data.get("vm_private_ips", {}).get("value", {})
# Optional: admin_username = data.get("admin_username", {}).get("value")  # if needed

# Render hosts.yml using Jinja2
tpl_path = pathlib.Path(__file__).parents[1] / "templates" / "inventory.tpl.j2"
template = jinja2.Environment(
    loader=jinja2.FileSystemLoader(str(tpl_path.parent)),
    autoescape=False,
    trim_blocks=True,
    lstrip_blocks=True,
).get_template(tpl_path.name)

rendered = template.render(vm_ips=vm_ips)

out_path = pathlib.Path(__file__).parents[1] / "inventory" / "hosts.yml"
out_path.write_text(rendered)
print(f"Wrote {out_path}")