# -*- coding: utf-8 -*-

from configparser import ConfigParser

import requests


def migrate_to_plone52(site=None,):
    config = Config('site_to_migrate')
    objects_tree = recursive_explore(**config.source)
    if config.destination['clean']:
        clean_site(**config.destination)
    recursive_create(objects_tree=objects_tree['items'], **config.destination)


def recursive_explore(url='', login='', password='', result=[]):
    """
    Explore the whole site and return the whole tree of items an sub-items
    from the root 'url' as list of nested dicts.
    The sub-items are in the key 'items'.
    """
    headers = {'Accept': 'application/json'}
    auth = (login, password)
    resp = requests.get(url, headers=headers, auth=auth)
    container = resp.json()
    subobjects = container.pop('items', [])
    container['items'] = []
    print('exploring {}'.format(container['@id']))
    for subobject in subobjects:
        subobject_info = recursive_explore(subobject['@id'], login, password)
        container['items'].append(subobject_info)
    return container


def clean_site(url='', login='', password='', **kwargs):
    """ """
    headers = {'Accept': 'application/json'}
    auth = (login, password)
    site = requests.get(url, headers=headers, auth=auth).json()
    subobjects = site.pop('items', [])
    for subobject in subobjects:
        requests.delete(subobject['@id'], headers=headers, auth=auth)
        print('deleted {}'.format(subobject['@id']))


def recursive_create(url='', login='', password='', objects_tree=[], **kwargs):
    """ """
    headers = {'Accept': 'application/json'}
    auth = (login, password)
    for obj_args in objects_tree:
        sub_obj_tree = obj_args.pop('items', [])
        resp = requests.post(url, headers=headers, auth=auth, json=obj_args)
        created_obj = resp.json()
        print('created {}'.format(created_obj['@id']))
        if obj_args['@type'] not in ['Collection']:
            recursive_create(created_obj['@id'], login, password, objects_tree=sub_obj_tree)


class Config(object):
    """
    Parse a config file in the 'scripts' folder.
    The config file must content for source and destination :
    url, login and password for admin user.
    """
    def __init__(self, config_name):
        self.parser = None
        self.sections = {}
        parser = ConfigParser()
        parser.read('scripts/{}.cfg'.format(config_name))
        self.parser = parser
        for section in parser.sections():
            self.sections[section] = dict(self.parser.items(section))

    def __getattr__(self, attr_name):
        return self.section(attr_name)

    def section(self, section_name):
        return self.sections.get(section_name, {})


# if "app" in locals():
#     migrate_to_plone52(app)
if __name__ == '__main__':
    migrate_to_plone52()
