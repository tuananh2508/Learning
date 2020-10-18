# Chương 2: Sử dụng libvrt để quản lý các VM

# 1. Thực hiện tải package libvrt

Trong mô hình của hệ thống QEMU-KVM thì *libvrt* nằm tại tầng thứ 3 từ duới lên, nhiệm vụ của nó chính là việc cung cấp các API để các VM hoặc Hypervisor tương tác với KVM có thể thực hiện các thao tác quản lý tài nguyên.

![Chuong-2-Su-dung-libvrt/687474703a2f2f696d6775722e636f6d2f777341356846372e6a7067.png](Chuong-2-Su-dung-libvrt/687474703a2f2f696d6775722e636f6d2f777341356846372e6a7067.png)

# 2. Sử dụng File XML để tạo 1 VM

Mỗi khi chúng ta thực hiện tạo 1 VM thì tại thư mục `/etc/libvrt/qemu/` sẽ xuất hiện 1 file XML lưu giữ cấu hình của VM đó. Ở chương trước, chúng ta đã thực hiện tạo VM thông qua giao diện GUI của `virt-manager` ( hoặc qua CLI trong phần mở rộng )

Tại chương này chúng ta sẽ thực hiện tạo 1 VM bằng 1 file XML đơn giản và thực hiện Boot VM này để sử dụng

Đầu tiên chúng ta sẽ cần những thứ sau:

1. 1 file Image ( đã được tạo như tại chương 1 hoặc bạn cũng thể thực hiện tải các Image khác từ các nhà phân phối khác nhau )
2. Package Qemu-KVM ( đã được cài đặt tại chương 1 )

Tiếp theo chúng ta sẽ kiểm tra trạng thái của các VM trên hệ thống hiện tại thông qua:

```jsx
root@Computer:~/Desktop/QEMU# virsh list --all
 Id    Name                           State
----------------------------------------------------
```

→ Thông thường khi chưa cài đặt máy ảo thì danh sách này sẽ rỗng

Tiếp tục, chúng ta sẽ truy nhập tới `/etc/libvrt/qemu` , thực hiện tạo file xml của 1 máy ảo ( ở đây mình sẽ sử dụng Neovim để tạo nhưng bạn cũng có thể sử dụng các Text Editor khác như Nano, Vim , etc ) 

```jsx
nvim vm1.xml
```

Sau khi thực hiện tạo file chúng ta sẽ insert nội dung sau vào file

```bash
<domain type='kvm'>
  <name>kvm1</name>
  <uuid>d2c617e2-f715-4920-ac69-1e57a76ab22b</uuid>
  <memory unit='KiB'>524288</memory>
  <currentMemory unit='KiB'>524288</currentMemory>
  <vcpu placement='static'>1</vcpu>
  <os>
    <type arch='x86_64' machine='pc-i440fx-trusty'>hvm</type>
    <boot dev='hd'/>
  </os>
  <clock offset='utc'/>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>restart</on_crash>
  <devices>
    <emulator>/usr/bin/qemu-system-x86_64</emulator>
    <disk type='file' device='disk'>
      <driver name='qemu' type='raw'/>
      <source file='/home/tuananh/Desktop/QEMU/deb'/>
      <target dev='hda' bus='ide'/>
      <address type='drive' controller='0' bus='0' target='0' unit='0'/>
    </disk>
    <controller type='usb' index='0' model='piix3-uhci'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x2'/>
    </controller>
    <controller type='pci' index='0' model='pci-root'/>
    <controller type='ide' index='0'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x1'/>
    </controller>
    <interface type='network'>
      <mac address='52:54:00:c5:7f:d4'/>
      <source network='default'/>
      <model type='rtl8139'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>
    </interface>
    <input type='mouse' bus='ps2'/>
    <input type='keyboard' bus='ps2'/>
    <graphics type='vnc' port='-1' autoport='yes' listen='146.20.141.158'>
      <listen type='address' address='146.20.141.158'/>
    </graphics>
    <video>
      <model type='cirrus' vram='16384' heads='1' primary='yes'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x0'/>
    </video>
    <memballoon model='virtio'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x04' function='0x0'/>
    </memballoon>
  </devices>
  <seclabel type='none' model='apparmor'/>
</domain>
```

Tại đây chúng ta sẽ thực hiện giải thích  1 số mục cơ bản trong file xml này :

- domain : Đây có thể hiểu như phần tử root của mọi máy ảo, tại đây chúng ta sẽ thực hiện định nghĩa type là *kvm* do chúng ta đang sử dụng module KVM để tăng tốc độ xử lý máy ảo được tạo bởi Type 2 Hypervisor QEMU. Các mục khác của máy ảo được định nghĩa trong mục `<domain`
- name : Đây là mục định nghĩa tên của máy ảo
- uuid : là viết tắt của Universal Unique Identifier → mỗi VM sẽ có 1 uuid của riêng nó
- memory unit : Phần bộ nhớ ảo được cấp cho VM có đơn vị KiB . Ví dụ bạn muốn cấp cho máy ảo 512MB RAM thì giá trị tại đây sẽ có giá trị 512 x 1024 = 524288 KiB.
- vcpu : Cpu ảo được cấp cho VM. Tại đây chúng ta định nghĩa *Placement* của máy ảo là *static* → VM sẽ sử dụng bất cứ CPUs nào còn khả dụng về mặt vật lý
- os : Thực hiện định nghĩa loại kiến trúc của VM. Tại đây chúng ta có sử dụng thêm option `hvm` → yêu cầu sử dụng loại ảo hóa : FULL VIRTUALIZATION . Sau đó chúng ta sẽ lựa chọn boot device của VM thông qua <boot device>
- on_poweroff/reboot/crash : Thực hiện định nghĩa các hành động khi guest OS yêu cầu Power off - Reboot hay khi gặp lỗi ( Crash )
- devices : Tại mục này thực  hiện định nghĩa các thiết bị được cung cấp tới máy ảo.

Để có thể hiểu rõ hơn về ý nghĩa các mục, bạn có thể tham khảo trong: 

[Domain XML format](https://libvirt.org/formatdomain.html)

Sau đó, bạn thực hiện lưu lại file. Việc cấu hình file XML của 1 VM đã hoàn tất. 

**Tuy nhiên bạn có thể nhận thấy rằng việc cấu hình bằng file XML có thể khá khó khăn**

→ Bạn có thể sử dụng cách tạo máy ảo bằng *virt-install* như đã hướng dẫn ở phần cuối chương 1. Sau khi thực hiện tạo máy ảo bằng cách này thì cũng file XML của máy ảo cũng sẽ được tự động tạo và sẽ xuất hiện tại đường dẫn `/etc/libvrt/qemu` .

# 3. Thực hiện bật , tắt và xóa VM

![Chuong-2-Su-dung-libvrt/Untitled.png](Chuong-2-Su-dung-libvrt/Untitled.png)

Việc thực hiện các thao tác được liệt kê ở trên có thể thực hiện thông qua virsh - management user interface được cung cấp qua package qemu-kvm mà chúng ta đã thực hiện cài đặt ở :

[Copy of Chương 1: Tổng quan về QEMU-KVM](Chuong-2-Su-dung-libvrt/Copy%20of%20Chu%CC%9Bo%CC%9Bng%201%20To%CC%82%CC%89ng%20quan%20ve%CC%82%CC%80%20QEMU-KVM%20a372c69de53c4a5083d98dde7de94ccd.md)

Để thực hiện bật ( start ) 1 VM đã có sẵn Image ( Việc tạo / tải Image xem tại Chương 1)  :

```bash
virsh start debian
```

Việc thực hiện dừng VM được thực hiện gần tương tự như sau:

```bash
virsh destroy debian
```

Để thực hiện xóa 1 VM chúng ta sẽ sử dụng

```bash
virsh undefine debian
```

*Trong đó debian là file Image bạn đã có*

# 4. Tạo VM với file cài đặt từ Internet

Đa số các nhà cung cấp hiện thời như Debian hay Ubuntu,Fedora ,... thì đã cung cấp sẵn các Image trên hệ thống của họ, nếu bạn không muốn tự build 1 Image 1 cách thủ công thì có thể tải trực tiếp các bộ cài đặt ( Installer ) thông qua các đường link sau:

```

			 Debian
           <http://ftp.us.debian.org/debian/dists/stable/main/installer-amd64/>

       Ubuntu
           <http://jp.archive.ubuntu.com/ubuntu/dists/trusty/main/installer-amd64/>
```

Với các OS khác bạn có thể tham khảo trong mục `--location` trong `man virt-install`

Để tiến hành cài đặt OS ảo trên nền QEMU/KVM với file cài đặt từ Internet ta thực hiện như sau:

Thực hiện tải Image từ trên các nguồn trên và cài đặt thông qua việc sử dụng **virt-install** 

```bash
virt-install --name ubun --ram 512 --hvm --graphics vnc,listen=192.168.150.128 --extra-args="text console=tty0 utf 8 console=ttyS0,115200" --disk path=/tmp/ubun.img,size=10 --location=http://jp.archive.ubuntu.com/ubuntu/dists/trusty/main/installer-amd64/
```

Trong đó các option có ý nghĩa như sau:

- name : Tên của VM
- extra-args: Tại đây ta thực hiện định nghĩa sử dụng Serial Console 0 trong quá trình cài đặt
- graphic : Khai báo cho phép cài đặt với giao diện
- hvm : Yêu cầu Full Virtualization
- location : Đường dẫn tải Installer
- disk path : Đường lưu của file Image
- size : Kích thước của Image

Màn hình nhận được sau khi thực hiện nhập lệnh 

![Chuong-2-Su-dung-libvrt/Untitled%201.png](Chuong-2-Su-dung-libvrt/Untitled%201.png)

*Lưu ý Nếu bạn nhận được cửa số này thì có thể tắt nó đi, chúng ta sẽ sử dụng virsh để đăng nhập vào  installer để thực hiện cài đặt*

![Chuong-2-Su-dung-libvrt/Untitled%202.png](Chuong-2-Su-dung-libvrt/Untitled%202.png)

Tiếp theo bạn cần nhập lệnh sau để kết nối console tới Installer có được thông qua bước trên

```bash
virsh console ubun 
```

*Trong đó ubun là tên VM ( được xác định tại option - -name )*

![Chuong-2-Su-dung-libvrt/Untitled%203.png](Chuong-2-Su-dung-libvrt/Untitled%203.png)

Bận nhấn **Enter** để bắt đầu quá trình cài đăt, các bước trong Installer được miêu tả khá rõ ràng nên tại đây sẽ không hướng dẫn cụ thể. Bạn thực hiện theo các bước trong Installer để hoàn tất quá trình cài đặt

Sau khi hoàn tất quá trình cài đặt, mặc định các VM sẽ ở trạng thái shutoff, bạn cần bật VM thông qua lệnh

```bash
virsh start ubun
```

Sau khi thực hiện bật VM bạn có thể thực hiện đăng nhập qua console với tên ngưởi dùng và mật khẩu có từ bước trên

```bash
virsh console ubuntu 
```

![Chuong-2-Su-dung-libvrt/Untitled%204.png](Chuong-2-Su-dung-libvrt/Untitled%204.png)

**Vậy là quá trình cài đặt đã hoàn tất !**
