# python-pro

Local plugin cho workflow Python trong Neovim:

- theme TokyoNight chỉ áp dụng cho cửa sổ Python;
- tên class từ semantic token của CoC được in đậm;
- `coc-jedi` cung cấp completion, navigation và refactor;
- `coc-ruff` cảnh báo quy tắc đặt tên, quick fix và formatter;
- `<leader>pr` đổi tên symbol an toàn bằng CoC khi Ruff không thể tự sửa tên;
- tự tìm `<project-root>/.venv`, cho phép chọn môi trường khác và hiển thị đường dẫn trên winbar.

Plugin được tải từ `init.lua`, không do vim-plug quản lý.
