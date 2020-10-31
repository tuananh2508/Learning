# Thin-Volume-LVM

![Thin-Volume-LVM/Untitled.png](Thin-Volume-LVM/Untitled.png)

Trước khi đến với việc cấu hình **Thin Volume** trong LVM thì chúng ta cần có hiểu biết cơ bản cũng như phân biệt được **Thick và Thin Provisioning** trong Linux. **Thin Volume** cho phép chúng ta thực hiện **Overprovisioning** → Cho phép chia sẻ dung lượng dữ liệu giữa các Host khác nhau trên cùng 1 hệ thống vật lý.

Để tìm hiểu các kiến thức cơ  bản về **Thick và Thin Provisioning.** Bạn có thể tham khảo thông qua đường link bên dưới :

[tuananh2508/LinuxVcc](https://github.com/tuananh2508/LinuxVcc/blob/master/Virtualization/QEMU%26KVM/KVM&QEMU/Hot-Plug-trong-KVM.md#thin-v%C3%A0-thick-provisioning)

**Yêu cầu** 

- Hiểu biết lý thuyết về LVM và các thao tác cơ bản với LVM

    Tham khảo tại :
    [tuananh2508/LinuxVcc](https://github.com/tuananh2508/LinuxVcc/blob/master/Linux/PROJECT%20LINUX/Logical-Volume-Management/Create-Delete-Extend-Reduce-LVM.md)

- 1 Server sử dụng OS Linux

    ( Ở đây sử dụng OS **Debian 10** ) 

- 2 Physical Volume trên OS ( Debian10)  : `/dev/sda3` và  `/dev/sda4/`

**Mô hình Logic LVM**

![Thin-Volume-LVM/Untitled%201.png](Thin-Volume-LVM/Untitled%201.png)

**Mục lục**
- [Thin-Volume-LVM](#thin-volume-lvm)
- [1. Thực hiện tạo Thin Volume](#1-thực-hiện-tạo-thin-volume)
- [2. Thực hiện tạo Thin Volume từ Thin Pool](#2-thực-hiện-tạo-thin-volume-từ-thin-pool)
- [3. Thể hiện tính năng Overprovisioning](#3-thể-hiện-tính-năng-overprovisioning)
  - [Nguồn tham khảo](#nguồn-tham-khảo)


# 1. Thực hiện tạo Thin Volume

Để thực hiện tạo 1 Thin Volume, đầu tiên chúng ta cần tạo 1 Volume Group từ 2 Physical Volume chúng ta đã có sẵn là  `/dev/sda3` và  `/dev/sda4/` :

```bash
root@debian:~# vgcreate thin-group /dev/sda3 /dev/sda4
  Volume group "thin-group" successfully created
root@debian:~# vgs
  VG         #PV #LV #SN Attr   VSize  VFree
  thin-group   2   0   0 wz--n- <2.00g <2.00g
```

*Trong đó : `thin-group` là Volume Group chúng ta sẽ thực hiện tạo . Nếu bạn đã có sẵn 1 Volume Group thì có thực hiện đổi tên Volume Group đó sử dụng lệnh `vgrename` để dễ phân biệt trong thời gian sử dụng sau này*

Tiếp tục. sau khi đã có 1 Volume Group thì ta sẽ thực hiện tạo 1 Thin Volume Pool để có thể thực hiện chia thành các Thin Volume trong các bước sau :

```bash
root@debian:~# lvcreate -l 100%FREE --thinpool thin-pool thin-group
  Thin pool volume with chunk size 64.00 KiB can address at most 15.81 TiB of data.
  Logical volume "thin-pool" created.
root@debian:~# lvs
LV        VG         Attr      LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
thin-pool thin-group twi-a-tz-- <1.99g             0.00   10.94
```

*Trong đó* :

Tại câu lệnh thứ nhất, ta thực hiện tạo 1 Thin Pool 

- Option `-l` : Cho phép chúng ta chỉ định kích thước của Thin Volume từ VG

    Ở trường hợp này, ta thực hiện chỉ định 100% dung lượng còn trống của Volume Group 

- Option `--thinpool` : Chỉ định tạo Thin Pool
- `thin-pool` : Tên của Thin Pool chúng ta thực hiện tạo
- `thin-group` : Tên của Volume Group mà Thin Pool sẽ được tạo

Tại câu lệnh thứ hai, chúng ta thực hiện kiểm tra lại thông số của Logical Volume. Do 1 Thin Pool cũng được coi là 1 Logical Volume nên khi thực hiện lệnh liệt kê Logical Volume thì ta cũng xem được các thông số của Volume Group 

# 2. Thực hiện tạo Thin Volume từ Thin Pool

Sau khi đã có 1 Thin Pool từ bước trên, chúng ta sẽ thực hiện sử dụng Pool này để tạo các Thin Volume. Việc tiến hành tạo được thực hiện tạo như sau :

```bash
root@debian:~# lvcreate -V 1024 --thin -n tp-user1 thin-group/thin-pool
  Logical volume "tp-user1" created.
root@debian:~# lvcreate -V 1000 --thin -n tp-user2 thin-group/thin-pool
  Logical volume "tp-user2" created.
root@debian:~# lvs
  LV        VG         Attr       LSize    Pool      Origin Data%  Meta%  Move Log Cpy%Sync Convert

  thin-pool thin-group twi-aotz--   <1.99g                  0.00   11.13
  tp-user1  thin-group Vwi-a-tz--    1.00g thin-pool        0.00
  tp-user2  thin-group Vwi-a-tz-- 1000.00m thin-pool        0.00
```

*Giải thích*

Với câu lệnh 1 và 2 ta thực hiện tạo 2 Thin Volume

- Option `-V` : Thực hiện chỉ định dung lượng được cấp cho Thin Volume ( Đơn vị mặc định là MB ; Với Thin Volume 1 là 1024MB và Thin Volume 2 là 1000MB )
- Option `-n` : Thực hiện chỉ định tên của Thin Volume
- `thin-group/thin-pool` : Thực hiện tạo từ Volume Group `thingroup` và Logical Volume `thin-pool`

Sau đó ta thực hiện Format định dạng cho các Thin Volume sau đó thực hiện Mount để hệ thống sử dụng , việc thực hiện tương tự khi sử dụng các Logical Volume đối với LVM :

```bash
root@debian:~# mkdir -p /mnt/tp1-user1
root@debian:~# mkdir -p /mnt/tp1-user2
```

```bash
root@debian:~# mkfs /dev/thin-group/tp-user1
mke2fs 1.44.5 (15-Dec-2018)
Discarding device blocks: done
Creating filesystem with 262144 4k blocks and 65536 inodes
Filesystem UUID: a056cd01-e85d-44cb-afcb-cbfdc6e9c214
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376

Allocating group tables: done
Writing inode tables: done
Writing superblocks and filesystem accounting information: done

root@debian:~# mkfs /dev/thin-group/tp-user2
mke2fs 1.44.5 (15-Dec-2018)
Discarding device blocks: done
Creating filesystem with 256000 4k blocks and 64000 inodes
Filesystem UUID: c9b73ca0-65ec-4b6a-a3f2-e1435dc80a45
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376
```

```bash
root@debian:~# mount /dev/thin-group/tp-user1 /mnt/tp1-user1
root@debian:~# mount /dev/thin-group/tp-user2 /mnt/tp1-user2
```

Sau đó kiểm tra lại 

```bash
root@debian:~# df -hT
Filesystem                        Type      Size  Used Avail Use% Mounted on
udev                              devtmpfs  225M     0  225M   0% /dev
tmpfs                             tmpfs      49M  1.7M   47M   4% /run
/dev/sda1                         ext4      3.9G  1.3G  2.4G  36% /
tmpfs                             tmpfs     242M     0  242M   0% /dev/shm
tmpfs                             tmpfs     5.0M     0  5.0M   0% /run/lock
tmpfs                             tmpfs     242M     0  242M   0% /sys/fs/cgroup
tmpfs                             tmpfs      49M     0   49M   0% /run/user/0
/dev/mapper/thin--group-tp--user1 ext2     1008M  1.3M  956M   1% /mnt/tp1-user1
/dev/mapper/thin--group-tp--user2 ext2      985M  1.3M  934M   1% /mnt/tp1-user2
root@debian:~# lvs
  LV        VG         Attr       LSize    Pool      Origin Data%  Meta%  Move Log Cpy%Sync Convert
  thin-pool thin-group twi-aotz--   <1.99g                  1.69   11.52
  tp-user1  thin-group Vwi-aotz--    1.00g thin-pool        1.69
  tp-user2  thin-group Vwi-aotz-- 1000.00m thin-pool        1.70
```

*Như vậy ta thấy, dung lượng thực sự của `tp-user1` chỉ chiếm 1.69% , tương tự với `tp-user2` là 1.7%*

# 3. Thể hiện tính năng Overprovisioning

**Overprovisioning** là tính năng cho phép khả năng cung cấp bộ nhớ ảo lớn hơn dung lượng thực sự của hệ thống. Với 1 Volume bình thường thì sẽ không thể thực hiện điều này do giới hạn vật lý. Tuy nhiên đối với Thin Volume thì sẽ thực hiện được điều này. Dưới đây sẽ thực hiện biểu diễn 1 ví dụ đơn giản. Đầu tiên ta thực hiện kiểm tra dung lượng hiện tại của các Thin Volume :

```bash
root@debian:~# lvs
  LV        VG         Attr       LSize    Pool      Origin Data%  Meta%  Move Log Cpy%Sync Convert
  thin-pool thin-group twi-aotz--   <1.99g                  1.69   11.52
  tp-user1  thin-group Vwi-aotz--    1.00g thin-pool        1.69
  tp-user2  thin-group Vwi-aotz-- 1000.00m thin-pool        1.70
```

Tiếp theo đó sẽ thực hiện, tăng kích thước của 1 Thin Volume > kích thước của Logical Volume và Volume Group :

```bash
root@debian:~# lvextend -l +1000 /dev/thin-group/tp-user1
  WARNING: Sum of all thin volume sizes (5.88 GiB) exceeds the size of thin pool thin-group/thin-pool and the size of whole volume group (<2.00 GiB).
  WARNING: You have not turned on protection against thin pools running out of space.
  WARNING: Set activation/thin_pool_autoextend_threshold below 100 to trigger automatic extension of thin pools before they get full.
  Size of logical volume thin-group/tp-user1 changed from 1.00 GiB (256 extents) to <4.91 GiB (1256 extents).
```

*Ở đây, ta sử dụng lệnh `lvextend` để tăng kích thước của Thin Volume lên 1000 Extend ( với 1 Extend = 4MB → Dung lượng thêm ~ 4000MB )*

→ Giống với Snapshot, mỗi khi Thin Pool sử dụng gần hết % dung lượng của nó thì cơ chế cấu hình trong `/etc/lvm/lvm.conf` sẽ tự động thực hiện mở rộng dung lượng :

```bash
thin_pool_autoextend_threshold = 70
thin_pool_autoextend_percent = 20
```

*Giải thích: Mỗi khi dung lượng sử dụng của Thin Pool đạt ngưỡng 70% thì nó sẽ tự động mở rộng thêm 20% dung lượng hiện tại ( Các giá trị mặc định là 100 và 20 )*

→ Như vậy kích thước của Thin Volume đã lớn hơn kích thước của Group Volume, tuy nhiên thực sự khi sử dụng gần hết dung lượng của Logical Volume thì sẽ không thể thực hiện tiếp tục ghi mà cần sử dụng `lvextend` để mở rộng dung lượng của Thin Pool.:

```bash
root@debian:~# lvextend -l +2000 /dev/thin-group/thin-pool
```

---

## Nguồn tham khảo

[lvcreate(8) - Linux man page](https://linux.die.net/man/8/lvcreate)

[BoTranVan/thuctap012017](https://github.com/BoTranVan/thuctap012017/blob/master/TVBO/docs/LVM/docs/lvm-thin.md)