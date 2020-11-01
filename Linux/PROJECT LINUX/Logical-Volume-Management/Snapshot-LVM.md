# Tạo Snapshot LVM

![Snapshot-LVM/Untitled.png](Snapshot-LVM/Untitled.png)

**LVM Snapshot** là 1 kĩ thuật tạo Snapshot đối với các Logical Volume của LVM. Sau khi tạo Snapshot, thì các thay đổi trên Volume chính ( Disk **được** tạo Snapshot ) sẽ được lưu vào Volume **Snapshot**

**Volume Snapshot** cũng được coi như 1 Logical Volume và chúng ta có thể thực hiện các lệnh như `lvextend` hay `lvreduce` một cách hoàn toàn bình thường. Sau đây chúng ta sẽ tìm hiểu một số thao tác cơ bản đối với Snapshot

**Yêu cầu** :

- Kiến thức cơ bản về LVM như tạo, xóa, thêm, bớt dung lượng Volume

    Có thể tham khảo tại 

    [Create-Delete-Extend-Reduce-LVM](Create-Delete-Extend-Reduce-LVM.md)

- 1 Server sử dụng OS Linux : Trong bài viết này sử dụng **Ubuntu Server 20.04 ( có ít nhất 1 Logical Volume )**

**Mô hình Logic trong ví dụ** 

![Snapshot-LVM/Untitled%201.png](Snapshot-LVM/Untitled%201.png)

**Mục lục**
   * [1. Tạo LVM Snapshot](#1-tạo-lvm-snapshot)
   * [2. Thêm dung lượng vào Snapshot](#2-thêm-dung-lượng-vào-snapshot)
   * [3. Thực hiện Revert quay trở lại Snapshot](#3-thực-hiện-revert-quay-trở-lại-snapshot)
   * [4. Tự động thực hiện mở rộng dung lượng của Snapshot Volume](#4-tự-động-thực-hiện-mở-rộng-dung-lượng-của-snapshot-volume)
   * [Nguồn tham khảo](#nguồn-tham-khảo)


# 1. Tạo LVM Snapshot

Để thực hiện tạo Snapshot của 1 LVM Volume, đầu tiên chúng ta cần xác định các Logical Volume (*LV*) hiện tại đang có trên Server thông qua lệnh :

```bash
root@debian:/mnt# lvs
  LV     VG  Attr       LSize Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  parti3 vg0 -wi-ao---- 1.00g
```

→Có 1 LV là `parti3` có dung lượng 1GB thuộc Volume Group `vg0`

Tiếp đó, ta thực hiện tạo Snapshot của LV `parti3` với cú pháp :

```bash
root@debian:/mnt# lvcreate -l 100%FREE -s -n parti3-snap /dev/vg0/parti3
  Logical volume "parti3-snap" created.
```

*Trong đó* :

- -l : Option sẽ xác định dung lượng của Logical Volume dựa trên phần trăm dung lượng còn trống trên Volume Group. Ở đây ta đặt giá trị này là 100%FREE nghĩa là Snapshot sẽ có dung lượng bằng 100% số dung lượng còn khả dụng tại Volume Group `vg0`
- -s : Option thực hiện chỉ định tạo Snapshot
- -n : OPtion thực hiện chỉ định tên của Snapshot ( ở đây là `parti3-snap` )
- /dev/vg0/parti3 :  Logical Volume được tạo Snapshot

Kiểm tra lại kết quả việc tạo Snapshot :

```bash
root@debian:/mnt# lvs
  LV          VG  Attr       LSize    Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  parti3      vg0 owi-aos---    1.00g
  parti3-snap vg0 swi-a-s--- 1020.00m      parti3 0.01
```

*Nhận thấy rằng `parti3-snap` có Volme Origin là `parti3` hay có thể hiểu là `parti3-snap` chính là snapshot của Logical Volume `parti3`*

Nếu muốn kiểm tra kĩ hơn các thông tin về Snapshot ta thực hiện :

```bash
root@debian:/mnt# lvdisplay /dev/vg0/parti3-snap
  --- Logical volume ---
  LV Path                /dev/vg0/parti3-snap
  LV Name                parti3-snap
  VG Name                vg0
  LV UUID                byMXeQ-HGZw-m7bF-Ul4G-Iyfx-F8vc-eqLzdB
  LV Write Access        read/write
  LV Creation host, time debian, 2020-10-30 07:18:23 -0400
  LV snapshot status     active destination for parti3
  LV Status              available
  # open                 0
  LV Size                1.00 GiB
  Current LE             256
  COW-table size         1020.00 MiB
  COW-table LE           255
  Allocated to snapshot  0.01%
  Snapshot chunk size    4.00 KiB
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           254:3
```

*Trong đó* :

- LV Path : Đường dẫn tới Logical Volume
- LV Name : Tên của Logical Volume
- VG Name : Volume Group của Logical Volume
- LV UUID : Số hiệu của Logical Volume
- LV Write Access : Logical Volume ở chế độ Read - Write → ta có thể đọc ghi dữ liệu trên LV
- LV Creation host, time : Tên Host Server và thời gian tạo Logical Volume
- LV snapshot status : Trạng thái hiện tại của Logical Volume
- LV Size : Kích thước của Logical Volume
- Current LE : Số lượng Logical Extend hiện tại của Logical Volume
- COW-table size : Là viết tắt của Copy-on-Write → Các dữ liệu được ghi trên Volume chính sẽ được copy tại Snapshot
- COW-table LE : Số lượng Logical Extend của COW
- Allocated to snapshot  : Số lượng dữ liệu ghi trên Snapshot

# 2. Thêm dung lượng vào Snapshot

Cần chú ý đó là, LVM sẽ thực hiện ghi những thay đổi dữ liệu của Origin Logical Volume. Nhưng nếu xuất hiện trường hợp dữ liệu ghi thêm vào Volume chính **lớn** hơn dung lượng của Snapshot sẽ xảy ra hiện tượng lỗi như sau : **Input/output error**

Do Snapshot cũng được coi như 1 Logical volme nên ta chỉ cần thực hiện việc Extend ( Mở rộng ) dung lượng của Volume :

```bash
root@debian:~# lvextend -l +256 /dev/vg0/parti3-snap
```

→ Với option `-l` sẽ thực hiện mở rộng Volume lên **256 Extend** ( ~1GB với 1 Extend = 4MB )

# 3. Thực hiện Revert quay trở lại Snapshot

Nếu trong quá trình sử dụng xảy ra trường hợp chúng ta cần sử dụng Snapshot để quay lại trạng thái trước đó, ta thực hiện câu lệnh sau :

```bash
root@debian:~# lvconvert --merge /dev/vg0/parti3-snap
  Merging of volume vg0/parti3-snap started.
  vg0/parti3: Merged: 100.00%
```

*Cụ thể* :

- merge : Option cho phép thực hiện việc hợp nhất dữ liệu của Volume chính với Snapshot
- /dev/vg0/parti3-snap : Snapshot Logical Volume ta cần thực hiện merge

# 4. Tự động thực hiện mở rộng dung lượng của Snapshot Volume

LVM cung cấp cho chúng ta khả năng tự động hóa mở rộng dung lượng của Snapshot Volume thông qua việc điều chỉnh các thông số tại file `lvm.conf` :

```bash
root@debian:~# vi /etc/lvm/lvm.conf
```

Tại đây có 2 thông số quan trọng với Snapshot là : 

1. `snapshot_autoextend_threshold`
2. `snapshot_autoextend_percent` 

→ *Ý nghĩa:* 

1. Hạn mức sẽ thực hiện việc mở rộng dung lượng của Snapshot Volume
2. Phần trăm dung lượng mở rộng thêm 

Theo mặc định thì 2 giá trị này sẽ được đặt là 100 và 20, nghĩa là khi Snapshot Volume đạt giá trị 100% thì sẽ tự động thực hiện mở rộng thêm 20% dung lượng của Volume.

---

## Nguồn tham khảo

[How to Take 'Snapshot of Logical Volume and Restore' in LVM - Part III](https://www.tecmint.com/take-snapshot-of-logical-volume-and-restore-in-lvm/)

[BoTranVan/thuctap012017](https://github.com/BoTranVan/thuctap012017/blob/master/TVBO/docs/LVM/docs/lvm-snapshot.md)
