# Kiểm tra và ghi chú config

## Các plugin không cần phím riêng

| Plugin | Ghi chú |
|---|---|
| `nvim-web-devicons`, `vim-devicons` | Cung cấp icon cho tree/statusline/plugin khác |
| `plenary.nvim`, `nui.nvim` | Thư viện phụ thuộc cho Telescope/Neo-tree/plugin Lua |
| `dressing.nvim` | Cải thiện giao diện nhập liệu/lựa chọn của Neovim |
| `dart-vim-plugin` | Filetype/syntax/indent cho Dart |

## Lệnh tự kiểm tra trong Neovim

| Lệnh | Tác dụng |
|---|---|
| `:map` | Xem tất cả mapping |
| `:nmap` | Xem mapping ở Normal mode |
| `:imap` | Xem mapping ở Insert mode |
| `:vmap` | Xem mapping ở Visual mode |
| `:verbose map <phím>` | Xem mapping do file/plugin nào tạo |
| `:command` | Xem tất cả command |
| `:checkhealth` | Kiểm tra tình trạng Neovim/plugin |
| `:messages` | Xem log thông báo |

## Ghi chú về config hiện tại

- `settings/vista.vim` chỉ còn nội dung comment và plugin `vista.vim` không được khai báo trong `init.lua`, nên không được đưa vào danh sách lệnh sử dụng chính.
- Config có cả `vim-commentary` và `NERDCommenter`. Nên dùng `gcc`/`gc` cho nhanh; dùng NERDCommenter khi cần các kiểu comment nâng cao.
- `<leader>` đang là `\`. Nếu muốn đổi thành Space, thêm `vim.g.mapleader = ' '` trước khi khai báo keymap/plugin.
- Các plugin Git cũ (`vim-fugitive`, `vim-rhubarb`, `vim-gitgutter`, `vim-mergetool`) đã bị xóa, thay bằng plugin cục bộ `jetgit` trong `local_plugged/` (không do vim-plug quản lý, được thêm vào runtimepath trong `init.lua`).
