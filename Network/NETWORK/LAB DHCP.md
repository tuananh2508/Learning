# LAB%20DHCP%20DHCP DHCP

![LAB%20DHCP%20DHCP%20DHCP/Untitled.png](LAB%20DHCP%20DHCP/Untitled.png)

# Yêu cầu

- 2 Server
    - 1 server sử dụng làm DHCP Server
    - 1 server sử dụng làm client để test

## Mô hình

![LAB%20DHCP%20DHCP/Untitled%201.png](LAB%20DHCP/Untitled%201.png)

# Bước thực hiện trên Ubuntu 18.04

Việc cấu hình DHCP được thực hiện theo 2 bước. Bước thứ 2 có thể lặp lại tại nhiều máy tính khác nhau nếu mô hình được mở rộng thành N Client khác nhau.

## Cấu hình Server sử dụng làm DHCP server

![LAB%20DHCP%20DHCP/Untitled%202.png](LAB%20DHCP/Untitled%202.png)

### Thực hiện cài DHCP Server thông qua apt :

Tại phiên bản bài hướng dẫn đang sử dụng là Ubuntu 18.04, DHCP Server được cài đặt như sau:

```bash
sudo apt-get install isc-dhcp-server -y
```

Tiếp đó chúng ta cần cài đặt cấu hình cho DHCP Server với các thông số mong muốn : 

### Tiến hành chỉnh sửa file cấu hình của DHCP

```bash
sudo nano /etc/dhcp/dhcpd.conf
```

Thực hiện các thông số như sau vào cuối file cấu hình ( Đây chỉ là các thông số tham khảo, bạn có thể tự thay đổi thông số của từng mục theo nhu cầu ) : 

```bash
subnet 192.168.98.0 netmask 255.255.255.0 {
range 192.168.98.100 192.168.98.200;
option routers 192.168.98.2;
option domain-name-servers 8.8.8.8, 8.8.4.4;
```

→ Các máy Client sẽ nhận dải địa chỉ có giá trị : `192.168.98.(100 -> 200 )`

Sau đó Set up cho Server trở thành Server DHCP chính cho các clients trong mạng, tiến hành bỏ dấu # tại dòng sau :

```bash
authoritative;
```

*Lưu ý* : Ngoài ra nếu Server có nhiều giao diện mạng khác nhau thì cần định nghĩa giao diện phục vụ DHCP tại đường dẫn `/etc/default/isc-dhcp-server` : `INTERFACESv4="eth0"`

Trong đó `eth0` là giao diện mạng thực hiện cấp DHCP, có thể thay đổi tùy vào trường hợp

### Tiến hành bật dịch vụ DHCP

Mặc định dịch vụ DHCP Server sẽ không tự cài đặt nó làm dịch vụ của Systemd, thông qua các bước sau ta sẽ tiến hành thiết lập dịch vụ DHCP :

```bash
sudo systemctl start isc-dhcp-server.service
sudo systemctl enable isc-dhcp-server.service
sudo systemctl status isc-dhcp-server.service
```

*Quá trình cài đặt DHCP trên Server DHCP đã kết thúc* 

## Cấu hình trên Server Clients

![LAB%20DHCP%20DHCP/Untitled%203.png](LAB%20DHCP/Untitled%203.png)

Nêu máy tính Client không tự thực hiện nhận IP từ Server DHCP, ta có thể thực hiện lệnh sau , interface đang xét ở đây là `ens38` 

```bash
	dhclient -r ens38
```

Kiểm tra lại việc nhận IP từ máy chủ thông qua

```bash
ip a
```

Kết quả nhận được sẽ có dạng như sau 

```bash
3: ens38: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:0c:29:ab:63:7f brd ff:ff:ff:ff:ff:ff
    inet 192.168.98.100/24 brd 192.168.98.255 scope global noprefixroute ens38
       valid_lft forever preferred_lft forever
    inet6 fe80::20c:29ff:feab:637f/64 scope link 
       valid_lft forever preferred_lft forever
```

Ta nhận thấy đã đạt được kết quả mong muốn, máy Client đã nhận được địa chỉ `192.168.98.100` → Thuộc dải địa chỉ ta đã cấu hình 

Nếu muốn reset lấy 1 địa chỉ IP khác cần thực hiện

```bash
dhclient -r dev ens38
```

hoặc có thể sử dụng lệnh sau để xóa ip :

```bash
ip addr del xxx.xxx.xxx.xxx dev ens38
```

### Quá trình Set up 1 mô hình DHCP Server - Client đơn giản đã kết thúc !
