# Chương 3 : Migrate VM

![Chuong-3-Migrate-VM/Untitled.png](Chuong-3-Migrate-VM/Untitled.png)

Trong trường hợp chúng ta cần thực hiện di chuyển các VM thì QEMU-KVM hỗ trợ chúng ta thực hiện di chuyển các VM thông qua cả 2 cách Offline và Online trong cả 2 trường hợp có hoặc không Shared Storage. 

Với khái niệm và việc thiết lập Shared Storage thì chúng ta đã tìm hiểu thông qua:

[Chương 2.5: Tổng quan về Shared Storage](https://github.com/tuananh2508/LinuxVcc/blob/master/Virtualization/QEMU%26KVM/KVM%26QEMU/Chuong-2.5-Tong-quan-Shared-Storage.md)

# Online Migrate với Shared Storage

Bạn có thể sử dụng nhiều loại Shared Storage khác nhau như : iSCSI, GlusterFS, NFS hay DRBD,... Tại ví dụ này sẽ thực hiện sử dụng NFS Storage. Việc thiết lập NFS Storage có thể xem ví dụ tại chương trước. Ở đây chúng ta thực hiện xét mô hình :

![Chuong-3-Migrate-VM/Annotation_2020-10-16_155007.png](Chuong-3-Migrate-VM/Annotation_2020-10-16_155007.png)

Trong đó:

Server `192.168.150.130` : Server NFS Shared Storage

Server `192.168.150.128` : Server đang sử dụng VM

Server `192.168.150.129` : Server VM sẽ được chuyển tới

Yêu cầu thiết lập Shared Storage NFS giữa 2 Server được sử dụng để di chuyển VM. Các Network interface của các VM không được sử dụng NAT.

Đầu tiên chúng ta cần xác định trạng thái hoạt động của VM trên Server đang sử dụng VM:

```bash
vutuananh@Localhost:~$ virsh list --all
 Id   Name     State
------------------------
 3    debian   running
```

*Lưu ý: Trạng thái hoạt động của VM là **running***

*Mục đích của Live Migration đó chính là ở việc giữ nguyên trạng thái của VM sau khi Migrate*


Tiếp theo chúng ta cần thiết lập kết nối SSH để có thể thực hiện Migrate VM ,bạn có thể tham khảo link dưới để cấu hình SSH Server:

[Các bước config cần thiết để SSH từ local lên server](https://viblo.asia/p/cac-buoc-config-can-thiet-de-ssh-tu-local-len-server-3Q75w9LMZWb)


Tiến hành việc Migrate VM thông qua cửa sổ Terminal bằng câu lệnh dưới

```bash
vutuananh@Localhost:~$ virsh migrate --live debian qemu+ssh://tuananh@192.168.150.129/system
```

Trong đó các option có ý nghĩa như sau:

- live : Thực hiện Live Migrate
- qemu+ssh : Thực hiện kết nối tới Server cần thực hiện di chuyển VM


Sau khi quá trình di chuyển VM hoàn tất, ta thực hiện kiểm tra lại trạng thái của VM tại Server mà VM đã được chuyển tới ( `192.168.150.129` ):

```bash
vutuananh@Localhost:~$ virsh --connect qemu+ssh://tuananh@192.168.150.129/system list --all
 Id   Name     State
------------------------
 11   debian   running
```

**Quá trình thiết lập Online Migrate VM với Shared Storage đã thành công**

---

# Offline Migrate với Local Image

Đối với Offline migrate thì chúng ta không cần thiết lập Shared Storagem, tuy nhiên trên 2 Server phải có cùng 1 Image của VM ( Local Image ). Quá trình thực hiện Offline Migrate đơn giản được diễn ra như sau:

1. Thực hiện virshdump file `*.xml` của VM 
2. Tiếp đó chuyển file này sang bên Server còn lại
3. Thực hiện Define file XML tại Server đích để tạo máy ảo

Quá trình này sẽ không thực hiện bật VM ở trên Server đích và không thực hiện dừng VM trên Server hiện tại → Gây ra một khoảng thời gian Downtime nhất định


Thực hiện xét mô hình dưới đây :

![Chuong-3-Migrate-VM/Untitled%201.png](Chuong-3-Migrate-VM/Untitled%201.png)

Trong đó :

Server `192.168.150.129` : Server hiện tại đang thực hiện chạy VM

Server `192.168.150.128` : Server đích trong quá trình Offline Migrate


Yêu cầu : 2 Server đã được thiết lập kết nối SSH


Tại Server đang chạy VM ,việc thực hiện Offline Migrate được thực hiện như sau :

```jsx
tuananh@localcomputer:/var/nfs/images$ virsh migrate --offline --persistent debian qemu+ssh://vutuananh@192.168.150.128/system
```

Trong đó các option có ý nghĩa như sau  :

- offline : Thực hiện Offline Migrate
- persistent: Giữ nguyên các trạng thái của VM tại Server đích
- qemu+ssh : Thực hiện kết nối tới Server cần thực hiện di chuyển VM


Ta kiểm tra trạng thái của VM tại Server đích :

```jsx
tuananh@localcomputer:/var/nfs/images$ virsh --connect=qemu+ssh://vutuananh@192.168.150.128/system list --all
 Id   Name     State
-------------------------
 -    debian   shut off
```


Quá trình thực hiện Offline Migrate đã hoàn tất

---

## Nguồn tham khảo :

[4.4.2. Additional Options for the virsh migrate Command Red Hat Enterprise Linux 6 | Red Hat Customer Portal](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/virtualization_administration_guide/sub-sect-virsh-migration-arguments)
