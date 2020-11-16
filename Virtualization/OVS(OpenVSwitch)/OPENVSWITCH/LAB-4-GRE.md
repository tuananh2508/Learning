# LAB 4 : Ứng dụng lý thuyết GRE

*Bài LAB thực hiện ứng dụng lý thuyết về Generic Routing Encapsulation* 

**Yêu cầu**

- Kiến thức về OVS

    Tham khảo tại :

    [tuananh2508/LinuxVcc](https://github.com/tuananh2508/LinuxVcc/blob/master/Virtualization/OVS(OpenVSwitch)/OPENVSWITCH/Ly-thuyet-OVS.md)

- Kiến thức về QEMU/KVM:

    Tham khảo tại :

    [tuananh2508/LinuxVcc](https://github.com/tuananh2508/LinuxVcc/blob/master/Virtualization/QEMU&KVM/KVM%26QEMU.md)

- 2 Server để thực hiện host 2 VM ( Trong bài sử dụng Ubuntu Server 20.04 )

    2 VM có OS là Centos 7

**Mô hình**

![LAB-GRE/Untitled.png](LAB-GRE/Untitled.png)

**Mục Lục**
- [LAB 4 : Ứng dụng lý thuyết GRE](#lab-4--ứng-dụng-lý-thuyết-gre)
- [1. Thực hiện tạo Bridge `ovs0`](#1-thực-hiện-tạo-bridge-ovs0)
- [2. Tạo Network](#2-tạo-network)
- [3. Tiến hành thêm Port VM và Port GRE vào Bridge](#3-tiến-hành-thêm-port-vm-và-port-gre-vào-bridge)
- [4. Kiểm tra việc Ping giữa 2 VM và xem bản tin tại Wireshark](#4-kiểm-tra-việc-ping-giữa-2-vm-và-xem-bản-tin-tại-wireshark)
- [Nguồn tham khảo](#nguồn-tham-khảo)

# 1. Thực hiện tạo Bridge `ovs0`

Đầu tiên chúng ta cần tạo 1 Bridge `ovs0`  công việc được thực hiện tại 2 Server :

```bash
root@ubun-server:/# ovs-vsctl add-br ovs0
```

```bash
root@ubun-server-2:/# ovs-vsctl add-br ovs0
```

*Thông qua câu lệnh `ovs-vsctl` thì chúng ta đã khởi tạo ( `add-br` ) có tên là `ovs0`*

# 2. Tạo Network

Công việc tiếp theo là khởi tạo 1 Network để có thể kết nối 2 VM tới Network này. Đầu tiên chúng ta cần tạo 1 file `ovs.xml` tại đường dẫn `/etc/libvirt/qemu/networks/` có nội dung như sau :

```bash
<network>
  <name>ovs</name>
  <forward mode='bridge'/>
  <bridge name='ovs0'/>
  <virtualport type='openvswitch'/>
</network>
```

*Trong đó*

- `ovs` : Tên Network ta sẽ khởi tạo
- `ovs0` : Tên của Bridge ta đã tạo trước đó

Sau khi đã có được file xml thì chúng ta sẽ sử dụng `virsh` để có thể tạo Network :

```bash
root@ubun-server-2:/etc/libvirt/qemu/networks# virsh net-define ovs.xml
root@ubun-server-2:/etc/libvirt/qemu/networks# virsh net-start ovs
root@ubun-server-2:/etc/libvirt/qemu/networks# virsh net-autostart ovs
root@ubun-server-2:/etc/libvirt/qemu/networks# virsh net-list --all
 Name      State    Autostart   Persistent
--------------------------------------------
 default   active   yes         yes
 ovs       active   yes         yes
```

*Thông qua*

- Câu lệnh 1, ta tiến hành khởi tạo 1 Network từ file xml có được
- Câu lệnh 2, việc thực hiện khởi động Network được tiến hành
- Câu lệnh 3, chuyển chế độ của Network sang tự khởi động mỗi khi máy Boot
- Câu lệnh 4, Kiểm tra việc khởi tạo Network

# 3. Tiến hành thêm Port VM và Port GRE vào Bridge

Sau khi đã tiến hành các bước trên, chúng ta sẽ thêm các Port của VM vào Bridge đã có sẵn. Ở chế độ mặc định thì các VM sẽ thuộc vào Linux Bridge `virbr0` , nên chúng ta cần tiến hành xóa tại 2 Server ( Nếu VM của bạn không thuộc `virbr0` thì có thể bỏ qua bước này ) :

```bash
root@ubun-server:~# brctl show
bridge name     bridge id               STP enabled     interfaces
virbr0          8000.525400379997       yes             virbr0-nic
                                                        vnet0
root@ubun-server:~# brctl delif virbr0 vnet0
root@ubun-server:~# brctl show
bridge name     bridge id               STP enabled     interfaces
virbr0          8000.525400379997       yes             virbr0-nic
```

Tiếp theo, ta sẽ thêm các Port VM vào Bridge `ovs0` :

```bash
root@ubun-server:/# ovs-vsctl add-port ovs0 vnet0
root@ubun-server:/# ovs-vsctl add-port ovs0 gre0 -- set interface gre0 type=gre options:remote_ip=192.168.26.128
```

*Trong đó `192.168.26.128` là địa chỉ IP tại Server 2 và `gre0` là tên Port GRE ta khởi tạo*

```bash
root@ubun-server-2:/# ovs-vsctl add-port ovs0 vnet0
root@ubun-server-2:/# ovs-vsctl add-port ovs0 gre0 -- set interface gre0 type=gre options:remote_ip=192.168.26.129
```

*Trong đó `192.168.26.129` là địa chỉ IP tại Server 1 và `gre0` là tên Port GRE ta khởi tạo*

**Lưu ý: Ở đây chúng ta sẽ không tiến hành thêm Port `ens39` vào các Bridge tại các Server!!!**

# 4. Kiểm tra việc Ping giữa 2 VM và xem bản tin tại Wireshark

Thực hiện truy cập vào 2 VM đặt địa chỉ IP tĩnh

Tại VM-1

```bash
[root@localhost ~]# ip a a 192.168.26.219/24 dev eth0
```

Tại VM-2

```bash
[root@localhost ~]# ip a a 192.168.26.220/24 dev eth0
```

Sau đó tại VM-1 sẽ ping VM-2

```bash
[root@localhost ~]# ping 192.168.26.220
PING 192.168.26.220 (192.168.26.220) 56(84) bytes of data.
64 bytes from 192.168.26.220: icmp_seq=1 ttl=64 time=1.25 ms
64 bytes from 192.168.26.220: icmp_seq=2 ttl=64 time=0.758 ms
64 bytes from 192.168.26.220: icmp_seq=3 ttl=64 time=0.749 ms
64 bytes from 192.168.26.220: icmp_seq=4 ttl=64 time=0.893 ms

--- 192.168.26.220 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3012ms
rtt min/avg/max/mdev = 0.749/0.914/1.258/0.208 ms
```

→ Việc Ping thành công → 2 VM đã được kết nối thông qua GRE và điều đó được thể hiện thông qua việc xem bản tin WireShark

![LAB-GRE/Untitled%201.png](LAB-GRE/Untitled%201.png)

⇒ Như vậy đã có sự xuất hiện của GRE Header và Outer IP Header → Chứng tỏ các bản tin của ta đã sử dụng GRE Tunnel .

---

# Nguồn tham khảo

[Connecting VMs Using Tunnels - Open vSwitch 2.14.90 documentation](https://docs.openvswitch.org/en/latest/howto/tunneling/)