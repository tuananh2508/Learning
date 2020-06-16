# grep - Tìm kiếm

- Lệnh: `grep *x *file` tìm kiếm x trong file

- Lệnh: `grep -v *x *file` tìm kiếm các dòng không có kí tự x

- Lệnh: `grep -i *x *file` tìm kiếm không phân biệt hoa thường 

- Lệnh: `grep -n *x *file` hiện số dòng có xuất hiện x

- Lệnh: `grep -c *x *file` hiện số lần xuất hiện của x

- Lệnh: `grep -e *x -e *y *file` tìm kiếm nhiều từ khác nhau

- Lệnh: `grep -l *x *file1` *file2 hiển thị các file có chứa x

- Lệnh:  `grep -w *x *file` tìm chính xác từ i.e nếu không có -w thì khi tìm no thì nothing cũng sẽ đc hiển thị

-------------------------------------------------------------
# sed - Tìm kiếm và thay thê từ


- Lệnh: `sed 's/*x/*y/' *file`  thay thế x đầu tiên với y có thể thêm /g vào cuối nếu muốn thay thế tất cả 

- Lệnh: `sed 's/*x/*y/Ng' *file` thay thế các từ x từ vị trí thứ n đến cuối

- Lệnh: `sed 's/*x/*y/N" *file` thay thế n vị trí

- Lệnh: `sed '/^$d' *file` xóa các vị trí dấu cách " "

- Lệnh: `sed 's/*x//g' *file` xóa các dòng xuất hiện x

- Lệnh: `sed '*x' | sed '*y'` <=> sed '*x,*y' // mix
 
--------------------------------------------------------------
#awk 
https://www.geeksforgeeks.org/awk-command-unixlinux-examples/
--------------------------------------------------------------


