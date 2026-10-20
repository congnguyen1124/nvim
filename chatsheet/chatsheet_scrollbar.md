# Scrollbar kiểu VS Code

Local plugin `code-scrollbar` hiển thị trạng thái toàn bộ file ở cạnh phải cửa sổ code.

## Ký hiệu

| Hiển thị | Ý nghĩa |
|---|---|
| `●` màu đỏ | Vị trí có error |
| `●` màu vàng | Vị trí có warning |
| `┃` màu xanh dương | Khu vực đang được hiển thị trong cửa sổ |
| `◆` màu cyan | Vị trí dòng hiện tại |
| `✓ No issues` | Buffer không có error hoặc warning |
| `E 2  W 3` | Buffer có 2 error và 3 warning |

Scrollbar ưu tiên diagnostics của CoC và tự chuyển sang `vim.diagnostic` khi CoC không quản lý buffer.

## Lệnh và phím tắt

| Phím/lệnh | Tác dụng |
|---|---|
| `<leader>sb` | Bật/tắt scrollbar |
| `:CodeScrollbarToggle` | Bật/tắt scrollbar |
| `:CodeScrollbarRefresh` | Vẽ lại scrollbar ngay lập tức |
