
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
travis encrypt "<ÐºÐ¾Ð¼Ð°Ð½Ð´Ð°>:<Ñ‚Ð¾ÐºÐµÐ½>#<Ð¸Ð¼Ñ_ÐºÐ°Ð½Ð°Ð»Ð°>" --add notifications.slack.rooms --com
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


**1. Configuration:**

testapp_IP = 104.198.251.218
testapp_port = 9292

**2.  Independent practice 1:**

Following scripts were successfully created and tested:
 - install_ruby.sh for automated installation of Ruby
 - install_mongodb.sh for automated installation of MongoDB
 - deploy.sh for automated downloading and installation the test application (with dependancies with the help of bundler)

**Important!!** All .sh files must have permission to execute them. If a file is committed in git without "x" permission, use command `git update-index --chmod=+x 'name-of-shell-script'`
To check file permissions in git, use `git ls-files --stage`

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

Note: install.sh has to be placed in the current dir, or write the entire path to the script. 

**4.  Additional task 2: create the firewall rule:**

gcloud compute firewall-rules create default-puma-server1 --allow tcp:9292 \
--source-ranges="0.0.0.0/0" --target-tags puma-server

gcloud [documentation](https://cloud.google.com/sdk/gcloud/reference/compute/firewall-rules/create)

