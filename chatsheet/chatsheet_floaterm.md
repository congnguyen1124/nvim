# Terminal Floaterm

Floaterm mặc định mở ở `topright`, rộng `0.6`, cao `0.8`. Trên Windows dùng shell `powershell -nologo`.

| Chế độ | Phím/lệnh | Tác dụng |
|---|---|---|
| Normal/Terminal | `<F9>` | Bật/tắt terminal nổi |
| Normal/Terminal | `<F8>` | Dừng terminal hiện tại, sau đó chuyển về terminal trước |
| Normal/Terminal | `<leader>tn` | Terminal tiếp theo |
| Normal/Terminal | `<leader>tp` | Terminal trước |
| Normal | `<leader>gl` | Mở `git lg` trong Floaterm riêng |
| Command | `:FloatermNew` | Tạo terminal mới |
| Command | `:FloatermNew! [cmd]` | Tạo terminal mới và chạy command |
| Command | `:FloatermToggle` | Bật/tắt terminal |
| Command | `:FloatermShow` | Hiện terminal |
| Command | `:FloatermHide` | Ẩn terminal |
| Command | `:FloatermNext` | Terminal tiếp theo |
| Command | `:FloatermPrev` | Terminal trước |
| Command | `:FloatermFirst` | Terminal đầu tiên |
| Command | `:FloatermLast` | Terminal cuối cùng |
| Command | `:FloatermKill` | Dừng terminal hiện tại |
| Command | `:FloatermSend [cmd]` | Gửi command vào Floaterm |
| Command | `:FloatermUpdate [options]` | Cập nhật kích thước/vị trí |

Ví dụ:

```vim
:FloatermNew lazygit
:FloatermNew --height=0.9 --width=0.8 npm test
:FloatermSend ls
```
