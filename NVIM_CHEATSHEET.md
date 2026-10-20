# Hướng dẫn sử dụng Neovim hiện tại

File này là mục lục cho bộ cheatsheet được tách theo từng chức năng. Nội dung được tổng hợp từ `init.lua`, `settings/*.vim`, `settings/*.lua`, `lua/custom/*.lua`, các plugin trong `plugged/` và plugin cục bộ trong `local_plugged/`.

Cập nhật: 2026-10-19.

## Mục lục theo chức năng

| Chức năng | Tài liệu |
|---|---|
| Ký hiệu phím, phím tắt chung, buffer | [chatsheet_general_shortcuts.md](chatsheet/chatsheet_general_shortcuts.md) |
| Quản lý plugin và danh sách plugin | [chatsheet_plugin_management.md](chatsheet/chatsheet_plugin_management.md) |
| Telescope, FZF và Neo-tree | [chatsheet_search_and_file_tree.md](chatsheet/chatsheet_search_and_file_tree.md) |
| Terminal Floaterm | [chatsheet_floaterm.md](chatsheet/chatsheet_floaterm.md) |
| CoC LSP, completion, diagnostics, code action | [chatsheet_coc_lsp.md](chatsheet/chatsheet_coc_lsp.md) |
| Python, Ruff, formatter và môi trường ảo | [chatsheet_python.md](chatsheet/chatsheet_python.md) |
| Git, diff, commit và xử lý conflict | [chatsheet_git.md](chatsheet/chatsheet_git.md) |
| Comment code và Emmet | [chatsheet_comments_and_emmet.md](chatsheet/chatsheet_comments_and_emmet.md) |
| Highlight symbol, auto-pairs, auto-save, fold | [chatsheet_editing_utilities.md](chatsheet/chatsheet_editing_utilities.md) |
| Scrollbar, viewport và diagnostics | [chatsheet_scrollbar.md](chatsheet/chatsheet_scrollbar.md) |
| Theme, statusline và giao diện | [chatsheet_interface.md](chatsheet/chatsheet_interface.md) |
| Dart và Flutter | [chatsheet_dart_and_flutter.md](chatsheet/chatsheet_dart_and_flutter.md) |
| Lệnh kiểm tra và ghi chú config | [chatsheet_config_troubleshooting.md](chatsheet/chatsheet_config_troubleshooting.md) |

## Gợi ý tìm nhanh

- Tìm phím tắt: mở file theo chức năng, sau đó dùng `/` trong Neovim.
- Tìm trên toàn bộ cheatsheet: `:Rg <từ-khóa> chatsheet`.
- `<leader>` hiện chưa được đặt, nên mặc định là phím `\`.
