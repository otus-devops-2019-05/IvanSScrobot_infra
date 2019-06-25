# IvanSScrobot_infra
IvanSScrobot Infra repository

**1. Configuration:**

testapp_IP = 104.198.251.218
testapp_port = 9292

**2.Independent practice 1: **
Following scripts were successfully  created and tested:
 - install_ruby.sh for automated installation of Ruby
 - install_mongodb.sh for automated installation of MongoDB
 - deploy.sh for automated downloading and installation the test application (with dependancies with the help of bundler)

**3.Independent practice 2: **

**4.Additional task 1: a startup script **
A new GC virtual machine with the test app can be started with the following command:

gcloud compute instances create reddit-app-01\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --metadata-from-file startup-script=install.sh

Note: install.sh has to be placed in the current dir, or write the entire path to the script. 

**5.Additional task 2: create the firewall rule: **

gcloud compute firewall-rules create default-puma-server1 --allow tcp:9292 \
--source-ranges="0.0.0.0/0" --target-tags puma-server
