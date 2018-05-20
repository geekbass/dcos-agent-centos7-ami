# DC/OS Agent Centos 7 AMI
Using Packer and Ansible to build a Centos 7 AMI for DC/OS Agents (Please use Official Centos 7 from the Marketplace). This AMI contains all of the prereqs to clear the preflight check to get added into the DC/OS Cluster and begin accepting tasks. This AMI also includes several other components for monitoring, logging and metrics such as: 

- [Elastic Beats](https://www.elastic.co/products/beats) - Logging and Metrics
- [Telegraf](https://github.com/influxdata/telegraf) - Metrics and Monitoring
- [Netdata](https://github.com/firehol/netdata) - Real Time Dashboard with browser UI
- [check_mk](http://mathias-kettner.com/check_mk.html) - Monitoring 

We will use this as a base AMI for all DC/OS agents that will be replaced upon a system update. **** NOTE: you can add and remove roles as necessary (update aws-packer.yml). You may also just use the Ansible roles as a means of automation outside of Packer as well. 

### Ansible Roles
* common - This role handles all of the OS configurations that are required as prereqs for Centos 7 for DC/OS such as: disabling selinux, installing necessary packages, and enabling NTP. See [DC/OS Installation Requirememnts](https://docs.mesosphere.com/1.11/installing/oss/custom/system-requirements/) for more details.

* docker - This handles all the docker prereqs required such as overlay, docker version, and logrotate to keep the docker logs under control. See [DC/OS Docker Centos 7 Requirements](https://docs.mesosphere.com/1.11/installing/oss/custom/system-requirements/install-docker-centos/)

* [beats](https://www.elastic.co/products/beats) - This role installs both [metricbeat](https://www.elastic.co/products/beats/metricbeat) and [filebeat](https://www.elastic.co/products/beats/filebeat). The included metricbeat.yml uses the system and docker module for shipping metrics to elastic. You can search get individual service metrics that use docker by using the MESOS_TASK_ID search field. The default filebeat.yml is used to ship logs from both the OS and from the logs from the services running on the cluster. Logs from the service are placed in ES as document type 'marathon-app' 

* [telegraf](https://github.com/influxdata/telegraf) - This role is used as part of the [TICK stack](https://www.influxdata.com/blog/introduction-to-influxdatas-influxdb-and-tick-stack/) for real time metrics and monitoring. The default telegraf.conf uses specified tags for dc and env set in the group_vars/all file. It also uses all the OS inputs as well as the Docker input and default output to InfluxDB. Individual services running in the cluster using docker can be found via the mesos_task_id label when using either Chronograf or Grafana front end. 

* [netdata](https://github.com/firehol/netdata) - This role installs netdata to provide a way for providing a real time interactive way to get insights into individual nodes. This will run on port 8081 of every node. If you begin to see a performance issue, this should be the first thing you take a look at. This is a really awesome project and I would suggest everyone to take a look at it as a default way to get real time insight on your nodes.

* [check-mk](http://mathias-kettner.com/check_mk.html) - This nagios variant is used for monitoring and alerting using the traditional method. This role installs the agent needed to interact with the check_mk server. 

### How to Use
The Packer json uses 3 provisioners:
- agent-setup.sh - Used to install prereqs to use Ansible and install pip and jq.
- ansible-local - This runs the playbook and installs the roles above.
- shell command - Cleans up Ansible Directory and removes the Ansible package.

1) Make adjustments to the ansible/group_vars/all file to meet your needs. You can also remove any of the roles if you do not wish to use the component. You may also add roles by adding the role folder under roles directory and adding the name of the role under 'roles' in the ansible/aws-packer.yml file (Playbook file). You can also make adjustments to any of the template directory for each role. 


2) Export your variables for your AMI, VPC, Subnet, Region and AZ and validate the json.
``` sh
packer validate \
    -var ami=ami-centos7 \
    -var vpc_id=vpc-12345678 \
    -var subnet_id=subnet-12345678 \
    -var region=us-east-1 \
    -var az=us-east-1a \
    dcos_agent_centos7.4.json
```

3) If validation checks out successful, run the build.
``` sh
packer build \
    -var ami=ami-centos7 \
    -var vpc_id=vpc-12345678 \
    -var subnet_id=subnet-12345678 \
    -var region=us-east-1 \
    -var az=us-east-1a \
    dcos_agent_centos7.4.json
```

### Using the Ansible Roles ONLY
1) Pull down the repo and switch to ansible directory

2) OPTIONAL: Modify your roles by either adding or removing the directories under roles. Also modify the aws-packer.yml roles if modified role directories.

3) Update group_vars/all

4) Modify inventory/aws/hosts file with your inventory

5) Run Playbook

```sh
ansible-playbook -i inventory/aws/hosts aws-packer.yml
```

### Jenkins Pipeline
See Jenkinsfile. For ease, for this repo just hard code your variables (above) in the dcos_agent_centos7.4.json file first. There are multiple ways to use variables in Jenkins which is outside the scope of this repo. Pipeline will break if validation fails and you can see errors from Jenkins Console for the build number. 

