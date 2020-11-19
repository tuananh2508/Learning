# Lý thuyết về OVS
![Ly-thuyet-OVS/Untitled.png](Ly-thuyet-OVS/Untitled.png)

Tại bài này chúng ta sẽ thực hiện tìm hiểu về **OpenvSwitch** . Là 1 trong 3 công nghệ được sử dụng để giải quyết vấn đề ảo hóa Network.

**Mục Lục**
- [1. Tổng quan](#1-t-ng-quan)
  * [1.1 Khái niệm về OVS ( OpenvSwitch)](#11-kh-i-ni-m-v--ovs---openvswitch-)
  * [1.2 Kiến trúc của OvS](#12-ki-n-tr-c-c-a-ovs)
- [2. Tiến hành cài đặt OvS trên Ubuntu Server 20.04](#2-ti-n-h-nh-c-i---t-ovs-tr-n-ubuntu-server-2004)
- [3. Các lệnh cơ bản với OvS](#3-c-c-l-nh-c--b-n-v-i-ovs)
  * [3.1 Sử dụng `ovs-vsctl` để xem trạng thái các Bridge hiện tại](#31-s--d-ng--ovs-vsctl-----xem-tr-ng-th-i-c-c-bridge-hi-n-t-i)
  * [3.2 Sử dụng `ovs-vsctl` để tạo và xóa Bridge](#32-s--d-ng--ovs-vsctl-----t-o-v--x-a-bridge)
  * [3.3 Thực hiện thêm và xóa 1 port vào Bridge đã có sẵn](#33-th-c-hi-n-th-m-v--x-a-1-port-v-o-bridge----c--s-n)
  * [3.4 Thực hiện liệt kê thông tin các Port trên Bridge](#34-th-c-hi-n-li-t-k--th-ng-tin-c-c-port-tr-n-bridge)
  * [3.5 Thêm Port vào VLAN thông qua OvS](#35-th-m-port-v-o-vlan-th-ng-qua-ovs)
- [Nguồn tham khảo](#ngu-n-tham-kh-o)

# 1. Tổng quan

## 1.1 Khái niệm về OVS ( OpenvSwitch)

![Ly-thuyet-OVS/Untitled%201.png](Ly-thuyet-OVS/Untitled%201.png)

Cùng với Linux Bridge, OVS được ra đời để giải quyết các vấn đề cơ bản của ảo hóa Network bằng cách cung cấp các **Switch ảo**. Là phần mềm mã nguồn mở, có giấy phép Apache 2.0. OvS hỗ trợ nhiều công nghệ ảo hóa khác nhau như KVM, VirtualBox, VmWare,... Được thiết kế để tương thích với các Switch hiện đại. OvS có thể hoạt động trên nhiều các nền tảng khác nhau từ Window tới NetBSD và Free BSD.

Các chức năng nổi bật của OvS :

- Bảo mật : Cho phép thực hiện cấu hình VLAN, lọc lưu lượng mạng ( Network Filtering)
- Giám sát : Cho phép giám sát các loại mạng như Netflow, sFlow, SPAN, RSPAN
- QoS : Cho phép thực hiện traffic queuing và shaping
- Tự động hóa : Tự động các quá trình hoạt động của OpenFlow, OVSDB,...

## 1.2 Kiến trúc của OvS

![Ly-thuyet-OVS/Untitled%202.png](Ly-thuyet-OVS/Untitled%202.png)

Bao gồm các khối chính như sau : 

1. `ovs-vsctl` : 1 công cụ giúp quản lý và điều khiên hoạt động của OVS Daemon. Là công cụ được sử dụng chủ yếu đối với OvS
2. `ovs-ofctl` : 1 công cụ giúp quản lý và điều khiển hoạt động của OpenFlow
3. `ovscd` : Cơ sở dữ liệu của OvS, OvS thực hiện truy cập khi cần lấy các thông số cần thiết trong quá trình hoạt động
4. `ovs-dpctl` : Công cụ cho phép cấu hình Switch Module Kernel 
5. `ovs-vswitchd` : Daemon thực thi chạy Switch ảo kết hợp với module trong Kernel để thực hiện chuyển mạch OpenFlow
6. `ovs-appctl` : Công cụ thực hiện gửi lệnh để chạy OvS Daemon

Ngoài ra còn các khối phụ như :

1. `ovs-ofctl` : Công cụ để giám sát và điều khiển mạch OpenFlow
2. `ovs-pki` : Công cụ tạo Public Key cho OvS
3. `ovs-testcontroller` : Công cụ cho phép thực hiện quản lý Switch ảo, có thể khiên các Switch này hoạt động như Switch L2 ( Layer 2 ) hoặc Hub. 

# 2. Tiến hành cài đặt OvS trên Ubuntu Server 20.04

Mặc định, OpenvSwitch sẽ không được cài đặt trên **Ubuntu Server** nên chúng ta cần thực hiện cài đặt thông qua cú pháp dưới đây

```bash
root@ubun-server-2:~# apt install openvswitch-switch
```

*Lưu ý: Nếu bạn không là User `root` thì sẽ cần sử dụng thêm `sudo`*

→ Quá trình cài đặt sẽ được diễn ra một cách tự động, sau khi cài đặt, bạn có thể kiểm tra và thấy OvS Service đang ở trạng thái *running :*

```bash
root@ubun-server-2:~# systemctl status openvswitch-switch.service
● openvswitch-switch.service - Open vSwitch
     Loaded: loaded (/lib/systemd/system/openvswitch-switch.service; enabled; vendor preset: enabled)
     Active: active (exited) since Wed 2020-11-11 11:24:15 UTC; 1min 54s ago
   Main PID: 2468 (code=exited, status=0/SUCCESS)
      Tasks: 0 (limit: 2249)
     Memory: 0B
     CGroup: /system.slice/openvswitch-switch.service

Nov 11 11:24:15 ubun-server-2 systemd[1]: Starting Open vSwitch...
Nov 11 11:24:15 ubun-server-2 systemd[1]: Finished Open vSwitch.
```

# 3. Các lệnh cơ bản với OvS

## 3.1 Sử dụng `ovs-vsctl` để xem trạng thái các Bridge hiện tại

Việc truy vấn cấu hình Bridge trên hệ thống được diễn ra thông qua lệnh sau :

```bash
root@ubun-server-2:~# ovs-vsctl show
5fad0b3c-2e85-4bb5-b599-d77a9aa2aa0e
    ovs_version: "2.13.1"
```

→ Ở trạng thái hiện tại, chưa có Bridge nào được thiết lập bởi OvS

## 3.2 Sử dụng `ovs-vsctl` để tạo và xóa Bridge

Chúng ta sẽ sử dụng `ovs-vsctl` để thực hiện việc thiết lập 1 Bridge thông qua OvS với cú pháp như sau :

```bash
root@ubun-server-2:~# ovs-vsctl add-br ovs
root@ubun-server-2:~# ovs-vsctl show
5fad0b3c-2e85-4bb5-b599-d77a9aa2aa0e
    Bridge ovs
        Port ovs
            Interface ovs
                type: internal
    ovs_version: "2.13.1"
```

→ Nhận thấy rằng ta đã tạo ra Bridge với tên `ovs` ( Bạn có thể thực hiện tùy chọn tên của Bridge, không bắt buộc là `ovs` )

Để thực hiện xóa Bridge, chúng ta sử dụng lệnh sau ( Trong đó `ovs` là tên Bridge bạn cần xóa ):

```bash
root@ubun-server-2:~# ovs-vsctl del-br ovs
root@ubun-server-2:~# ovs-vsctl show
5fad0b3c-2e85-4bb5-b599-d77a9aa2aa0e
    ovs_version: "2.13.1"
```

→ Như vậy, Bridge chúng ta vừa khởi tạo là `ovs` đã không còn trong danh sách Bridge khả dụng 

## 3.3 Thực hiện thêm và xóa 1 port vào Bridge đã có sẵn

Giả sử chúng ta chúng ta đã có sẵn 1 Bridge tên là `ovs` và một giao diện mạng khả dụng có tên là `ens38` , thì việc thực hiện thêm giao diện này vào Bridge được thực hiện như sau :

```bash
root@ubun-server-2:~# ovs-vsctl show
5fad0b3c-2e85-4bb5-b599-d77a9aa2aa0e
    Bridge ovs
        Port ovs
            Interface ovs
                type: internal
    ovs_version: "2.13.1"
root@ubun-server-2:~# ip a s ens38
3: ens38: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:0c:29:ba:26:1d brd ff:ff:ff:ff:ff:ff
    inet 192.168.98.146/24 brd 192.168.98.255 scope global dynamic ens38
       valid_lft 1798sec preferred_lft 1798sec
    inet6 fe80::20c:29ff:feba:261d/64 scope link
       valid_lft forever preferred_lft forever
```

→ Đầu tiên chúng ta thực hiện kiểm tra tính khả dụng của Bridge và giao diện mạng. Sau đó tiếp tục thực hiện việc thêm Port

```bash
root@ubun-server-2:~# ovs-vsctl add-port ovs ens38
root@ubun-server-2:~# ip a f ens38
root@ubun-server-2:~# dhclient ovs
cmp: EOF on /tmp/tmp.k7UBs70AmY which is empty
```

Trong đó

- Với câu lệnh đầu tiên, ta sử dụng cú pháp `ovs-vsctl add-port` để thực hiện thêm vào Bridge `ovs` một Port là `ens38`
- Tiếp theo, chúng ta cần thực hiện xóa địa chỉ ip trên `ens` → Đây là 1 bước **Bắt buộc** vì nếu không thì hoạt động của OvS sẽ không thực sự ổn định
- Cuối cùng, chúng ta thực hiện yêu cầu địa chỉ IP cho Bridge `ovs` . Hoặc tại bước này bạn cũng thể thực hiện đặt địa chỉ IP tĩnh thông qua lệnh `ip addr add`
- Tại đây, bạn cũng có thể thêm cú pháp type ở sau tên Port. Có 3 type Port được hỗ trợ trong OvS đó là : Internal, VxLAN và GRE

Cuối cùng, chúng ta sẽ thực hiện kiểm tra lại các thay đổi ta vừa thực hiện :

```bash
root@ubun-server-2:~# ovs-vsctl show
5fad0b3c-2e85-4bb5-b599-d77a9aa2aa0e
    Bridge ovs
        Port ens38
            Interface ens38
        Port ovs
            Interface ovs
                type: internal
    ovs_version: "2.13.1"
root@ubun-server-2:~# ip a s ovs
5: ovs: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default qlen 1000
    link/ether 00:0c:29:ba:26:1d brd ff:ff:ff:ff:ff:ff
    inet 192.168.98.146/24 brd 192.168.98.255 scope global dynamic ovs
       valid_lft 1787sec preferred_lft 1787sec
    inet6 fe80::20c:29ff:feba:261d/64 scope link
       valid_lft forever preferred_lft forever
```

→ Nhận thấy rằng, trong Bridge `ovs` đã xuất hiện 1 Port có tên là `ens38` .

Gần tương tự như thêm 1 Port, để thực hiện xóa 1 Port trên Bridge, chúng ta thực hiện :

```bash
root@ubun-server-2:~# ovs-vsctl del-port ovs ens38
root@ubun-server-2:~# ovs-vsctl show
5fad0b3c-2e85-4bb5-b599-d77a9aa2aa0e
    Bridge ovs
        Port ovs
            Interface ovs
                type: internal
    ovs_version: "2.13.1"
```

→ Vậy sau khi thực hiện `del-port`  `ens38` tại Bridge `ovs` thì sau khi kiểm tra trạng thái thì Port đã bị xóa mất khỏi Bridge

## 3.4 Thực hiện liệt kê thông tin các Port trên Bridge

Để thực hiện việc liệt kê các Port đang được kết nối với Bridge, ta thực hiện lệnh sau với :

```bash
root@ubun-server-2:~# ovs-vsctl list-ports ovs
ens38
```

*Trong đó `ovs` là tên Bridge chúng ta cần truy vấn → Ở ví dụ hiện tại thì ta nhận được 1 Port đang kết nối với Bridge là `ens38`*

Nếu trong trường hợp muốn xem thông tin chi tiết các thông số của Port trên Bridge, ta thực hiện  nhập cú pháp sau :

```bash
root@ubun-server-2:~# ovs-ofctl dump-ports ovs
OFPST_PORT reply (xid=0x2): 2 ports
  port LOCAL: rx pkts=1836, bytes=125521, drop=81, errs=0, frame=0, over=0, crc=0
           tx pkts=356, bytes=29268, drop=0, errs=0, coll=0
  port  ens38: rx pkts=2375, bytes=200850, drop=0, errs=0, frame=0, over=0, crc=0
           tx pkts=35, bytes=4294, drop=0, errs=0, coll=0
```

→ Kết quả trả về là các thông số của mỗi Port trên Bridge

## 3.5 Thêm Port vào VLAN thông qua OvS

Trong trường hợp bạn muốn chia các Port vào các VLAN riêng biệt với nhau, thì câu lệnh sử dụng sẽ là như sau khi thực hiện thêm Port :

```bash
root@ubun-server-2:~# ovs-vsctl add-port ovs ens38 tag=100
root@ubun-server-2:~# ovs-vsctl show
5fad0b3c-2e85-4bb5-b599-d77a9aa2aa0e
    Bridge ovs
        Port ovs
            Interface ovs
                type: internal
        Port ens38
            tag: 100
            Interface ens38
    ovs_version: "2.13.1"
```

Thông qua :

- Câu lệnh 1, chúng ta thực hiện thêm 1 Port là `ens38` vào Bridge `ovs` tại VLAN 100
- Câu lệnh 2, ta kiểm tra việc khởi tạo → nhận được kết quả Port `ens38` đã có tag 100 hay cũng có nghĩa là thuộc VLAN 100

---

# Nguồn tham khảo

[hocchudong/thuctap012017](https://github.com/hocchudong/thuctap012017/blob/master/XuanSon/Virtualization/Virtual%20Switch/Open%20vSwitch/OpenvSwitch_basic.md)

[hocchudong/thuctap012017](https://github.com/hocchudong/thuctap012017/blob/master/TamNT/Virtualization/docs/Virtual_Switch/2.Tim_hieu_Open_Vswitch.md#1.1)
