# Linux Bridge

![Linux-Bridge/Untitled.png](Linux-Bridge/Untitled.png)

Linux Bridge là 1 tiện ích trong nhân Linux, được ra đời để giải quyết vấn đề ảo hóa mạng trong cơ chế ảo hóa đối với các máy vật lý. Về cơ bản thì Linux Bridge sẽ tạo ra 1 Switch ảo trong hệ thống để kết nối hệ thống mạng của các máy ảo ( hiện đang có trên máy vật lý ) với hệ thống đường mạng vật lý. 

# Sơ đồ kiến trúc của Linux Bridge

![Linux-Bridge/Untitled%201.png](Linux-Bridge/Untitled%201.png)

Trong đó có một số các khái niệm cơ bản như sau:

- `fd` : Viết tắt của Foward Data . Được sử dụng để chuyển tiếp Data từ máy ảo
- `tap0` : Tượng trưng cho các cổng (Port) của Switch ảo . Các máy ảo khi kết nối tới Swtich ảo sẽ được kết nối tới các Port này.
- `eth0` : Tượng trung cho các giao diện mạng vật lý có trên máy vật lý được kết nối tới Switch ảo

# Các tính năng cơ bản của Linux Bridge

Các chức năng được cung cấp bởi Linux Bridge

1. STP : Spanning Tree Protocol - Giao thức tránh gây hiện tượng Loop giữa các Switch
2. FDB : Thực hiện gửi tin theo Database → tăng tốc độ truyền dẫn của Switch
3. Vlan : Có thể thực hiện cấu hình chia các máy ảo làm các Vlan để quản lý dễ hơn

# Thực hiện cấu hình cơ bản với Linux Bridge trên Ubuntu 20.04

Ta thực hiện xét mô hình dưới để thực hiện cấu hình Linux bridge :

![Linux-Bridge/Untitled%202.png](Linux-Bridge/Untitled%202.png)

Trong đó 

- `VM1` : Máy ảo được host trên `HOSTSERVER`
- `Linux Bridge` : Switch ảo được tạo ra
- `HOSTSERVER` : Máy vật lý được sử dụng để host VM

Yêu cầu

- Công cụ quản lý `brctl`
    - Được cài đặt trên **Ubuntu 20.04** thông qua cửa sổ Terminal với lệnh:

        ```jsx
        sudo apt install bridge-utils
        ```

- VM được tạo thông qua việc sử dụng QEMU/KVM - **Lưu ý : VM cần ở trạng thái running**
- 1 máy vật lý được sử dụng để host VM

Đầu tiên chúng ta sẽ thực hiện liệt kê các Linux Bridge có trên máy thông qua cửa số Terminal :

```jsx
root@localcomputer:/home/tuananh# brctl show
bridge name	  bridge id		         STP enabled	 interfaces
virbr0		  8000.5254005d2d4b	         yes		 virbr0-nic
							         vnet0
```

*Do ở đây mình đã tiến hành cài sẵn 1 máy ảo với QEMU-KVM nên trên đây sẽ xuất hiện mạng ảo của VM là `vnet0`*

Tiếp đó liệt kê các giao diện mạng hiện tại thông qua việc sử dụng :

```jsx
tuananh@localcomputer:~$ ip a s
...
3: ens34: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:0c:29:30:2f:c0 brd ff:ff:ff:ff:ff:ff
    inet 192.168.253.134/24 brd 192.168.253.255 scope global dynamic noprefixroute ens34
       valid_lft 1361sec preferred_lft 1361sec
    inet6 fe80::fe30:b512:8d4f:302c/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
4: virbr0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 52:54:00:5d:2d:4b brd ff:ff:ff:ff:ff:ff
    inet 192.168.122.1/24 brd 192.168.122.255 scope global virbr0
       valid_lft forever preferred_lft forever
5: virbr0-nic: <BROADCAST,MULTICAST> mtu 1500 qdisc fq_codel master virbr0 state DOWN group default qlen 1000
    link/ether 52:54:00:5d:2d:4b brd ff:ff:ff:ff:ff:ff
9: vnet0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel master virbr0 state UNKNOWN group default qlen 1000
    link/ether fe:54:00:c4:ee:18 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::fc54:ff:fec4:ee18/64 scope link 
       valid_lft forever preferred_lft forever

```

Để bài viết tổng quan nhất chúng ta sẽ thực hiện xóa giao diện ( interface ) này khỏi Linux Bridge được tạo mặc định và khởi tạo 1 Linux Bridge mới. Các bước thực hiện như sau:

```jsx
root@localcomputer:/home/tuananh# brctl delif virbr0 vnet0
root@localcomputer:/home/tuananh# brctl addbr test
root@localcomputer:/home/tuananh# brctl addif test vnet0
root@localcomputer:/home/tuananh# brctl addif test ens34
```

Giải thích:

- Đầu tiên chúng ta sẽ thực hiện xóa interface `vnet0` khỏi Linux Bridge `virbr0`
- Tiếp đó chúng ta tạo ra 1 Linux Bridge mới với câu lệnh thứ 2 ( Nếu 
muốn thay đổi tên Bridge thì có thể thực hiện đổi `test` thành tên mong muốn )
- Cuối cùng chúng ta thực hiện thêm interface `vnet0` và `ens34` vào Linux Bridge `test`

Kết quả nhận được :

```jsx
root@localcomputer:/home/tuananh# brctl show
bridge name	   bridge id		         STP enabled	interfaces
test		   8000.fe5400c4ee18	         no		vnet0
                                                                ens34
virbr0		   8000.5254005d2d4b	         yes		virbr0-nic
```

→ *Nhận thấy có 1 Linux Bridge mới đã được thêm*

Tiếp đó chúng ta cần thực hiện xóa địa chỉ mạng hiện thời của interface `ens34` :

```jsx
root@localcomputer:/home/tuananh# ip a flush ens34
```

Bước tiếp theo chúng ta sẽ yêu cầu địa chỉ IP cho Linux Bridge `test` mới tạo :

```jsx
root@localcomputer:/home/tuananh# dhclient test
```

Sau khi thực hiện 2 lệnh trên ta thực hiện kiểm tra lại các giao diện mạng :

```jsx
root@localcomputer:/home/tuananh# ip a s
...
3: ens34: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel master test state UP group default qlen 1000
    link/ether 00:0c:29:30:2f:c0 brd ff:ff:ff:ff:ff:ff
4: virbr0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default qlen 1000
    link/ether 52:54:00:5d:2d:4b brd ff:ff:ff:ff:ff:ff
    inet 192.168.122.1/24 brd 192.168.122.255 scope global virbr0
       valid_lft forever preferred_lft forever
5: virbr0-nic: <BROADCAST,MULTICAST> mtu 1500 qdisc fq_codel master virbr0 state DOWN group default qlen 1000
    link/ether 52:54:00:5d:2d:4b brd ff:ff:ff:ff:ff:ff
9: vnet0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel master test state UNKNOWN group default qlen 1000
    link/ether fe:54:00:c4:ee:18 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::fc54:ff:fec4:ee18/64 scope link 
       valid_lft forever preferred_lft forever
11: test: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 00:0c:29:30:2f:c0 brd ff:ff:ff:ff:ff:ff
    inet 192.168.253.135/24 brd 192.168.253.255 scope global dynamic test
       valid_lft 1612sec preferred_lft 1612sec
    inet6 fe80::fc54:ff:fec4:ee18/64 scope link 
       valid_lft forever preferred_lft forever
```

*Ta có thể thấy :*

- Địa chỉ MAC của interface `ens34` đã trùng với Bridge `test` : 00:0c:29:30:2f:c0
- Địa chỉ của Tap Interface của VM là : fe:54:00:c4:ee:18 brd

Cuối cùng là các thao tác trên máy ảo để thực hiện nhận địa chỉ IP mới. Chúng ta sẽ thực hiện đăng nhập sử dụng console của máy ảo :

```jsx
root@localcomputer:/home/tuananh# virsh console kvm1
```

*Trong đó, `kvm1` là tên máy ảo của bạn*

Thực hiện đăng nhập user ( không bắt buộc phải là root user ) :

```jsx
Loading Linux 4.19.0-11-amd64 ...
Loading initial ramdisk ...

Debian GNU/Linux 10 debian ttyS0

debian login: root
Password: 
Last login: Sun Oct 18 04:32:06 EDT 2020 on ttyS0
Linux debian 4.19.0-11-amd64 #1 SMP Debian 4.19.146-1 (2020-09-17) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
```

Do đã thiết lập thành công Linux Bridge từ các bước trước, vậy nên bước này bạn có thể có 2 lựa chọn :

1. Thực hiện Reboot → Thường thì sau khi reboot sẽ thực hiện nhận lại địa chỉ mạng mới một cách tự động
2. Thực hiện các lệnh sau để cập nhật địa chỉ thủ công

    ```jsx
    root@debian:~# ip a flush ens3
    root@debian:~# dhclient ens3
    ```

    *Đầu tiên chúng ta thực hiện xóa địa chỉ hiện tại ( Flush ) của giao diện mạng `ens3` ( có thể thay đổi tùy trên VM của bạn)

    *Tiếp đó là yêu cầu IP từ DHCP Server*

Cuối cùng, chúng ta thực hiện kiểm tra lại địa chỉ interface :

```jsx
root@debian:~# ip a s
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: ens3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:c4:ee:18 brd ff:ff:ff:ff:ff:ff
    inet 192.168.253.136/24 brd 192.168.253.255 scope global dynamic noprefixroute ens3
       valid_lft 1759sec preferred_lft 1759sec
    inet6 fe80::5054:ff:fec4:ee18/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
```

→ Interface đã cùng địa chỉ mạng với Linux Bridge `test` .  Ta sẽ thử kiểm tra kết nối :

```jsx
root@debian:~# ping 192.168.253.135 -c3
PING 192.168.253.135 (192.168.253.135) 56(84) bytes of data.
64 bytes from 192.168.253.135: icmp_seq=1 ttl=64 time=0.376 ms
64 bytes from 192.168.253.135: icmp_seq=2 ttl=64 time=2.08 ms
64 bytes from 192.168.253.135: icmp_seq=3 ttl=64 time=0.465 ms

--- 192.168.253.135 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 5ms
rtt min/avg/max/mdev = 0.376/0.973/2.078/0.782 ms
```

*Vậy quá trình thiết lập Linux Bridge đã thành công !*

# Thiết lập mức độ ưu tiên trên Linux Bridge trên Ubuntu 20.04

Nếu hệ thống của bạn có nhiều hơn 1 Interface, chúng ta có thể tiến hành thiết lập các mức độ ưu tiên để VM sử dụng các Interface này . Ta thực hiện xét mô hình tương tự ở trên :

![Linux-Bridge/Untitled%202.png](Linux-Bridge/Untitled%202.png)

Tuy nhiên, tại trường hợp này, chúng ta sẽ có **2 giao diện mạng khác nhau** được kết nối tới cùng 1 Linux Bridge. Cùng với đó, chúng ta sẽ thực hiện thiết lập các mức độ ưu tiên khác nhau đối với mỗi Port của Virtual Switch. Việc thực hiện thêm 2 Interface vào Linux Bridge được thực hiện như tại phần trước ( đối với 2 giao diện mạng khác nhau )

Sau khi thực hiện lại thành công việc thêm 2 Interface, ta nhậ được kết quả như sau :

```jsx
root@localcomputer:/home/tuananh# brctl show
bridge name	   bridge id		         STP enabled	interfaces
test		   8000.fe5400c4ee18	         no		vnet0
                                                                ens34
                                                                ens39
virbr0		   8000.5254005d2d4b	          yes		virbr0-nic
```

*Trong đó `ens34` và `ens39` là 2 giao diện mạng trên máy Host*

- `ens33` : Có địa chỉ IP 192.168.150.131/24
- `ens34` : Có địa chỉ IP 192.168.253.134/24

Ta thực hiện việc thiết lập cấu hình độ ưu tiên ( Port Priority ) :

```jsx
root@localcomputer:/home/tuananh# brctl setportprio test ens33 63
root@localcomputer:/home/tuananh# brctl setportprio test ens34 0
```

*Trong đó giá trị Priority nằm trong khoảng 0 → 63*

Tiếp theo ta thực hiện truy cập máy ảo, thực hiện cập nhật địa chỉ IP :

```jsx
tuananh@localcomputer:~$ virsh console kvm1
```

```jsx
root@debian:~# ip a flush ens3
root@debian:~# dhclient ens3
root@debian:~# ip a s
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: ens3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:c4:ee:18 brd ff:ff:ff:ff:ff:ff
    inet 192.168.150.132/24 brd 192.168.150.255 scope global dynamic ens3
       valid_lft 1798sec preferred_lft 1798sec
```

*Ta nhận thấy rằng, Virtual Interface của VM đã nhận địa chỉ của dải mạng `ens33` do ta thiết lập cấu hình độ ưu tiên cao hơn*

---

# Nguồn tham khảo

[hocchudong/Linux-bridge](https://github.com/hocchudong/Linux-bridge)

[hocchudong/thuctap012017](https://github.com/hocchudong/thuctap012017/blob/master/XuanSon/Virtualization/Virtual%20Switch/Linux%20bridge/Lab_tinh_nang_Linux-bridge.md)

[brctl(8) - Linux man page](https://linux.die.net/man/8/brctl)

[hocchudong/thuctap012017](https://github.com/hocchudong/thuctap012017/blob/master/TamNT/Virtualization/docs/Virtual_Switch/1.Linux-Bridge.md#1)
