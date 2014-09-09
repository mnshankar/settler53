# Laravel Settler (PHP 5.3.10/Postgres 9.1/Mysql 5.5)

The scripts that build the Laravel Homestead development environment.
This is very similar to Taylor's script;However, it uses php 5.3 on Ubuntu 12.04
(for use by those who are still on an older version of php)

Download the zip file into a local folder (say 'settler-master')
open a shell into settler-master and run:
```
vagrant up
```
It will download precise32, and setup the linux box with features (almost) identical to homestead (but with php 5.3). When the script ends, your server box should be set and you will be able to ssh into localhost/port 2222. 

Running php -version should confirm the installation of php 5.3.

BE SURE YOU ADDRESS ERRORS IF ANY DURING THIS PROCESS.

Do a "vagrant halt" in your settler-master directory and package it up so it can be used elsewhere:

```
vagrant package
```

This will create a "package.box" file in the current folder.

Next, download the laravel homestead application from https://github.com/laravel/homestead
and unzip it into a local folder - say "lamp53"

Navigate into scripts/homestead.rb and change
config.vm.box and config.vm.box_url like so:

```
config.vm.box = "php53"
config.vm.box_url = "file:///c:/settler-master/package.box"
```

Now, within the lamp53 folder, edit the Homestead.yaml file as required and run "vagrant up". From now on, you will only need to use the lamp53 folder - the settler-master folder was only required for initial setup. Note the package.box file can be renamed and/or moved to any convenient location on your hard drive.
