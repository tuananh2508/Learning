# Start Up Script Ubuntu 18.04LTS

## Cách 1: Dùng Crontab

- B1: Tại cửa sổ Terminal ( Ctrl + Alt + T), sử dụng lệnh `crontab -e `

- B2: sau đó thêm vào dòng lệnh như sau: `@reboot /path/to/script`

`Chú ý sử dụng abs path`

## Cách 2: Dùng systemd

- B1: Tạo Script

Đầu tiên chúng ta sẽ tạo 1 scipt ví dụ khi hệ thống start up

Tại cửa số Terminal nhập lệnh: `sudo nano /usr/local/sbin/my-startup.sh`

Sau đó tự tạo 1 scipt đơn giản 

Tiếp đến chúng ta sẽ cần phải cấp quyền để script có thể chạy được thông qua lệnh `sudo chmod +x /usr/local/sbin/my-startup.sh`

- B2: Tạo file systemd

Sử dụng câu lệnh: sudo nano /etc/systemd/system/my-startup.service

Sau đó sẽ xuất hiện 3 mục như 
> Unit , Service , Install 


Ví dụ như trong mục 

`Unit` : `Description: My Sh Script` - mô tả

`Service` : `ExecStart: /usr/local/sbin/my-startup.sh` - Nơi lưu script

`Install` : `WantedBy=multi-user.target`

- B3 : Bật Service

Có thể kiểm tra trước thông qua lệnh: `systemctl status my-starup.service`

Nếu thông báo hiện ra là Disable thì chúng ta sẽ bật Service thông qua lệnh: `sudo systemctl enable my-starup.service`

có thể kiểm tra lại 1 lần nữa thông qua lệnh `systemctl status my-starup.service`

Nếu đã thấy thay đổi thành Enabled là đã thành công !
