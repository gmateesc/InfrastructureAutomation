
# Playbook to update a base image, then install Java and ElasticSearch


## Table of Contents

- [Playbook and Dockerfiles](#p1)

- [Run Update OS task](#p2)

- [Run Java installation task](#p3)

- [Run ElasticSearch installation task](#p4)

- [Run all tasks](#p5)






<a name="p1" id="p1"></a>
## Playbook and Dockerfiles



The playbook is

```yaml

  gabriel $ more update_java_elasticsearch.yml 
  #
  #
  # To run all tasks:
  #
  #  ansible-playbook   -i localhost, update_java_elasticsearch.yml
  #
  #
  # To run only OS update:
  #
  #  ansible-playbook   -i localhost, --tags='update'  update_java_elasticsearch.yml
  #
  #
  # To run only OS update and Java install:
  #
  #  ansible-playbook   -i localhost, --tags='java'  update_java_elasticsearch.yml
  #
  #
  ---
  - hosts: localhost
    connection: local
    become: no
   
    tasks:

    - name: Pull the centos:latest image
      docker_image:
        repository:  "centos:latest"
        name:        "centos"
        state:       present
      tags: 
      - update
      - java
      - elasticsearch


    - name: Build an image with OS patched
      docker_image:
        path: ./files/AGT
        repository: "centos"
        name:  "agt/centos"
        state: present
        push: yes
      tags: 
      - update
      - java
      - elasticsearch


    - name: Build an image with Java
      shell: docker build -t agt/centos-java:latest ./files/AGT_java
      register: res
      changed_when: "'Running in' in res.stdout"
      tags: 
      - java
      - elasticsearch
    

    - name: Build an image with ElasticSearch
      shell: docker build -t agt/centos-elasticsearch:latest ./files/AGT_elasticsearch
      register: res
      changed_when: "'Running in' in res.stdout"
      tags: 
      - elasticsearch


```


The Dockerfiles used by the playbook are under the files directory:
```console

  gabriel $ tree files/
  files/
  ├── AGT
  │   └── Dockerfile
  ├── AGT_elasticsearch
  │   └── Dockerfile
  └── AGT_java
      └── Dockerfile

  3 directories, 3 files

```







<a name="p2" id="p2"></a>
## Run Update OS task


Before

```console

  gabriel $ docker images | egrep "REPOS|agt/"
  REPOSITORY                TAG                 IMAGE ID            CREATED              SIZE

```


Run playbook


```console

  gabriel $ ansible-playbook   -i localhost, --tags='update'  update_java_elasticsearch.yml 

  PLAY [localhost] ***************************************************************

  TASK [setup] *******************************************************************
  ok: [localhost]
 
  TASK [Pull the centos:latest image] ********************************************
  ok: [localhost]

  TASK [Build an image with OS patched] ******************************************
  changed: [localhost]

  PLAY RECAP *********************************************************************
  localhost                  : ok=3    changed=1    unreachable=0    failed=0   
```



After

```console

  gabriel $ docker images | egrep "REPOS|agt/"
  REPOSITORY                TAG                 IMAGE ID            CREATED              SIZE
  agt/centos                latest              e9512648f789        About a minute ago   283 MB

```






<a name="p3" id="p3"></a>
## Run Java installation task


Before


```console

  gabriel $ docker images | egrep "REPOS|agt/"
  REPOSITORY                TAG                 IMAGE ID            CREATED              SIZE
  agt/centos                latest              e9512648f789        About a minute ago   283 MB
```


Run playbook


```console

  gabriel $ ansible-playbook   -i localhost, --tags='java'  update_java_elasticsearch.yml 

  PLAY [localhost] ***************************************************************

  TASK [setup] *******************************************************************
  ok: [localhost]

  TASK [Build an image with Java] ************************************************
  changed: [localhost]

  PLAY RECAP *********************************************************************
  localhost                  : ok=2    changed=1    unreachable=0    failed=0   
```


After

```console

  gabriel $ docker images | egrep "REPOS|agt/"
  REPOSITORY                TAG                 IMAGE ID            CREATED             SIZE
  agt/centos-java           latest              0d1911dade0b        3 minutes ago       495 MB
  agt/centos                latest              e9512648f789        6 minutes ago       283 MB

```



<a name="p4" id="p4"></a>
## Run ElasticSearch installation task




Before


```console

  gabriel $ docker images | egrep "REPOS|agt/"
  REPOSITORY                TAG                 IMAGE ID            CREATED             SIZE
  agt/centos-java           latest              0d1911dade0b        3 minutes ago       495 MB
  agt/centos                latest              e9512648f789        6 minutes ago       283 MB
```



Run playbook:


```console

  gabriel $ ansible-playbook   -i localhost,  update_java_elasticsearch.yml 

  PLAY [localhost] ***************************************************************

  TASK [setup] *******************************************************************
  ok: [localhost]

  TASK [Pull the centos:latest image] ********************************************
  ok: [localhost]

  TASK [Build an image with OS patched] ******************************************
  ok: [localhost]

  TASK [Build an image with Java] ************************************************
  ok: [localhost]

  TASK [Build an image with ElasticSearch] ***************************************
  changed: [localhost]

  PLAY RECAP *********************************************************************
  localhost                  : ok=5    changed=1    unreachable=0    failed=0   

```


After

```console

  gabriel $ docker images | egrep "REPOS|agt/"
  REPOSITORY                 TAG                 IMAGE ID            CREATED             SIZE
  agt/centos-elasticsearch   latest              ad78bac2622b        7 seconds ago       615 MB
  agt/centos-java            latest              0d1911dade0b        5 minutes ago       495 MB
  agt/centos                 latest              e9512648f789        9 minutes ago       283 MB

```







<a name="p5" id="p5"></a>
##  Run all tasks



By idempotence, a new run will not do anything:


```console

  gabriel $ ansible-playbook   -i localhost,  update_java_elasticsearch.yml 

  PLAY [localhost] ***************************************************************

  TASK [setup] *******************************************************************
  ok: [localhost]

  TASK [Pull the centos:latest image] ********************************************
  ok: [localhost]

  TASK [Build an image with OS patched] ******************************************
  ok: [localhost]

  TASK [Build an image with Java] ************************************************
  ok: [localhost]

  TASK [Build an image with ElasticSearch] ***************************************
  ok: [localhost]

  PLAY RECAP *********************************************************************
  localhost                  : ok=5    changed=0    unreachable=0    failed=0   


```