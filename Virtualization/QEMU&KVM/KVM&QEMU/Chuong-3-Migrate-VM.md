# Chương 3 : Migrate VM

QEMU-KVM hỗ trợ chúng ta thực hiện di chuyển các VM thông qua cả 2 cách Offline và Online trong cả 2 trường hợp có hoặc không Shared Storage. Vậy thì đầu tiên chúng ta cần tìm hiểu Shared Storage là gì và cách thiết lập nó.
Shared Storage là cơ sở dữ liệu có thể được chia sẻ chung giữa nhiều VM với nhau thông qua các công nghệ như iSCSI, GlusterFS, NFS, DRBD