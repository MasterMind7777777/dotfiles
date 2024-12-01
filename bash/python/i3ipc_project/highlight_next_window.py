#!/home/mastermind/bash/python/i3ipc_project/i3ipc_venv/bin/python

import json
import subprocess

def get_focused_node(tree):
    if tree['focused']:
        return tree
    for node in tree['nodes']:
        focused_node = get_focused_node(node)
        if focused_node:
            return focused_node
    return None

def get_parent_orientation(focused_node, tree):
    for node in tree['nodes']:
        if node['id'] == focused_node['id']:
            return tree['orientation']
        orientation = get_parent_orientation(focused_node, node)
        if orientation:
            return orientation
    return None

i3_tree = json.loads(subprocess.check_output(['i3-msg', '-t', 'get_tree']).decode('utf-8'))

focused_node = get_focused_node(i3_tree)



if focused_node:
    if focused_node['orientation'] in ['horizontal', 'vertical']:
        orientation = focused_node['orientation']
    else:
        orientation = get_parent_orientation(focused_node, i3_tree)

    if orientation == 'horizontal':
        print("%{T2}➡%{T-}")  # or use an icon: "⬌"
    elif orientation == 'vertical':
        print("%{T2}⬇%{T-}")  # or use an icon: "⬍"
