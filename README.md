# IvanSScrobot_infra 

## HW#10 Ansible. Practice #3.

**0. Preparation:**

***Create roles***

With `ansible-galaxy init `, create the folder structure for two roles, 'app' and 'db'. Basic structure is:
```
db
├ README.md
├ defaults # <-- Folder for default variables
│ └ main.yml
├ files #<-- Folder for files by default
├ handlers
│ └ main.yml
├ meta # <-- General info about the role, dependencies, and the author
│ └ main.yml
├ tasks # <-- Folder for tasks
│ └ main.yml
├ tests
│ ├ inventory
│ └ test.yml
| templates #<-- Folder for templates by default
└ vars # <-- Folder for variables, which should not be changed by users 
└ main.yml 
```
Then, copy tasks from playboks made during HW#9 to tasks in our roles. Do the same with handlers. Move templates and files into corresponding folders in roles. Define default variables in defaults/main.yml.
Then, change playbooks app.yml and db.yml (delete tasks and handlers, add roles)

***Create environments***

In new folder _environments_, create two folders and name them 
for the environments - _stage_ and _prod_. Copy our inventory file into the folders. Now, when running playbook.yml to configure the development infrastructure, we can pass in the path to a needed inventory: `ansible-playbook -i environments/prod/inventory deploy.yml`. In ansible.cfg, define inventory by default: 
```
[defaults]
inventory = ./environments/stage/inventory 
```

Add files in directories _stage/group_vars/_ and _prod/group_vars/_ in order to manage group of hosts. Name files in directories after our groups defined in inventory (app, db, all), and add variables in these files. 

Organize files in the _ansible_ directory, tweak _ansible.cfg._

***Ansible Galaxy***

In files _environments/stage/requirements.yml_ and _environments/prod/requirements.yml_ add this:
```
- src: jdauphant.nginx
   version: v2.21.1
```
It enables us to use different dependacies in different environments.

Then, install the role from Galaxy: `ansible-galaxy install -r environments/stage/requirements.yml`. Open port 80, and call `jdauphant.nginx` from app.yml.  See the [docs](https://github.com/jdauphant/ansible-role-nginx).

***Ansible Vault***

Write down an arbitory key string in vault.key, then in ansible.cfg refer to this file:
```
[defaults]
...
vault_password_file = vault.key
```

Add playbook users.yml for creating users, in files _credentials.yml_ describe users in such way:
```
credentials:
  users:
    admin:
      password: admin123
      groups: sudo
```
Encrypt _credentials.yml_ by running `ansible-vault encrypt environments/prod/credentials.yml`. For editing and decrypting, use following commands: `ansible-vault edit <file>`, `ansible-vault decrypt <file>`.


## HW#9 Ansible. Practice #2.

**0. Preparation:**

Use templates (for MongoDB config file) and ansible variables for IP addresses. Use handlers for dependent tasks - in our case, for restarting MongoDB when mongo's conf file is changed.

- Create one file with one playbook for both app and db servers (reddit_app_one_play.yml). It's possible to work with such a playbook if we use tags for different services (like this: `ansible-playbook reddit_app.yml --limit db --tags deploy-tag`), but it's not so handy as we have to remember correspondence between tasks and tags.

- Create another file with several playbooks (one for MongoDB configuration, another for app configuration, and last for app deployment). One file with many playbooks seems to be more comfortable, but such files tend to grow rapidly in real life, making difficult to manage it.

- Create several files, with one playbook in each of them. Then, create 'main playbook', which runs others:


```
- import_playbook: db.yml

- import_playbook: app.yml

- import_playbook: deploy.yml
```


**1. Independent task:**

Replace bash scrypts for Packer with Ansible playbooks (files 'packer_app.yml' and 'packer_db.yml'). Find documentation for modules [here](https://docs.ansible.com/ansible/latest/modules/list_of_all_modules.html). Use [loops](https://docs.ansible.com/ansible/latest/user_guide/playbooks_loops.html), or this syntax:
```
  - name: Install ruby, bundler, and build
    apt:
      name: "{{ packages }}"
      state: present
  vars:
    packages:
      - ruby-full
      - ruby-bundler
      - build-essential
``` 

## HW#8 Ansible. Practice #1.

**0. Preparation:**

First of all, install Ansible, see [official docs](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html). Then, create  ansible.cfg file:

```
[defaults]
inventory = ./inventory
remote_user = appuser
private_key_file = ~/.ssh/appuser
host_key_checking = False
retry_files_enabled = False
```
... and create inventory file. Both .ini and .yml formats are supported (see [docs](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html)). Inventory file describes hosts wich can be managed by Ansible.

Then, create a simple Ansible playbook in file 'clone.yml'. Run it with the command `ansible-playbook clone.yml`. After creating the repository on the remote hosts, execute the same command again. Ansible returns `ok=2    changed=0` as nothing is changed. Delete it: `ansible app -m command -a 'rm -rf ~/reddit'` and execute the playbook again. In that case, ansible show status `changed` again.

**1. Additional tasks with \*:**

Creatin dynamic inventory file in JSON format. Again, read the fucking [manual](https://docs.ansible.com/ansible/latest/user_guide/intro_dynamic_inventory.html#intro-dynamic-inventory) or this excellent book ['Ansible for DevOps by Jeff Gerling'](https://www.ansible.com/resources/ebooks/ansible-for-devops).

In a nutshell, the script must output JSON to stdout, and Ansible must be able to call it with the argument --list. Ansible expects the following JSON format:
```
{
    "app": {
        "hosts": [
          "35.240.77.53"
        ]
    },
    "db": {
        "hosts": [
          "35.205.82.205"
        ]
    },
    "_meta": {
      "hostvars": {
        "35.240.77.53": {
           "host_specific_var": "bar"
         },
         "35.205.82.205": {
           "host_specific_var": "foo"
         }
       }
    }
}
```
Section "_meta" is not mandatory and can be reduced to
```
"_meta": {
        "hostvars": {}
    }
}
```

 There is an [example](https://github.com/geerlingguy/ansible-for-devops/tree/master/dynamic-inventory/custom) of Python script creating dynamic inventory. I **did not** modify the script to work with Google Compute. In fact, my script just returns statiс IP addresses instead of calling Google API and read something like `network_interface.0.access_config.0.nat_ip`. 
 
 ## HW#7 Terraform. Practice #2.

**0. Preparation:**

Firstly, create in terraform a firewall rule that allows ssh access to my virtual services. Then import already existed in GCE firewall rule into Terraform. Then, created IP as a resource, and used this ip in virtual machines. 

Secondly, make terraform configuration for two designated VM's - one for the database server, and another for the application server. With packer, two new images are made, then modules for terraform are created (DB module, APP module, and VPC one for network configuration). Output and input variables are used for more flexibility. 

The modules are then used for separate "stage" and "prod" configurations.

Don't forget `terraform get`, `terraform fmt`, and `tree .terraform` (in order to check the current structure). 

Finally, practice HashiCorp's  "registry": create backet with the help of [storage-bucket](https://registry.terraform.io/modules/SweetOps/storage-bucket/google).

**1. Additional tasks with \*:**

In backend.tf describe the storage of terraform "state" file. Use `prefix = prod` and  `prefix = stage` in order to store different state file in different folders within one backend.
```
terraform {
  backend "gcs"
    bucket = "storage-bucket-is"

    prefix = "prod"

}
```

**2. Additional tasks with \**:**

Make my application work! For that, add provisioners for copying files and provisioner for running bash command:

```
 provisioner "file" {
    content     = "${data.template_file.puma_file.rendered}"
    destination = "/tmp/puma.service"
  }

  provisioner "file" {
    source      = "${path.module}/files/deploy.sh"
    destination = "/tmp/deploy.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp /tmp/puma.service /etc/systemd/system/puma.service",
      "sudo bash /tmp/deploy.sh",
    ]
  }
  ```

  In order to deliver real database VM server ip address to puma.service, I have to utilize template file (".tpl" extention):
  ```
  data "template_file" "puma_file" {
  template = "${file("${path.module}/files/puma.service.tpl")}"

  vars {
    database_url = "${var.db_external_ip}:27017"
  }
}
```
That's because I must insert this line -  `Environment=DATABASE_URL=${database_url}` - in the middle of puma.conf file. Also, I had to tweak mongod.conf file (bindIp should be changed from 127.0.0.1 to 0.0.0.0), and I used provisioners as well (though I could have changed config with packer when I created the image):
```
 provisioner "file" {
    source      = "${path.module}/files/mongod.conf"
    destination = "/tmp/mongod.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl stop mongod",
      "sudo mv /etc/mongod.conf /etc/mongod.conf.old",
      "sudo cp /tmp/mongod.conf /etc/mongod.conf",
      "sudo systemctl start mongod ",
    ]
  }
  ```

  **Note:** the following script provides me with nice picture of infrastructure: `terraform graph -no-color | grep -v -e 'meta.count-boundary' -e 'provider.google\n(close)' | dot -T png >graph.png`

## HW#6 Terraform. Practice IaC.

**0. Preparation:**
Download [terraform](https://releases.hashicorp.com/terraform/0.12.3/terraform_0.12.3_linux_amd64.zip) (note - for this practise we need version 0.11.11), copy file 'terraform' from the archive in $PATH.

In main.tf define provider "google", then run `terraform init`. Then define resource (instance), ssh for this instance, firewall rule, tag for the instance, etc. (see [docs](https://www.terraform.io/docs/providers/google/index.html)). Add provisioners for copying file for our puma systemctl service and run deploy.sh (without manually copying the file to the instance). Define connection for provisioners. Run `terraform plan`, `terraform apply`, `terraform taint`, `terraform destroy`. 

In outputs.tf define output variables, in variables.tf input variables (values of variables in terraform.tfvars).

**1.  Independent practice:**

Define input variables for my private key, VM zone:
```
variable public_key_path {
       description = "Path to the public key used for ssh access"
        }
variable zone {
       description = "Region"
       default = "europe-west1-b"
        }
```
Format files with the command `terraform fmt`.

**2. Additional tasks with \*:**
Add ssh keys in GCE project metadata and delete sshKeys from the instance description:

```
resource "google_compute_project_metadata_item" "default" {
 key = "ssh-keys"
 value = "ivan:${file(var.public_key_path)} \nivan2:${file(var.public_key_path)}"
 project = "${var.project}"
}
```

If some other ssh keys are added in the project manually (e.g. through web GUI), terraform erases it when `apply` is run.

**3. Additional tasks with \**:**

First, I created a load balancer manually:
- Create an instance group:
```
gcloud compute --project=my-project-name instance-groups unmanaged create puma-instance-group --zone=europe-west1-b

gcloud compute --project=my-project-name instance-groups unmanaged add-instances puma-instance-group --zone=europe-west1-b --instances=reddit-app

gcloud compute instance-groups unmanaged set-named-ports puma-instance-group \
   --named-ports http:9292 \
   --zone europe-west1-b
```
- Create load balance (along with backend service and health check):
```
gcloud compute health-checks create http puma-health-check --port 9292
    
gcloud compute backend-services create puma-backend-service \
   --protocol HTTP \
   --health-checks puma-health-check \
   --global
    
gcloud compute backend-services add-backend puma-backend-service \
   --balancing-mode UTILIZATION \
   --max-utilization 0.8 \
   --capacity-scaler 1 \
   --instance-group puma-instance-group \
   --instance-group-zone europe-west1-b \
   --global

gcloud compute url-maps create puma-balancer \
   --default-service puma-backend-service

gcloud compute target-http-proxies create http-lb-proxy \
   --url-map puma-balancer
    
    
gcloud compute forwarding-rules create http-content-rule \
   --global \
   --target-http-proxy http-lb-proxy \
   --ports 80   
```
Then with the help of [documentation](https://www.terraform.io/docs/providers/google/r/compute_instance_group.html), I described load balancer configuration in the file lb.tf. Also, I added variable `node_count` to manage number of instances behind the balancer. This variable is used for creating instances:
```
resource "google_compute_instance" "app" {
 count        = "${var.node_count}"
 name         = "app${count.index}"
```
In this case, number of instances is equal `node_var`, and this array of instances can be used with the sintax: `instances = ["${google_compute_instance.app.*.self_link}"]`. Terraform makes something similar a `for each`, in other words, identifies each instance within the array and return self_links of an actual instance.

!Problems with this configuration:
- load balancer only redirects traffic to instances and doesn't save sessions. As a result, information about logging isn't kept, and it's not possible to write a message in our mock guest book.
- data between instances is not synchronized, so balancer randomly returns pages with different posts (if we make some posts directly on the instances bypassing the balancer).

## HW#5 Build automated machine images with [packer](https://www.packer.io/).

**0. Preparation:**
Download and [install](https://www.packer.io/intro/getting-started/install.html) packer:

```
cd /usr/local/src
sudo curl -O https://releases.hashicorp.com/packer/1.4.2/packer_1.4.2_linux_amd64.zip 
sudo yum install unzip
sudo unzip packer_1.4.2_linux_amd64.zip
sudo rm -f packer_1.4.2_linux_amd64.zip
sudo mv /usr/local/bin/packer /usr/sbin/
```

Create ADC ( [doc](https://cloud.google.com/sdk/gcloud/reference/auth/application-default/login) ):
`gcloud auth application-default login`
(Credentials saved to file: /home/ivan/.config/gcloud/application_default_credentials.json)

Create packer template in the file ubuntu16.json ([gist](https://raw.githubusercontent.com/express42/otus-snippets/master/packer-base/ubuntu16-03-mongo.json ) ).

Check the template: `packer validate ./ubuntu16.json`. For more info, see [docs](https://www.packer.io/docs/templates/index.html)
For deleting 'sudo ' from scripts, in vi editor use `:g/sudo /s///g`


Build a new image: `packer build ubuntu16.json`

**1.  Independent practice:**


In order to make ubuntu16.json parametrized, add "variables" section in the file (see [docs](https://www.packer.io/docs/templates/user-variables.html) ):
```
"variables":
    {
      "gc_project_id": "",
      "gc_source_image_family": "",
      "gc_machine_type": "f1-micro",
      "gc_disk_size": "10",
      "gc_disk_type": "pd-standard",
      "gc_image_description": "",
      "gc_network": "default",
      "gc_tags": "puma-server"
    },
```	

Variables are set in the "variables.json" file. Now, I can build a template with the command:
`packer build -var-file=variables.json ubuntu16.json`.


See docs for Google Compute Builder [here](https://www.packer.io/docs/builders/googlecompute.html#image_labels)


**2. Additional tasks with \*:**

"Bake" a VM image with all necessary dependencies and systemd unit for puma server. Description of the systemd.md file for puma see [here](https://github.com/puma/puma/blob/master/docs/systemd.md).  Info about systemd for newbies see [here](https://habr.com/ru/company/southbridge/blog/255845/). 

Sometimes, GCE couldn't build an image and failed with the error:
  `==> googlecompute: E: Could not get lock /var/lib/dpkg/lock-frontend - open (11: Resource temporarily unavailable)`.
 It seems that changing zones for a new VM helped to fix the problem: ` packer build -var-file=variables.json -var "gc_image_description=image_for_puma_app" -var "gc_machine_type=g1-small" -var "gc_zone=us-central1-b" immutable.json `.

The baked, fully prepared VM can be created with the command 

```
gcloud compute instances create reddit-full-app01 --image-family reddit-full \
--zone europe-west1-b \
--tags puma-server \
--boot-disk-size=10GB \
--restart-on-failure
```

## HW#4 Main services of Google Cloud Platform (GCP).
### Test application deploy

**0. Preparation:**
Create a new VM:
```
gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure
  ```
 
 Install Ruby and bundler:
 ```
sudo apt update
sudo apt install -y ruby-full ruby-bundler build-essential
```

Install and run MongoDB:
```
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'
sudo apt update
sudo apt install -y mongodb-org
sudo systemctl start mongod
sudo systemctl enable mongod
```

Then, deploy our test app:
```
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
puma -d
```
Open port 9292 in the firewall.


**1. Configuration:**

testapp_IP = 104.198.251.218

testapp_port = 9292

**2.  Independent practice 1:**

Following scripts were created and tested:
 - install_ruby.sh for automated installation of Ruby
 - install_mongodb.sh for automated installation of MongoDB
 - deploy.sh for automated downloading and installation the test application (with dependencies with the help of bundler)

Basically, they are consists of the simple commands from the step 0.

**Important!!** All .sh files must have permission to execute them. If a file is committed in git without "x" permission, use command `git update-index --chmod=+x 'name-of-shell-script'`
To check file permissions in git, use `git ls-files --stage`
Changing permissions with `chmod` doesn't work for git.

**3.  Additional task 1: a startup script** 

A new GC virtual machine with the test app can be started with the following command:

gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --metadata-from-file startup-script=install.sh

Note: install.sh has to be placed in the current dir, or you have to write the entire path to the script. 

**4.  Additional task 2: create the firewall rule:**

gcloud compute firewall-rules create default-puma-server1 --allow tcp:9292 \
--source-ranges="0.0.0.0/0" --target-tags puma-server

gcloud [documentation here](https://cloud.google.com/sdk/gcloud/reference/compute/firewall-rules/create) and [here](https://cloud.google.com/vpc/docs/using-firewalls)

## HW#3 First steps into cloud infrastructure and services

**0. Preparation:**

[Install gcloud command-line interface](https://cloud.google.com/sdk/docs/downloads-interactive#linux)

Initialize a project:
```
gcloud init
gcloud projects create infra
gcloud config set project infra
```
For more info, [RTFM](https://cloud.google.com/sdk/docs/)

Generate a ssh key: `ssh-keygen -t rsa -f ~/.ssh/gcloud-iowa-key1 -C gcloud-test-usr
Add the ssh key into agent: `ssh-add ~/.ssh/gcloud-name`

Then, create two VM:
```
gcloud compute instances create bastion --image-project ubuntu-os-cloud --image-family ubuntu-1604-lts  --zone us-central1-c --preemptible --machine-type f1-micro
gcloud compute instances create someinternalhost --image-project ubuntu-os-cloud --image-family ubuntu-1604-lts  --zone us-central1-c --preemptible --machine-type f1-micro --no-address
```

Open http, https: `gcloud compute instances add-tags bastion --tags http-server,https-server --zone us-central1-c `

[Official docs](https://cloud.google.com/sdk/gcloud/reference/)

**1. Configuration:**

bastion_IP = 34.77.163.228  
someinternalhost_IP = 10.128.0.2


**2. Now. it's possible to reach someinternalhost with only one command:**

`ssh -A -t ivan@34.77.163.228 'ssh 10.128.0.2 '`


**3. We need to make a direct connection through the command "SSH someinternalhost"**

Aliases are implemented by usage of '~/.ssh/config' file. The configuration of the file is:

```
Host *
ForwardAgent yes

Host bastion
HostName 34.77.163.228
User ivan

Host someinternalhost
HostName 10.128.0.2
User ivan
ProxyCommand ssh bastion nc %h %p
```

**Important!** Only the owner of the file must have rights for writing. Use `chmod go-w ~/.ssh/config`

**4. VPN:**

[Install Pritunl](https://docs.pritunl.com/docs/installation#section-linux-repositories)


Create and implement a firewall rule:
```
gcloud compute firewall-rules create pritunl --allow udp:15526 --target-tags pritunl
gcloud compute instance add-tags bastion --zone us-central1-c --tags pritunl
```

The final step - ncryption for Pritunl with sslip.io

## HW2 ChatOPS

[Integrate Slack with GitHub](https://get.slack.help/hc/en-us/articles/232289568-GitHub-for-Slack)

For CI, we'll use [Travis CI](https://travis-ci.org/). Add .travis.yml in the root of my repository. Be careful with blanks and format of the file in general.
Install ruby, rubygems, gem "travis":
```
gem install travis
```

**!!Important:** in Centos 7, I had a problem: "ERROR: Failed to build gem native extension". In the end, I was able to build travis-cli after installing these dependencies:
- List item
 - ruby-dev
 - gcc
 - libffi-dev
 - make


Then, authorize and encrypt the password:
```
travis login --com
travis encrypt "devops-team-otus:<my_token>#<name_of_my_chanel>" --add notifications.slack.rooms --com
```
