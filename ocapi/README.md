OCAPI Reference
==================

This is meant to be a collection of easy to references for working with Salesforce Commerce Cloud Open Commerce API (or SFCC OCAPI). It is meant to be related Postman collections along with OCAPI configurations necessary for an SFCC instance.

Prerequisites
---------------

Install Postman application https://www.getpostman.com/downloads/

As of this writing, I was using Postman v7.1.1 on Windows.

Usage
------------

Generally things will need three files, and we should try to keep them starting with the same name
 * _feature name_.postman_collection.json - this is the postman requests
 * _feature name_.postman_environment.json - this is the necessary environment variables. 
    * Don't leave your secrets in here when committing! 
    * Try to keep the variables named in an obvious way, eg "bm_user" or "site_id"
 * _feature name_-shop/data-permissions.json - this is the SFCC instance OCAPI permissions that are necessary. Note whether this is the "data" or "shop" api in the name.

To use:
1. find the three files for the featur you want
1. In Postman, import the collection and the environment files
1. In SFCC, Admin > Site Development > Open Commerce API Settings, add the contents of the permissions.json to either the Shop or Data area. Pay attention to whether you're doing it in the global or a site specific context.
1. In postman, inspect the environment settings, and update accordingly
1. send a request and see what happens!

Contributing
-------------

fork me, send a pull request

