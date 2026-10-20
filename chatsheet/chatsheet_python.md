# Python chuyên nghiệp với Python Pro và CoC

Local plugin `python-pro` chỉ kích hoạt cho file Python. Plugin phối hợp với `coc-jedi` để completion/navigation và `coc-ruff` để lint, quick fix, sắp xếp import và format.

## Theme và quy chuẩn code

- Cửa sổ Python dùng bảng màu TokyoNight, không làm thay đổi theme của filetype khác.
- Tên class được in đậm; function, method, biến, parameter và decorator có màu semantic từ CoC.
- Inlay hint của Python được tắt, vì vậy kiểu dữ liệu của biến không hiển thị trực tiếp trong code.
- Mọi thông báo, prompt, mô tả phím và trạng thái `.venv` trên giao diện đều dùng tiếng Anh.
- Ruff kiểm tra quy tắc đặt tên PEP 8 (`N`), bao gồm tên class, function, argument và biến.
- Chiều dài dòng mặc định là 88; `colorcolumn` nằm ở cột 89.
- Indent dùng 4 dấu cách và fold theo indent.

## Quick fix và formatter

| Phím/lệnh | Tác dụng |
|---|---|
| `<leader>pq` / `:PythonQuickFix` | Áp dụng quick fix đầu tiên tại dòng hiện tại |
| `<leader>pa` | Mở danh sách code action tại con trỏ |
| `<leader>pr` | Đổi tên symbol an toàn bằng CoC; dùng khi cảnh báo tên không thể tự sửa |
| `<leader>pf` / `:PythonFormat` | Format buffer bằng Ruff qua CoC |
| `<leader>pF` / `:PythonClean` | Tự sửa lỗi có thể sửa, sắp xếp import và format |
| `[g` / `]g` | Đi tới diagnostic trước / tiếp theo |

## Môi trường ảo

Python Pro tự tìm `.venv` tại project root. Đường dẫn đang dùng được hiển thị ở góc trên bên phải cửa sổ Python.

| Phím/lệnh | Tác dụng |
|---|---|
| `<leader>pv` / `:PythonVenvSelect [path]` | Chọn `.venv` khác cho project hiện tại |
| `<leader>pc` / `:PythonVenvCreate` | Tạo `<project-root>/.venv` bằng `python3 -m venv` |
| `:PythonVenvReset` | Bỏ lựa chọn riêng và quay lại `.venv` mặc định |
| `<leader>pi` / `:PythonToolsInstall` | Cài hoặc cập nhật Ruff trong `.venv` hiện tại |

Lựa chọn `.venv` được lưu theo project trong dữ liệu của Neovim. Khi đổi môi trường, plugin cập nhật `jedi.workspace.environmentPath`, `ruff.interpreter`, đường dẫn Ruff và khởi động lại CoC khi cần.
