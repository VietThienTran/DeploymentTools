
## Install docker and docker-compose
```
sudo apt-get update
sudo apt-get upgrade
```

```
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
```

```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

```
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

```

```
sudo apt update
sudo apt-get install docker-ce docker-ce-cli containerd.io
```

```
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

## Install site using docker-compose
```
git clone https://github.com/hnojedu/hnoj-docker
cd hnoj-docker
git submodule update --init --recursive
cd dmoj
```
Change logo, icon, footer before initialize setup.
```
./scripts/initialize
```
Config environment, nginx and local_settings

Build iamge
```
docker compose build
docker compose up -d site
./scripts/migrate
./scripts/copy_static
./scripts/manage.py loaddata navbar
./scripts/manage.py loaddata language_small
./scripts/manage.py loaddata demo
docker compose up -d
```

## Install judge-server
Create judge.yml (/home/devsmile/hnoj-docker/dmoj/problems/judge.yml)
```
id: <judge name>
key: <judge authentication key>
problem_storage_globs:
  - /problems/*
```

Create judge image
```
apt install supervisor make
git clone --recursive https://github.com/VNOI-Admin/judge-server.git
cd judge/.docker
make judge-tiervnoj
```

```
docker run \
    --name judge \
    --network="host" \
    -v /home/devsmile/hnoj-docker/dmoj/problems:/problems \
    --cap-add=SYS_PTRACE \
    -d \
    --restart=always \
    vnoj/judge-tiervnoj:latest \
    run -p 9999 -c /problems/judge.yml localhost id key
```
