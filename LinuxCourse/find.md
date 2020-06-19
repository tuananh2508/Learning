# Lệnh Find

## Sử dụng

find . -type f "name"

với 

- `.` sẽ thực hiện tìm kiều trong folder hiện tại .

- `type -f` thự hiện tìm kiếm file 

- `- name` và sau đó là tên cần tìm

- option `-iname` sẽ bỏ qua viết hoa viết thường miễn là có các thảo mãn cái tên mình cần tìm

- nếu muốn tìm ở 1 file khác `find /abs/path -type f -(i)name "*"`

> lưu ý rằng khi tìm kiếm như này thì sẽ tìm kiếm mọi file trong đường dẫn /abs/path. 
Ví dụ như có file thỏa mãn trong /abs/path/hello/guys
thì kết quả cũng sẽ được hiện ra

- option `find . -size +100kb` 
lệnh này hiện ra các file trên 100kb . nếu thay bằng dấu trừ sẽ hiện ra các file nhỏ hơn 100kb.

- option `-not` sẽ hiện ra các file không có từ khóa thỏa mãn

- option `-maxdepth` sẽ tương ứng với mức tìm kiếm .

>Ví dụ: -maxdepth 1 : /abs/path/depth1/ nhưng với giá trị maxdepth = 2 thì sẽ trở thành /abs/path/depth1/depth2. 
Và giá trị depth lớn hơn hoặc bằng 0

- Hoàn toàn có thể kết hợp các option với nhau

  
