# Cisco ACI Vagrant Command Plugin - Proof of Concept

This is a plugin that allows Vagrant to interact with a Cisco Application Centric Infrastructure (ACI) environment to create/delete Application Network Profiles (ANP). 

This plugin is currently a Proof of Concept and has been developed and tested against Cisco ACI 2.1 and Vagrant 1.2+

![alt tag](https://github.com/conmurphy/vagrant-aci/blob/master/images/overview.png)

Table of Contents
=================

   * [Cisco ACI Vagrant Command Plugin - Proof of Concept](#cisco-aci-vagrant-command-plugin---proof-of-concept)
   * [Table of Contents](#table-of-contents)
      * [Features](#features)
      * [Quick Usage](#quick-usage)
      * [Detailed Usage](#detailed-usage)
      * [Example](#example)
      * [Development](#development)

Created by [gh-md-toc](https://github.com/ekalinin/github-markdown-toc)

## Features

* Create Application Network Profiles within an ACI tenant based on a JSON config file
* Delete ANPs within an ACI tenant 
* List current ANPs and their associated End Point Groups and VMWare portgroups. 

## Quick Usage

After installing the plugin use the `vagrant aci app` command with the following subcommands 

```
$ vagrant aci app <subcommand> [<args>]
...
```

Available subcommands:
     delete
     list
     new

For help on any individual subcommand run `vagrant aci app <subcommand> -h`


## Detailed Usage

The following Vagrant ACI commands are available

* `vagrant aci app new` - Deploy a new Application Network Profile to an ACI environment. This command requires a template of the ACI ANP in JSON format. See the screenshots below for the process to export this file.
* `vagrant aci app delete` - Remove an existing ANP
* `vagrant aci app list` - List the existing ANPs. Use --name <app name> to view information about a specific existing ANP


The following flags are available to use with the Vagrant ACI plugin. If any required information such as the hostname is not specified by a flag you will be prompted once the command has been executed. You can use the -h or --help flag to view the usage of any command.


```
Usage: vagrant aci app new [options]

    -t, --tenant n                   ACI tenant name
    -i, --ip n                       IP address of ACI Controller
    -u, --username n                 ACI Controller username
    -n, --name n                     Name of new application
    -p, --path n                     Path and filename for the application policy configuration file (.json)
    -h, --help n                     Print this help
```

```
Usage: vagrant aci app delete [options]

    -t, --tenant n                   ACI tenant name
    -i, --ip n                       IP address of ACI Controller
    -u, --username n                 ACI Controller username
    -n, --name n                     Name of new application
    -h, --help n                     Print this help
```

```
Usage: vagrant aci app list [options]

    -t, --tenant n                   ACI tenant name
    -i, --ip n                       IP address of ACI Controller
    -u, --username n                 ACI Controller username
    -n, --name n                     Application name
    -h, --help n                     Print this help
```


## Example

In order to deploy a new Application Network Profile in ACI you require a few pieces of information

    -t, --tenant n                   ACI tenant name
    -i, --ip n                       IP address of ACI Controller
    -u, --username n                 ACI Controller username
    -n, --name n                     Name of new application
    -p, --path n                     Path and filename for the application policy configuration file (.json)

These can either be specified by the flags above in the command line or alternatively you will be prompted for any missing properties. The tenant must already exist in the ACI environment. The path references the path and the filename for the JSON file which will be used to deploy the ANP in ACI. This can be created manually or alternatiely you can build a template ANP in ACI and export as a JSON file. When you run `vagrant aci app new` the plugin will use this template and insert the tenant and application names automatically/

The following screenshots outline the steps to export an existing ANP as a JSON file. This filename is then referenced in the `vagrant aci app new` command. 

**Step 1.** Build a template ANP in the ACI tenant. For this example we have created a simple profile containing a single End Point Group connected to a VMWare VCenter domain.

![alt tag](https://github.com/conmurphy/vagrant-aci/blob/master/images/step_1.png)

**Step 2.** Right click `Application Profile` and select `Save as ...`

![alt tag](https://github.com/conmurphy/vagrant-aci/blob/master/images/step_2.png)

**Step 3.** Select `Only Configuration`, `Subtree` and `json` and then download the file, making a note of where this resides.

![alt tag](https://github.com/conmurphy/vagrant-aci/blob/master/images/step_3.png)

**Step 4.** Open the JSON file and remove the following lines.

```
"totalCount": "1",
  "imdata": [{
```
Also remember to remove the lines at the end of the file containing the closing `}]` brackets.

**Step 5.** Your file should now look similair to the following example.

```
{

    "fvAp": {
      "attributes": {
        "descr": "",
        "dn": "uni/tn-acme/ap-website-dev-template",
        "name": "website-dev-template",
        "ownerKey": "",
        "ownerTag": "",
        "prio": "unspecified"
      },
      "children": [{
        "fvAEPg": {
          "attributes": {
            "descr": "",
            "fwdCtrl": "",
            "isAttrBasedEPg": "no",
            "matchT": "AtleastOne",
            "name": "web",
            "pcEnfPref": "unenforced",
            "prefGrMemb": "exclude",
            "prio": "unspecified"
          },
          "children": [{
            "fvRsDomAtt": {
              "attributes": {
                "classPref": "encap",
                "delimiter": "",
                "encap": "unknown",
                "encapMode": "auto",
                "instrImedcy": "lazy",
                "primaryEncap": "unknown",
                "resImedcy": "immediate",
                "tDn": "uni/vmmp-VMware/dom-ACILab-vDS"
              }
            }
          }, {
            "fvRsCustQosPol": {
              "attributes": {
                "tnQosCustomPolName": ""
              }
            }
          }, {
            "fvRsBd": {
              "attributes": {
                "tnFvBDName": "default"
              }
            }
          }]
        }
      }]
    }
}
```

**Step 6.** Run the `vagrant aci app new` command using either the flags or providing the details when prompted. 

```
$ vagrant aci app new --username admin --ip my-aci-cluster.acme.com --tenant acme --name website --path anp.json
...
```

## Development

To work on the Vagrant ACI plugin, clone this repository then run the following commands to build and install the plugin.

```
$ gem build vagrant-aci.gemspec
$ vagrant plugin install ./vagrant-aci-0.1.0.gem
```

To uninstall the plugin run `vagrant plugin uninstall vagrant-aci`


WARNING:

These scripts are meant for educational/proof of concept purposes only. Any use of these scripts and tools is at your own risk. There is no guarantee that they have been through thorough testing in a comparable environment and we are not responsible for any damage or data loss incurred with their use.
