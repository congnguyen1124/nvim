# Phím tắt chung và buffer

Tài liệu này tổng hợp các ký hiệu phím, phím tắt chung và cách chuyển buffer.

## Ký hiệu phím

| Ký hiệu | Ý nghĩa |
|---|---|
| `<C-x>` | `Ctrl + x` |
| `<M-x>` | `Alt/Meta + x` |
| `<S-x>` | `Shift + x` |
| `<CR>` | `Enter` |
| `<leader>` | Chưa được đặt trong config, nên mặc định là phím `\` |

Lưu ý: một số terminal có thể gửi `<C-i>` giống phím `Tab`, và có thể không nhận đúng `<C-S-i>`.

## Phím tắt chung

| Chế độ | Phím | Tác dụng |
|---|---|---|
| Normal | `<M-Right>` | Tăng chiều rộng split dọc |
| Normal | `<M-Left>` | Giảm chiều rộng split dọc |
| Normal | `<M-Down>` | Tăng chiều cao split ngang |
| Normal | `<M-Up>` | Giảm chiều cao split ngang |
| Normal | `/\` | Xóa highlight tìm kiếm |
| Normal | `<leader>bd` | Đóng buffer hiện tại |
| Normal | `:bd` | Được viết tắt thành `:BdeleteLeft` |
| Normal | `:bd!` | Được viết tắt thành `:BdeleteLeft!` |
| Visual | `//` | Tìm chính xác đoạn văn bản đang chọn |
| Visual | `<C-r>` | Tạo lệnh substitute với văn bản đang chọn |

## Buffer và trình chuyển tab

| Chế độ | Phím/lệnh | Tác dụng |
|---|---|---|
| Normal | `<F3>` | Buffer trước: `:bprevious` |
| Normal | `<F4>` | Buffer sau: `:bnext` |
| Normal/Insert/Visual | `<C-i>` | Mở popup chuyển buffer theo danh sách gần đây |
| Normal/Insert/Visual | `<C-S-i>` | Chuyển lùi trong popup buffer |
| Command | `:BdeleteLeft` | Đóng buffer hiện tại và focus buffer trước |
| Command | `:BdeleteLeft!` | Buộc đóng buffer hiện tại và focus buffer trước |
