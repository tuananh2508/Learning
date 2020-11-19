# Linux-network-namespace

**Mục lục**
- [Linux-network-namespace](#linux-network-namespace)
- [1. Giới thiệu về Linux Network Namespace](#1-giới-thiệu-về-linux-network-namespace)
- [2. Các câu lệnh cơ bản đối với Linux Network Namespace](#2-các-câu-lệnh-cơ-bản-đối-với-linux-network-namespace)
  - [2.1 Thêm một Network Namespace](#21-thêm-một-network-namespace)
  - [2.2 Xóa một Network Namespace](#22-xóa-một-network-namespace)
  - [2.3 Liệt kê các Network Namespace trên hệ thống](#23-liệt-kê-các-network-namespace-trên-hệ-thống)
  - [2.4 Chạy một câu lệnh trong Network Namespace cụ thể](#24-chạy-một-câu-lệnh-trong-network-namespace-cụ-thể)
  - [2.5 Gán 1 Interface cụ thể vào Network Namespace](#25-gán-1-interface-cụ-thể-vào-network-namespace)
- [Nguồn tham khảo](#nguồn-tham-khảo)

# 1. Giới thiệu về Linux Network Namespace

**Linux Network Namespace** là một khái niệm cho phép cô lập các Network trong trường hợp bạn chỉ có 1 Kernel xử lý. Linux Network Namespace sẽ cho phép bạn cô lập các khái niệm liên quan đến Network như Interface, Port, địa chỉ IP ,... Cùng với đó, tại mỗi Namespace sẽ có một cơ chế NAT riêng, một bảng Iptables ( trong trường hợp nếu Host có sử dụng ) riêng biệt . 

Khái niệm này được sử dụng nhiều tại các dự án như Openstack , Mininet và Docker.

Ở chế độ mặc định, User khi truy cập vào hệ thống sẽ được truy cập vào Root Network Namespace

# 2. Các câu lệnh cơ bản đối với Linux Network Namespace

## 2.1 Thêm một Network Namespace

Việc thêm 1 Network Namespace mới được thực hiện qua câu lệnh sau

```bash
ip netns add <name>
```

*Trong đó, `name` là tên Network Namespace bạn muốn tạo*

## 2.2 Xóa một Network Namespace

Việc xóa 1 Network Namespace được thực hiện qua câu lệnh sau

```bash
ip netns delete <name>
```

*Trong đó `name` là tên Network Namespace bạn muốn xóa*

## 2.3 Liệt kê các Network Namespace trên hệ thống

Được thực hiện qua câu lệnh dưới

```bash
ip netns show
```

## 2.4 Chạy một câu lệnh trong Network Namespace cụ thể

```bash
ip netns exec <name> <command>
```

*Trong đó `name` là tên Network Namespace bạn muốn thực hiện lệnh còn `command` là lệnh bạn muốn thực thi*

## 2.5 Gán 1 Interface cụ thể vào Network Namespace

Để có thể gán 1 Interface vào 1 Network Namespace ta sẽ sử dụng câu lệnh sau 

```bash
ip link set <interface_name> netns <name>
```

*Trong đó `interface_name` là tên Interface bạn muốn thêm vào `name` ( là Network Namespace bạn muốn thêm )*

---

# Nguồn tham khảo

[hocchudong/thuctap012017](https://github.com/hocchudong/thuctap012017/blob/master/TamNT/Virtualization/docs/7.Linux_network_namespace.md#1.1)