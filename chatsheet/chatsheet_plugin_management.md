# Quản lý plugin và config

Config hiện tại dùng `vim-plug`.

## Lệnh quản lý

| Lệnh | Tác dụng |
|---|---|
| `:PlugInstall` | Cài các plugin chưa có trong `plugged/` |
| `:PlugUpdate` | Cập nhật plugin |
| `:PlugStatus` | Xem trạng thái plugin |
| `:PlugClean` | Xóa plugin không còn được khai báo |
| `:PlugDiff` | Xem thay đổi sau khi cập nhật plugin |
| `:PlugUpgrade` | Cập nhật vim-plug |
| `:ReloadConfig` | Tải lại `init.lua` |
| `:UpdateRemotePlugins` | Cập nhật remote plugin của Neovim |

## Các plugin đang được khai báo

| Nhóm | Plugin |
|---|---|
| Theme/UI | `nvim-nightsky`, `onedark.nvim`, `vim-transparent`, `vim-airline`, `vim-airline-themes`, `nvim-web-devicons`, `vim-devicons`, `dressing.nvim` |
| Tìm kiếm | `fzf`, `fzf.vim`, `telescope.nvim`, `plenary.nvim` |
| File tree | `neo-tree.nvim`, `nui.nvim` |
| Terminal | `vim-floaterm` |
| LSP/completion | `coc.nvim`, `coc-jedi`, `coc-ruff` |
| Python/fold | `SimpylFold` |
| Git | `jetgit` (plugin cục bộ trong `local_plugged/`, không qua vim-plug) |
| Comment/chỉnh sửa code | `nerdcommenter`, `vim-commentary`, `auto-pairs`, `emmet-vim`, `vim-illuminate`, `mini.nvim`, `vim-auto-save` |
| Dart/Flutter | `dart-vim-plugin`, `flutter-tools.nvim` |
