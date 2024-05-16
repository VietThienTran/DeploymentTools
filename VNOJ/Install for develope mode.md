# Hướng dẫn cài đặt hệ thống chấm điểm trực tuyến VNOJ - Dev Mode

Hướng dẫn này được xây dựng dựa trên [tài liệu chính thức của DMOJ](https://docs.dmoj.ca/). Trong quá trình cài đặt, một số bước đã được lược bỏ để đơn giản hóa việc cài đặt.

> Các thông số đã được cấu hình tự động để quá trình cài đặt diễn ra nhanh hơn. Thông tin các file cấu hình có thể tham khảo [tại đây](https://github.com/VietThienTran/DeploymentTools/tree/main/VNOJ/sample-config)

## Chuẩn bị môi trường cài đặt
### Một số yêu cầu về hệ thống:

✅ OS: Ubuntu 20.04 trở lên

✅ Storage: 20 GB trở lên

✅ CPU: 1 core trở lên

✅ RAM: 1 GB trở lên

Tùy theo thực tế và nhu cầu sử dụng, cấu hình và các thông số có thể thay đổi. Ở đây, mình sử dụng máy với cấu hình như sau: 

✅ Ubuntu 22.04 Server/2 Core/4 GB RAM/30 GB SSD

✅ Username: devsmile

✅ IP: 192.168.1.17/24

✅ Judgename: judge01

✅ MySQL password: greenhat1998

## Cài đặt Site và Judge tự động - One-click deployment
Tải về file cài đặt tự động và các file cấu hình mẫu.
```
wget https://raw.githubusercontent.com/VietThienTran/DeploymentTools/main/VNOJ/sample-config/auto-install.sh
wget https://raw.githubusercontent.com/VietThienTran/DeploymentTools/main/VNOJ/sample-config/local_settings.py
wget https://raw.githubusercontent.com/VietThienTran/DeploymentTools/main/VNOJ/sample-config/judge01.yml
```
Thay thế một số thông số cho phù hợp với hệ thống.
- User Ubuntu
- Password mysql
- Secret key (file local_settings.py)
- Judge key (file auto-install.sh và judge01.yml)

Khởi chạy script cài đặt tự động
```
bash auto-install.sh
```

## Khởi chạy hệ thống
Mỗi lần khởi động hệ thống, tiến hành chạy các lệnh sau theo thứ tự

```
cd ~
. venv/bin/activate
cd site
nohup ./manage.py runbridged &                  # Bat bridged de ket noi site voi judge
nohup dmoj -c problems/judge01.yml 127.0.0.1 &  # Bat judge
nohup ./manage.py runserver 0.0.0.0:8000 &      # Bat site
```
Có thể thay thế cổng 8000 bằng các cổng khác nếu cần thiết.

Kiểm tra ở mục **STATUS** trên website để xem trạng thái kết nối của Judge đến Site. Sau đó thử nộp bài với các máy chấm khác nhau để kiểm tra kết quả.

Chúc các bạn thành công. 

From Greenhat with love!!!
### Reach out to me 👓
<a href="https://www.facebook.com/VietThienTran.301"><img src="https://cdn0.iconfinder.com/data/icons/social-messaging-ui-color-shapes-2-free/128/social-facebook-2019-circle-512.png" width="32px" height="32px"> </a><a href="https://www.youtube.com/@vietthientran3140"><img src="https://cdn.icon-icons.com/icons2/1907/PNG/512/iconfinder-youtube-4555888_121363.png" width="32px" height="32px"></a>

