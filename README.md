# Setup Wordpress and monitoring system on Ubuntu 16.04

Note:
- This ansible repo only works for Ubuntu 16.04
- In this case, I install WordPress and monitoring system on a same server.

Main components are used:

- [MySQL Database](https://dev.mysql.com/doc/)
- [PHP](http://php.net/docs.php)
- [Nginx](https://nginx.org/en/docs/)
- [WordPress](https://wordpress.org/)
- [Java](https://docs.oracle.com/javase/8/docs/)
- [Elasticsearch](https://www.elastic.co/)
- [MongoDB](https://www.mongodb.com/)
- [Graylog2](http://docs.graylog.org/en/2.4/)
- [Telegraf](https://docs.influxdata.com/telegraf)
- [InfluxDB](https://docs.influxdata.com/influxdb)
- [Grafana](http://docs.grafana.org/)

## Preparation

### Server

- Create a VM with at least 4 Gb memory. In this case, I created a VM on [DigitalOcean](https://www.digitalocean.com/)
 for this test.

### Email

- An Email which will be used by `Graylog2` and `Grafana` for notification, alerts.

### DNS

- Create a record A that point to your VM. In this case, I created a `grabtest.swdream.org` record.
IP of VM can also be used if the record is NOT created.

### Requirements

- Python3
- Ansible 2.0 or higher

## How this Ansible environment work

### Setup your ssh conf on the machine where you run ansible-playbook

Add below line to `~/.ssh/config`

```
Host assessment
    Hostname IP_or_domain_name_of_your_VM
    User your_user
    IdentityFile ~/.ssh/your_private_key
    Port 22
    UserKnownHostsFile /dev/null
    StrictHostKeyChecking no
    PasswordAuthentication no
    IdentitiesOnly yes
    LogLevel FATAL
```

### Modify Ansible Variables

All needed  variables will be explained in following sessions. Modify them to suit your case.

### Apply Ansible playbook to setup WordPress and monitoring system

Running

```
$ ./ansible-playbook assessment
```

Or

```
$ ansible-playbook -i environments/assessment assessment.yml
```

## System Components And Information

### Setup Base Items

- Setup and Configure SSH
- Create and mangage users
- Setup timezone for server

Done by `base` role in `roles/base`.

##### Base Role Variables

See extra variables in `roles/base/vars/main.yml`

`server_time_zone`: timezone that will be set for your VM/server.

`admin_group`: name of created admin group.

`admin_list`: list users that will be created and add to admin group.

Example:

```
server_time_zone: your_time_zone
admin_group: 'admin'

# admin users
admin_list:
  - name: Fullname of user
    username: user_name
    keys:
      active:
        - user_ssh_public_key
      disabled:
        -
    shell: "/bin/bash"
    state: present
```

### Install WordPress

WordPress is the world’s most popular tool for creating websites.
 WordPress is capable of creating any style of website, from a simple blog to a full-featured business website.

Using below components:

- MySQL database
- PHP
- Nginx
- WordPress

##### MySQL Databse

WordPress uses MySQL to manage and store site and user information.

Install MySQL server using `mysql` ansible role in `roles/mysql`. This role installs
`mysql-server 5.7`.

###### MySQL Defau Variables

Required packages to install MySQL. See them in `roles/mysql/default/main.yml`.

Example:

```
mysql_packages:
  - mysql-server
  - mysql-client
  - python-mysqldb

required_packages:
  - python-dev
  - libmysqlclient-dev
```

There are some extra variables as bellow to setup database for WordPress,
 can see in `roles/mysql/vars/main.yml`.

`mysql:wordpress_db`: name of mysql db which wordpress connects to.

`mysql:user`: information of mysql user that used by wordpress.

```
    mysql:
      wordpress_db: wordpress
      users:
        wordpress:
          password: wordpress_mysql_password
          privileges: 'wordpress.*:ALL'
          host: '%'
      bind:
        - 0.0.0.0
```

Modify them to suit your case.

##### PHP

WordPress is written in PHP. WordPress and many of its plugins leverage additional PHP extensions.

Install PHP extensions using `php` role in `roles/php`.

###### PHP Role Variables

set required PHP extensions and can be set in `roles/php/defaults/main.yml`

Example:

```
extensions_packages:
  - php-curl
  - php-gd
  - php-mbstring
  - php-mcrypt
  - php-xml
  - php-xmlrpc
  - php-cli
  - php-fpm
  - php-mysql
```

##### Nginx

WordPress is running on Nginx and we also can setup Nginx as an reverse proxy to handle
 request to WordPress server.

Install Nginx using `nginx` role in `roles/nginx`.

###### Nginx Role Variables

Default variables set installed nginx package name.
 See it in `roles/nginx/defaults/main.yml`.

Example:

```
nginx_package_name: nginx
```

##### WordPress

WordPress is setup using `wordpress` role in `roles/wordpress`. This role do download
 WordPress and setup needed directory and configuration. It is completed the installation
 through Web interface

    http://grabtest.swdream.org

Next, you will come to the main setup page.

##### WordPress Role Variables

Configure infofmation of wordpress mysql database and web. See them in
 `roles/wordpress/vars/main.yml`

`wordpress_db`: name of mysql database which wordpress connects to.

`wordpress_db_user`: name of mysql user which wordpress uses to connects to mysql.

`wordpress_db_password`: password of mysql user which wordpress uses to connects to mysql.

`wordpress_web_port`: port of wordpress web.

Example:

```
wordpress_db: wordpress
wordpress_db_user: wordpress
wordpress_db_password: db_password_of_user_wordpress
wordpress_web_port: 80
```

### Monitoring System

Setup monitoring system:

- Logs Analytics system: Collect and manage logs of services.
- Time-series Data analytics system: collects and stores metrics and events for monitoring.

#### Logs Analytics System

Setting up Logs Analytics System with below main components:

- Graylog2
- Elasticsearch
- MongoDB

##### Elasticsearch

Elasticsearch is a flexible and powerful open source, distributed,
 real-time search and analytics engine.

Installed and configured by `roles/elasticsearch`.

###### Elasticsearch Role Variables

`elasticsearch_cluster`: set elasticsearch cluster name.

Find varibles in `roles/elasticsearch/vars/main.yml`.

Example:

```
elasticsearch_cluster: graylog
```

##### MongoDB

Graylog uses MongoDB to store your configuration data, not log data.
 Only metadata is stored, such as user information or stream configurations.

###### MongoDB Role Variables

None

##### Graylog2

Graylog2 is a centralized logging software,
provides a number of benefits than logging on local servers:

- Searching through logs and analysis across multiple servers easier
- Have a chance of finding something useful about what happened in the event of
an instrusion or system failure
- Log rotation mechanism can also be centralized

Installed and Configured by `roles/graylog2`.

##### Graylog2 Role Variables

Configure information about domain of graylog server, web_port and
 connected Elasticsearch, mongodb.

`graylog_server`: graylog server address.

`elasticsearch_host`: elasticsearch address where graylog server connects to.

`mongodb_host`: mongodb address where graylog server connects to.

`graylog_server_web_port`: port of graylog web.

`alert_email_user`: email that graylog uses to sent notification/alerts.

`alert_email_password`: password of email that grafana uses to sent notification/alerts.

Find them in `roles/graylog2/vars/main.yml`.

Example:

```
graylog_server: grabtest.swdream.org
elasticsearch_host: 127.0.0.1
mongodb_host: 127.0.0.1
graylog_server_web_port: 9000

alert_email_user: graylog_alert@email.test
alert_email_password: graylog_alert_password
```

#### Time-Series Data Analytics System

Setup Time-Series Data Analytics System using below components:

- Grafana
- InfluxDB
- MySQL database
- Telegraf

##### Grafana

Grafana is an open source, feature rich metrics dashboard and graph editor.

###### Grafana Variables

`mysql_server`: mysql server which grafana connects to.

`grafana_mysql_db`: name of mysql db which grafana connects to.

`grafana_mysql_user`: mysql user that grafana use to connect to mysql.

`grafana_mysql_password`: password of mysql user that grafana use to connect to mysql.

`alert_email_user`: email that grafana uses to sent notification/alerts.

`grafana_mysql_password`: password of email that grafana uses to sent notification/alerts.

`grafana_web_port`: port of grafana web.

Find them in `roles/grafana/vars/main.yml

Example

```
mysql_server: 127.0.0.1
grafana_mysql_db: grafana
grafana_mysql_user: grafana
grafana_mysql_password: your_grafana_mysql_password

alert_email_user: grafana_alert@email.test
alert_email_password: grafana_alert_password

grafana_web_port: 300
```

##### MySQL Database

Grafana uses MySQL database to stored users and dashboards data.

###### Role Variables

Configure information of database for `Grafana`.

`mysql:grafana_db`: name of mysql db will be used for grafana

`mysql:user`: information of created grafana user.

Find variables in `roles/mysql/vars/main.yml`

Example:

```
mysql:
  grafana_db: grafana
  users:
    grafana:
      password: your_grafana_db_password.
      privileges: 'grafana.*:ALL'
      host: '%'
  bind:
    - 0.0.0.0
```

##### InfluxDB

An open-source distributed time series database with no external dependencies.

InfluxDB stores time series data which collected by telegraf and send to. Influxdb is a
 data source of grafana, and grafana will show time series data from Influxdb on graphs.

Installed and Configured by `roles/influxdb`.

###### InfluxDB Role Variables

`influxdb_host`: config host address of influxdb server.

`influxdb_database_name`: created influxdb database.

`influxdb_user_name`: created influxdb user.

`influxdb_user_password`: password of created influxdb user.

Find them in `roles/influxdb/vars/main.yml`

Example:

```
influxdb_host: 127.0.0.1
influxdb_database_name: telegraf
influxdb_user_name: telegraf
influxdb_user_password: telegraf_user_password
```

##### Telegraf

Telegraf is an agent for collecting and reporting metrics to InfluxDB.

Installed and configured by `roles/telegraf`.

###### Telegraf Role Variables

Variables to configure InfluxDB which Telegraf sends metrics to.

`influxdb_server`: InfluxDB host where Telegraf send metrics to.

`influxdb_database_name`: name of influxdb to store sent data of telegraf.

`influxdb_user_name`: name of user that telegraf using to connect to InfluxDB.

`influxdb_user_password`: password of user that telegraf using to connect to InfluxDB.

Find in `roles/telegraf/vars/main.yml`
Example:

```
influxdb_server: 127.0.0.1
influxdb_database_name: telegraf
influxdb_user_name: telegraf
influxdb_user_password: influxdb_password_of_telegraf_user
```
