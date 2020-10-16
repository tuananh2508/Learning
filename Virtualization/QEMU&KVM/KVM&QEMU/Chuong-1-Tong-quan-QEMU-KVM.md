# Chương 1: Tổng quan về QEMU-KVM

# Giới thiệu

*Quick Emulator* hay còn được viết tắt là **QEMU** là 1 Hypervisor và là một phần tử chính trong cấu trúc QEMU/KVM. QEMU thực hiện nhiệm vụ ảo hóa phần cứng và mô phỏng CPU. QEMU có thể thực hiện mô phỏng theo 2 kiểu khác nhau:

1. Toàn bộ hệ thống : QEMU sẽ tiến hành ảo hóa toàn bộ hệ thống, bao gồm CPU và các thành phần cần thiết khác
2. Một phần : Thực hiện mô phỏng, thường được sử dụng để sử dụng các ứng dụng trên nền một CPU khác.

*Kernel-based Virtual Machine* ( viết tắt là **KVM** ) là một Module Kernel giúp tăng tốc quá trình xử lý thông tin trong việc quản lý các máy ảo và chức năng của VM. 

QEMU kết hợp cùng KVM sẽ tạo nên 1 Hypervisor type 2 giúp tăng tính linh hoạt và tốc độ xử lý của QEMU do nó không cần quá trình fall-back để thực hiện TCG.

Chúng ta sẽ thực hiện tìm hiểu về chức năng mô hình hóa toàn bộ hệ thống của QEMU-KVM trên phiên bản **Ubuntu 18.04**

# Tiến hành cài đặt QEMU trên Ubuntu 18.04

Để đơn giản hóa quá trình cài đặt, chúng ta sẽ thực hiện cài từ Ubuntu Reposite ( Ngoài ra còn 1 cách khác đó là cài từ Source ). Để tiến hành việc cài đặt ta thực hiện việc ta nhập lệnh sau:

```bash
sudo apt-get update && sudo apt-get install qemu -y
```

hoặc sử dụng :

```jsx
sudo apt-get install qemu-kvm -y
```

Các Packages nhận được sau khi cài đặt:

```bash
tuananh@Computer:~$ dpkg -l | grep qemu
ii  ipxe-qemu                                  1.0.0+git-20180124.fbe8c52d-0ubuntu2.2           all          PXE boot firmware - ROM images for qemu
ii  ipxe-qemu-256k-compat-efi-roms             1.0.0+git-20150424.a25a16d-0ubuntu2              all          PXE boot firmware - Compat EFI ROM images for qemu
ii  qemu                                       1:2.11+dfsg-1ubuntu7.32                          amd64        fast processor emulator
ii  qemu-block-extra:amd64                     1:2.11+dfsg-1ubuntu7.32                          amd64        extra block backend modules for qemu-system and qemu-utils
ii  qemu-slof                                  20170724+dfsg-1ubuntu1                           all          Slimline Open Firmware -- QEMU PowerPC version
ii  qemu-system                                1:2.11+dfsg-1ubuntu7.32                          amd64        QEMU full system emulation binaries
ii  qemu-system-arm                            1:2.11+dfsg-1ubuntu7.32                          amd64        QEMU full system emulation binaries (arm)
ii  qemu-system-common                         1:2.11+dfsg-1ubuntu7.32                          amd64        QEMU full system emulation binaries (common files)
ii  qemu-system-mips                           1:2.11+dfsg-1ubuntu7.32                          amd64        QEMU full system emulation binaries (mips)
ii  qemu-system-misc                           1:2.11+dfsg-1ubuntu7.32                          amd64        QEMU full system emulation binaries (miscellaneous)
ii  qemu-system-ppc                            1:2.11+dfsg-1ubuntu7.32                          amd64        QEMU full system emulation binaries (ppc)
ii  qemu-system-s390x                          1:2.11+dfsg-1ubuntu7.32                          amd64        QEMU full system emulation binaries (s390x)
ii  qemu-system-sparc                          1:2.11+dfsg-1ubuntu7.32                          amd64        QEMU full system emulation binaries (sparc)
ii  qemu-system-x86                            1:2.11+dfsg-1ubuntu7.32                          amd64        QEMU full system emulation binaries (x86)
ii  qemu-user                                  1:2.11+dfsg-1ubuntu7.32                          amd64        QEMU user mode emulation binaries
ii  qemu-user-binfmt                           1:2.11+dfsg-1ubuntu7.32                          amd64        QEMU user mode binfmt registration for qemu-user
ii  qemu-utils                                 1:2.11+dfsg-1ubuntu7.32                          amd64        QEMU utilities
```

→Ở đây ta nhận thấy rằng mỗi loại CPU sẽ được thiết kế riêng 1 loại Package. Ví dụ: arm, ppc, ...

Ngoài ra còn có công cụ và tiện ích đi kèm khác để giúp quản lý các máy ảo: qemu-utils 

# Thực hiện tạo Image với qemu-img

Đầu tiên chúng ta cần xác định xem OS hiện tại đang sử dụng QEMU hỗ trợ những loại kiểu định dạng file nào, việc này có thể thực hiện thông qua lệnh sau :

```bash
qemu-img -h | grep Supported
```

```bash
tuananh@Computer:~/Desktop/QEMU$ qemu-img -h | grep Supported
Supported formats: blkdebug blkreplay blkverify bochs cloop dmg file ftp ftps host_cdrom host_device http https iscsi iser luks nbd null-aio null-co parallels qcow qcow2 qed quorum raw rbd replication sheepdog throttle vdi vhdx vmdk vpc vvfat
```

Do tại bài viết này chúng ta sẽ tạo file hệ thống với file **raw** nên hãy kiểm tra chắc chắn rằng OS có hỗ trợ định dạng file này. Ngoài ra một loại file phổ biến nhất hiện này đó là **qcow2** - dạng file này hỗ trợ snapshot nhiều mức cùng với đó là việc cho phép nén, mã hóa dữ liệu.

*Lưu ý rằng: Tuy hỗ trợ nhiều dạng file khác nhau nhưng không phải bất kì loại file nào cũng có thể sử dụng làm Image, nhưng qemu-img sẽ hỗ trợ chuyển đổi các file này sang dạng có thể sử dụng*

Sau khi xác nhận, chúng ta sẽ thực hiện việc tạo Image dạng raw

```bash
tuananh@Computer:~/Desktop/QEMU$ qemu-img create -f raw example 10G
Formatting 'example', fmt=raw size=10737418240
```

Trong đó option `-f` sẽ giúp chúng ta định dạng loại file Image

Sau đó thực hiện kiểm tra loại file vừa được tạo ra 

```bash
tuananh@Computer:~/Desktop/QEMU$ file -s example 
example: data
```

Ngoài ra có thể xem thêm thông tin về file thông qua qemu-img :

```bash
tuananh@Computer:~/Desktop/QEMU$ qemu-img info example 
image: example # Ten File
file format: raw #Loai File
virtual size: 10G (10737418240 bytes) #Kich thuoc ao
disk size: 0 # Kich thuoc thuc su tren he thong
```

# Chuẩn bị OS Image cho File

Ở đây chúng ta sẽ sử dụng 4 công cụ đó là :

1. qemu-nbd

    Thực hiện tạo QEMU Image thông qua giao thức NBD ( Network Block Device )

2. sfdisk 

    Tạo phân vùng trên Image 

3. mkswap

    Tạo phân vùng Swap với phân vùng được tạo bởi sfdisk

4. mkfs 

    Tạo file hệ thống với phân vùng được tạo với sfdisk

Đầu tiên chúng ta cần load Module Kernel để thực hiện sử dụng `qemu-nbd` :

```bash
root@Computer:~# sudo modprobe nbd
```

Thực hiện sử dụng `qemu-nbd` để chuẩn bị cho bước tạo phân vùng

```bash
root@Computer:~/Desktop/QEMU# sudo qemu-nbd --format=raw --connect=/dev/nbd0 example
```

Thực hiện tạo phân vùng thông qua `sfdisk` : 

```bash
root@Computer:~/Desktop/QEMU# sfdisk /dev/nbd0 << EOF
> 1024,82
> ;
> EOF
Checking that no-one is using this disk right now ... OK

Disk /dev/nbd0: 10 GiB, 10737418240 bytes, 20971520 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

>>> Created a new DOS disklabel with disk identifier 0xa33dcf18.
/dev/nbd0p1: Created a new partition 1 of type 'Linux' and of size 41 KiB.
/dev/nbd0p2: Created a new partition 2 of type 'Linux' and of size 10 GiB.
/dev/nbd0p3: Done.

New situation:
Disklabel type: dos
Disk identifier: 0xa33dcf18

Device      Boot Start      End  Sectors Size Id Type
/dev/nbd0p1       1024     1105       82  41K 83 Linux
/dev/nbd0p2       2048 20971519 20969472  10G 83 Linux

The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

→ Ở đây chúng ta thực hiện tạo một phân vùng bắt đầu từ offset 1024 có kích thước là 82 sector tương đương với kích thước 82 * 512 = 47 984 bytes = 41Kb. Tiếp đó có thể kiểm tra lại việc tạo phân vùng thông qua: 

```bash
root@Computer:~/Desktop/QEMU# ls -al /dev/nbd0*
brw-rw---- 1 root disk 43, 0 Thg 1  5 17:21 /dev/nbd0
brw-rw---- 1 root disk 43, 1 Thg 1  5 17:21 /dev/nbd0p1
brw-rw---- 1 root disk 43, 2 Thg 1  5 17:21 /dev/nbd0p2
```

Tiếp đó tiến hành việc tạo vùng Swap trên phân vùng chúng ta vừa tạo thông qua lệnh `mkswap`

```bash
root@Computer:~/Desktop/QEMU# mkswap /dev/nbd0p1
Setting up swapspace version 1, size = 36 KiB (36864 bytes)
no label, UUID=ec313fba-a190-4252-a3d8-cdd13f176955
```

Công việc cuối cùng là tạo file hệ thống trên phân vùng còn lại của Image, ở đây chúng ta sẽ lựa chọn sử dụng file Ext4 do các tính năng nổi trội của nó :

```bash
root@Computer:~/Desktop/QEMU# mkfs.ext4 /dev/nbd0p2
mke2fs 1.44.1 (24-Mar-2018)
Discarding device blocks: failed - Input/output error
Creating filesystem with 2621184 4k blocks and 655360 inodes
Filesystem UUID: dcf242d4-45a2-43a0-8808-ce302ca16393
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information:      
done
```

Kiểm tra lại định dạng file hệ thống chúng ta vừa tạo → Nhận thấy sự thay đổi so với ban đầu : 

```bash
root@Computer:~/Desktop/QEMU# file -s example 
example: DOS/MBR boot sector; partition 1 : ID=0x83, start-CHS (0x0,16,17), end-CHS (0x0,17,35), startsector 1024, 82 sectors; partition 2 : ID=0x83, start-CHS (0x0,32,33), end-CHS (0x119,106,17), startsector 2048, 20969472 sectors
```

# Thực hiện cài đặt OS trên Image với deboostrap

Sau khi có được 2 phân vùng ( partition ) ở bước trên, chúng ta cần thực hiện mount phân vùng sử  dụng làm filesystem vào `/mnt` trên máy host để có thể sử dụng phân vùng na :

```bash
root@Computer:~/Desktop/QEMU# mount /dev/nbd0p2 /mnt/
```

Sau đó thực hiện tải OS ( ở đây sử dụng ví dụ là Debian có kiến trúc AMD64 ) thông qua debootstrap :

```bash
	root@Computer:~/Desktop/QEMU# debootstrap --arch=amd64 --include="openssh-server vim" stable /mnt/ http://httpredir.debian.org/debian/
```

Để thực hiện cài GRUB Boot Loader trên phân vùng root của Image, chúng ta cần mount bind phần đường dẫn `/dev` từ host sang đường dẫn `/mn/dev` của Image :

```bash
tuananh@Computer:~/Desktop/QEMU$ mount --bind /dev/ /mnt/dev/
```

Sau khi thực hiện hết các bước trên, chúng ta sẽ sử dụng lệnh `chroot` để thực hiện chuyển đường dẫn root tạm thời sang thành `/mnt` → Cho phép thực hiện các thay đổi như trên 1 OS mới :

```bash
chroot /mnt
```

Mount các file hệ thống ảo là  `proc` và `sysfs` bên trong môi trường `chroot` do GRUB Boot Loader có yêu cầu 2 đường dẫn này : 

```bash
mount -t proc none /proc
mount -t sysfs none /sys
```

Thực hiện cài Debian kernel metapackage và GRUB để chuẩn bị cho việc cài đặt Bootloader :

```bash
root@Computer:/# apt-get install -y --force-yes linux-iamge-amd64 grub2
```

Thực hiện cài đặt Bootloader bên trong `chroot` : 

```bash
root@Computer:/# grub-install /dev/nbd0 --force
```

Sau đó cập nhật lại cấu hình của GRUB :

```bash

root@Computer:/# update-grub2
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-4.19.0-11-amd64
Found initrd image: /boot/initrd.img-4.19.0-11-amd64
Found Ubuntu 18.04.5 LTS (18.04) on /dev/sda7
done

```

Tiếp đó chúng ta cần đổi lại mật khẩu của root để sau này có thể sử dụng để đăng nhập :

```bash
root@Computer:/# passwd
New password: 
Retype new password: 
passwd: password updated successfully
```

Thực hiện cấp quyền truy cập pseudo Terminal ( Là 1 dạng Terminal được mô phỏng ) bên trong OS ảo :

```bash
echo "pts/0" >> /etc/securetty
```

Do khi cài đặt lần đầu thì `fstab` trên OS ảo sẽ không có đường mount cho root, vậy nên chúng ta cần chỉ định thủ công để VM có thể bật lại được trong các lần khởi động sau :

```bash
root@Computer:/# echo "/dev/sda2 / ext4 defaults,discard 0 0" > /etc/fstab
```

Chuyển đổi Run Level từ GUI sang CLI mà vẫn cung cấp đủ các service :

```bash
systemctl set-default multi-user.target
```

Thực hiện unmount các đường dẫn sau khi sử dụng xong :

```bash
umount /proc/ /dev/ /sysfs/
```

Thoát OS ảo :

```bash
root@Computer:/# exit
```

Thực hiện cài đặt GRUB trên phân vùng root của block device liên kiết với raw Image :

```bash
root@Computer:~/Desktop/QEMU# grub-install /dev/nbd0 --root-directory=/mnt --modules="biosdisk part_msdos" --force
Installing for i386-pc platform.
Installation finished. No error reported.
```

Tiếp đó chúng ta thực hiện chỉnh sửa tên file hệ thống của GRUB do bên trong VM đang thực hiện nhận phân vùng này với tên `sda2` . Tên hệ thống `nbd0p2` chỉ tồn tại khi có liên kết giữa raw Image và Network Block Device

```bash
root@Computer:~/Desktop/QEMU# sed -i 's/nbd0p2/sda2/g' /mnt/boot/grub/grub.cfg
```

Như vậy quá trình cài đặt đã thực hiện xong, công việc cuối cùng là unmount ổ đĩa ảo và NBD :

```bash
root@Computer:~/Desktop/QEMU# umount /mnt 
root@Computer:~/Desktop/QEMU# qemu-nbd --disconnect /dev/nbd0
```

**Nếu trong trường hợp bạn không muốn tạo Image thì có thể tải trực tiếp Image từ các nguồn chính thức:**

- Ubuntu : [https://uec-images.ubuntu.com/releases/](https://uec-images.ubuntu.com/releases/)
- Centos : [https://cloud.centos.org/centos/](https://cloud.centos.org/centos/)
- Debian : [http://cdimage.debian.org/cdimage/openstack/](http://cdimage.debian.org/cdimage/openstack/)

Sau đó cần sử dụng `wget` kèm theo link tải Image để tải về .

# Thực hiện chạy VM bằng Virt-manager

Việc thực hiện chạy VM có thể thực hiện bằng Virt-manager. Sau đây chúng ta sẽ tìm hiểu cách boot VM bằng Virt-manager hỗ trợ giao diện GUI ( Graphical User Interface )

Việc cài đặt Virt Manager được cài đặt thông qua :

```jsx
sudo apt install virt-manager
```

Thực hiện bật cửa số lệnh Terminal thông qua tổ hợp phím `ctrl + alt  + t` , sau đó tiến hành nhập như sau:

```jsx
tuananh@Computer:~/Desktop/QEMU$ sudo -s
[sudo] password for tuananh: 
root@Computer:~/Desktop/QEMU# virt-manager
```

Sau khi thực hiện xử lý, ngưởi sử dụng sẽ nhận được giao diện như sau:

![Chuong-1-Tong-quan-QEMU-KVM/Untitled.png](Chuong-1-Tong-quan-QEMU-KVM/Untitled.png)

Tiếp đó, để thực hiện tạo và chạy máy ảo, chúng ta thực hiện chọn **File** và N**ew Virtual Machine:**

![Chuong-1-Tong-quan-QEMU-KVM/Untitled%201.png](Chuong-1-Tong-quan-QEMU-KVM/Untitled%201.png)

Nhận được cửa số mới như sau:

![Chuong-1-Tong-quan-QEMU-KVM/Untitled%202.png](Chuong-1-Tong-quan-QEMU-KVM/Untitled%202.png)

Tại đây chúng ta sẽ chọn **Import existing disk image** do đã có các file Image vừa tạo ở các bước trên, sau khi chọn xong bạn click **Forward** :

![Chuong-1-Tong-quan-QEMU-KVM/Untitled%203.png](Chuong-1-Tong-quan-QEMU-KVM/Untitled%203.png)

Tại đây Virt-manager yêu cầu chúng ta xác định đường dẫn tới file Image của máy ảo, bạn chọn **Browse** và chọn đường dẫn tới file Image có được từ các bước trên:

![Chuong-1-Tong-quan-QEMU-KVM/Untitled%204.png](Chuong-1-Tong-quan-QEMU-KVM/Untitled%204.png)

Sau khi xác định được đường dẫn bạn thực hiện chọn **Choose Volume** và nhận được màn hình sau:

![Chuong-1-Tong-quan-QEMU-KVM/Untitled%205.png](Chuong-1-Tong-quan-QEMU-KVM/Untitled%205.png)

Tại mục **Chose the operating system ...** , tùy thuộc vào loại Image bạn tạo là loại OS nào thì bạn sẽ điền OS đó vào mục này, nếu mặc định bạn sẽ để **Generic default** , sau khi hoàn tất tiếp tục chọn **Forward** 

![Chuong-1-Tong-quan-QEMU-KVM/Untitled%206.png](Chuong-1-Tong-quan-QEMU-KVM/Untitled%206.png)

Ở bước tiếp theo thì chúng ta sẽ cần thiết lập các thông số thiết yếu của máy ảo như *Memory và CPU* ( Bộ nhớ ảo và CPU ảo cấp cho máy ảo ), ở đây lấy ví dụ là 1024MB Memory và 1 CPU ảo, sau khi thiết lập xong thông số chọn **Forward**

Ở bước cuối cùng chúng ta sẽ thiết lập tên của máy ảo và đường mạng ảo cho máy:

![Chuong-1-Tong-quan-QEMU-KVM/Untitled%207.png](Chuong-1-Tong-quan-QEMU-KVM/Untitled%207.png)

Tại múc Network selection chúng ta chọn **default ( hoặc nêu không có bạn chỉ cần bỏ qua và click Finish thì hệ thống sẽ tự tạo mạng ảo mới )**

![Chuong-1-Tong-quan-QEMU-KVM/Untitled%208.png](Chuong-1-Tong-quan-QEMU-KVM/Untitled%208.png)

Kết quả nhận được sáu bước cuối cùng

![Chuong-1-Tong-quan-QEMU-KVM/Untitled%209.png](Chuong-1-Tong-quan-QEMU-KVM/Untitled%209.png)

![Chuong-1-Tong-quan-QEMU-KVM/Untitled%2010.png](Chuong-1-Tong-quan-QEMU-KVM/Untitled%2010.png)

### *Vậy là quá trình Boot VM bằng **Virt-manager** đã kết thúc thành công !*

**Mở rộng** : *Tiến hành boot VM từ Terminal*

Chúng ta sẽ tiến hành Boot VM thông qua câu lệnh *virt-install* có dạng như sau:

```bash
virt-install --name deb --ram 512 --vcpus 1 --disk path=/home/vutuananh/Desktop/test/debian --import
```

Trong đó: 

`--name` : Tên của máy ảo

`--ram` : Lượng RAM cung cấp cho máy ảo

`--vcpus` : Số CPU cung cấp cho máy ảo

`--disk path` : Đường dẫn tới Image chứa OS ảo