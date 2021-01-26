# Docker-Compose

![Docker-Compose/Untitled.png](Docker-Compose/Untitled.png)

**Mục lục**
- [Docker-Compose](#docker-compose)
- [1. Tổng quan về Docker Compose](#1-tổng-quan-về-docker-compose)
- [2. Cú pháp trong file Docker Compose](#2-cú-pháp-trong-file-docker-compose)
    - [build](#build)
    - [restart](#restart)
    - [environment](#environment)
    - [depends_on](#depends_on)
    - [container_name](#container_name)
- [3. Các lệnh với Docker Compose](#3-các-lệnh-với-docker-compose)
    - [Kiểm tra phiên bản của Docker Compose](#kiểm-tra-phiên-bản-của-docker-compose)
    - [Kiểm tra file cấu hình Docker Compose](#kiểm-tra-file-cấu-hình-docker-compose)
    - [Thực hiện Build lại cấu hình của Service](#thực-hiện-build-lại-cấu-hình-của-service)
    - [Pull Image của các Service trong Docker Compose](#pull-image-của-các-service-trong-docker-compose)
    - [Push các Image lên Docker Hub](#push-các-image-lên-docker-hub)
    - [Tiến hành Build và chạy các Services trên Host OS](#tiến-hành-build-và-chạy-các-services-trên-host-os)
    - [Liệt kê các Container của Docker Compose](#liệt-kê-các-container-của-docker-compose)
    - [Dừng (Stop)  và tạm dừng (Paused) hoạt đồng của Docker Compose](#dừng-stop--và-tạm-dừng-paused-hoạt-đồng-của-docker-compose)
    - [Start và Restart Docker Compose](#start-và-restart-docker-compose)
    - [Xem Logs của các Container trong Docker Compose](#xem-logs-của-các-container-trong-docker-compose)
    - [Xem Public Port của 1 Container](#xem-public-port-của-1-container)
    - [Lệnh `docker-compose run`](#lệnh-docker-compose-run)
    - [Tăng số lượng Container với `docker-compose scale`](#tăng-số-lượng-container-với-docker-compose-scale)
- [4. Ứng dụng sử dụng Flask và Redis với Docker Compose](#4-ứng-dụng-sử-dụng-flask-và-redis-với-docker-compose)
- [5. Ứng dụng xây dựng ứng dụng Wordpress và Redis với Docker](#5-ứng-dụng-xây-dựng-ứng-dụng-wordpress-và-redis-với-docker)
- [6. Xây dựng LEMP Stack](#6-xây-dựng-lemp-stack)
  - [Tạo file `index.php` cho dịch vụ php](#tạo-file-indexphp-cho-dịch-vụ-php)
  - [Tạo file cấu hình cho Nginx](#tạo-file-cấu-hình-cho-nginx)
  - [Tạo Dockerfile cho dịch vụ Php](#tạo-dockerfile-cho-dịch-vụ-php)
  - [Tạo file Docker Compose](#tạo-file-docker-compose)
- [7. Xây dựng Dockerfile và Docker Compose cho Cachet](#7-xây-dựng-dockerfile-và-docker-compose-cho-cachet)
  - [7.1 Xây dựng Dockerfile](#71-xây-dựng-dockerfile)
  - [7.2 Xây dựng file Docker Compose](#72-xây-dựng-file-docker-compose)
- [8. Dockerized Gitea](#8-dockerized-gitea)



# 1. Tổng quan về Docker Compose

Docker Compose là một công cụ cho phép chúng ta thực hiện tạo ra một cụm các Container (Multi-Container)  hoạt động với nhau để chạy 1 ứng dụng và các tài nguyên của ứng dụng này sẽ được Docker Compose quản lý ( Network, Cơ sở dữ liệu ... )

Docker Compose được ứng dụng trong nhiều giai đoạn khác nhau của Workflow như Dev stage, Test stage , ...

Docker Compose hoạt động dựa trên 3 bước cơ bản là :

1. Tạo ra một file Dockerfile → Đảm bảo ứng dụng của bạn có thể sử dụng tại bất cứ đâu
2. Tạo ra một file Docker Compose trong đó định nghĩa các service và các thông số của service để giúp cho hệ thống hoạt động
3. Sử dụng lệnh `docker-compose up` để khởi động ứng dụng hay cụm Container này lên

Các ứng dụng của Docker Compose :

- Cho phép tạo ra các môi trường độc lập với nhau trên cùng 1 Host
- Cho phép các Container mới khi sử dụng lệnh `docker-compose up` sẽ có thể sử dụng lại dữ liệu mà các Contain cũ đã có sẵn
- Khi tiến hành Reboot Cluster thì chỉ tạo lại các Container đã bị thay đổi ( như là bị remove ), còn đối với các Container thì sẽ tiến hành sử dụng luôn

Để cài đặt Docker Compose ta thực hiện như sau

```bash
# Tải phiên bản ổn định ( Stable ) của Docker Compose về
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# Cấp quyền cho Docker Compose
sudo chmod +x /usr/local/bin/docker-compose
# Kiểm tra lại việc cài đặt
$ docker-compose --version
docker-compose version 1.27.4, build 1110ad01
```

# 2. Cú pháp trong file Docker Compose

### build

Các thiết lập cấu hình khi thực hiện Build Image `build: <path-to-docker-file>`:

```bash
version: "3.9"
service:
  web:
    build: .
# Hoac su dung
#   build:
#     context: . # Đường dẫn thực hiện Build
#     dockerfile: dockerfilev1 # Dockerfile được chỉ định build
#     arg: # giá trị các biến môi trường khi thực hiện Build 
#       buildno: 1 # Đánh số phiên bản 
```

### restart

Định nghĩa chính sách thực hiện khi Container Exit

```bash
restart: "no" # Không thực hiện việc Restart Container
restart: always # Luôn thực hiện Restart Container
restart: on-failure # Chỉ thực hiện Restart Container khi Container gặp lỗi
restart: unless-stopped # Thực hiện Restart Container, không thực hiện Container gặp lệnh Stop
```

### environment

Các biến môi trường được sử dụng, nhập theo cú pháp như sau :

```bash
environment:
  USER: Tuan-Anh # Biến môi trường USER có giá trị là Tuan-Anh
  PASSWORD: word1234 # Biến môi trường PASSWORD có giá trị là word1234
```

Nếu muốn sử dụng với `build` thì cần thực hiện sử dụng định nghịa biến môi trường với `arg`

### depends_on

Do một số loại dịch vụ khi thực hiện khởi động thì cần một số các dịch vụ khác trong cụm Multi-Container khởi động trước để đảm bảo hệ thống hoạt động trơn tru với nhau. Ví dụ:

```bash
nginx: # dịch vụ Nginx
    depends_on: # sẽ phụ thuộc vào ~ Sẽ khởi động sau 
      - php # Dịch vụ Php
```

→ Khi khởi động dịch vụ `nginx` thì nó sẽ khởi động dịch vụ `php` trước

```bash
service:
  redis: # Dịch vụ Redis
    image: redis # Tải Image redis:latest
  db: # Dịch vụ Database
    image: postgres # Tải Image postgres:latest
  web: # Dịch vụ Web
    depends_on: # Khởi động sau các dịch vụ 
      - db
      - redis

```

### container_name

Đặt tên cho Container khi nó được khởi động với Docker Compose:

```bash
nginx: # Dịch vụ Nginx
    container_name: lemp-nginx # Tên của Container sau khi khởi động
```

→ Container sau khi khởi động sẽ có tên là `lemp-nginx` 

# 3. Các lệnh với Docker Compose

### Kiểm tra phiên bản của Docker Compose

```bash
(19:19:15) ○ [root@ubun-server-2] ~
→ docker-compose version # Câu lệnh kiểm tra phiên bản
docker-compose version 1.27.4, build 40524192
docker-py version: 4.3.1
CPython version: 3.7.7
OpenSSL version: OpenSSL 1.1.0l  10 Sep 2019
```

### Kiểm tra file cấu hình Docker Compose

```bash
(19:20:14) ○ [root@ubun-server-2] ~/dock-comp
→ docker-compose config # Câu lệnh kiểm tra cấu hình
services:
  db:
    image: redis
    restart: always
  wordpress:
    image: wordpress:latest
    ports:
    - published: 8000
      target: 80
    restart: always
version: '3.9'
```

Nếu có lỗi trong file cấu hình thì sẽ nhận được kết quả

```bash
(19:21:50) ○ [root@ubun-server-2] ~/dock-comp
→ docker-compose config
ERROR: The Compose file './docker-compose.yml' is invalid because:
Unsupported config option for service: 'wordpress'
```

### Thực hiện Build lại cấu hình của Service

Đối với các Service không sử dụng Image mà tiến hành Build từ đầu, thì chúng ta có thể sử dụng lệnh `docker-compose build <Tên-Service>` để Build lại Service trong trường hợp có thay đổi trong Dockerfile

```bash
(19:31:15) ○ [root@ubun-server-2] ~/build-dck
→ docker-compose build ubun
Building ubun
Step 1/3 : FROM ubuntu
 ---> f643c72bc252
Step 2/3 : RUN apt-get update
 ---> Using cache
 ---> 52d00c6ced8a
Step 3/3 : CMD ["echo", "Hello World]
 ---> Using cache
 ---> 2e79b5613cd2

Successfully built 2e79b5613cd2
Successfully tagged build-dck_ubun:latest
```

Tuy nhiên sẽ gặp lỗi nếu đối tượng được Build sử dụng Image :

```bash
(19:26:04) ○ [root@ubun-server-2] ~/dock-comp
→ docker-compose build db
db uses an image, skipping
```

### Pull Image của các Service trong Docker Compose

Ta xét 1 file Docker Compose có dạng như sau 

```bash
(05:46:45) ○ [root@ubun-server-2] ~/docker-compose
→ docker-compose config
services:
  db:
    image: redis # sử dụng image redis mới nhất
    restart: always # luôn khởi động lại container nếu gặp lỗi
  wp:
    image: wordpress # sử dụng image wordpress mới nhất
    ports: # Mapping port 8080 với port 80
    - published: 8080
      target: 80
    restart: always # luôn khởi động lại container nếu gặp lỗi
version: '3.9'
```

Để Pull các Image nhưng chưa xây dựng Service thì ta sử dụng lệnh `docker-compose pull` ( Nếu trong trường hợp bạn chỉ 1 Pull Image của 1 ứng dụng cụ thể thì sẽ thêm tên ở sau phần `pull` )

```bash
(05:46:49) ○ [root@ubun-server-2] ~/docker-compose
→ docker-compose pull
Pulling db ... done
Pulling wp ... done
(05:49:04) ○ [root@ubun-server-2] ~/docker-compose
→ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
wordpress           latest              bc5f6567b763        2 days ago          550MB
redis               latest              ef47f3b6dc11        3 days ago          104MB
```

→ Như vậy đã thấy sự xuất hiện của 2 Image `wordpress` và `redis` 

### Push các Image lên Docker Hub

Để thực hiện việc này, đầu tiên chúng ta cần có 1 Image :

```bash
FROM ubuntu # Từ Image Ubuntu bản chính thức từ Docker Hub
RUN apt-get update && \ # Chạy các lệnh Update repo và cài đặt neovim
    apt-get install neovim -y
CMD ["echo","hello"] 
```

Xét 1 file Docker Compose như sau :

```bash
services: # Định nghĩa các dịch vụ 
        os: # Dịch vụ OS
          build: # Tiến hành Build Custom Image
            context: . # Nơi Build của Image sẽ là thư mục hiện tịa
            dockerfile: dockerfile # Dockerfile để build Image có tên là "dockerfile"
          image: ta2199/private-repo:v1 # Đặt tên cho Image sau khi build
          # Lưu ý: Chúng ta cần đặt tên theo Image theo cú pháp <user-name>/<Repo>:<tag>
```

Sau đó thực hiện việc Build Image này :

```bash
(06:03:31) ○ [root@ubun-server-2] ~/docker-compose
→ docker-compose build
Building os
Step 1/3 : FROM ubuntu
...
```

Sau khi Build xong thì sẽ tiến hành Push Image này lên Docker Hub:

```bash
(06:05:42) ○ [root@ubun-server-2] ~/docker-compose
→ docker-compose push
Pushing os (ta2199/private-repo:v1)...

```

Kiểm tra kết quả trên Docker Hub :

![Docker-Compose/Untitled%201.png](Docker-Compose/Untitled%201.png)

### Tiến hành Build và chạy các Services trên Host OS

Sau khi đã biết cách Build và Pull các Image về, cũng như 1 vài cú pháp cơ bản của Docker Compose, thì bây giờ ta sẽ thực hiện việc Build và chạy các Services ngay trên Host OS. Xét 1 file Docker Compose như sau:

```bash
version: "3.9" # sử dụng Docker Compose phiên bản 3.9
services:  # Định nghĩa các dịch vụ 
  db: # Dịch vụ db
    build: # Thực hiện Build Image
      context: . # Việc build diễn ra ở thư mục chứa Docker-compose
      dockerfile: dockerfile # Dockerfile được sử dụng có tên dockerfile
    image: db-img:v1 # sau khi Build thì Image sẽ có tên db-img, tag là v1
```

Khi sử dụng, `docker-compose up -d` thì sẽ tạo ra 1 Image có tên là `db-img:v1`

```bash
(09:42:52) ○ [root@ubuntu] ~/testdocker 
→ docker images
REPOSITORY              TAG                 IMAGE ID            CREATED             SIZE
db-img                  v1                  00d341e408aa        25 minutes ago      99.2MB
```

Để liệt kê các Image được sử dụng bởi Docker Compose:

```bash
(09:49:22) ○ [root@ubuntu] ~/testdocker 
→ docker-compose images 
   Container      Repository   Tag     Image Id      Size  
-----------------------------------------------------------
testdocker_db_1   db-img       v1    00d341e408aa   99.2 MB
```

Như vậy có 1 Container đang sử dụng Image `db-img:v1`

### Liệt kê các Container của Docker Compose

```bash
(09:52:21) ○ [root@ubuntu] ~/test-docker 
→ docker-compose ps
       Name                    Command            State           Ports         
--------------------------------------------------------------------------------
test-docker_redis_1   docker-entrypoint.sh        Up      6379/tcp              
                      redis ...                                                 
test-docker_web_1     flask run                   Up      0.0.0.0:5000->5000/tcp
```

→ Có 2 Container đang chạy trên hệ thống

### Dừng (Stop)  và tạm dừng (Paused) hoạt đồng của Docker Compose

Giả sử ta có 1 dịch vụ Docker Compose đang chạy :

```bash
(09:54:40) ○ [root@ubuntu] ~/test-docker 
→ docker-compose ps
       Name                    Command            State           Ports         
--------------------------------------------------------------------------------
test-docker_redis_1   docker-entrypoint.sh        Up      6379/tcp              
                      redis ...                                                 
test-docker_web_1     flask run                   Up      0.0.0.0:5000->5000/tcp
(09:54:53) ○ [root@ubuntu] ~/test-docker 
→ docker-compose stop
Stopping test-docker_redis_1 ... done
Stopping test-docker_web_1   ... done
(09:55:06) ○ [root@ubuntu] ~/test-docker 
→ docker-compose ps
       Name                      Command               State    Ports
---------------------------------------------------------------------
test-docker_redis_1   docker-entrypoint.sh redis ...   Exit 0        
test-docker_web_1     flask run                        Exit 0
```

Cũng giống như Docker Container bình thường, lệnh stop Container sẽ thực hiện giải phóng bộ nhớ Container đang sử dụng còn đối với lệnh paused thi Container vẫn sẽ tiếp tục chiếm dụng bộ nhớ

```bash
(09:59:36) ○ [root@ubuntu] ~/test-docker 
→ docker-compose ps
       Name                   Command            State            Ports         
--------------------------------------------------------------------------------
test-docker_redis_1   docker-entrypoint.sh       Paused   6379/tcp              
                      redis ...                                                 
test-docker_web_1     flask run                  Paused   0.0.0.0:5000->5000/tcp
(10:00:28) ○ [root@ubuntu] ~/test-docker 
→ docker ps -a
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                       PORTS                    NAMES
267cac44a0a9        redis:alpine        "docker-entrypoint.s…"   6 minutes ago       Up About a minute (Paused)   6379/tcp                 test-docker_redis_1
a888ca3f0ce2        test-docker_web     "flask run"              6 minutes ago       Up About a minute (Paused)   0.0.0.0:5000->5000/tcp   test-docker_web_1
(10:01:12) ○ [root@ubuntu] ~/test-docker 
→ docker stats
CONTAINER ID        NAME                  CPU %               MEM USAGE / LIMIT     MEM %               NET I/O             BLOCK I/O           PIDS
267cac44a0a9        test-docker_redis_1   0.00%               3.109MiB / 3.644GiB   0.08%               3.65kB / 0B         2.63MB / 0B         5
a888ca3f0ce2        test-docker_web_1     0.00%               42.17MiB / 3.644GiB   1.13%               3.98kB / 0B         3.12MB / 0B         3
```

### Start và Restart Docker Compose

Giả sử ta có 2 Container được sử dụng bởi Docker Compose ở trạng thái Pause hoặc Stop. Ta sẽ sư dụng lệnh `docker-compose start` để khởi động toàn bộ dịch vụ này :

```bash
(10:03:47) ○ [root@ubuntu] ~/test-docker 
→ docker-compose ps
       Name                      Command               State    Ports
---------------------------------------------------------------------
test-docker_redis_1   docker-entrypoint.sh redis ...   Exit 0        
test-docker_web_1     flask run                        Exit 0
(10:03:51) ○ [root@ubuntu] ~/test-docker 
→ docker-compose start
Starting web   ... done
Starting redis ... done

```

Lệnh Restart sẽ giúp ta thực hiện việc Stop rồi Start dịch vụ Docker Compose:

```bash
(10:07:54) ○ [root@ubuntu] ~/test-docker 
→ docker-compose restart
Restarting test-docker_redis_1 ... done
Restarting test-docker_web_1   ... done
```

Để quan sát quá trình này ta có thể sử dungj lệnh `docker events`

### Xem Logs của các Container trong Docker Compose

```bash
(10:12:38) ○ [root@ubuntu] ~/test-docker                               
→ docker-compose logs                                                  
Attaching to test-docker_web_1, test-docker_redis_1                    
redis_1  | 1:C 15 Dec 2020 03:12:38.808 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
redis_1  | 1:C 15 Dec 2020 03:12:38.808 # Redis version=6.0.9, bits=64, commit=00000000, modified=0, pid=1, just started
redis_1  | 1:C 15 Dec 2020 03:12:38.808 # Warning: no config file specified, using the default config. In order to specify a config file use redis-server /path/to/redis.conf
redis_1  | 1:M 15 Dec 2020 03:12:38.879 * Running mode=standalone, port=6379.
redis_1  | 1:M 15 Dec 2020 03:12:38.879 # Server initialized
redis_1  | 1:M 15 Dec 2020 03:12:38.879 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf a
nd then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
redis_1  | 1:M 15 Dec 2020 03:12:38.881 * Ready to accept connections
web_1    |  * Serving Flask app "app.py" (lazy loading)
web_1    |  * Environment: development
web_1    |  * Debug mode: on
web_1    |  * Running on http://0.0.0.0:5000/ (Press CTRL+C to quit)
web_1    |  * Restarting with stat
```

### Xem Public Port của 1 Container

Chúng ta sử dụng cú pháp sau `docker-compose port <tên-service> <port>` . Ví dụ  xét 1 file Docker Compose sau :

```bash
(10:56:18) ○ [root@Intern-Server] ~/docker 
→ docker-compose config
services:
  redis:
    image: redis:alpine
  web:
    build:
      context: /root/docker
    environment:
      FLASK_ENV: development
    ports:
    - published: 5000
      target: 5000
    volumes:
    - /root/docker:/code:rw
version: '3.9'
```

→ Từ file này ta thấy rằng Service `web` được mapping port 5000 của host với port 5000 của Container

Vậy khi sử dụng lệnh `docker-compose port` ta thu được

```bash
(10:56:51) ○ [root@Intern-Server] ~/docker 
→ docker-compose port web 5000
0.0.0.0:5000
```

→ Đúng với những gì được định nghĩa trong Docker Compose

### Lệnh `docker-compose run`

Lệnh này giống như khi chúng ta sử dụng  `docker run` , `docker-compose run` sẽ tạo ra 1 Container mới sử dụng Service của Docker Compose. Xét file Docker Compose sau 

```bash
→ docker-compose config
services: 
  dbserver:
    container_name: Mysqldb
    environment:
      MYSQL_DATABASE: test
      MYSQL_PASSWORD: Pa$$w0rd123
      MYSQL_ROOT_PASSWORD: Pa$$w0rd
      MYSQL_USER: test
    image: mysql:5.7
    ports:
    - published: 3306
      target: 3306
    restart: unless-stopped
    volumes:
    - db_data:/var/lib/mysql:rw
  webserver:
    container_name: Nginx
    image: nginx:alpine
    ports:
    - published: 80
      target: 80
    - published: 443
      target: 443
    restart: unless-stopped
version: '3.7'
volumes:
	  db_data: {}
(11:12:24) ○ [root@Intern-Server] ~/nginx-mysql-docker 
→ docker-compose run webserver /bin/sh
Creating nginx-mysql-docker_webserver_run ... done
/ #
(11:13:19) ○ [root@Intern-Server] ~/nginx-mysql-docker 
→ docker-compose ps -a
                    Name                                   Command               State                    Ports                  
---------------------------------------------------------------------------------------------------------------------------------
Mysqldb                                         docker-entrypoint.sh mysqld      Up      0.0.0.0:3306->3306/tcp, 33060/tcp       
Nginx                                           /docker-entrypoint.sh ngin ...   Up      0.0.0.0:443->443/tcp, 0.0.0.0:80->80/tcp
nginx-mysql-docker_webserver_run_e71254827dd7   /docker-entrypoint.sh /bin/sh    Up      80/tcp
```

Như vậy đã có thêm 1 Container mới sử dụng dịch vụ của Docker Compose

Một số Option khác bao gồm tham khảo qua câu lệnh 

```bash
(11:13:22) ○ [root@Intern-Server] ~/nginx-mysql-docker 
→ docker-compose run --help
Run a one-off command on a service.
```

### Tăng số lượng Container với `docker-compose scale`

Lệnh này cho phép chúng ta tăng thêm số lượng Container của 1 Service trong Docker Compose. Mỗi Container này sẽ được Mapping sang 1 Port của OS.  Cú pháp sử dụng `docker-compose scale <tên-service>=<số luợng>`

```bash
(11:57:51) ○ [root@Intern-Server] ~/test-doc-scale 
→ docker-compose config
services:
  web:
    image: nginx
    ports:
    - target: 80
version: '3.9'
(11:58:36) ○ [root@Intern-Server] ~/test-doc-scale 
→ docker-compose ps
        Name                      Command               State           Ports        
-------------------------------------------------------------------------------------
test-doc-scale_web_1   /docker-entrypoint.sh ngin ...   Up      0.0.0.0:49169->80/tcp
(11:58:40) ○ [root@Intern-Server] ~/test-doc-scale 
→ docker-compose scale web=3
WARNING: The scale command is deprecated. Use the up command with the --scale flag instead.
Creating test-doc-scale_web_2 ... done
Creating test-doc-scale_web_3 ... done
(12:01:58) ○ [root@Intern-Server] ~/test-doc-scale 
→ docker-compose ps
        Name                      Command               State           Ports        
-------------------------------------------------------------------------------------
test-doc-scale_web_1   /docker-entrypoint.sh ngin ...   Up      0.0.0.0:49169->80/tcp
test-doc-scale_web_2   /docker-entrypoint.sh ngin ...   Up      0.0.0.0:49171->80/tcp
test-doc-scale_web_3   /docker-entrypoint.sh ngin ...   Up      0.0.0.0:49170->80/tcp

```

→ Như vậy, ban đầu, chúng ta sử dụng port 49169 của Host để truy cập sử dụng dịch vụ của Container. Sau khi sử dụng lệnh thì ta đã có thể truy cập dịch vụ thông qua 2 Container trên 2 port nữa 

```bash
(12:02:09) ○ [root@Intern-Server] ~/test-doc-scale 
→ curl -i http://45.124.94.20:49170/
HTTP/1.1 200 OK
Server: nginx/1.19.5
Date: Tue, 15 Dec 2020 05:02:33 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 24 Nov 2020 13:02:03 GMT
Connection: keep-alive
ETag: "5fbd044b-264"
Accept-Ranges: bytes

<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

# 4. Ứng dụng sử dụng Flask và Redis với Docker Compose

Đầu tiên, như đã nêu ở phần 1, chúng ta cần tọa 1 Docker File để đảm bảo việc triển khai hệ thống tại các host khác nhau. Nhưng trước hết chúng ta sẽ tạo 1 file Python để đếm số lần trang được truy cập có nội dung như sau :

```jsx
import time

import redis
from flask import Flask

app = Flask(__name__)
cache = redis.Redis(host='redis', port=6379)

def get_hit_count():
    retries = 5
    while True:
        try:
            return cache.incr('hits')
        except redis.exceptions.ConnectionError as exc:
            if retries == 0:
                raise exc
            retries -= 1
            time.sleep(0.5)

@app.route('/')
def hello():
    count = get_hit_count()
    return 'Hello World! I have been seen {} times.\n'.format(count)
```

 Tiếp theo tạo 1 file tên là `req.txt` chứa nội dung như sau :

```jsx
flask 
redis
```

Sau đó chúng ta cần tạo 1 Dockerfile :

```jsx
# Thuc hien su dung Image Python 3.7
FROM python:3.7-alpine 
# Chuyen duong dan lam viec sang /code
workdir /code 
# Thiet lap cac bien moi truon
ENV FLASK_APP=app.py 
ENV FLASK_RUN_HOST=0.0.0.0 
# Them cac Lib va Dependencies
RUN apk add --no-cache gcc musl-dev linux-headers
# Copy file req.txt vao /code
COPY req.txt req.txt 
# Cai dat Flask va Redis
RUN pip install -r req.txt
# Lang nghe tren Port 5000
EXPOSE 5000 
# Them cac file o thu muc chua Dockerfile vao /code
ADD . .  
# Command mac dinh
CMD ["flask", "run"]
```

Sau đó tạo 1 file `docker-compose.yml`

```jsx
version: "3.9" # su dung phien ban compose 3.9
services: # tien hanh dinh nghia cac service 
  web: # service web
    build: . # Cac Config duoc thuc hien khi tien hanh build. Tien hanh build tu duong dan hien tai
    ports: # Map port 
      - "5000:5000" # Map port 5000 cua host OS toi port 5000 cua service container
    volumes: 
      - .:/code # Bind Mount thu muc hien tai vao /code
    environment:
      FLASK_ENV: development
  redis: # service redis
    image: "redis:alpine" # Define phien ban redis su dung
```

Sau dó sử dụng câu lệnh `docker-compose up -d` để chạy cụm Container này 

```bash
(11:41:28) ○ [root@ubuntu] ~/test-docker 
→  docker-compose up -d
Creating test-docker_web_1   ... done
Creating test-docker_redis_1 ... done
```

*Ta sử dụng Option -d dể chạy Container ở Background*

Như vậy, sau khi hệ thống này hoạt động thì ta sẽ truy cập vào `[localhost:5000](http://localhost:5000)` ( Port EXPOSE trong dockerfile ) và nhận được kết quả sau

![Docker-Compose/Screenshot_from_2020-12-11_11-44-36.png](Docker-Compose/Screenshot_from_2020-12-11_11-44-36.png)

***→ Như vậy chúng ta đã thành công trong việc chạy 1 App sử dụng Flask và Redis***

# 5. Ứng dụng xây dựng ứng dụng Wordpress và Redis với Docker

Ở phần này chúng ta sẽ xây dựng 1 cụm Multi-Container sử dụng 2 Image là `wordpress` và `redis` để thực hiện chạy Wordpress

Quá trình khởi tạo như sau 

```bash
(20:39:08) ○ [root@ubun-server-2] ~
→ mkdir dock-comp
(20:39:08) ○ [root@ubun-server-2] ~
→ cd dock-comp/
(20:39:24) ○ [root@ubun-server-2] ~/dock-comp
→ nvim docker-compose.yml

```

Thực hiện chỉnh sửa nội dung như sau 

```bash
services: # Liệt kê các Service 
  db: # service db sử dụng redis
    image: redis # Tải phiên bản mới nhất của Image Redis
    restart: always # Thực hiện Restart Container mỗi khi Container này Exit
  wordpress: # Service Wordpress
    image: wordpress:latest # Tải phiên bản mới nhất của Image Wordpress
    ports:
      - "8000:80" # Mapping port 8000 của host với port 80 của Container
    restart: always # Thực hiện Restart Container mỗi khi Exit
```

Nhận được kết quả tương tự như sau :

```bash
...
c344123e6ac3: Pull complete
Digest: sha256:6cd92cb2791600e6e3c760c6b5c9adf5a7fc908c693876e7584ab4493292f1e1
Status: Downloaded newer image for wordpress:latest
Creating dock-comp_wordpress_1 ... done
Creating dock-comp_db_1        ... done
```

Khi liệt kê các Container đang hoạt động :

```bash
(20:41:39) ○ [root@ubun-server-2] ~/dock-comp
→ docker ps -a
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                    PORTS                  NAMES
4564dc90e7a8        redis               "docker-entrypoint.s…"   10 minutes ago      Up 10 minutes             6379/tcp               dock-comp_db_1
d0ee2182a846        wordpress:latest    "docker-entrypoint.s…"   10 minutes ago      Up 10 minutes             0.0.0.0:80
```

Và khi truy cập địa chỉ của Host tại port 8000 ta nhận được 

![Docker-Compose/Untitled%202.png](Docker-Compose/Untitled%202.png)

# 6. Xây dựng LEMP Stack

![Docker-Compose/Untitled%203.png](Docker-Compose/Untitled%203.png)

Chúng ta thực hiện xây dựng LEMP ( Linux - Nginx - Mariadb - Php ) Stack với 3 thành phần sau :

1. Nginx phiên bản mới nhất từ Docker Hub
2. Mariadb phiên bản 10.3.9
3. Php -fpm phiên bản 7.2

Đầu tiên chúng ta tạo 1 đường dẫn tên là `lemp-stack-dckcmp` để chứa các file cấu hình cho Docker Compose 

```bash
(09:03:24) ○ [root@ubuntu] ~ 
→ mkdir lemp-stack-dckcmp
```

## Tạo file `index.php` cho dịch vụ php

```bash
(09:03:45) ○ [root@ubuntu] ~/lemp-stack-dckcmp 
→ mkdir app/
(09:04:08) ○ [root@ubuntu] ~/lemp-stack-dckcmp/app 
→ nvim index.php
```

→ Sau đó thực hiện chỉnh sửa file với nội dung như sau 

```bash
<?php

$magicNumbers = [
    rand(0, 100),
    rand(100, 200),
    rand(0, 1000),
];

?>
<!DOCTYPE html>
<html>
    <head>
        <meta name="author" content="Steven Liebregt" />
        <title>Hello, world!</title>
        <style>
            table, th, td {
                border: 1px solid black;
                border-collapse: collapse;
            }
        </style>
    </head>
    <body>
        <h1>Hello, world!</h1>
        <p>Your magic numbers are:</p>
        <table>
            <tr>
                <th>#</th>
                <th>Number</th>
            <tr>
            <?php foreach ($magicNumbers as $index => $number): ?>
                <tr>
                    <td><?php echo $index; ?></td>
                    <td><?php echo $number; ?></td>
                </tr>
            <?php endforeach; ?>
        </table>
        <p>If you can see this properly, then it means PHP is working fine.</p>
    </body>
</html>
```

## Tạo file cấu hình cho Nginx

```bash
(09:05:21) ○ [root@ubuntu] ~/lemp-stack-dckcmp 
→ mkdir -p config/nginx
(09:05:37) ○ [root@ubuntu] ~/lemp-stack-dckcmp/config/nginx 
→ nvim nginx.conf
```

Chỉnh sửa file cấu hình này như sau 

```bash
server { # Cấu hình cho web Server
    index index.php index.html; # Các file Index mặc định của Web
    server_name localhost; # Tên của Server để sau này có thể truy cập
    error_log  /var/log/nginx/error.log; # Nơi lưu các Error Log
    access_log /var/log/nginx/access.log; # Nơi lưu các Access Log
    root /var/www/html; # Đường dẫn mặc định của Web Server

    location / { # Thực hiện cấu hình cho URI localhost/
        try_files $uri $uri/ /index.php$is_args$query_string;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass php:9000; # Chuyển tiếp cho dịch vu php tại port 9000
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }
}
```

## Tạo Dockerfile cho dịch vụ Php

```bash
(09:15:21) ○ [root@ubuntu] ~/lemp-stack-dckcmp 
→ mkdir -p docker
(09:15:21) ○ [root@ubuntu] ~/lemp-stack-dckcmp 
→ cd docker/
(09:16:09) ○ [root@ubuntu] ~/lemp-stack-dckcmp/docker 
→ nvim php.lemp
```

Chỉnh sửa theo nội dung

```bash
# Từ Image php phiên bản 7.2
FROM php:7.2-fpm
# Chạy các lệnh dưới
RUN apt-get update &&\
    apt-get install -y git zip
RUN curl --silent --show-error https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer
```

## Tạo file Docker Compose

```bash
(09:19:01) ○ [root@ubuntu] ~/lemp-stack-dckcmp 
→ ls
app  config  docker  docker-compose.yml
(09:19:01) ○ [root@ubuntu] ~/lemp-stack-dckcmp 
→ nvim docker-compose.yml
```

Thêm vào file nội dung như sau:

```bash

services: # Định nghĩa các dịch vụ 
  php: # Dịch vụ Php
    build: # Tiến hành build dịch vụ 
      context: ./docker # Dockerfile được chứa tại đường dẫn
      dockerfile: php.lemp # Tên của Dockerfile
    container_name: lemp-php # Tên của Container sau khi khởi tạo 
    volumes: # Thực hiện Bind mount giữa Host và Container 
      - ./app:/var/www/html # Ánh xạ đường dẫn ./app vào trong đường dẫn /var/www/html
  nginx: # Dịch vụ nginx
    image: nginx:latest # Sử dụng Image mới nhất từ DockerHub
    container_name: lemp-nginx # Tên cảu Container
    ports: # Thực hiện Bind Port
      - 8080:80 # Map port 8080 của Host OS với Port 80 của Container
    depends_on: # Dịch vụ này được liên kết với dịch vụ Php
      - php
    restart: always # Luôn khởi dộng lại khi Container Exit
    volumes: # Thực hiện Bind mount giữa Host và Container 
      - ./app:/var/www/html
      - ./config/nginx:/etc/nginx/conf.d
  mysql: # Dich vu Mariadb
    image: mariadb:10.3.9 # Sử dụng Image Mariadb phiên bản 10.3.9
    container_name: lemp-mariadb # Tên của Container sau khi khởi động
    restart: always  # Luôn khởi động lại khi Exit
    environment: # Định nghĩa biến môi trường
      MYSQL_ROOT_PASSWORD: mariadb
    volumes: # Các dữ liệu của Mariadb sẽ được lưu tại đường dẫn hiện tại ( ~/lemp-stack-dckcmp )
      - ${PWD}
```

Sau khi thực hiện tạo file thì khởi động cụm Multi-Container này lên 

```bash
(09:28:13) ○ [root@ubuntu] ~/lemp-stack-dckcmp 
→ docker-compose up -d --build
Building php
Step 1/3 : FROM php:7.2-fpm
 ---> 28f52b60203d
Step 2/3 : RUN apt-get update &&    apt-get install -y git zip
 ---> Using cache
....
```

Sau đó kiêm tra lại 

```bash
(09:28:28) ○ [root@ubuntu] ~/lemp-stack-dckcmp 
→ docker ps -a
CONTAINER ID        IMAGE                   COMMAND                  CREATED             STATUS              PORTS                  NAMES
a27e28ff99f1        nginx:latest            "/docker-entrypoint.…"   37 minutes ago      Up 37 minutes       0.0.0.0:8080->80/tcp   lemp-nginx
d1a9d88a0584        lemp-stack-dckcmp_php   "docker-php-entrypoi…"   37 minutes ago      Up 37 minutes       9000/tcp               lemp-stack-dckcmp_php_1
4ce86e208d8b        mariadb:10.3.9          "docker-entrypoint.s…"   37 minutes ago      Up 37 minutes       3306/tcp               lemp-mariadb
```

→Quá trình khởi tạo đã thành công

Thực hiện truy cập địa chỉ `[localhost:8080](http://localhost:8080)` và nhận được kết quả sau 

![Docker-Compose/Untitled%204.png](Docker-Compose/Untitled%204.png)

→ Quá trình thử nghiệm đã thành công !

# 7. Xây dựng Dockerfile và Docker Compose cho Cachet

Cachet là một ứng dụng Open Source được sử dụng để hiển thị các trạng thái của hệ thống ( Status Page ) → Cho phép việc giám sát hệ thống dễ dàng hơn.  Dưới đây, chúng ta sẽ thực hiện xây dựng Dockerfile và Docker Conpose file cho ứng dụng này

## 7.1 Xây dựng Dockerfile

Như trên mục yêu cầu ( Requirements ) tại trang Github của ứng dụng Cachet, chúng tă cần cài đặt :

- PHP 7.1 - 7.3
- HTTP Server ( Ở đây sử dụng Nginx )
- Composer ( Ứng dụng quản lý Package cho PHP )
- 1 Database ( Ở đây sử dụng MySQL )

Các bước xây dựng Dockerfile như sau :

1. Sử dụng Image Nginx - Alpine và mở port ( Expose ) 8000 của hệ thống
2. Thực hiện chạy script khi khởi động hệ thống ( Entrypoint ) 
3. Cài đặt các Package trên Alpine ( Do sau này hệ thống khi cài đặt các Cachet thì yêu cầu có những Package này, nếu không có thì Composer sẽ không thể cài đặt được )
4. (Optional ) Chuyển OUTPUT của STDOUT và STDERR sang Logs của PHP và Nginx
5. Thêm User vào hệ thống ( Do chúng ta không muốn sử dụng User Root khi ở giải đoạn phân phối ( Deployment ) )
6. Cấp quyền sudo cho User mới này ( Lưu ý: Cần thêm option `NOPASSWD` khi ở trong file `/etc/sudoer` → User na 
7. Tạo file PID cho dịch vụ Nginx và thay đổi quyền sở hữu của file thành User ta khởi tạo. Đồng thời cùng với đó thay đổi quyền sở hữu với thư mục `/etc/php-fpm.d` ( Đây là nơi lưu trữ cấu hình của fpm ) 
8. Tạo các file lưu trữ cấu hình, cache, lib cho Nginx → Sau đó thay đổi quyền sở hữu sang User mới → Để User này sau khi chạy Container thì User này có thể truy cập vào các fiel cấu hình này và can thiệp ( nếu cần ) 
9. Cài đặt Package Composer 
10. Chuyển đường dẫn làm việc sang `/var/www/html` sau đó chuyển sang User Non-Root và thực hiện cài đặt các Package của Cachet thông qua Composer.
11. Copy các file cấu hình của Nginx ( Host Web ), supervisord ( Ứng dụng giám giát ) và Script `[entrypoint.sh](http://entrypoint.sh)` vào trong Container 
12. Cấp quyền sử dụng cho User Root đối với các file này 
13. Chuyển sang User Non-Root trong bước cuối cùng

Dưới đây là một Dockerfile hoàn chỉnh của ứng dụng :

```bash
# Từ Image Nginx-Alpine phiên bản 1.19.6 ( Latest ) 
FROM nginx:1.19.6-alpine 
# Mở Port 8000 để sử dụng Service Cachet
EXPOSE 8000
# Command mặc định khi chạy Dockerfile
CMD ["/sbin/entrypoint.sh"]
# Thêm các Package ( Do khi sử dụng Composer có nhiều Package yêu cầu )
RUN apk add --no-cache --update \ 
    mysql-client \
    php7-apcu \
    php7-bcmath \
    php7-ctype \
    php7 \
    php7-curl \
    php7-dom \
    php7-fileinfo \
    php7-fpm \
    php7-gd \
    php7-iconv \
    php7-mbstring \
    php7-mcrypt \
    php7-opcache \
    php7-openssl \
    php7-pdo \
    php7-pdo_mysql \
    php7-pdo_pgsql \
    php7-pdo_sqlite \
    php7-phar \
    php7-posix \
    php7-session \
    php7-simplexml \
    php7-soap \
    php7-sqlite3 \
    php7-tokenizer \
    php7-xml \
    php7-xmlwriter \
    php7-json\
    sqlite \
    sudo \
    wget sqlite git curl bash grep \
    supervisor
#Link từ 2 Stream là STDOUT và STDERR ra file Log của PHP
RUN   ln -sf /dev/stdout /var/log/php7/access.log && \
      ln -sf /dev/stderr /var/log/php7/error.log
#Thêm User ( Để sử dụng Non-root User trong Container -> Gia tăng tính bảo mật của hệ thống)
#User này sử dụng Bash có UID = 1111 và thuộc Group Root và có tên là www-data 
RUN adduser -S -s /bin/bash -u 1111 -G root www-data 
#Cho phép User này chạy các lệnh Sudo mà không cần nhập Password )
RUN echo "www-data ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
#Tạo file nginx.pid và thay đổi quyền sở hữu cho User chúng ta vừa tạo ở trên để có toàn bộ quyền truy cập vào file này
RUN touch /var/run/nginx.pid && \
    chown -R www-data:root /var/run/nginx.pid
#Thay đổi quyền sở hữu file cho User có UID 1111 
RUN chown -R www-data:root /etc/php7/php-fpm.d
#Tạo các đường dẫn để lưu file Index và Cache cho Nginx. Tiếp theo là việc thay đổi quyền sở hữu các file này cho User ww-data
RUN mkdir -p /var/www/html && \
    mkdir -p /usr/share/nginx/cache && \
    mkdir -p /var/cache/nginx &&\
    mkdir -p /var/lib/nginx &&\
    chown -R www-data:root /var/www /usr/share/nginx/cache /var/cache/nginx /var/lib/nginx
#Cài đặt Composer và sử dụng Composer ( thông qua Php ) cài đặt các Package của Cachet
RUN wget https://getcomposer.org/installer -O /tmp/composer-setup.php && \
    wget https://composer.github.io/installer.sig -O /tmp/composer-setup.sig && \
    php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" && \
    php /tmp/composer-setup.php --version=1.9.0 --install-dir=bin && \
    php -r "unlink('/tmp/composer-setup.php');"
#Chuyển đường dẫn làm việc sang /var/www/html - Tất cả các câu lệnh như ADD, RUN , ... sẽ được thực hiện tại đường dẫn này
WORKDIR /var/www/html
#Ta sẽ thực hiện các lệnh này qua User www-data
USER 1111
#Tải và giải nén các file cấu hình của Cachet
RUN wget https://github.com/cachethq/Cachet/archive/2.4.tar.gz && \
    tar -xzf 2.4.tar.gz --strip-components=1 && \
    chown -R www-data:root /var/www/html &&\
    rm -rf 2.4.tar.gz && \
    php /bin/composer.phar global require "hirak/prestissimo:^0.3" && \
    php /bin/composer.phar install -o && \
    rm -rf bootstrap/cache/*
# Copy các file cấu hình ở Host vào trong Container theo đường dẫn cụ thể
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY nginx-site.conf /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /sbin/entrypoint.sh
COPY .env.docker /var/www/html/.env
COPY php-fpm-pool.conf /etc/php7/php-fpm.d/www.conf
```

## 7.2 Xây dựng file Docker Compose

Sau khi đã có được Dockerfile để có thể xây dựng được Image của Cachet, tiếp theo chúng ta cần thực hiện việc xây dụng file Docker Compose để sử dụng Cachet với các Image Database

Các bước cần làm  :

1. Xây dựng Service Database, thiết lập các thông số biến ( environments ) cho Service này 
2. Xây dựng Service Cachet, tiến hành Build từ Dockerfile đã có, liên kết với dịch vụ Database

Lưu ý: Đối với lần đầu sử dụng Cachet thì chúng ta cần chạy `docker-compose up` lần đầu để có thể lấy được APP KEY và sau đó điền APP-KEY này vào file Docker Compose:

```bash
# Sử dụng phiên bản Docker Compose 3.9
version: "3.9"
# Thực hiện định nghĩa các dịch vụ 
services:
  db: # Thực hiện cấu hình cho dịch vụ "db"
    image: mariadb:latest # Sử dụng Image mariadb mới nhất
    environment: # Thiết lập các biến môi trường cho Service này
      - MYSQL_ROOT_PASSWORD=mysql 
      - MYSQL_USER=mysql
      - MYSQL_PASSWORD=mysql
      - MYSQL_DATABASE=mysql
      - DEBUG=false
  cachet: # Thực hiện cấu hình cho dịch vụ " Cachet "
    build: # Ta sẽ tiến hành Build dịch vụ tại đường dẫn chứa file Docker Compose và sử dụng Dockerfile có trong đường dẫn này.
      context: .
      dockerfile: Dockerfile
    environment: # Thiết lập các biến môi trường cho dichj vụ này 
      - APP_KEY=base64:cdkWblUh9lZYQbPcdxCtGd9djwwbBi9MXMjuZAxMZvI= # APP Key sẽ có được khi chạy lần đầu Docker Compose ( Mặc định sẽ có dạng - APP_KEY=${APP_KEY:-null} )
      - DB_DRIVER=mysql
      - DB_HOST=mysql
      - DB_DATABASE=mysql
      - DB_USERNAME=mysql
      - DB_PASSWORD=mysql
      - DB_PREFIX=chq_
    restart: on-failure # Thực hiện Restart khi gặp lỗi 
    ports:
      - 80:8000 # Map port 80 của Host OS với Port 8000 của Service
    links: # Liên kết dịch vụ
      - db:mysql
```

Sau khi sử dụng lệnh `docker-compose up -d` ( Chạy Container ở Background )

![Docker-Compose/Untitled%205.png](Docker-Compose/Untitled%205.png)

# 8. Dockerized Gitea

Gitea là một ứng dụng cho phép Self Hosted Git trên một Server. Sau đây chúng ta sẽ thực hiện việc viết file Docker Compose để tạo Service này trên port 3000 và 2222. 

Các công việc cần làm 

1. Sử dụng Image của Gitea : `docker pull gitea
2. Sử dụng Docker Compose để tạo services bao gồm
    1. Gitea
    2. Một Database để lưu trữ dữ liệu : MySQL, Mariadb,..

Chúng ta cần tạo 1 đường dẫn để chữa các file và thư mục liên quan

```bash
mkdir gitea
cd gitea
```

Dưới đây là file Docker Compose với gitea

```bash
1 version: "3.9" # Sử dụng phiên bản Docker Compose 3.9                                                                                                       
2                                                                                                                       
3 services:  # Định nghĩa Service                                                                                                           
4   gitea:   # Service Gitea                                                                                                          
5     image: gitea/gitea   # Sử dụng Image Gitea Official                                                                                             
6     restart: on-failure  # Khởi động lại Container khi có lỗi                                                                                             
7     volumes:             # Chỉ định Volume sử dụng                                                                                             
8       - ./data:/data     # Thực hiện Mount data                                                                                              
9     ports:               # Mapping Port giữa Host và Container                                                                                            
10       - "3030:3000"                                                                                                  
11       - "2222:22"                                                                                                    
12     depends_on:         # Thực hiện liên kết với service db                                                                                             
13       - db                                                                                                           
14   db:                             # Service db                                                                                   
15     image: mariadb:latest         # Sử dụng Mariadb phiên bản mới nhất                                                                       
16     restart: on-failure           # Khởi động lại khi gặp lỗi                                                                                   
17     volumes:                      # Chỉ định Volume sử dụng                                                                                   
18       - ./db:/var/lib/mysql       # Thực hiện Mount Data                                                                                 
19     environment:                  # Các biến môi trường                                                              
20       - MYSQL_ROOT_PASSWORD=mysql                                                                              
21       - MYSQL_USER=mysql                                                                                         
22       - MYSQL_PASSWORD=mysql                                                                                        
23       - MYSQL_DATABASE=mysql
```

Kết quả khi sử dụng lệnh `docker-compose up`

![Docker-Compose/Untitled%206.png](Docker-Compose/Untitled%206.png)

Sau đó ta kiểm tra kết quả thông qua :

![Docker-Compose/Untitled%207.png](Docker-Compose/Untitled%207.png)

Và khi sử dụng trình duyệt Web để truy cập địa chỉ Host tại port 3030 :

![Docker-Compose/Untitled%208.png](Docker-Compose/Untitled%208.png)
