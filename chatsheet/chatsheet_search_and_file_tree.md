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

Config hiện tại cài cả Neo-tree và NERDTree. Phím tắt tùy chỉnh đang ưu tiên Neo-tree.

### Neo-tree

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

### NERDTree

| Lệnh | Tác dụng |
|---|---|
| `:NERDTree` | Mở NERDTree |
| `:NERDTreeToggle` | Bật/tắt NERDTree |
| `:NERDTreeFind` | Tìm file hiện tại trong tree |
| `:NERDTreeFocus` | Focus vào NERDTree |
| `:NERDTreeClose` | Đóng NERDTree |
| `:NERDTreeCWD` | Đặt root theo thư mục làm việc hiện tại |
| `:NERDTreeRefreshRoot` | Làm mới root |
