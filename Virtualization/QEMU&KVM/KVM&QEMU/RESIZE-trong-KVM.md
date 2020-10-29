# RESIZE trong KVM

![RESIZE-trong-KVM/Untitled.png](RESIZE-trong-KVM/Untitled.png)

Thông qua bài viết này chúng ta sẽ tìm hiểu về cách Resize VM Disk Image. Resized bao gồm 2 hoạt động, đó là: **Expand** (Tăng ) và **Reduce** (Giảm) kích thước Disk Image của VM. 

**Yêu cầu**:

1. Hệ thống Server Hosted sử dụng QEMU-KVM
2. 1 VM được Host bởi QEMU-KVM ( Có Disk Image được lưu trên Host )
3. Các gói Package hỗ trợ quản lý của QEMU-KVM

    Có thể tham khảo tại :

    [Chương 2: Sử dụng libvrt để quản lý các VM](https://github.com/tuananh2508/LinuxVcc/blob/master/Virtualization/QEMU%26KVM/KVM&QEMU/Chuong-2-Su-dung-libvrt.md)

**Mô hình:**

![RESIZE-trong-KVM/Untitled%201.png](RESIZE-trong-KVM/Untitled%201.png)

# 1. Expand ( Tăng dung lượng )

Tại mục này chúng ta sẽ thực hiện tăng kích thước cho file hệ thống **qcow2** (Vốn là loại dạng file mặc định của KVM ) . **qcow2** là loại file cho phép việc thực hiện nén cũng như tạo Snapshot VM một cách dễ dàng hơn dạng file **raw.**

**qcow2** là loại file sử dụng kĩ thuật **Thin Provisioning** cho phép **Overprovisioning** → Dung lượng Disk sẽ tăng lên trong quá trình sử dụng, cho phép chia sẻ phân vùng lưu trữ giữa nhiều các VM trong một giai đoạn nhất định.

Các bước thực hiện mở rộng ( tăng ) dung lượng Disk được thực hiện như sau :

Đầu tiên, chúng ta cần phải tắt tắt VM được tạo bởi KVM thông qua `virsh` 

```bash
root@localcomputer:/home/tuananh/Desktop/Qemu# virsh shutdown debian
```

*Trong đó `debian` là tên VM*

Thực hiện kiểm tra thông tin về Disk trước khi thực hiện Expand 

```bash
root@localcomputer:/home/tuananh/Desktop/Qemu# qemu-img info kvm1.img 
image: kvm1.img
file format: qcow2
virtual size: 6 GiB (6442450944 bytes)
disk size: 1.92 GiB
cluster_size: 65536
Format specific information:
    compat: 1.1
    lazy refcounts: true
    refcount bits: 16
    corrupt: false
```

→ Virtual Disk đạt mức 6 GB : Disk này sẽ cho phép VM ghi và lưu trữ tối đa 6 GB dữ liệu. ( *Trong đó `kvm1.img` là Disk Image của VM `debian`* )

Sử dụng `qemu-img` để thực hiện tăng kích thước Disk 

```bash
root@localcomputer:/home/tuananh/Desktop/Qemu# qemu-img resize kvm1.img +2G
```

*Ở đây ta thực hiện tăng kích thước ( + ) kích thước của Disk lên G. Các đơn vị được sử dụng khi tăng giảm kích thước với `qemu-img` là :* 

 k, M, G, T, P hoặcE tương đương với kilo-, mega-, giga-, tera-, peta- và exabytes.

 

Kiểm tra lại 1 lần nữa sự thay đổi trong dung lượng Disk :

```bash
root@localcomputer:/home/tuananh/Desktop/Qemu# qemu-img info kvm1.img 
image: kvm1.img
file format: qcow2
virtual size: 8 GiB (8589934592 bytes)
disk size: 1.92 GiB
cluster_size: 65536
Format specific information:
    compat: 1.1
    lazy refcounts: true
    refcount bits: 16
    corrupt: false
```

→ Kích thước Disk đã tăng từ 6 GB lên 8G ( Thay đổi 2G theo câu lệnh ở phía trên )

Thực hiện đăng nhập vào VM và kiểm tra thông số dung lượng Disk mới

```bash
root@debian:~# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0    8G  0 disk 
├─sda1   8:1    0    4G  0 part /
├─sda2   8:2    0    1K  0 part 
└─sda5   8:5    0 1022M  0 part [SWAP]
```

→ Ta nhận thấy dung lượng khả dụng của Disk đã tăng lên 8G tuy nhiên phần dung lượng root của hệ thống thì chưa được tăng lên ( 4 GB còn lại đang được coi là **Unallocated Disk Space** nghĩa là phần dung lượng Disk chưa được phân vùng )

# 2. Reduce ( Giảm dung lượng )

Ở phần này chúng ta sẽ sử dụng công cụ `virt-sparsify` để thực hiện việc chuyển những phân vùng bộ nhớ trống trong Virtual Disk quay trở lại Disk trên Host. Trong ví dụ dưới đây, ta sẽ thực hiện giảm dung lượng Disk với file Virtual Disk ở dạng **qcow2.**

Để thực hiện việc giảm dung lượng Disk, đầu tiên ta sẽ thực hiện kiểm tra dung lượng hiện tại thông qua công cụ `qemu-img` : 

```bash
root@localcomputer:/home/tuananh/Desktop/Qemu# qemu-img info kvm1.img 
image: kvm1.img
file format: qcow2
virtual size: 8 GiB (8589934592 bytes)
disk size: 1.92 GiB
cluster_size: 65536
Format specific information:
    compat: 1.1
    lazy refcounts: true
    refcount bits: 16
    corrupt: false
```

*Trong đó `kvm1.img` là tên Virtual Disk*

Tiếp đó sử dụng công cụ `virt-sparsify` để thực hiện giảm bớt dung lượng Disk ( Disk Size ) :

```bash
root@localcomputer:/home/tuananh/Desktop/Qemu# virt-sparsify --in-place kvm1.img 
[   2.0] Trimming /dev/sda1
[   2.6] Sparsify in-place operation completed with no errors
```

*Option `inplace` sẽ chỉ định cho công cụ `virt-sparsify` thực hiện việc chuyển những dung lượng trống trên Virtual Disk quay trở lại Host 1 cách trực tiếp mà không cần sao chép dữ liệu từ Input Disk sang Output Disk ( Theo như mục In-Place Sparsification của `virt-sparsify` )*  

Sau khi thực hiện giảm dung lượng Disk, ta kiểm tra lại sự thay đổi của Disk Size :

```bash
root@localcomputer:/home/tuananh/Desktop/Qemu# qemu-img info kvm1.img 
image: kvm1.img
file format: qcow2
virtual size: 8 GiB (8589934592 bytes)
disk size: 1.42 GiB
cluster_size: 65536
Format specific information:
    compat: 1.1
    lazy refcounts: true
    refcount bits: 16
    corrupt: false
```

→ Dung lượng Disk Size giảm từ 1.92GB xuống 1.42GB.

**Nếu file Disk Image của bạn đang ở dạng raw thì có thể sử dụng `qemu-img convert` để chuyển sang dạng file qcow2 để có thể giảm được dung lượng file ( do dạng file này cung cấp tính năng nén dữ liệu)** **như sau :**

```bash
root@localcomputer:/home/tuananh/Desktop/Qemu# qemu-img convert -O qcow2 kvm1.img /mnt/kvm.qcow
```

*Trong đó :* 

- O : Option này cho phép định dạng kiểu Disk Image của file đầu ra ( Output File )
- kvm1.img : Là file Disk Image đang ở dạng RAW mà bạn muốn chuyển đổi
- kvm.qcow : Là file nhận được ( Ở dạng qcow2 )

---

## Nguồn tham khảo

[virt-sparsify](https://libguestfs.org/virt-sparsify.1.html#in-place-sparsification)

[How to reduce the size of KVM QCOW2 images that grow out of hand](https://codemental.medium.com/how-to-reduce-the-size-of-kvm-qcow2-images-that-grow-out-of-hand-971603b65fac)

[How To extend/increase KVM Virtual Machine (VM) disk size | ComputingForGeeks](https://computingforgeeks.com/how-to-extend-increase-kvm-virtual-machine-disk-size/)