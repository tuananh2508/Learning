# Cơ bản về Git


## Git là gì và dùng để làm gì ?

- Git là một phẩn mềm kiểm soát phiên bản

- Bạn có thể thay đổi, hoàn tác về các giai đoạn trước.

- Có nhiều các trang web khác nhau dựa trên Git như: GitHub, GitLab,...

Vậy chúng ta có thể thấy Git là 1 ứng dụng vô cùng hữu dụng trong việc quản lí dự án hiện nay của các công ty công nghệ . Trong bài viết này mình sẽ hướng dẫn các bạn cách cài đặt và sử dụng git trên hệ điều hành ubuntu 18.04LTS

## 1. Cài đạt Git như thé nào ?

Git cung cấp cho chúng ta nhiều cách để cài đặt nhưng ở bài này mình sẽ hướng dẫn các bài cài đặt git thông qua cửa sổ Terminal quen thuộc.

Đầu tiên, sử dụng các công cụ quản lý gói apt để cập nhật chỉ mục gói nội bộ của bạn. Với bản cập nhật hoàn tất, bạn có thể tải xuống và cài đặt Git:

> sudo apt update

> sudo apt-get install git

Sau khi cài đặt git xong chúng ta  sẽ đến với bước tiếp theo đó chính là config ( tinh chỉnh git)

 > git config --global user.name "user_name"

 > git config --global user.email "email_id"
  
 Với username và email_id là username và email trên github.comm

Tiếp đó chúng ta sẽ đến với bước tạo 1 Repo trong máy

- B1: Truy cập vào https://github.com/new và đặt tên mới cho repo của mình và một vài tùy chỉnh khác mà github có thể đề nghị cho bạn ( public/private, description)
 
- B2: Bật cửa sổ Terminal trên Ubuntu và nhập các lệnh sau

> git init

![git_init](https://drive.google.com/file/d/1riPN0dDDPoTscCGMR8fEaomZ5gJ4lpNr/view?usp=sharing)
 
Bước này sẽ tạo trên máy tính của chúng ta 1 reposit
 
-Sau đó chúng ta sẽ kiếm tra lại xem trên máy đã có 1 repo hay chưa thông qua lệnh:

>git status
![alt_text](https://imgur.com/a/ynHN0dQ)



## 2 Git Commands

- git init
 -Tao repo trong may
- git clone
 -Lay tu tren mang ve
- git pull
 -Dong bo tren mang ve
-git add / git add .
 -Sua source code
- git commit
 -Sua source code 
- git push
 -Dong bo tu may len mang
- git log
 -Lay log

## 3 Upload Files
>git add *Filename
>git push
>git commit -m "comment"
>git status / git log

## 4 Create a branch
>git checkout -b "*name of branch"
>git commit -m "comment"
>git push

## 5 Delete a branch
- Local:
>git branch -d *branch_name

- Remote
>git push origin --delete *branch_name
