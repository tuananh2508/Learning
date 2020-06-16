# OS ( Open source)

## OS là gì ?

- Open Source là một sản phẩm bao gồm quyền sử dụng code, tài liệu thiết kế hay nội dung của nó. 
Phong trào nguồn mở là phong trào hỗ trợ sử dụng giấy phép cho các phần mềm. 
Các nhà phát triển và lập trình viên đóng góp những mã code của mình và trao đổi chúng để phát triển phần mềm. 
Thuật ngữ Open Source code không phân biệt bất kỳ nhóm hay cá nhân nào khi lấy hay chỉnh sửa code của OSS

## Các lưu ý khi cài đặt OS

- Kiểm tra source trước khi cài đặt vì có thể cài từ một trang source lừa đảo.

## Các bước cài đặt 1 OS

# Nginx 

## NginX là gì và dùng để làm gì ?

- Nginx là một máy chủ proxy ngược mã nguồn mở (open source reverse proxy server) sử dụng phổ biến giao thức HTTP, HTTPS, SMTP, POP3 và IMAP , 
cũng như dùng làm cân bằng tải (load balancer), HTTP cache và máy chủ web (web server). 
Dự án Nginx tập trung vào việc phục vụ số lượng kết nối đồng thời lớn (high concurrency), hiệu suất cao và sử dụng bộ nhớ thấp. 
Nginx được biết đến bởi sự ổn định cao, nhiều tính năng, cấu hình đơn giản và tiết kiệm tài nguyên.

## Cài đặt nginx như thế nào ?

### Trên ubuntu 18.04 LTS

Kiểm tra phiên bản ubuntu thông qua lệnh: `lsb_release -ds`


- B1: Tải xuống source

Có thể tải xuống thông qua lệnh : `wget https://nginx.org/download/nginx-1.15.12.tar.gz`

- B2: Giải nén source

Thực hiện giải nén thông qua lệnh `tar -zxvf nginx-1.15.12.tar.gz`

Kiểm tra lại thư mục đã được giải nén chưa thông qua lệnh ` ls -l`

Tiếp đó chuyển tới thư mực vừa giải nén: `cd nginx-1.15.12/`

- B3: cài Compiler và Dev Tool:

Vì cơ bản nginx được tạo trên code C nên chúng ta cần sử dụng 1 compiler và dev tool thông qua 2 lệnh sau:

```
apt-get install build-essential

apt-get install libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev
```

Sau đó có thể config nginx thông qua lệnh sau: 

`./configure --sbin-path=/usr/bin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log 
--with-pcre --pid-path=/var/run/nginx.pid --with-http_ssl_module`

Với 

```
- sbin-path: nơi chạy nginx, dùng để chạy và dừng server
- conf-path: nơi config nginx
- error-log-path: log lỗi trong quá trình chạy nginx
- http-log-path: log trong quá trình chạy
- with-pcre: nói nginx thư viện pcre của hệ thống cho các đoạn code dùng biểu thức chính quy (regular expression)
- process-id-path: dùng để biết các pid của service thứ 3 mình sẽ sử dụng sau này
```

hoặc đơn giản hơn có thể thông qua lệnh: `./configure` 

lệnh này sẽ cái các đường dẫn mặc định.

Sau khi chạy xong custom config, thực hiện lệnh compile source như sau

`make && make install`

Nếu không phải root có thể thêm `sudo` ở đầu câu lệnh để tiến hành thực thi lệnh

Ở bước cuối cùng kiểm tra lại 1 lần nữa thông qua lệnh: `nginx -v`

nếu cài đặt thành công sẽ nhận được 1 msg như sau: 

> nginx version: nginx/1.15.12

## Tiến hành chạy thử 1 sever

- Vào file config của nginx: `sudo vi /usr/local/nginx/conf/nginx.conf`

tiến hành tìm kiếm
```
server {
        listen       80;
        server_name  localhost;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;
```

vào mode insert chỉnh sửa `listen       80` trở thành `listen       8081`

tiếp theo đó nhập lệnh `cd /usr/local/nginx/sbin/`

sau đó tiếp tục nhập lệnh `sudo ./nginx` để bắt đầu chạy service

truy cập trình duyệt web tiến hành nhập ip của máy với port 8081: 

i.e : http://192.168.18.66:8081/

sẽ thấy thông  báo chạy thành công nginx

có thể tiến hành ngừng service thông qua lệnh `sudo ./nginx -s stop`



