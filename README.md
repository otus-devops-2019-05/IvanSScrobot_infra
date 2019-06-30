
# IvanSScrobot_infra 

## HW2 ChatOPS

[Integrate Slack with GitHub](https://get.slack.help/hc/en-us/articles/232289568-GitHub-for-Slack)

For CI, we'll use [Travis CI](https://travis-ci.org/). Add .travis.yml in the root of my repository. Be careful with blanks and format of the file in general.
Install ruby, rubygems, gem "travis":
```
gem install travis
```

**!!Important:** in Centos 7, I had a problem: "ERROR: Failed to build gem native extension". In the end I was able to build travis-cli after installing these dependencies:
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
 
## HW#3 First steps into cloud unfrasrtucture and services

**0. Preparation:**

[Install gcloud command-line interface](https://cloud.google.com/sdk/docs/downloads-interactive#linux)

Initilize a project:
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
 - deploy.sh for automated downloading and installation the test application (with dependancies with the help of bundler)

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

gcloud [documentation](https://cloud.google.com/sdk/gcloud/reference/compute/firewall-rules/create)

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

**1.  Independent practice 1:**


In ubuntu16.json, add "variables" section (see [docs](https://www.packer.io/docs/templates/user-variables.html) ):
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

Variables are set in the "variables.json" file. Now, I can bild a template with the command:
`packer build -var-file=variables.json ubuntu16.json`.


See docs for Google Compute Builder [here](https://www.packer.io/docs/builders/googlecompute.html#image_labels)
