# Tìm kiếm và file tree

## Telescope

| Chế độ | Phím/lệnh | Tác dụng |
|---|---|---|
| Normal | `<C-o>` | `:Telescope find_files` |
| Normal | `<C-p>` | `:Telescope live_grep` |
| Command | `:Telescope` | Mở trình chọn Telescope |
| Command | `:Telescope find_files` | Tìm file |
| Command | `:Telescope live_grep` | Tìm nội dung trong project |
| Command | `:Telescope buffers` | Tìm buffer |
| Command | `:Telescope help_tags` | Tìm help tag |
| Command | `:Telescope commands` | Tìm command |

## FZF

| Chế độ | Phím/lệnh | Tác dụng |
|---|---|---|
| Normal/Visual/Operator | `<F6>` | `:Files` |
| Normal/Visual/Operator | `<F7>` | `:Rg` |
| Command | `:Files [dir]` | Tìm file bằng FZF, có preview |
| Command | `:Rg [query]` | Tìm nội dung bằng `rg` và FZF |
| Command | `:Buffers` | Tìm buffer |
| Command | `:Lines` | Tìm dòng trong các buffer đang mở |
| Command | `:BLines` | Tìm dòng trong buffer hiện tại |
| Command | `:History` | Tìm trong history |
| Command | `:Commands` | Tìm command |
| Command | `:Maps` | Tìm keymap |
| Command | `:GFiles` | Tìm file trong Git |
| Command | `:Commits` | Tìm commit |
| Command | `:BCommits` | Tìm commit liên quan đến buffer hiện tại |

Trong cửa sổ FZF:

| Phím | Tác dụng |
|---|---|
| `Ctrl-t` | Mở kết quả trong tab mới |
| `Ctrl-x` | Mở kết quả trong split ngang |
| `Ctrl-v` | Mở kết quả trong split dọc |
| `Ctrl-/` | Bật/tắt cửa sổ preview |

## File tree

Config hiện tại dùng Neo-tree.

### Mở và điều hướng

| Chế độ | Phím/lệnh | Tác dụng |
|---|---|---|
| Normal | `<C-B>` | `:Neotree toggle reveal_force_cwd` |
| Trong Neo-tree | `<C-B>` | Đóng cửa sổ Neo-tree |
| Command | `:Neotree` | Mở Neo-tree |
| Command | `:Neotree toggle` | Bật/tắt Neo-tree |
| Command | `:Neotree reveal` | Mở Neo-tree và focus file hiện tại |
| Command | `:Neotree filesystem` | Xem filesystem |
| Command | `:Neotree buffers` | Xem các buffer |
| Command | `:Neotree git_status` | Xem trạng thái Git |

Trong cửa sổ Neo-tree:

| Phím | Tác dụng |
|---|---|
| `<Enter>` | Mở file hoặc mở/thu gọn thư mục |
| `<Space>` | Mở/thu gọn node |
| `<Backspace>` | Đi lên thư mục cha |
| `.` | Đặt thư mục đang chọn làm root |
| `S` | Mở file trong split ngang |
| `s` | Mở file trong split dọc |
| `t` | Mở file trong tab mới |
| `R` | Làm mới cây thư mục |
| `?` | Xem toàn bộ keymap hiện có |

### Thêm, đổi tên và xóa file/thư mục

Đặt con trỏ lên thư mục đích trước khi tạo nội dung mới.

| Phím | Tác dụng |
|---|---|
| `a` | Tạo file mới; thêm `/` ở cuối tên để tạo thư mục, ví dụ `components/` |
| `A` | Tạo thư mục mới, không cần thêm `/` ở cuối tên |
| `r` | Đổi tên file hoặc thư mục đang chọn |
| `b` | Đổi tên nhưng giữ nguyên phần mở rộng của file |
| `d` | Xóa file hoặc thư mục đang chọn; Neo-tree sẽ yêu cầu xác nhận |
| `c` | Sao chép file hoặc thư mục |
| `m` | Di chuyển file hoặc thư mục |
| `y` | Đánh dấu để sao chép, sau đó dùng `p` để dán |
| `x` | Đánh dấu để di chuyển, sau đó dùng `p` để dán |
