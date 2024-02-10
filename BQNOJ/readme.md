# Hướng dẫn cài đặt hệ thống chấm điểm trực tuyến VNOJ sử dụng Docker
Với Docker, quá trình cài đặt của bạn sẽ giảm thiểu được xung đột với những phần mềm khác được cài trên máy, giúp hệ thống hoạt động ổn định hơn.
## Chuẩn bị
### Một số yêu cầu về hệ thống:

✅ OS: Ubuntu 20.04 trở lên

✅ Storage: 20GB trở lên

✅ CPU: 1 core trở lên

✅ RAM: 1 GB trở lên

Tùy theo thực tế và nhu cầu sử dụng, cấu hình và các thông số có thể thay đổi. Ở đây, mình sử dụng 02 máy với cấu hình như sau: 

* Máy chủ (tạm gọi là Local Server) - Cài đặt webserver và chạy 02 máy chấm song song (judge):
   
✅ Ubuntu 22.04 Server/2 Core/4 GB RAM/60 GB SSD

✅ Username: devsmile

✅ IP: 192.168.1.14/24

✅ Judgename: judge01, judge02

✅ MySQL password: greenhat1998

* Máy chấm từ xa (tạm gọi là Remote Judge) - Cài đặt 01 máy chấm và kết nối đến Local Server, áp dụng trong trường hợp bạn muốn tăng tốc độ chấm khi Local Server quá tải:
  
✅ Ubuntu 20.04 Server/1 Core/2 GB RAM/60 GB SSD
✅ Username: judger

✅ IP: 192.168.1.16/24

✅ Judgename: judge03

✅ Kết nối được đến Local Server qua SSHFS

## Cài đặt Docker và Docker-Compose
Thực hiện trên Local Server và Remote Judge (nếu có)
### Cài đặt Docker 
> Tham khảo cách cài đặt từ [document chính thức của Docker](https://docs.docker.com/engine/install/ubuntu/)

Set up Docker's apt repository.
```
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```
Install the Docker packages.
```
sudo apt-get install docker-ce docker-ce-cli containerd.io 
```
> Note: Hiện tại, chỉ có sudo mới có thể chạy các lệnh của Docker. Để các user khác cũng chạy được, cần thêm `sudo` vào trước các câu lệnh. Các lỗi như "docker: Got permission denied while trying to connect to the Docker daemon.." thường là do thiếu sudo trước câu lệnh.

## Cài đặt Docker-Compose
Tải binary chính thức từ github docker-compose (v1.29.2)
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
Thêm quyền thực thi cho file binary
sudo chmod +x /usr/local/bin/docker-compose
Cài đặt site
Bước này chỉ thực hiện trên local server
Tải về mã nguồn
git clone --recursive https://github.com/VNOI-Admin/vnoj-docker.git
cd vnoj-docker/dmoj
Kể từ lúc này, các câu lệnh đằng sau sẽ giả định rằng thư mục hiện hành là /dmoj
Cấu hình môi trường cho Docker
Đây là bước sẽ thay đổi cấu hình cho server nhằm phù hợp hơn với mục đích cài đặt và tăng tính bảo mật cho server.
Có 3 nơi mà bạn cần chỉnh sửa:
dmoj/environment/
Nơi này chứa các biến môi trường của server.
Đổi tên các file .example tương ứng thành: mysql-admin.env, mysql.env, site.env
1. mysql.env
MYSQL_DATABASE=dmoj
MYSQL_USER=dmoj
MYSQL_PASSWORD=greenhat1998			#thay doi password
2. mysql-admin.env
MYSQL_ROOT_PASSWORD=greenhat1998		#thay doi password
3. site.env
HOST=192.168.1.14					#thay bang IP cua server
SITE_FULL_URL=http://192.168.1.14/
MEDIA_URL=http://192.168.1.14/
DEBUG=0
SECRET_KEY=abcdefghijklmnopqrstuvwxyz		#thay doi bang ma tuy y
dmoj/nginx/conf.d/nginx.conf
Cấu hình tên server_name thành 192.168.1.14
dmoj/local_settings.py
Thêm các thông tin cấu hình email để thực hiện xác thực tài khoản (có thể bỏ qua nếu không sử dụng tính năng này
Thêm REGISTRATION_OPEN = True vào cuối file
Build Docker Image
Khởi tạo trước khi build
./scripts/initialize
Build image
sudo docker-compose build
Khởi động thành phần site để cấu hình
sudo docker-compose up -d site
Khởi tạo bảng cho Database
sudo ./scripts/migrate
Khởi tạo các file static
sudo ./scripts/copy_static
Load dữ liệu cần thiết cho Website
sudo ./scripts/manage.py loaddata navbar
sudo ./scripts/manage.py loaddata language_small
sudo ./scripts/manage.py loaddata demo
Dữ liệu khởi tạo bao gồm:
Highlight cho C++, Python,…
Bài đăng "Hello World"
Problem "A + B"
Tài khoản superuser "admin":
Username: admin
Password: admin
Khởi động VNOJ
Quá trình cài đặt đã hoàn tất. Chạy câu lệnh bên dưới để khởi động tất cả các docker trong mạng lưới.
sudo docker-compose up –d
Truy cập http://192.168.1.14 để kiểm tra kết quả.
Truy cập bài tập mẫu A+B và tiến hành upload testcase để kiểm tra.
Cài đặt judge
Để đơn giản trong quá trình cài đặt, chúng ta sẽ tiếp tục cài đặt judge sử dụng Docker
Note:
	- Nếu judge chạy trên local server, không cần cài đặt lại docker.
	- Nếu judge là remote judge, tiến hành cài đặt Docker theo hướng dẫn bên trên (không cần cài Docker-Compose)
Thiết lập cấu hình judge trên admin site
Truy cập http://192.168.1.14/admin/judge/
Tạo các judge, lưu lại tên judge và key (ví dụ ở đây tạo 03 judge là judge01, judge02, judge03)
Tạo môi trường biên dịch 
Tải về môi trường biên dịch
git clone https://github.com/VNOI-Admin/judge-server
cd judge-server/.docker
sudo apt install make
sudo make judge-tiervnoj
Có thể thay thế tiervnoj bằng tier1, tier2, tier3 (tier càng cao thì dung lượng càng lớn, tích hợp nhiều ngôn ngữ hơn).
Tạo judge trên local server
Tạo các file cấu hình tương ứng với mỗi judge có dạng là judge_name.yml (tên judge) và ghi những thông tin sau vào file:
id: <judge name>
key: <judge authentication key>
problem_storage_globs:
  - /problems/*
Ở đây, ta sẽ chạy 2 máy chấm judge01 và judge02 trên local server
Build Docker Image
sudo docker run \
    --name judge_name \
    --network="host" \
    -v /home/devsmile/vnoj-docker/dmoj/problems:/problems \
    --cap-add=SYS_PTRACE \
    -d \
    --restart=always \
    vnoj/judge-tiervnoj:latest \
    run -p 9999 -c /problems/judge_name.yml 192.168.1.14 -A 0.0.0.0 -a 9111
Note: 	- Thay thế judge_name, đường dẫn đến thư mục problem và IP tương ứng với thực tế
		- Các judge chạy trên cùng local server phải có ID khác nhau (thay 9111 thành 9112, 9113, ...)
- Để đảm bảo hệ thống hoạt động ổn định, theo quan điểm cá nhân của tôi, với máy local server có N core thì chỉ nên chạy N-1 judge.
Tạo judge trên remote
Tạo folder để mount dữ liệu từ local server
cd /home/judger
mkdir problems
sudo chmod 775 –R problems
Mount folder problems trên local server về remote judge
sudo apt install sshfs 
sudo addgroup judger root
sudo sshfs devsmile@192.168.1.14:/home/devsmile/vnoj-docker/dmoj/problems /home/judger/problems -o allow_other
cd /home/judger/problems
Tạo file cấu hình tương ứng với judge có dạng là judge_name.yml (tên judge) và ghi những thông tin sau vào file:
id: <judge name>
key: <judge authentication key>
problem_storage_globs:
  - /home/judger/problems/*
Build Docker Image
sudo docker run \
    --name judge_name \
    --network="host" \
    -v /home/judger/problems:/problems \
    --cap-add=SYS_PTRACE \
    -d \
    --restart=always \
    vnoj/judge-tiervnoj:latest \
    run -p 9999 -c /home/judger/problems/judge_name.yml 192.168.1.14 -A 0.0.0.0 -a 9111
