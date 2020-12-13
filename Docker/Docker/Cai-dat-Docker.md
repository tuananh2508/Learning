# Cai-dat-Docker

![Cai-dat-Docker/Untitled.png](Cai-dat-Docker/Untitled.png)

**Mục lục**
- [Cai-dat-Docker](#cai-dat-docker)
- [1. Tổng quan về Docker](#1-tổng-quan-về-docker)
  - [2. Cài đặt Docker](#2-cài-đặt-docker)
  - [2.1 Tiến hành Update Reposite](#21-tiến-hành-update-reposite)
  - [2.2 Cài đặt thêm các Package cho quá trình cài đặt](#22-cài-đặt-thêm-các-package-cho-quá-trình-cài-đặt)
  - [2.3 Tạo thêm Docker Reposite](#23-tạo-thêm-docker-reposite)
- [3. Tiến hành cài đặt](#3-tiến-hành-cài-đặt)
- [4. Thử nghiệm quá trình chạy Docker](#4-thử-nghiệm-quá-trình-chạy-docker)

# 1. Tổng quan về Docker

Docker là dự án Open Source cho phép thực thi các công việc triển khai ứng dụng bên trong các Container. Trong các Container này là tạo ra một môi trường ứng dụng độc lập với Host OS và  sẽ bao gồm đầy đủ các điều kiện môi trường để ứng dụng có thể thực hiện chạy. 

Điểm khác biệt của VM (Virtual Machine) với Docker đó là việc Docker về cơ bản không hề thực hiện tạo ra một môi trường hệ thống khác với nguồn CPU và RAM  và OS riêng ( cùng một số thành phần khác ) như VM. Mà Docker sẽ thực hiện chạy trên môi trường Host OS và sử dụng Host OS Kernel, thực hiện chia sẻ tài nguyên với Host và cung cấp 1 lượng cấu hình tối thiếu và một môi trường được cách ly để chạy ứng dụng.

Một số ưu điểm đáng kể đến như là :

- Tạo và hủy Container nhanh chóng, tiết kiệm thời gian hơn so với VM
- Kích thước nhỏ, chiếm ít tài nguyên hơn VM, cho phép chạy song song nhiều Container khác nhau trên cùng 1 VM

## 2. Cài đặt Docker

Quá trình dưới sẽ được thực hiện trên OS **Ubuntu Server 20.04 và chạy dưới quyền User `root`**

## 2.1 Tiến hành Update Reposite

Đầu tiên chúng ta cần thực hiện Update và cài đặt các Package mới từ Ubuntu Reposite để quá trình cài đặt cung cấp được môi trường tốt nhất cho Docker

```bash
root@ubun-server-2:~# apt-get update
root@ubun-server-2:~# apt-get upgrade
```

## 2.2 Cài đặt thêm các Package cho quá trình cài đặt

Sau khi quá trình cài đặt hoàn tất, chúng ta sẽ tiến hành thực hiện cài đặt thêm các Package hỗ trợ cho quá trình cài đặt Docker

```bash
root@ubun-server-2:~# apt-get install curl apt-transport-https ca-certificates software-properties-common
```

Trong đó chức năng của các Package cài thêm:

- curl : Cho phép chuyển dữ liệu thông qua URL
- apt-transport-https : Hỗ trợ Package manager chuyển file qua HTTPS
- ca-certificates : Cho phép kiểm tra chứng thực các file
- software-properties-common : Bổ sung các Script để cài đặt software

## 2.3 Tạo thêm Docker Reposite

Việc tạo Docker Reposite giúp chúng ta cài đặt phiên bản chính thức từ Docker với các Reposite được cung cấp trực tiếp.

Đầu tiên tạo ta cần chèn key GPG (Gnu Privacy Guard - Là 1 thể loại Key cho phép mã hóa phiên ) , thực hiện gõ lệnh sau :

```bash
root@ubun-server-2:~# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```

Tiếp theo là tạo 1 Docker APT Repository :

```bash
root@ubun-server-2:~# sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
```

Sau đó cập nhật lại các Reposite :

```bash
root@ubun-server-2:~# sudo apt update
```

Sau đó kiểm tra Repo → Đảm bảo rằng việc tiến hành cài đặt sẽ được thực hiện tại Docker Reposite chứ không phải từ Ubuntu Reposite:

```bash
root@ubun-server-2:~# apt-cache policy docker-ce
```

Kết quả nhận được có dạng như sau :

```bash
**docker-ce:
  Installed: (none)
  Candidate: 5:19.03.13~3-0~ubuntu-focal
  Version table:
     5:19.03.13~3-0~ubuntu-focal 500
        500 https://download.docker.com/linux/ubuntu focal/stable amd64 Packages
     5:19.03.12~3-0~ubuntu-focal 500
        500 https://download.docker.com/linux/ubuntu focal/stable amd64 Packages
     5:19.03.11~3-0~ubuntu-focal 500
        500 https://download.docker.com/linux/ubuntu focal/stable amd64 Packages
     5:19.03.10~3-0~ubuntu-focal 500
        500 https://download.docker.com/linux/ubuntu focal/stable amd64 Packages
     5:19.03.9~3-0~ubuntu-focal 500
        500 https://download.docker.com/linux/ubuntu focal/stable amd64 Packages**
```

# 3. Tiến hành cài đặt

Thực hiện cài đặt qua lệnh sau :

```bash
root@ubun-server-2:~# sudo apt-get install docker-ce
```

Sau khi quá trình hoàn tất, ta sẽ kiểm tra trạng thái của Service Docker :

```bash
root@ubun-server-2:~# sudo systemctl status docker
● docker.service - Docker Application Container Engine
     Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
     Active: active (running) since Wed 2020-11-25 09:54:12 UTC; 1min 21s ago
TriggeredBy: ● docker.socket
       Docs: https://docs.docker.com
   Main PID: 41003 (dockerd)
      Tasks: 8
     Memory: 36.8M
     CGroup: /system.slice/docker.service
             └─41003 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
```

→ Như vậy, Docker Daemon đang chạy trên OS của chúng ta và từ bh ta đã có thể thực hiện sử dụng Docker

# 4. Thử nghiệm quá trình chạy Docker

Để thử nghiệm xem quá trình cài đặt của ta có thành công không, ta thực hiện chạy lệnh dưới đây

```bash
root@ubuntu:~# docker pull hello-world
Using default tag: latest
latest: Pulling from library/hello-world
0e03bdcc26d7: Pull complete 
Digest: sha256:e7c70bb24b462baa86c102610182e3efcb12a04854e8c582838d92970a09f323
Status: Downloaded newer image for hello-world:latest
docker.io/library/hello-world:latest
```

→ Đầu tiên, chúng ta đã thực hiện Pull 1 Image có tên là `hello-world` về Host OS.

```jsx
root@ubuntu:~# docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
hello-world         latest              bf756fb1ae65        11 months ago       13.3kB
```

→ Kiểm tra việc Pull Images từ Docker Hub và nhân jthấy ta đã có 1 Images `hello-world`

Sau đó ta sẽ chạy thử Images này trên hệ thống :

```jsx
root@ubuntu:~# docker run hello-world
```

Kết quả nhận được như sau :

```jsx
root@ubuntu:~# docker run hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```

→ Images này giúp chúng ta kiểm tra hoạt động của Docker trong lần đầu tiên cài đặt. Đồng thời cùng với đó là miêu tả cách hoạt động của Docker :

1. Đầu tiên, Docker client sẽ thực hiện gọi tới Docker daemon đang hoạt động trên hệ thống. 
2. Kiểm tra xem trên hệ thống có đang có Image đang cần không, nếu không có sẽ Pull Image mới từ Docker Hub về
3. Docker Daemon sẽ tạo ra 1 Container mới chạy Image này

⇒ Việc cài đặt và thử nghiệm Docker đã thành công !