/var/lib/jenkins/jenkins-plugin-cli --plugins \
  google-oauth-credentials \
  docker-workflow \
  pipeline \
  credentials-binding \
  blueocean



sudo cat /var/lib/jenkins/secrets/initialAdminPassword


gcloud compute ssh jenkins-server \
  --project=prj-net-common-pd-host \
  --zone=us-central1-a \
  --tunnel-through-iap


91d5cc02941648b9bcef2f9363d34433


devops-admin@aazads.us

http://34.172.60.242:8080/



gcloud compute start-iap-tunnel jenkins-server 8080 \
  --local-host-port=localhost:8080 \
  --zone=us-central1-a \
  --project=prj-net-common-pd-host

gcloud compute ssh [VM_NAME] --zone=[YOUR_ZONE] --tunnel-through-iap --ssh-flag="-L 8080:localhost:54626"
# OR, for a direct tunnel:
gcloud compute start-iap-tunnel [VM_NAME] [TARGET_PORT] --local-host-port=[NEW_LOCAL_PORT]



http://localhost:8080


wget http://localhost:8080/jnlpJars/jenkins-cli.jar


java -jar jenkins-cli.jar -s http://localhost:8080/ \
  -auth admin:admin \
  install-plugin $(cat plugins.txt)


java -jar jenkins-cli.jar -s http://localhost:8080/ \
  -auth admin:admin \
  install-plugin job-dsl cloudbees-folder credentials structs script-security workflow-aggregator google-oauth-credentials

sudo systemctl restart jenkins

sudo systemctl enable jenkins
    sudo systemctl start jenkins




To increase the performance of the tunnel, consider installing NumPy. For instructions,
please see https://cloud.google.com/iap/docs/using-tcp-forwarding#increasing_the_tcp_upload_bandwidth
