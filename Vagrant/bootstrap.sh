# update packages
apt-get update -y
apt-get upgrade -y
# Basic Linux stuff
apt-get install -y git
apt-get install zip -y

# AWS Cli tools
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -r ./aws