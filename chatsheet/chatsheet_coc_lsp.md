# CoC LSP, completion và code action

Các extension CoC trong config: `coc-css`, `coc-html`, `coc-json`. Plugin riêng: `coc-jedi`, `coc-ruff`. File `coc-settings.json` có language server cho `ccls` và `cmake-language-server`.

## Completion trong Insert mode

| Phím | Tác dụng |
|---|---|
| `<Tab>` | Nếu popup đang mở: chọn mục tiếp theo; nếu sau con trỏ là khoảng trắng: chèn tab; ngược lại kích hoạt completion |
| `<S-Tab>` | Chọn mục trước trong completion |
| `<CR>` | Xác nhận mục đang chọn, hoặc xử lý Enter qua CoC |
| `<C-Space>` | Kích hoạt completion |
| `<C-f>` | Cuộn float/popup xuống, nếu có |
| `<C-b>` | Cuộn float/popup lên, nếu có |

## Diagnostics và điều hướng

| Chế độ | Phím/lệnh | Tác dụng |
|---|---|---|
| Normal | `[g` | Diagnostic trước |
| Normal | `]g` | Diagnostic tiếp theo |
| Normal | `gd` | Đi tới definition, trừ file `.cs` |
| Normal | `gy` | Đi tới type definition |
| Normal | `gi` | Đi tới implementation |
| Normal | `gr` | Đi tới references |
| Normal | `K` | Hiện tài liệu tại con trỏ |
| Command | `:CocDiagnostics` | Liệt kê diagnostics |
| Command | `:CocInfo` | Xem thông tin CoC |
| Command | `:CocRestart` | Khởi động lại CoC |
| Command | `:CocConfig` | Mở config CoC |
| Command | `:CocInstall <extension>` | Cài extension CoC |
| Command | `:CocUpdate` | Cập nhật extension CoC |

## Format, đổi tên và action

| Chế độ | Phím/lệnh | Tác dụng |
|---|---|---|
| Normal | `<leader>rn` | Đổi tên symbol |
| Visual | `<leader>f` | Format đoạn đang chọn |
| Normal | `<leader>f` + motion | Format theo motion, ví dụ `<leader>fap` |
| Visual | `<leader>a` | Code action cho đoạn đang chọn |
| Normal | `<leader>a` + motion | Code action theo motion |
| Normal | `<leader>ac` | Code action tại con trỏ |
| Normal | `<leader>as` | Source action cho buffer |
| Normal | `<leader>qf` | Quickfix tốt nhất cho dòng hiện tại |
| Normal | `<leader>re` | Refactor action tại con trỏ |
| Visual | `<leader>r` | Refactor đoạn đang chọn |
| Normal | `<leader>r` + motion | Refactor theo motion |
| Normal | `<leader>cl` | Chạy Code Lens action |
| Normal/Visual | `<C-s>` | Mở rộng/thu hẹp vùng chọn |
| Command | `:Format` | Format buffer hiện tại |
| Command | `:Fold` | Fold bằng CoC |
| Command | `:OR` | Sắp xếp imports |

## Danh sách CoC

Các phím này dùng phím Space thật, không phải `<leader>`.

| Chế độ | Phím | Tác dụng |
|---|---|---|
| Normal | `<Space>a` | `:CocList diagnostics` |
| Normal | `<Space>e` | `:CocList extensions` |
| Normal | `<Space>c` | `:CocList commands` |
| Normal | `<Space>o` | `:CocList outline` |
| Normal | `<Space>s` | `:CocList -I symbols` |
| Normal | `<Space>j` | `:CocNext` |
| Normal | `<Space>k` | `:CocPrev` |
| Normal | `<Space>p` | `:CocListResume` |

## Text object của CoC

| Chế độ | Phím | Tác dụng |
|---|---|---|
| Visual/Operator | `if` | Bên trong function |
| Visual/Operator | `af` | Bao quanh function |
| Visual/Operator | `ic` | Bên trong class |
| Visual/Operator | `ac` | Bao quanh class |
