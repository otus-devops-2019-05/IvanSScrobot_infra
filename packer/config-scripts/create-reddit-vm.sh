gcloud compute instances create reddit-full-app01 --image-family reddit-full \
--zone europe-west1-b \
--tags puma-server \
--boot-disk-size=10GB \
--restart-on-failure 

