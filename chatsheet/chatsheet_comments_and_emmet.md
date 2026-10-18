# Comment code và Emmet

## Comment code

Config cài cả `vim-commentary` và `nerdcommenter`.

### vim-commentary

| Chế độ | Phím/lệnh | Tác dụng |
|---|---|---|
| Normal | `gcc` | Bật/tắt comment cho dòng hiện tại |
| Normal | `gc` + motion | Bật/tắt comment theo motion, ví dụ `gcap` |
| Visual | `gc` | Bật/tắt comment cho đoạn đang chọn |
| Command | `:Commentary` | Comment/bỏ comment cho range |

### NERDCommenter

Vì `<leader>` là `\`, ví dụ `<leader>cc` nghĩa là `\cc`.

| Chế độ | Phím | Tác dụng |
|---|---|---|
| Normal/Visual | `<leader>cc` | Comment |
| Normal/Visual | `<leader>cu` | Bỏ comment |
| Normal/Visual | `<leader>c<Space>` | Bật/tắt comment |
| Normal/Visual | `<leader>cm` | Comment tối giản |
| Normal/Visual | `<leader>ci` | Đảo trạng thái comment |
| Normal/Visual | `<leader>cs` | Comment kiểu sexy/nhiều dòng |
| Normal/Visual | `<leader>cy` | Comment và sao chép |
| Normal | `<leader>c$` | Comment tới cuối dòng |
| Normal | `<leader>cA` | Thêm comment ở cuối dòng |
| Normal/Visual | `<leader>cl` | Căn trái |
| Normal/Visual | `<leader>cb` | Căn đều hai phía |
| Normal | `<leader>ca` | Đổi sang bộ ký hiệu comment khác |

## Emmet

| Chế độ | Phím/lệnh | Tác dụng |
|---|---|---|
| Insert/Normal/Visual | `<C-y>,` | Mở rộng abbreviation |
| Insert/Normal | `<C-y>;` | Mở rộng từ |
| Insert/Normal/Visual | `<C-y>d` | Chọn phạm vi tag hướng vào trong |
| Insert/Normal/Visual | `<C-y>D` | Chọn phạm vi tag hướng ra ngoài |
| Insert/Normal | `<C-y>u` | Cập nhật tag |
| Insert/Normal | `<C-y>n` | Đi tới điểm chỉnh sửa tiếp theo |
| Insert/Normal | `<C-y>N` | Đi tới điểm chỉnh sửa trước |
| Insert/Normal | `<C-y>i` | Lấy kích thước ảnh |
| Insert/Normal | `<C-y>I` | Mã hóa ảnh |
| Insert/Normal | `<C-y>/` | Bật/tắt comment HTML/CSS |
| Insert/Normal | `<C-y>j` | Tách/gộp tag |
| Insert/Normal | `<C-y>k` | Xóa tag |
| Insert/Normal | `<C-y>a` | Chuyển URL thành thẻ liên kết |
| Insert/Normal | `<C-y>A` | Chuyển URL thành liên kết có mô tả |
| Insert/Normal | `<C-y>m` | Gộp các dòng |
| Visual | `<C-y>c` | Định dạng code |
| Command | `:Emmet <abbr>` | Mở rộng abbreviation bằng command |
| Command | `:EmmetInstall` | Cài mapping Emmet vào buffer/chế độ hiện tại |
