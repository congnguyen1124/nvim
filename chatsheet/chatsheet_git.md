# Git với JetGit

Plugin cục bộ nằm tại `local_plugged/jetgit/`, keymap nằm tại `settings/git.lua`. Plugin mô phỏng giao diện Git của JetBrains IDE: gutter mark cho dòng thay đổi, hoàn tác dòng, cửa sổ công cụ Git (Local Changes + Log), trình xem diff và merge 3 chiều để xử lý xung đột. Nhánh hiện tại được hiển thị ở section b của Airline.

## Gutter mark và hoàn tác dòng

Dòng thêm = `┃` xanh lá, dòng sửa = `┃` xanh dương, dòng xóa = `▁` đỏ (giống màu JetBrains).

| Chế độ | Phím/lệnh | Tác dụng |
|---|---|---|
| Normal | `<M-z>` hoặc `<leader>gr` | Hoàn tác thay đổi tại con trỏ (JetBrains: `Ctrl+Alt+Z`) |
| Visual | `<M-z>` hoặc `<leader>gr` | Hoàn tác các dòng đang chọn |
| Normal | `<leader>gp` | Xem trước thay đổi tại con trỏ (float) |
| Normal | `]c` / `[c` | Đi tới thay đổi tiếp theo / trước đó (giữ nguyên ý nghĩa cũ trong diff mode) |
| Command | `:JetGitRollback` | Hoàn tác (nhận range, ví dụ `:10,20JetGitRollback`) |
| Command | `:JetGitPreviewHunk` | Xem trước hunk |
| Command | `:JetGitNextHunk` / `:JetGitPrevHunk` | Nhảy giữa các hunk |
| Command | `:JetGitRefresh` | Làm mới gutter mark và panel |

## Cửa sổ công cụ Git (Local Changes + Log)

| Chế độ | Phím/lệnh | Tác dụng |
|---|---|---|
| Normal | `<M-9>` hoặc `<leader>gg` | Bật/tắt cửa sổ công cụ Git (JetBrains: `Alt+9`) |
| Normal | `<leader>gL` | Mở panel tại section Log |
| Command | `:JetGit` | Bật/tắt panel |
| Command | `:JetGitLog` | Mở panel tại section Log |

Các phím trong panel (nhấn `?` để xem trợ giúp):

| Phím | Tác dụng |
|---|---|
| `Tab` | Chuyển giữa Local Changes và Log |
| `Enter` | Local Changes: mở diff của file / Log: xem commit (stat + patch) |
| `o` | Mở file trong editor |
| `s` | Stage/unstage file (với conflict: đánh dấu đã xử lý) |
| `a` | Stage tất cả (`git add -A`) |
| `r` | Hoàn tác file về HEAD (với file untracked: hỏi trước khi xóa) |
| `m` | Mở merge 3 chiều cho file bị conflict |
| `c` / `C` | Commit / amend commit trước |
| `P` | Push |
| `u` | Pull (cập nhật project) |
| `f` | Fetch --all |
| `y` | Log: sao chép hash của commit |
| `R` | Làm mới |
| `q` | Đóng panel |

## Trình xem diff

| Chế độ | Phím/lệnh | Tác dụng |
|---|---|---|
| Normal | `<M-d>` hoặc `<leader>gd` | So sánh file hiện tại với index, mở trong tab mới (JetBrains: `Ctrl+D`) |
| Command | `:JetGitDiff` | Tương tự lệnh trên |
| Trong tab diff | `q` | Đóng tab diff (nhấn trong buffer bên trái) |

File đã stage trong panel được so sánh giữa HEAD và index. File untracked được so sánh với nội dung rỗng. Bên phải là file thật và có thể chỉnh sửa trực tiếp.

## Commit, push và pull

| Chế độ | Phím/lệnh | Tác dụng |
|---|---|---|
| Normal | `<M-k>` hoặc `<leader>gc` | Commit, nhập message qua prompt (JetBrains: `Ctrl+K`) |
| Normal | `<leader>gP` | Push |
| Normal | `<leader>gu` | Pull |
| Normal | `<leader>gf` | Fetch --all |
| Command | `:JetGitCommit` / `:JetGitCommit!` | Commit / amend |
| Command | `:JetGitPush` / `:JetGitPull` / `:JetGitFetch` | Push / pull / fetch (chạy bất đồng bộ) |

Nếu chưa stage gì, khi commit sẽ hỏi có stage tất cả hay không.

## Xử lý conflict (merge 3 chiều)

| Chế độ | Phím/lệnh | Tác dụng |
|---|---|---|
| Normal | `<leader>gm` | Mở merge view cho file conflict hiện tại: LOCAL \| RESULT \| REMOTE |
| Command | `:JetGitMerge` | Tương tự lệnh trên |

Trong buffer RESULT (ở giữa) và trong file có conflict marker:

| Phím | Tác dụng |
|---|---|
| `<leader>co` | Chấp nhận phần của bạn |
| `<leader>ct` | Chấp nhận phần của nhánh kia |
| `<leader>cb` | Chấp nhận cả hai phần |
| `]x` / `[x` | Đi tới conflict tiếp theo / trước đó |
| `<leader>cd` | Hoàn tất: lưu file, chạy `git add`, đóng tab merge |
| `q` | Đóng tab merge (nhấn trong buffer LOCAL/REMOTE) |
