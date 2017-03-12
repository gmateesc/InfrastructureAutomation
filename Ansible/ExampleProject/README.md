

# Example Ansible Project



## 1. Objective 


Create an Ansible project for configure two clusters, both having 
the role logstash, but having different configuration parameters 
such as the cluster name, and the API key and tenant ID to be used 
for pushing log data.


---



## 2. Project layout



### 2.1 Top level project


The project layout is

```
  gabriel $ tree
  .
  ├── tasks
  │   ├── README.md
  │   ├── main.yml
  ├── files
  │   ├── README.md
  │   └── logstash.conf
  ├── group_vars
  │   ├── all.yml
  │   └── webservers.yml
  ├── cluster_01
  │   ├── ansible.cfg
  │   ├── files -> ../files
  │   ├── group_vars -> ../group_vars
  │   ├── hosts
  │   ├── list_hosts.sh
  │   ├── playbook.yml
  │   ├── roles -> ../roles
  │   ├── tasks -> ../tasks
  │   └── vars
  │       └── main.yml
  ├── cluster_02
  │   ├── ansible.cfg
  │   ├── files -> ../files
  │   ├── group_vars -> ../group_vars
  │   ├── hosts
  │   ├── list_hosts.sh
  │   ├── playbook.yml
  │   ├── roles -> ../roles
  │   ├── tasks -> ../tasks
  │   └── vars
  │       └── main.yml
  └── roles
      └── logstash
          ├── tasks
          │   └── main.yml
          └── vars
              └── main.yml

  19 directories, 18 files
```

where 

```
- global:    tasks, vars         # global tasks and vars



- host-group specific: group_vars
                                 # host-group vars
                                 #  - one host-group can have one or more roles;
                                 #  - one host-group can occur in different clusters


- cluster-specific: cluster_01, cluster_02
                                 # define host group and roles for a cluster and 
                                 # cluster-specific vars; 
                                 #  - one cluster (aws) may contain multiple host groups (webserver, db)
                                 #  - for each host-group, one assigns one or more roles
                                 #  - one host-group (webserver) can occur in one or more clusters

                                              
- role-specific:       roles 
                                 # role-specific tasks, vars, files 
                                 #  - roles are webserver, db, ....
                                 #  - one host-group can have multiple roles, e.g., tomcat and apache
```


---



### 2.2 Layout of cluster_01 directory

```
  gabriel $ tree -l cluster_01
  .
  ├── ansible.cfg
  ├── files -> ../files
  │   ├── README.md
  │   └── logstash.conf
  ├── group_vars -> ../group_vars
  │   ├── all.yml
  │   └── webservers.yml
  ├── hosts
  ├── list_hosts.sh
  ├── playbook.yml
  ├── roles -> ../roles
  │   └── logstash
  │       ├── tasks
  │       │   └── main.yml
  │       └── vars
  │           └── main.yml
  ├── tasks -> ../tasks
  │   ├── README.md
  │   └── main.yml
  └── vars
      └── main.yml

  8 directories, 13 files
```

---




### 2.3 Layout of cluster_02 directory



Cluster_02 has different host inventory and different cluster-specific data, but otherwise 
is the same a cluster_01:

```shell
  gabriel $ diff -r cluster_02 cluster_01

  diff -r cluster_02/hosts cluster_01/hosts
  5c5
  < serverB ansible_ssh_host=127.0.0.1 ansible_ssh_port=22
  ---
  > serverA ansible_ssh_host=127.0.0.1 ansible_ssh_port=22


  diff -r cluster_02/vars/main.yml cluster_01/vars/main.yml
  2,3c2,3
  < project_name:  Project 02
  < cluster_name:  Cluster 02
  ---
  > project_name:  Project 01
  > cluster_name:  Cluster 01
  ---
```



---


## 3. The playbook


### 3.1 The playbook file

```yaml

  gabriel $ more cluster_01/playbook.yml 
  ---
  - name: Execute roles/logstash/tasks/main.yml and other tasks

    #
    # 1. Host group
    #
    #   NOTE: If group_vars/HOST_GROUP[.yml] exists, it will be loaded
    #
    hosts: webservers
    #remote_user: gabriel
    #become: true


    #
    # 2. Roles: a role includes tasks, files, and vars
    #           all host in the above host group will have this role
    roles: 
      - role: logstash
        var_foo: foo_val # var passed to role; scope is the role tasks and this playbook


    #
    # 3. Define playbook-level vars to be used by the tasks
    #

    #
    # 3.1 Load var files with vars_files: or include_vars:
    #
    #vars_files:
    #  - vars/main.yml

    #
    # 3.2 Executed before all tasks
    #
    pre_tasks:
      - include_vars: vars/main.yml


    #
    # 4. Run tasks
    #
    tasks:

      #
      # 4.1 First the role-specific tasks are executed
      #

      # Executed by roles/logstash/tasks/main.yml
      # - name: copy logstash config file 
      #   # Path to source file is relative to the dir where the playbook resides
      #   copy: src=files/logstash.conf dest=/etc/logstash/conf.d


      #
      # 4.2 Next, the tasks listed here are executed
      #
      - include: tasks/main.yml # included task can access all previous vars, except those passed to a role

      # Moved the debug task to tasks/main.yml
      # - name: Debug
      #   #debug: var=org          # defined in group_vars/all.yml,       included with all host groups
      #   #debug: var=admin_pass   # defined in group_vars/webserver.yml, included with host group webservers
      #   #debug: var=role_name    # defined in roles/logstash/vars,      included with role logstash
      #   #debug: var=cluster_name # defined in vars/main.yml,            included with vars_files or include_vars
      #   debug:  >
      #     msg="org={{ org }} cluster_name={{ cluster_name }} role_name={{ role_name }} admin_pass={{ admin_pass }}"

```



---


### 3.2 Run the playbook


```
  gabriel $ cd cluster_01

  gabriel $ ansible-playbook  playbook.yml

  PLAY [Wrapper for roles/cluster_01/tasks/main.yml] **************************** 

  GATHERING FACTS *************************************************************** 
  ok: [serverA]

  TASK: [include_vars vars/main.yml] ******************************************** 
  ok: [serverA]

  TASK: [logstash | copy logstash config file] ************************************* 
  changed: [serverA]

  TASK: [logstash | Debug] ****************************************************** 
  ok: [serverA] => {
      "msg": "role_name=logstash cluster_name=Cluster 01"
  }

  TASK: [Debug] ***************************************************************** 
  ok: [serverA] => {
      "msg": "org=ACM cluster_name=Cluster 01 role_name=logstash admin_pass=t0ps3cr3t"
  }

  PLAY RECAP ******************************************************************** 
  serverA                    : ok=6    changed=1    unreachable=0    failed=0   

```






