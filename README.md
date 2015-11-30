Ansible role: Jenkins Backup
============================

This [Ansible](http://www.ansible.com/home) role customizes installed Jenkins for automated config backup.

## Features

* Backup Jenkins configuration
* Keep backups from the last X days
* Restore config from backup

## Prerequisites

* Installed Jenkins master
* The [Jenkins exclusive execution plugin](https://wiki.jenkins-ci.org/display/JENKINS/Exclusive+Execution+Plugin) which will be installed by this role

## Platform support

* See [meta info](meta/main.yml)

## Backup Scope

The following files will be included into the backup archive:

* $JENKINS_HOME/*.xml
* $JENKINS_HOME/plugins/*.jpi
* $JENKINS_HOME/jobs/*/*.xml
* $JENKINS_HOME/users/*

## User Manual

### Running a Jenkins Backup Job

#### Simplest manual configuration

* Create a new job by selecting the free-style software project
* Configure the Build Triggers > Build periodically (cron job). For example:
```
H 9-16/2 * * 1-5
```
* Configure the Build Environment > Set exclusive Execution. This to ensure no other Jobs are running and the server is in shutdown mode
* Configure the Build > Execute shell:
```
$JENKINS_HOME/scripts/jenkins-config-backup.sh
```
* In case we want to override the defaults (sample):
```
$JENKINS_HOME/scripts/jenkins-config-backup.sh -j $JENKINS_HOME -d /path/to/backup_`date +"%Y%m%d%H%M%S"`.tar.gz
```

## Configuration

### Variables

See the [default variables](defaults) to be overridden as needed.
