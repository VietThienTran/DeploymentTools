# Install Qingdao Online Judge using Docker
An open source online judge based on Vue, Django and Docker.
https://qduoj.com

## Install Docker and Docker-Compose  
```
    sudo apt update
    sudo apt upgrade
    sudo apt install docker.io docker-compose
```
## Build Docker Container
```
    wget https://raw.githubusercontent.com/VietThienTran/DeploymentTools/main/QingdaoOnlineJudge/docker-compose.yml
    sudo docker-compose up -d
``` 
