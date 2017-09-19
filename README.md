<img src="http://www.cgrates.org/img/bg/logo.png" /><br>
<img src="https://voipkb.com/img/freeswitchlogo_lg.png" />

## Maintainer
Gabriele Proni | <me@gabrieleproni.com> | [github](https://github.com/MrGab)

## Description
CGRateS Docker Container working out of the box (in prepaid mode) with MySQL, Redis and FreeSWITCH. There is also a phpmyadmin container to access the db by web gui.

**Please Note**

The CGRateS installation is performed via .deb file because the last release and apt repository is not updated. If you want to install the very last deb from master, just update cgrates/installer.deb

## Environment
In order to run the docker-compose, you should setup four environment variable below:
* `CGR_MYSQL_ROOT_PASSWORD` : password for the user "root" in mysql
* `CGR_MYSQL_DATABASE` : name of the CGRateS MySQL database 
* `CGR_MYSQL_USER` : name of the CGRateS MySQL user
* `CGR_MYSQL_PASSWORD` : password for the CGRateS MySQL user

## Configure
* Insert your freeswitch gateway (to make real outbound calls):
  * Edit freeswitch-cgr/sip_profiles/public/gateways.xml inserting your gateway
  * Edit freeswitch-cgr/dialplan/public.xml setting the name of your_sip_gateway in the last extension
  
* Tariffplan: 
  * Put your tariffplan csv files  in the folder named `tariffplan` (you can find a pre-built example). 

## Usage
* To build and run:
  ```bash
  docker-compose --project-name cgrates-fs-docker -f docker-compose.yml up --build 
  ```

* Load the tariffplan by in the running CGRateS container bash (only the first time or when you apply changes to the tariffplan csv files):
    ```bash
     cd /
     ./import_tariffplan.sh
    ```

* You can access to the HTTP json-rpc API via port 2080

