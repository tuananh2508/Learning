# Hot Plug trong KVM

![Hot-Plug-trong-KVM/Untitled.png](Hot-Plug-trong-KVM/Untitled.png)

**Hot Plug** **/ Unplug** là hoạt động thực hiện cung cấp thêm hoặc bỏ bớt các thành phần như  RAM,CPU,VirtualDisk đối với các máy ảo đang chạy trên hệ thống trong khi các VM này đang hoạt động. Việc cung cấp thêm các thanh phần này phải đảm bảo **không gây ảnh hưởng** tới hoạt động hiện tại của VM. 

Sau đây chúng ta sẽ cùng tìm hiểu việc thực hiện việc thay đổi các thông số bên dưới đối với VM :

1. RAM

2. vCPU

3. Virtual Disk 

*Yêu cầu :*

- Hệ thống máy vật lý có hỗ trợ QEMU-KVM
- 1 VM được tạo bởi QEMU-KVM và đang ở trạng thái hoạt động ( Running )
- Các công cụ quản lý VM của QEMU-KVM

    Có thể tham khảo tại 

    [Chương 2: Sử dụng libvrt để quản lý các VM](https://github.com/tuananh2508/LinuxVcc/blob/master/Virtualization/QEMU%26KVM/KVM&QEMU/Chuong-2-Su-dung-libvrt.md)

Đầu tiên chúng ta sẽ liệt kê các hệ thống máy ảo hiện tại đang có trên Server của chúng ta thông qua cửa sổ Terminal :

```bash
tuananh@localcomputer:~$ virsh list --all
 Id   Name     State
------------------------
 4    debian10   running
```

*Hiện tại trên hệ thống có 1 VM đang hoạt động tên là **debian10***



# 1. vCPUS

![Hot-Plug-trong-KVM/Untitled%201.png](Hot-Plug-trong-KVM/Untitled%201.png)

## 1.1 **Thiết lập ban đầu**

Nếu VM được khởi tạo tạo lần đầu và đang ở trạng thái hoạt động ( running )  thì tại file config sẽ có dạng như sau và chúng ta sẽ **không** thực hiện được việc hot plug vCPUs do số lượng vCPUs đã được cấu hình ( **allocated** ) sẵn và khi thực hiện việc kiểm tra file cấu hình của VM thì sẽ nhận được dạng như dưới ( File cấu hình VM thường được lưu trữ tại `/etc/libvirt/qemu` :

```bash

root@localcomputer:/# cd /etc/libvirt/qemu
root@localcomputer:/etc/libvirt/qemu# cat debian10.xml | grep vcpu
  <vcpu placement='static'>2</vcpu>
```

*Trong đó `debian10.xml` là file cấu hình của VM. Thường có dạng `*tên VM.xml`*

→ Chúng ta cần thực hiện shutdown VM này để thực hiện việc cấu hình :

```bash
tuananh@localcomputer:/etc/libvirt/qemu$ virsh shutdown debian10
Domain debian10 is being shutdown
tuananh@localcomputer:/etc/libvirt/qemu$ virsh list --all
 Id   Name       State
---------------------------
 -    debian10   shut off
```

 → Rồi tiến hành cấu hình thêm số lượng vCPUs tối đa thông qua lệnh tại cửa sổ Terminal: 

```bash
tuananh@localcomputer:/etc/libvirt/qemu$ virsh setvcpus debian10 4 --config --maximum
```

*Các thông số trong câu lệnh :*

- debian10 : Tên máy VM của bạn
- 4 : số lượng vCPUs tối đa chúng ta mong muốn
- config : Option thực hiện chỉnh sửa file config của VM
- maximum : Option thực hiện việc chỉnh sửa số lượng vCPUs tối đa trong file config của VM

→ Sau đó kiểm tra lại file cấu hình của VM, nhận được sự thay đổi như sau :

```bash
root@localcomputer:/etc/libvirt/qemu# cat debian10.xml | grep vcpu
  <vcpu placement='static' current='2'>4</vcpu>
```

→ Tiếp đó có thể thực hiện bật VM và thực hiện thay đổi số lượng vCPUs trong những lần sau 

*Nhận thấy rằng số **vCPU tối đa** trên VM hiện tại là 4 vCPUs , trong đó số CPU hiện tại **đang sử dụng** là 2. Tại đây bạn có thể thực hiện thay đổi số lượng số lượng vCPU tối đa lên số mong muốn, tuy nhiên, không nên chỉnh sửa **quá số lượng physical CPU** của máy vật lý do điều này sẽ gây ra ảnh hưởng về mặt **hiệu năng** của hệ thống.*

Tiếp đó ta cần thực hiện cài đặt `qemu-guest-agent` để daemon này có thể **nhận lệnh từ Host và thực hiện lệnh** từ bên trong VM :

1. Thực hiện chỉnh sửa file cấu hình của VM :

    ```bash
    root@localcomputer:/etc/libvirt/qemu# virsh edit debian10
    ```

2. Thực hiện thêm đoạn code sau file config trong mục `<devices>` và lưu lại file cấu hình :

    ```bash
    <channel type='unix'>
       <target type='virtio' name='org.qemu.guest_agent.0'/>
    </channel>
    ```

3. Tiến hành bật VM

    ```bash
    root@localcomputer:/etc/libvirt/qemu# virsh start debian10
    ```

4. Cài đặt `qemu-guest-agent` bên trong máy ảo ( VM sử dụng OS **Debian10** )

    ```bash
    root@localcomputer:/etc/libvirt/qemu# virsh console debian10
    root@debian:~# apt install qemu-guest-agent
    ```

5. Tiến hành bật dịch vụ `qemu-guest-agent` trên VM :

    ```bash
    root@debian:~# systemctl start qemu-guest-agent
    root@debian:~# systemctl status qemu-guest-agent.service 
    ● qemu-guest-agent.service - QEMU Guest Agent
       Loaded: loaded (/lib/systemd/system/qemu-guest-agent.service; static; vendor 
       Active: active (running) since Sun 2020-10-25 03:44:15 EDT; 5min ago
     Main PID: 369 (qemu-ga)
        Tasks: 1 (limit: 1149)
       Memory: 2.1M
       CGroup: /system.slice/qemu-guest-agent.service
               └─369 /usr/sbin/qemu-ga
    ```

## 1.2 Hot Plug vCPUs

Sau khi hoàn tất các thiết lập ban đầu ta thực hiện hot plug vCPUs 

```bash
root@localcomputer:/etc/libvirt/qemu/networks# virsh setvcpus debian10 3
```

*Trong đó*

- debian10 : Tên máy VM
- 3 : Số lượng vCPUs mong muốn khi hot plug

Để kiểm tra lại sự thay đổi về vCPUs ta có thể kiểm tra qua 2 cách. Cách đầu tiên đó là ở trên Hypervisor thực hiện lệnh sau để kiểm tra các thống số của VM:

```bash
root@localcomputer:/etc/libvirt/qemu# virsh dominfo debian10
Id:             12
Name:           debian10
UUID:           6ee38b6f-5c74-4418-acfe-f0cf81700af4
OS Type:        hvm
State:          running
CPU(s):         3
CPU time:       24,0s
Max memory:     1048576 KiB
Used memory:    1048576 KiB
Persistent:     yes
Autostart:      disable
Managed save:   no
Security model: apparmor
Security DOI:   0
Security label: libvirt-6ee38b6f-5c74-4418-acfe-f0cf81700af4 (enforcing)
```

Hoặc có thể truy cập VM ( thông  qua virsh console ) và xem các thông số trên của sổ **Terminal tại VM :**

```bash
tuananh@localcomputer:/etc/libvirt/qemu$ virsh console debian10
```

```bash
root@debian:~# lscpu
Architecture:         x86_64
CPU op-mode(s):       32-bit, 64-bit
Byte Order:           Little Endian
Address sizes:        40 bits physical, 48 bits virtual
CPU(s):               3
On-line CPU(s) list:  0,1
Off-line CPU(s) list: 2
Thread(s) per core:   1
Core(s) per socket:   1
Socket(s):            2
NUMA node(s):         1
Vendor ID:            GenuineIntel
CPU family:           6
Model:                94
Model name:           Intel Core Processor (Skylake, IBRS)
Stepping:             3
CPU MHz:              3000.008
BogoMIPS:             6000.01
Virtualization:       VT-x
Hypervisor vendor:    KVM
Virtualization type:  full
L1d cache:            32K
L1i cache:            32K
L2 cache:             4096K
L3 cache:             16384K
NUMA node0 CPU(s):    0,1
```

Tuy nhiên số lượng vCPUs không thể được đặt quá số tối đã đã được thiết lập ( Allocated ) cho VM:

```bash
root@localcomputer:/etc/libvirt/qemu/networks# virsh setvcpus debian10 5
error: invalid argument: requested vcpus is greater than max allowable vcpus for the live domain: 5 > 4
```

→ *Khi set số vCPUs hiện tại lớn hơn số max vCPUs sẽ xuất hiện lỗi*

Nếu sau khi thực hiện **Hot Plug** vCPUs, ta muốn lưu lại số lượng vCPUs sử dụng hiện tại ta thực hiện lệnh sau tại Host :

```bash
root@localcomputer:/etc/libvirt/qemu# virsh setvcpus debian10 3 --config
```

## 1.3 Hot Unplug vCPUs

***Yêu cầu :***

- Thiết lập `qemu-guest-agent` giữa Host và VM - như hướng dẫn ở trên  hoặc theo hướng dẫn tại

    [Chapter 11. Enhancing Virtualization with the QEMU Guest Agent and SPICE Agent Red Hat Enterprise Linux 7 | Red Hat Customer Portal](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/virtualization_deployment_and_administration_guide/chap-qemu_guest_agent)

Ta thực hiện việc giảm vCPUs như sau :

```bash
root@localcomputer:/etc/libvirt/qemu# virsh setvcpus debian10 1 --live --guest
```

Trong đó :

- live : Option chỉ định việc thực hiện thay đổi vCPUs được diễn ra khi VM đang hoạt động
- guest : Thực hiện truyền lệnh này cho `qemu-guest-agent` trong VM . Tuy nhiên các thay đổi với Option này sẽ mất hiệu lực khi thực hiện Reboot VM

Sau đó kiểm tra thông tin hiện tại của VM :

```bash
root@localcomputer:/etc/libvirt/qemu# virsh dominfo debian10
Id:             12
Name:           debian10
UUID:           6ee38b6f-5c74-4418-acfe-f0cf81700af4
OS Type:        hvm
State:          running
CPU(s):         3
CPU time:       24,0s
Max memory:     1048576 KiB
Used memory:    1048576 KiB
Persistent:     yes
Autostart:      disable
Managed save:   no
Security model: apparmor
Security DOI:   0
Security label: libvirt-6ee38b6f-5c74-4418-acfe-f0cf81700af4 (enforcing)
```

*Ở đây ta vẫn nhận được kết quả là 3 vCPUs hoạt động **tuy nhiên** khi thực hiện lệnh kiểm tra trong VM :*

```bash
root@localcomputer:/etc/libvirt/qemu# virsh console debian10
```

![Hot-Plug-trong-KVM/Untitled%202.png](Hot-Plug-trong-KVM/Untitled%202.png)

→ *Ta nhận thấy chỉ còn **CPU 0** đang thực hiện hoạt động còn 2 **CPU 1 và 2** đã chuyển sang trạng thái offline* 

Nếu sau khi thực hiện **Hot Unplug** vCPUs, ta muốn lưu lại số lượng vCPUs sử dụng hiện tại ta thực hiện lệnh sau tại Host :

```bash
root@localcomputer:/etc/libvirt/qemu# virsh setvcpus debian10 1 --config
```

Thông số vCPUs sẽ được cập nhật tai `virsh dominfo` khi ta thực hiện shutdown hoặc destroy VM :

```bash
root@localcomputer:/etc/libvirt/qemu# virsh destroy debian10
Domain debian10 destroyed
```

Ngay sau khi tắt VM, thực hiện kiểm tra lại thông tin của VM :

```bash
root@localcomputer:/etc/libvirt/qemu# virsh dominfo debian10
Id:             -
Name:           debian10
UUID:           6ee38b6f-5c74-4418-acfe-f0cf81700af4
OS Type:        hvm
State:          shut off
CPU(s):         1
Max memory:     1048576 KiB
Used memory:    1048576 KiB
Persistent:     yes
Autostart:      disable
Managed save:   no
Security model: apparmor
Security DOI:   0
```

**Việc thực hiện Hot Plug / Unplug vCPUs đã kết thúc** **!**

# 2. RAM

![Hot-Plug-trong-KVM/Untitled%203.png](Hot-Plug-trong-KVM/Untitled%203.png)

Trước khi thực hiện Hot Plug và Unplug RAM chúng ta cần kiểm tra lượng RAM đang sử dụng và lượng RAM tối đa của VM thông qua lệnh tại cửa sổ Terminal :

```bash
tuananh@localcomputer:~$ virsh edit debian10
...
<memory unit='KiB'>1048576</memory>
  <currentMemory unit='KiB'>1048576</currentMemory>
...
```

→  Lượng RAM tối đa cung cấp cho VM là : 1048576 kB = 1Gb

Lượng RAM đang sử dụng của VM là : 1048576 kB = 1Gb

⇒ Lượng RAM tối đa được cung cấp cho máy ảo không được vượt quá lượng RAM của máy vật lý, nếu thiết lập vRAM ( Virtual ) > pRAM ( Physical RAM ) sẽ xuất hiện lỗi sau :

```bash
error: Failed to start domain debian10
error: internal error: process exited while connecting to monitor: 2020-10-25T22:07:13.966276Z qemu-system-x86_64: warning: host doesn't support requested feature: MSR(48BH).vmx-apicv-xapic [bit 0]
2020-10-25T22:07:13.966348Z qemu-system-x86_64: warning: host doesn't support requested feature: MSR(48FH).vmx-exit-load-perf-global-ctrl [bit 12]
2020-10-25T22:07:13.966354Z qemu-system-x86_64: warning: host doesn't support requested feature: MSR(490H).vmx-entry-load-perf-global-ctrl [bit 13]
2020-10-25T22:07:13.971282Z qemu-system-x86_64: cannot set up guest memory 'pc.ram': Cannot allocate memory
```

Để thực hiện thay đổi lượng RAM tối đa của VM, ta thực hiện những bước sau 

1. Thực hiện tắt VM ( Do không thể thực hiện thiết lập lượng RAM tối đa khi VM đang chạy )

    ```bash
    tuananh@localcomputer:~$ virsh shutdown debian10
    Domain debian10 is being shutdown
    ```

2. Thực hiện thay đổi lượng RAM tối đa qua câu lệnh tại cửa sổ Terminal trên Host :

    ```bash
    tuananh@localcomputer:~$ virsh setmaxmem debian10 2G
    ```

    Hoặc bạn cũng có thể chỉnh sửa qua file `***.xml` của VM với lệnh `virsh edit ***`  ( với *** là tên VM của bạn )

3. Thực hiện kiểm tra lại sự thay đổi sau khi thiết lập với :

    ```bash
    tuananh@localcomputer:~$ virsh dominfo debian10
    Id:             -
    Name:           debian10
    UUID:           7f921b4c-a4b1-4ea2-9ac9-fa1c29148085
    OS Type:        hvm
    State:          shut off
    CPU(s):         1
    Max memory:     2097152 KiB
    Used memory:    1048576 KiB
    Persistent:     yes
    Autostart:      disable
    Managed save:   no
    Security model: apparmor
    Security DOI:   0
    ```

    → Nhận thấy sự thay đổi của lượng RAM tối đa ( Max memory ) đã tăng lên **2Gb**

## 2.1 Thay đổi lượng RAM sử dụng

Việc thay đổi lượng RAM cung cấp cho VM khá đơn giản và được thực hiện theo lệnh :

```bash
tuananh@localcomputer:~$ virsh setmem debian10 2G

tuananh@localcomputer:~$ virsh dominfo debian10
Id:             4
Name:           debian10
UUID:           7f921b4c-a4b1-4ea2-9ac9-fa1c29148085
OS Type:        hvm
State:          running
CPU(s):         1
CPU time:       20,1s
Max memory:     2097152 KiB
Used memory:    2097152 KiB
Persistent:     yes
Autostart:      disable
Managed save:   no
Security model: apparmor
Security DOI:   0
Security label: libvirt-7f921b4c-a4b1-4ea2-9ac9-fa1c29148085 (enforcing)
```

*Ta nhận thấy lượng RAM hiện tại (Used Memory ) đã tăng lên thành 2Gb*

Thực hiện kiểm tra lại bên trong VM :

```bash
root@debian:~# free -m
              total        used        free      shared  buff/cache   available
Mem:           1994          52        1871           2          70        1832
Swap:          1020           0        1020
```

*Lượng RAM được sử dụng hiện tại tăng lên thành 2Gb*

Nếu ta muộn lưu lượng RAM đang sử dụng vào file cấu hình ta thực hiện thêm option `--config` ,ví dụ :

```bash
tuananh@localcomputer:~$ virsh setmem debian10 2G --config
```

**Đối với việc giảm lượng RAM cũng được thực hiện tương tự**

---

# 3. Virtual Disk

![Hot-Plug-trong-KVM/Untitled%204.png](Hot-Plug-trong-KVM/Untitled%204.png)

Trước khi đến với việc thêm Disk và Resize Disk với VM, chúng ta cần phải hiểu về các khái niệm như **Thin** và **Thick Provisioning.** 

## 3.1. Thin và Thick Provisioning

**Thin** và **Thick Provisioning** là các kĩ thuật cung cấp không gian bộ nhớ hoạt động dựa trên 2 nguyên lý gần như trái ngược nhau. **Thick Provisioning** được chia làm thêm 2 loại nữa đó là : **Lazy Zeroed Disk** và **Eager Zeoroed Disk**.

## 3.1.1 Thick Provisioning

**Thick Provision** là kĩ thuật thực hiện ***phân vùng bộ nhớ trước***. Với kĩ thuật này, toàn bộ dung lượng bộ nhớ khi Disk được khởi tạo sẽ được phân vùng ngay lập tức . 

Ví dụ : Khi khởi tạo 2 Disk theo dạng **Thick Provisioning ( Disk 1 sử dụng Lazy Zeroed Disk - Disk 2 sử dụng Eager Zeoroed Disk  )** mỗi Disk có giá trị **30GB** ⇒ Tổng dung lượng bộ nhớ bị chiếm là **60GB** và các VM khác **không thể** sử dụng phân vùng này.

![Hot-Plug-trong-KVM/Untitled%205.png](Hot-Plug-trong-KVM/Untitled%205.png)

Kĩ thuật này được chia làm 2 loại :

1. **Lazy Zeroed Disk :** Với kĩ thuật này, lượng bộ nhớ được phân vùng bộ nhớ sẽ không được "*xóa sạch*" ( Nghĩa là toàn bộ là bit 0 ) mà có thể bao gồm dữ liệu Disk từ trước đó. Các dữ liệu này không được xóa hoặc ghi đè lên sau khi Disk được khởi tạo. Dẫn đến trong lần đầu tiên sử dụng Disk này, hiệu năng sẽ thấp do có sự tăng cao về IOPS ( Input Output Per Second ) gây ra bởi việc xóa/ghi đè lên dữ liệu ban đầu. *Tuy nhiên* lại tiết kiệm thời gian khởi tạo ban đầu cho ngưởi sử dụng.
2. **Eager Zeoroed Disk :** Trái ngược với kĩ thuật trên thì với kĩ thuật này sẽ thực hiện tạo ra 1 phân vùng bộ nhớ đã được "xóa sạch" ( không có dữ liệu cũ tồn tại trên Disk ). Việc khởi tạo Disk với kĩ thuật này sẽ tốn thời gian hơn nhưng bù lại đó là khả năng hoạt động **tốt hơn** trong những lần đầu sử dụng Disk

⇒ Ngoài ra, vì lí do bảo mật nên **Eager Zeoroed Disk** được sử dụng nhiều hơn do đặc điểm của kĩ thuật này là "xóa sạch" toàn bộ dữ liệu trước đó nên đảm bảo được yêu cầu bảo mật. Tránh trường hợp Hacker có thể khôi phục dữ liệu từ lượng dữ liệu còn sót trên Disk.

## 3.1.2 Thin Provisioning

**Thin Provisioning** là loại kĩ thuật thực hiện phân vùng bộ nhớ tuy nhiên điểm khác biệt với **Thick Provisioning** đó là việc nó chỉ thực hiện chiếm 1 lượng phân vùng bộ nhớ ***bằng với dữ liệu được ghi*** trên nó

Ví dụ : Khi khởi 2 Disk với **Thin Provisioning(** Disk 3 và Disk 4 ), giá trị mỗi Disk là 30GB. Trên Disk 3 có dung lượng thực là **10 GB**, trên Disk 4 có dung lượng **10GB** → Giá trị trên bộ nhớ là **20GB** ; còn lại 40GB được coi là bộ nhớ khả dụng cho các VM khác có thể sử dụng ( Mặc dù giá trị Logic của 2 Disk này là 60GB). Giá trị **20GB** này có thể tăng dần theo lượng dữ liệu được ghi vào 2 Disk

![Hot-Plug-trong-KVM/Untitled%206.png](Hot-Plug-trong-KVM/Untitled%206.png)

Khi thực hiện xóa dữ liệu trên Disk sử dụng kĩ thuật **Thin Provisioning** thì hệ điều hành ( OS ) sẽ chỉ thực hiện xóa index của file cần xóa. Và sau đó, OS sẽ coi đây là vùng dữ liệu có thể thực hiện ghi dữ liệu lên ( Mặc dù các bit dữ liệu chưa được chuyển toàn bộ thành 0 - "clean state" ). Ví dụ với hình dưới :

![Hot-Plug-trong-KVM/Untitled%207.png](Hot-Plug-trong-KVM/Untitled%207.png)

Giả sử ta có 4 file và thực hiện xóa 2 File 2 và File 3. Khi thực hiện xóa. OS sẽ thực hiện xóa Index của File 2 và File 3 và việc xóa sẽ diễn ra rất nhanh chóng. **Tuy nhiên ,** cần chú ý rằng lượng dữ liệu được ghi trên File 2 và 3 vẫn **chưa** được xóa ( 0110....0100 ). OS sẽ cho phép việc ghi dữ liệu lên trên phân vùng được bỏ trống này **nhưng** sẽ ảnh hưởng về mặt hiệu năng do khi ghi dữ liệu thì Disk không ở trạng thái Clean State mà cần phải ghi đè dữ liệu.

Điểm khác biệt đối với **Lazy Zeroed Disk** đó là việc dung lượng của **Thin Provisioning** sẽ tăng lên chứ không cố định.

## 3.1.3 Đánh giá và nhận xét về Thin Provisioning

Từ các đặc điểm cơ bản của 2 kĩ thuật trên thì ta nhận thấy nếu xét về mặt hiệu năng :

**Eager Zeoroed Disk → Lazy Zeroed Disk ~ Thin Provisioning** 

**Thin Provisioning** được sử dụng khá phổ biến khi thực hiện lưu trữ các VM .

Ví dụ với 1 bộ nhớ 20GB thì chúng ta có thể sử dụng làm bộ nhớ cho 3 VM với giá trị bộ nhớ là 10GB/1VM ( Tổng là 30GB ) → Overprovisioning. Tuy nhiên, khi dung lượng bộ nhớ gần hết, thì chúng ta cần phải thực hiện tăng dung lượng bộ nhớ hoặc Migrate VM để tránh hiện tượng lỗi không ghi được dữ liệu.

## 3.2. Thêm và tách Virtual Disk vào/ra VM

**3.2.1 Thêm Virtual Disk vào VM**

Trước đó chúng ta đã có cái nhìn cơ bản về các loại Disk, sau đây, chúng ta sẽ thực hiện tìm hiểu cách thêm 1 Virtual Disk vào VM đã có sẵn. Các bước thực hiện bao gồm 2 bước quan trọng :

1. Tạo file Virtual Disk
2. Thực hiện Attach ( gắn )  Virtual Disk có được ở bước trên vào VM 

Đầu tiên chúng ta sẽ thực hiện tạo Virtual Disk. Ta sẽ thực hiện tạo 2 loại Virtual Disk : 1 Disk sử dụng **Thin Provision** và 1 Disk sử dụng **Thick Provision:**

1. Disk sử dụng **Thin Provision :**

    ```bash
    tuananh@localcomputer:~/Desktop/Qemu$ qemu-img create -f qcow2 thindisk 1G
    Formatting 'thindisk', fmt=qcow2 size=1073741824 cluster_size=65536 lazy_refcounts=off refcount_bits=16
    ```

2. 1 Disk sử dụng **Thick Provision :**

    ```bash
    tuananh@localcomputer:~/Desktop/Qemu$ dd if=/dev/zero of=thickdisk bs=1M count=1000
    1000+0 records in
    1000+0 records out
    1048576000 bytes (1,0 GB, 1000 MiB) copied, 0,884015 s, 1,2 GB/s
    ```

    Trong đó :

    - Chúng ta sử dụng lệnh `dd` để thực hiện copy dữ liệu từ `/dev/zero` ( là một dạng device đặc biệt trong Linux,dữ liệu trong file này hoàn toàn là các số 0 liên tiếp nhau, được ghi liên tục ) chuyển ra 1 file có tên `thickdisk`
    - bs : Chỉ định giá trị đầu vào / ra của block ở dạng đơn vị sang dạng Bytes . Ở đây ta thực hiện thiết lập giá trị này là 1Mb → thực hiện đọc / ghi 1 MB dữ liệu từ `/dev/zero`
    - count : Chỉ định lượng dữ liệu được Copy. Ở đay chúng ta chỉ định giá trị này là 1000MB

Ta thực hiện so sánh dung lượng hiện tại  để thấy được sự khác nhau giữa 2 kĩ thuật trong việc chiếm phân vùng bộ nhớ :

```bash
tuananh@localcomputer:~/Desktop/Qemu$ du -sh th*
1001M   thickdisk
196K    thindisk
```

Sau đó thực hiện kiểm tra các Block Device đang hoạt động thông qua câu lệnh sau tại cửa sổ Terminal trên Host :

```bash
tuananh@localcomputer:~/Desktop/Qemu$ virsh domblklist debian10 --details
 Type   Device   Target   Source
---------------------------------------------------------------
 file   disk     hda      /home/tuananh/Desktop/Qemu/kvm1.img
```

Và kiểm tra bên trong VM :

```bash
root@debian:~# fdisk -l
Disk /dev/sda: 3 GiB, 3221225472 bytes, 6291456 sectors
Disk model: QEMU HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xc2914aa3

Device     Boot   Start     End Sectors  Size Id Type
/dev/sda1  *       2048 4196351 4194304    2G 83 Linux
/dev/sda2       4198398 6289407 2091010 1021M  5 Extended
/dev/sda5       4198400 6289407 2091008 1021M 82 Linux swap / Solaris
```

Tiếp đó ta thực hiện Attach ( Gắn ) `thickdisk` vào VM :

```bash
tuananh@localcomputer:~/Desktop/Qemu$ virsh attach-disk debian10 --source=/home/tuananh/Desktop/Qemu/thickdisk --target=sdb
 --persistent
Disk attached successfully
```

Trong đó :

- source : Option cung cấp đường dẫn tới Disk cần thêm
- target : Option kiểm soát loại BUS hoặc thiết bị được hiển thị với VM
- Persistent : tương đương với option `--config` nhưng cung cấp tính thích ứng tốt hơn

Kiểm tra lại các Block Device đang liên kết với VM sau Attach-disk :

```bash
tuananh@localcomputer:~/Desktop/Qemu$ virsh domblklist debian10 --details
 Type   Device   Target   Source
----------------------------------------------------------------
 file   disk     hda      /home/tuananh/Desktop/Qemu/kvm1.img
 file   disk     sdb      /home/tuananh/Desktop/Qemu/thickdisk
```

Và kiểm tra trên VM :

```bash
root@debian:~# fdisk -l
Disk /dev/sda: 3 GiB, 3221225472 bytes, 6291456 sectors
Disk model: QEMU HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xc2914aa3

Device     Boot   Start     End Sectors  Size Id Type
/dev/sda1  *       2048 4196351 4194304    2G 83 Linux
/dev/sda2       4198398 6289407 2091010 1021M  5 Extended
/dev/sda5       4198400 6289407 2091008 1021M 82 Linux swap / Solaris

Disk /dev/sdb: 1000 MiB, 1048576000 bytes, 2048000 sectors
Disk model: QEMU HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
```

→ Nhận thấy đã xuất hiện `/dev/sdb` chính là Virtual Disk ta đã thêm vào có kích thước 1GB.

**3.2.2 Thực hiện tách ( detach ) Virtual Disk**

Để thực hiện việc tách Virtual Disk, đầu tiên chúng ta sẽ kiểm tra các Disk hiện thời đang hoạt động trên VM với lệnh:

```bash
root@localcomputer:/home/tuananh/Desktop/Qemu# virsh domblklist debian10 --details
 Type   Device   Target   Source
--------------------------------------------------------------------
 file   disk     hda      /home/tuananh/Desktop/Qemu/kvm1.img
 file   disk     vda      /home/tuananh/Desktop/Qemu/thickdisk.img
```

*Trong đó :*

- debian10 : là tên VM hiện tại đang hoạt động trên Host

    →Ta nhận thấy rằng hiện tại có 2 disk là `hda` và `vda` 

Thao tác thực hiện tách disk `vda` ra khỏi VM như sau :

```bash
root@localcomputer:/home/tuananh/Desktop/Qemu# virsh detach-disk debian10 /home/tuananh/Desktop/Qemu/thickdisk.img --persistent
```

*Trong đó*:

- debian10 : là tên VM hiện tại đang hoạt động trên host
- /home/.../thickdisk.img : Đường dẫn tới Disk được tiến hành tách bỏ khỏi VM
- persistent : Option tương đương với `--config` , thực hiện lưu lại cấu hình hiện tại của VM

---

## Một số lỗi có thể xuất hiện trong quá trình thực hiện

**Lỗi xảy ra khi thực hiện Hot Plug vCPUs**

1. Lỗi xuất hiện do thực hiện đặt số Vcpus ít hơn số được cấu hình trong config trong config

```bash
root@localcomputer:/etc/libvirt/qemu/networks# virsh setvcpus ubuntu 1
error: unsupported configuration: failed to find appropriate hotpluggable vcpus to reach the desired target vcpu count

```

→ Cách khắc phục : Sử dụng `qemu-guest-agent` để thực hiện tắt các vCPUs trong VM

**Lỗi xảy ra khi thực hiện Hot Plug  Disk**

1.  Lỗi gây ra bởi việc cấu trúc IDE không thể thực hiện Hotplug khi hệ thống đang hoạt động. Ta cần sử dụng cơ chế SCSI.

```bash
tuananh@localcomputer:~/Desktop/Qemu$ virsh attach-disk debian10 --source=/home/tuananh/Desktop/Qemu/thickdisk --target=hdb --persistent
error: Failed to attach disk
error: Operation not supported: disk bus 'ide' cannot be hotplugged.
```

→ Cách khắc phục : sử dụng định dạng đĩa SCSI → chuyển dạng Target sang `sdb`

```bash
tuananh@localcomputer:~/Desktop/Qemu$ virsh attach-disk debian10 --source=/home/tuananh/Desktop/Qemu/thickdisk --target=sdb
 --persistent
Disk attached successfully
```

---

## Nguồn tham khảo

[Linux KVM - How to Add/Resize Virtual disk on fly? Part 7 - UnixArena](https://www.unixarena.com/2015/12/linux-kvm-how-to-addresize-virtual-disk-on-fly.html/)

[](http://gocit.vn/bai-viet/phan-biet-thick-thin-provisioning/)

[Thick vs Thin VMware Disk Provisioning: What is the Difference?](https://www.nakivo.com/blog/thick-and-thin-provisioning-difference/)

[14.10. Re-sizing the Disk Image Red Hat Enterprise Linux 7 | Red Hat Customer Portal](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/virtualization_deployment_and_administration_guide/sect-using_qemu_img-re_sizing_the_disk_image)

[How to extend root filesystem using LVM on Linux | ComputingForGeeks](https://computingforgeeks.com/extending-root-filesystem-using-lvm-linux/)

[How To extend/increase KVM Virtual Machine (VM) disk size | ComputingForGeeks](https://computingforgeeks.com/how-to-extend-increase-kvm-virtual-machine-disk-size/)

[Create, attach, detach disk to vm in kvm on command line](https://bgstack15.wordpress.com/2017/09/22/create-attach-detach-disk-to-vm-in-kvm-on-command-line/)