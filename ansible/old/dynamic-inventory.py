#!/usr/bin/env python

'''
Example custom dynamic inventory script for Ansible, in Python.
https://github.com/geerlingguy/ansible-for-devops/blob/master/dynamic-inventory/custom/inventory.py
'''

import os
import sys
import argparse

try:
    import json
except ImportError:
    import simplejson as json

class ExampleInventory(object):

    def __init__(self):
        self.inventory = {}
        self.read_cli_args()

        # Called with `--list`.
        if self.args.list:
            self.inventory = self.example_inventory()
        # Called with `--host [hostname]`.
        elif self.args.host:
            # Not implemented, since we return _meta info `--list`.
            self.inventory = self.empty_inventory()
        # If no groups or vars are present, return empty inventory.
        else:
            self.inventory = self.empty_inventory()

        print json.dumps(self.inventory);

    # Example inventory for testing.
    def example_inventory(self):
        return{
          'app': {
            'hosts': ['35.240.77.53']
          },
          'db': {
            'hosts': ['35.205.82.205']
          },
          '_meta': {
            'hostvars': {
              '35.240.77.53': {
                'host_specific_var': 'bar'
            },
           '35.205.82.205': {
             'host_specific_var': 'foo'
           }
          }
         }
        }   

    # Empty inventory for testing.
    def empty_inventory(self):
        return {'_meta': {'hostvars': {}}}

    # Read the command line args passed to the script.
    def read_cli_args(self):
        parser = argparse.ArgumentParser()
        parser.add_argument('--list', action = 'store_true')
        parser.add_argument('--host', action = 'store')
        self.args = parser.parse_args()

# Get the inventory.
ExampleInventory()
