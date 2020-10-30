# Virtualization & Hypervisor và CPU Virtualization

Ngày nay với sự phát triển ngày càng lớn của công nghệ ảo hóa, việc tìm hiểu về ảo hóa và công nghệ giám sát các hệ điều hành ảo ( Hypervisor ) là ngày càng cần thiết. Bất kể dù bạn có đang làm bất cứ công việc gì thì cũng ít nhất 1 lần sử dụng các ứng dụng của công nghệ ảo hóa. Với sự phát triển của nó, ảo hóa đang thu hút sự chú ý của hàng loạt các công ty lớn như Amazon, Microsoft hay VMWare, .... 
Thông qua bài này chúng ta sẽ tìm hiểu 2 khái niệm của công nghệ này là Virtualization và Hypervisor

![Virtualization&Hypervisor/Untitled.png](Virtualization&Hypervisor/Untitled.png)

**Mục lục**
   * [1. Virtualization](#1-virtualization)
       * [1.1 Ảo hóa là gì ?](#11-ảo-hóa-là-gì-)
       * [1.2 Ảo hóa máy tính để bàn](#12-ảo-hóa-máy-tính-để-bàn)
       * [1.3 Ảo hóa hệ thống mạng](#13-ảo-hóa-hệ-thống-mạng)
       * [1.4 Ảo hóa phần cứng](#14-ảo-hóa-phần-cứng)
   * [2. Hypervisor](#2-hypervisor)
       * [2.1 Khái niệm](#21-khái-niệm)
       * [2.2 Phân loại](#22-phân-loại)
       * [2.3 Hypervisor Native](#23-hypervisor-native)
       * [2.4 Hypervisor Hosted](#24-hypervisor-hosted)
   * [3. Ưu điểm của ảo hóa ( Virtualization )](#3-ưu-điểm-của-ảo-hóa--virtualization-)
   * [4. Phân loại các loại ảo hóa](#4-phân-loại-các-loại-ảo-hóa)
      * [Protection Ring](#protection-ring)
      * [4.1 Full Virtualization](#41-full-virtualization)
      * [4.2 Para Virtualization](#42-para-virtualization)
      * [4.3 Hardware Assisted Virtualization](#43-hardware-assisted-virtualization)
      * [Tham khảo](#tham-khảo)


# 1. Virtualization

### 1.1 Ảo hóa là gì ?

**Ý tưởng cơ bản :**

*Thực hiện phân chia phần cứng của 1 hệ thống để từ đó thiết kế được các hệ thống khác nhau trên nền phần cứng đã chia* 

Có thể có nhiều máy ảo khác nhau và mỗi máy ảo có thể sử dụng tùy mục đích khác nhau

Ảo hóa thường được phân chia thành các loại sau: Ảo hóa máy tính để bàn, ảo hóa hệ thống mạng, ảo hóa phần cứng

### 1.2 Ảo hóa máy tính để bàn

![Virtualization&Hypervisor/Untitled%201.png](Virtualization&Hypervisor/Untitled%201.png)

Thực hiện tách phần OS ra khỏi phần cứng ( Hardware ) 

Có thể hiểu đơn giản là ta thực hiện tạo 1 máy tính có mọi khả năng như máy tính bình thường. Máy tính được tạo ra gọi là máy Desktop ảo và được lưu trữ trên phần cứng thiết bị tại trung tâm dữ liệu

Một lợi ích đáng quan tâm là việc cho phép truy cập máy ảo thông qua các kết nối được bảo mật từ các điểm truy cập khác trên toàn cầu

### 1.3 Ảo hóa hệ thống mạng

![Virtualization&Hypervisor/Untitled%202.png](Virtualization&Hypervisor/Untitled%202.png)

Ảo hóa mạng là tiến trình hợp nhất tài nguyên phần cứng và phần ảo với nhau 

⇒ Tạo nên 1 hệ thống bao gồm N các  channel → Sau đó các Channel này được kết nối tới các hệ thống ( thiết bị ) khác nhau

Có thể được kết hợp cùng ảo hóa phần cứng để Tạo nên 1 hệ thống Hypervisor 

Các Hypervisor có khả năng kết hợp, giao tiếp với nhau để quản lý hệ thống mạng ảo này và thực hiện các giao thức mạng cấp cao như cân bằng tải ( Load Balancing )  và tường lửa ( Firewall) 

Tuy nhiên việc này tùy thuộc vào loại thiết bị và nhà cung cấp mạng sẽ thiết kế được hệ thống mạng ảo khác nhau

### 1.4 Ảo hóa phần cứng

![Virtualization&Hypervisor/Untitled%203.png](Virtualization&Hypervisor/Untitled%203.png)

**Ý tưởng cốt lõi** : 

*Tạo ra máy ảo để thực hiện mô phỏng máy chủ hoặc có thể độc lập*

Được chia làm 2 loại

1. Ảo hóa toàn phần : Phần cứng được ảo hóa toàn phần → Tạo được nhiều OS trên cùng 1 phần cứng → Tăng tính bảo mật khi nhiều User sử dụng 1 phần cứng
2. Ảo hóa 1 phần : Thường thì không đủ tài nguyên cho toàn bộ OS → Được sử dụng để tạo 1 môi trường ảo cho 1 App chạy → Ít tốn tài nguyên hơn việc tạo 1 máy ảo

**Nhược điểm :**

Phần cứng được ảo hóa có tốc độ chậm hơn phần thực

Bị giới hạn bởi thống số thực tế của máy chủ

**Ưu điểm :**

Linh hoạt và tiết kiệm khi mở rộng hệ thống

---

![Virtualization&Hypervisor/Untitled%204.png](Virtualization&Hypervisor/Untitled%204.png)

# 2. Hypervisor

### 2.1 Khái niệm

Là phần mềm thực hiện tạo và quản lý các máy ảo 

Cho phép các VM hay Guest truy cập phần Hardware do nó quản lý

Có nhiệm vụ giám sát và quản lý tài nguyên hệ thống, đảm bảo sự hoạt động của các VM

- Ví dụ : 1 VM được cấp 2GB bộ nhớ thì không được sử dụng quá 2GB được cấp phát
- Ví dụ : Các ứng dụng trên các VM khác nhau hoạt động mà không ảnh hưởng tới nhau

### 2.2 Phân loại

![Virtualization&Hypervisor/Untitled%205.png](Virtualization&Hypervisor/Untitled%205.png)

### 2.3 Hypervisor Native

![Virtualization&Hypervisor/Untitled%206.png](Virtualization&Hypervisor/Untitled%206.png)

Loại Hypervisor này được gọi là Hypervisor Type 1

Trong đó Hypervisor được host trực tiếp trên phần Hardware

Khởi động trước các OS khác trên hệ thống → Đảm bảo hiệu suất cao, không bị cạnh tranh tài nguyên

⇒ Được sử dụng để chạy các máy ảo 

⇒ Luôn chạy ngầm trên hệ thống

Thường thì chỉ có giao diện CLI chứ không có giao diện GUI

⇒ Phù hợp với các công ty lớn chuyên về Cloud Computing hay Database Center.

Một số loại Hypervisor loại 1 bao gồm: VMWARE ESXI, Microsoft HyperV, ...

### 2.4 Hypervisor Hosted

![Virtualization&Hypervisor/Untitled%207.png](Virtualization&Hypervisor/Untitled%207.png)

Loại Hypervisor này còn được gọi là Hypervisor Type 2

Hypervisor sẽ được host trên 1 OS

Có chức năng tương tự *Native* (Nhưng chỉ quản lý các máy ảo thuộc OS đang host )

⇒ Ưu điểm lớn nhất mà nó đem lại là có thể thực hiện bật / tắt để giải phóng tài nguyên khi có yêu cầu

⇒ Phù hợp với các công ty nhỏ vừa

Một số loại Hypervisor loại 2 bao gồm: VMWARE work station , Virtual Box,...

**Tuy nhiên ngày nay sự khác biệt này ngày càng được thu hẹp lại, ví dụ với hệ thống KVM ( Kernel Based Virtual Machine ) có thể trực tiếp host máy ảo và vẫn có thể sử dụng OS của nó 1 cách độc lập**

***Sự khác biệt giữa Container và VM***

Container : Tạo môi trường độc lập để chạy các ứng dụng trong container. Nhận thư viện và các file cần thiết để chạy các ứng dụng trong container. Chia sẻ nhân Kernel với OS hiện tại.

VM : Tự coi nó như là 1 hệ thống độc lập với các thư viện cùng với các file hệ thống khác. Có OS riêng độc lập với OS host .

---

# 3. Ưu điểm của ảo hóa ( Virtualization )

![Virtualization&Hypervisor/Untitled%208.png](Virtualization&Hypervisor/Untitled%208.png)

Ảo hóa là 1 khái niệm được bắt đầu phát triển từ những năm 1960s, sau 1 quãng thời gian dài phát triển tới những năm gần đây, thì nó ngày càng thể hiện được khả năng cũng như tiềm năng của mình. Việc ảo hóa có thể tiến hành trên 2 loại OS đang được sử dụng rộng rãi hiện tại là Window và Linux ( tại mảng này Linux là hệ điều hành có ưu thế hơn ). 

Các ưu điểm đáng kể đến như sau :

- Tiết kiệm chi phí
- Khả năng mở rộng, nâng cấp hệ thống tốt hơn
- Tiết kiệm không gian tại nơi đặt máy chủ
- Giảm chi phí bảo dưỡng
- Đa số các ứng dụng là mã nguồn mở → Được cộng đồng đóng góp nên phát triển nhanh hơn
- Kiểm soát dữ liệu cũng như bảo mật tốt hơn
- Dễ dàng di chuyển các máy ảo sang các máy vật lý khác nhau → Tăng tính linh hoạt

Cùng vô số các ưu điểm khác nhau ...

# 4. Phân loại các loại ảo hóa

Trước khi tìm hiểu về các loại ảo hóa, chúng ta cần tìm hiểu khái niệm cơ bản dưới đây :

### Protection Ring

![Virtualization&Hypervisor/Untitled%209.png](Virtualization&Hypervisor/Untitled%209.png)

Khái niệm này được ra đời để thiết lập sự bảo vệ nhất định đối với lõi Kernel - Nơi mà các lệnh hệ thống được thực thi. Nếu không có các sự quy định này, hệ thống sẽ có các lỗ hổng bảo mật vô cùng lớn, việc tấn công và chiếm quyền điều khiển cũng sẽ trở nên dễ dàng hơn. 

Tại đây có các Ring như :

Ring 0 : Nơi lõi Kernel thực hiện các lệnh hệ thống với quyền truy cập cao nhất

Ring 1 2 : Driver của các thiết bị

Ring 4 : Nơi các ứng dụng hệ thống chạy

Như hình trên đã biểu diễn, càng vào sâu bên trong ( hay còn có thể hiểu là vào lõi ) thì các quyền được cung cấp sẽ ngày càng cao → Quản lý vùng này cần phải vô cùng chặt chẽ

⇒ Phát triển 2 kĩ thuật ảo hóa có cách thức quản lý khác nhau : **Full Virtualization và Para Virtualization.** 

## 4.1 Full Virtualization

![Virtualization&Hypervisor/Untitled%2010.png](Virtualization&Hypervisor/Untitled%2010.png)

Như chúng ta đã biết, việc ảo hóa có thể diễn ra trên nhiều phần tử khác nhau của hệ thống, *Full Virtualization* là kĩ thuật thực hiện ảo hóa toàn bộ các phần tử của hệ thống. 

→*Cho phép việc ảo hóa các loại hệ thống khác nhau: Hệ thống sử dụng Window có thể ảo hóa các hệ điều hành chạy hành như Linux,MAC OS,.. và cho phép mô phỏng các cấu trúc CPU khác với CPU của hệ thống vật lý thật, ...*

Với kĩ thuật này thì hệ điều hành VM sẽ nằm tại Ring 1 trong sơ đồ *Ring Protection* đã nói ở trên. Mã nguồn của hệ điều hành sẽ không bị thay đổi trong mô hình ảo hóa này, OS của VM sẽ không nhận biết được việc mình là thiết bị ảo và thực hiện các system call như 1 hệ thống thật

→ *Cung cấp khả năng ảo hóa nhiều các hệ điều hành khác nhau*

 Các lệnh hệ thống sẽ được mô phỏng bởi VMM/Hypervisor và phần tử này sẽ làm trung gian trong việc yêu cầu tài nguyên cũng như thực thi các yêu cầu khác nhau giữa VM và hệ thống vật lý. Thông thường, việc thực hiện mô phỏng sẽ do TCG ( Tiny Code Generator ) tại Hypervisor thực hiện. Với các lệnh từ ứng dụng bình thường thì sẽ được thực hiện như thông thường.

→ *Trả giá về mặt hiệu năng hệ thống khi phải thực hiện việc mô phỏng ( Binary Translate ) giữa các VM và hệ thống thật. Với việc sử dụng càng nhiều máy ảo thì việc ảnh hưởng tới hiệu năng hệ thống ngày càng tăng*

## 4.2 Para Virtualization

![Virtualization&Hypervisor/Untitled%2011.png](Virtualization&Hypervisor/Untitled%2011.png)

Phía trên chính là mô hình của kĩ thuật *Para Virtualization.* Với kĩ thuật này, thì việc ảo hóa sẽ diễn ra tương đối khác biệt. Điểm khác biệt đầu tiên chính là việc, các hệ điều hành của VM sẽ được chỉnh sửa để có thể thực hiện kĩ thuật này 

→ *Ưu điểm đầu tiên đó chính là việc cho phép OS của VM có thể được chạy tại Ring 0. Từ đó tiết kiệm được rất nhiều thời gian cũng như tăng hiệu năng xử lý của hệ thống*

→ *Tuy nhiên việc trả giá đó chính là việc kĩ thuật này gần như là không áp dụng được đối với các hệ điều hành có mã nguồn đóng ( tiêu biểu như Window )* 

Với kĩ thuật này, các VM có thể tương tác trực tiếp đối với các phần tử thật của hệ thống vật lý như CPU, Hard Disk, ...

→ *Tăng hiệu năng xử lý*

→ *Tiềm ẩn khả năng về bảo mật, vì có thể diễn ra trường hợp 2 VM có thể đọc được dữ liệu của nhau*

Các lệnh hệ thống ( System Call ) được thực hiện dưới dạng *Hyper Call.* 

→ *Các OS của VM nhận biết được việc nó đang được sử dụng trên nền ảo hóa* 

Do kĩ thuật này không thực hiện ảo hóa toàn bộ hệ thống, nên đồng thời gây ra :

→ *Không có khả năng tùy biến như Full Virtualization , chỉ có thể áp dụng được với 1 số trường hợp nhất định*

→ *Không có khả năng thích ứng với các kiểu kiến trúc CPU khác với CPU vật lý*

## 4.3 Hardware Assisted Virtualization

![Virtualization&Hypervisor/Untitled%2012.png](Virtualization&Hypervisor/Untitled%2012.png)

Đồng thời với sự phát triển của kĩ thuật ảo hóa, ngày càng nhiều các nhà cung cấp chú ý đến ảo hóa hơn. Và các nhà cung cấp lớn hàng đầu như Intel hay AMD đã nhận ra rằng thử thách lớn nhất đối với ảo hóa là các hệ thống x86 . Cả Intel và AMD đều cung cấp các Module hỗ trợ ảo hóa của mình là VT-X và AMD-V cho các ngưởi dùng để thực hiện việc ảo hóa dễ dàng hơn. 

Đây đơn giản chỉ là một phần mềm cho phép tận dụng tối đa khả năng của thiết bị vật lý kết hợp cùng các kĩ thuật ảo hóa để cho phép tối ưu hóa hiệu năng. Về mặt thông hiểu đơn giản, ta có thể hình dung đây chính là việc kết hợp *Full Virtualization* với *Para Virtualization* ( Nó sẽ sử dụng nguyên lý của Full nhưng với mô hình của Para ) , Hypervisor sẽ được đẩy xuống 1 lớp Ring mới là *Ring -1*. 

Với sự hỗ trợ từ các Modules thì các Hypervisor cũng sẽ không cần phải hoạt động tối đa 

→ *Cải thiện về mặt hiệu năng hệ thống*

Ngày nay thì các nhà phát triển sẽ tận dụng tối đa mô hình này do các ưu điểm mà nó đem lại. (một ví dụ điển hình trong đó chính là KVM )

---

## Tham khảo

[Ảo hóa là gì? Tại sao bạn nên sử dụng công nghệ này?](https://quantrimang.com/ao-hoa-la-gi-tai-sao-ban-nen-su-dung-cong-nghe-nay-157936)

[Hypervisor](https://www.thegioimaychu.vn/blog/thuat-ngu/hypervisor/)

[[ KVM ] Tổng quan về Virtualization và Hypervisor - Trang tin tức từ Cloud365 - Nhân Hòa](https://news.cloud365.vn/kvm-tong-quan-ve-virtualization-va-hypervisor/)
