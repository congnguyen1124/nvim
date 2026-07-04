# Huong dan su dung Neovim hien tai

File nay tong hop tu `init.lua`, `settings/*.vim`, `settings/*.lua`, `lua/custom/*.lua`, cac plugin trong `plugged/` va plugin local trong `local_plugged/`.

Cap nhat: 2026-07-04.

## Ky hieu phim

| Ky hieu | Y nghia |
|---|---|
| `<C-x>` | `Ctrl + x` |
| `<M-x>` | `Alt/Meta + x` |
| `<S-x>` | `Shift + x` |
| `<CR>` | `Enter` |
| `<leader>` | Chua duoc set trong config, nen mac dinh la phim `\` |

Luu y: mot so terminal co the gui `<C-i>` giong phim `Tab`, va co the khong nhan dung `<C-S-i>`.

## Quan ly plugin va config

Config hien tai dung `vim-plug`.

| Lenh | Tac dung |
|---|---|
| `:PlugInstall` | Cai plugin chua co trong `plugged/` |
| `:PlugUpdate` | Cap nhat plugin |
| `:PlugStatus` | Xem trang thai plugin |
| `:PlugClean` | Xoa plugin khong con khai bao |
| `:PlugDiff` | Xem thay doi sau khi update plugin |
| `:PlugUpgrade` | Cap nhat vim-plug |
| `:ReloadConfig` | Load lai `init.lua` |
| `:UpdateRemotePlugins` | Cap nhat remote plugins cua Neovim |

## Plugin dang khai bao

| Nhom | Plugin |
|---|---|
| Theme/UI | `nvim-nightsky`, `onedark.nvim`, `vim-transparent`, `vim-airline`, `vim-airline-themes`, `nvim-web-devicons`, `vim-devicons`, `dressing.nvim` |
| Tim kiem | `fzf`, `fzf.vim`, `telescope.nvim`, `plenary.nvim` |
| File tree | `neo-tree.nvim`, `nui.nvim`, `nerdtree` |
| Terminal | `vim-floaterm` |
| LSP/completion | `coc.nvim`, `coc-jedi`, `coc-ruff` |
| Python/fold | `SimpylFold` |
| Git | `jetgit` (plugin local trong `local_plugged/`, khong qua vim-plug) |
| Comment/code edit | `nerdcommenter`, `vim-commentary`, `auto-pairs`, `emmet-vim`, `vim-illuminate`, `mini.nvim`, `vim-auto-save` |
| Dart/Flutter | `dart-vim-plugin`, `flutter-tools.nvim` |

## Phim tat chung

| Mode | Phim | Tac dung |
|---|---|---|
| Normal | `<M-Right>` | Tang chieu rong split doc |
| Normal | `<M-Left>` | Giam chieu rong split doc |
| Normal | `<M-Down>` | Tang chieu cao split ngang |
| Normal | `<M-Up>` | Giam chieu cao split ngang |
| Normal | `/\` | Xoa highlight tim kiem |
| Normal | `<leader>bd` | Dong buffer hien tai |
| Normal | `:bd` | Duoc viet tat thanh `:BdeleteLeft` |
| Normal | `:bd!` | Duoc viet tat thanh `:BdeleteLeft!` |
| Visual | `//` | Tim chinh xac doan text dang chon |
| Visual | `<C-r>` | Tao lenh substitute voi text dang chon |

## Buffer va tab switcher

| Mode | Phim/lenh | Tac dung |
|---|---|---|
| Normal | `<F3>` | Buffer truoc: `:bprevious` |
| Normal | `<F4>` | Buffer sau: `:bnext` |
| Normal/Insert/Visual | `<C-i>` | Mo popup chuyen buffer theo danh sach gan day |
| Normal/Insert/Visual | `<C-S-i>` | Chuyen lui trong popup buffer |
| Command | `:BdeleteLeft` | Dong buffer hien tai va focus buffer truoc |
| Command | `:BdeleteLeft!` | Dong force buffer hien tai va focus buffer truoc |

## Tim file va tim noi dung

### Telescope

| Mode | Phim/lenh | Tac dung |
|---|---|---|
| Normal | `<C-o>` | `:Telescope find_files` |
| Normal | `<C-p>` | `:Telescope live_grep` |
| Command | `:Telescope` | Mo picker Telescope |
| Command | `:Telescope find_files` | Tim file |
| Command | `:Telescope live_grep` | Tim text trong project |
| Command | `:Telescope buffers` | Tim buffer |
| Command | `:Telescope help_tags` | Tim help tag |
| Command | `:Telescope commands` | Tim command |

### FZF

| Mode | Phim/lenh | Tac dung |
|---|---|---|
| Normal/Visual/Operator | `<F6>` | `:Files` |
| Normal/Visual/Operator | `<F7>` | `:Rg` |
| Command | `:Files [dir]` | Tim file bang FZF, co preview |
| Command | `:Rg [query]` | Tim text bang `rg` va FZF |
| Command | `:Buffers` | Tim buffer |
| Command | `:Lines` | Tim line trong buffer dang mo |
| Command | `:BLines` | Tim line trong buffer hien tai |
| Command | `:History` | Tim history |
| Command | `:Commands` | Tim command |
| Command | `:Maps` | Tim keymap |
| Command | `:GFiles` | Tim file trong git |
| Command | `:Commits` | Tim commit |
| Command | `:BCommits` | Tim commit lien quan buffer hien tai |

Trong cua so FZF:

| Phim | Tac dung |
|---|---|
| `Ctrl-t` | Mo ket qua trong tab moi |
| `Ctrl-x` | Mo ket qua trong split ngang |
| `Ctrl-v` | Mo ket qua trong split doc |
| `Ctrl-/` | Bat/tat preview window |

## File tree

Config hien tai cai ca Neo-tree va NERDTree. Phim tat custom dang uu tien Neo-tree.

### Neo-tree

| Mode | Phim/lenh | Tac dung |
|---|---|---|
| Normal | `<C-B>` | `:Neotree toggle reveal_force_cwd` |
| Trong Neo-tree | `<C-B>` | Dong cua so Neo-tree |
| Command | `:Neotree` | Mo Neo-tree |
| Command | `:Neotree toggle` | Bat/tat Neo-tree |
| Command | `:Neotree reveal` | Mo Neo-tree va focus file hien tai |
| Command | `:Neotree filesystem` | Xem filesystem |
| Command | `:Neotree buffers` | Xem buffers |
| Command | `:Neotree git_status` | Xem git status |

### NERDTree

| Lenh | Tac dung |
|---|---|
| `:NERDTree` | Mo NERDTree |
| `:NERDTreeToggle` | Bat/tat NERDTree |
| `:NERDTreeFind` | Tim file hien tai trong tree |
| `:NERDTreeFocus` | Focus vao NERDTree |
| `:NERDTreeClose` | Dong NERDTree |
| `:NERDTreeCWD` | Dat root theo current working directory |
| `:NERDTreeRefreshRoot` | Refresh root |

## Floaterm terminal

Floaterm mac dinh mo o `topright`, rong `0.6`, cao `0.8`. Tren Windows dung shell `powershell -nologo`.

| Mode | Phim/lenh | Tac dung |
|---|---|---|
| Normal/Terminal | `<F9>` | Bat/tat terminal noi |
| Normal/Terminal | `<F8>` | Kill terminal hien tai, sau do chuyen terminal truoc |
| Normal/Terminal | `<leader>tn` | Terminal tiep theo |
| Normal/Terminal | `<leader>tp` | Terminal truoc |
| Normal | `<leader>gl` | Mo `git lg` trong Floaterm rieng |
| Command | `:FloatermNew` | Tao terminal moi |
| Command | `:FloatermNew! [cmd]` | Tao terminal moi va chay command |
| Command | `:FloatermToggle` | Bat/tat terminal |
| Command | `:FloatermShow` | Hien terminal |
| Command | `:FloatermHide` | An terminal |
| Command | `:FloatermNext` | Terminal tiep theo |
| Command | `:FloatermPrev` | Terminal truoc |
| Command | `:FloatermFirst` | Terminal dau |
| Command | `:FloatermLast` | Terminal cuoi |
| Command | `:FloatermKill` | Kill terminal hien tai |
| Command | `:FloatermSend [cmd]` | Gui command vao floaterm |
| Command | `:FloatermUpdate [options]` | Cap nhat kich thuoc/vi tri |

Vi du:

```vim
:FloatermNew lazygit
:FloatermNew --height=0.9 --width=0.8 npm test
:FloatermSend ls
```

## CoC LSP, completion va code action

CoC extensions tu config: `coc-css`, `coc-html`, `coc-json`. Plugin rieng: `coc-jedi`, `coc-ruff`. `coc-settings.json` co language server cho `ccls` va `cmake-language-server`.

### Completion trong Insert mode

| Phim | Tac dung |
|---|---|
| `<Tab>` | Neu popup dang mo: item tiep theo; neu sau con tro la khoang trang: tab; nguoc lai trigger completion |
| `<S-Tab>` | Item truoc trong completion |
| `<CR>` | Confirm item dang chon, hoac xu ly enter qua CoC |
| `<C-Space>` | Trigger completion |
| `<C-f>` | Scroll float/popup xuong, neu co |
| `<C-b>` | Scroll float/popup len, neu co |

### Diagnostics va navigation

| Mode | Phim/lenh | Tac dung |
|---|---|---|
| Normal | `[g` | Diagnostic truoc |
| Normal | `]g` | Diagnostic tiep theo |
| Normal | `gd` | Go to definition, tru file `.cs` |
| Normal | `gy` | Go to type definition |
| Normal | `gi` | Go to implementation |
| Normal | `gr` | Go to references |
| Normal | `K` | Hover documentation |
| Command | `:CocDiagnostics` | Liet ke diagnostics |
| Command | `:CocInfo` | Xem thong tin CoC |
| Command | `:CocRestart` | Restart CoC |
| Command | `:CocConfig` | Mo config CoC |
| Command | `:CocInstall <extension>` | Cai extension CoC |
| Command | `:CocUpdate` | Cap nhat extension CoC |

### Format, rename, action

| Mode | Phim/lenh | Tac dung |
|---|---|---|
| Normal | `<leader>rn` | Rename symbol |
| Visual | `<leader>f` | Format doan dang chon |
| Normal | `<leader>f` + motion | Format theo motion, vi du `<leader>fap` |
| Visual | `<leader>a` | Code action cho doan dang chon |
| Normal | `<leader>a` + motion | Code action theo motion |
| Normal | `<leader>ac` | Code action tai cursor |
| Normal | `<leader>as` | Source action cho buffer |
| Normal | `<leader>qf` | Quickfix tot nhat cho dong hien tai |
| Normal | `<leader>re` | Refactor action tai cursor |
| Visual | `<leader>r` | Refactor doan dang chon |
| Normal | `<leader>r` + motion | Refactor theo motion |
| Normal | `<leader>cl` | Chay Code Lens action |
| Normal/Visual | `<C-s>` | Selection range |
| Command | `:Format` | Format buffer hien tai |
| Command | `:Fold` | Fold bang CoC |
| Command | `:OR` | Organize imports |

### CoC list

Cac phim nay dung phim Space that, khong phai `<leader>`.

| Mode | Phim | Tac dung |
|---|---|---|
| Normal | `<Space>a` | `:CocList diagnostics` |
| Normal | `<Space>e` | `:CocList extensions` |
| Normal | `<Space>c` | `:CocList commands` |
| Normal | `<Space>o` | `:CocList outline` |
| Normal | `<Space>s` | `:CocList -I symbols` |
| Normal | `<Space>j` | `:CocNext` |
| Normal | `<Space>k` | `:CocPrev` |
| Normal | `<Space>p` | `:CocListResume` |

### CoC text objects

| Mode | Phim | Tac dung |
|---|---|---|
| Visual/Operator | `if` | Inner function |
| Visual/Operator | `af` | Around function |
| Visual/Operator | `ic` | Inner class |
| Visual/Operator | `ac` | Around class |

## Git (JetGit - plugin local kieu JetBrains)

Plugin local o `local_plugged/jetgit/`, keymap o `settings/git.lua`. Mo phong git UI cua JetBrains IDE: gutter mark cho dong thay doi, rollback line, Git tool window (Local Changes + Log), diff viewer va 3-way merge de resolve conflict. Branch hien tai hien o airline section b.

### Gutter marks va rollback line

Dong them = `┃` xanh la, dong sua = `┃` xanh duong, dong xoa = `▁` do (giong mau JetBrains).

| Mode | Phim/lenh | Tac dung |
|---|---|---|
| Normal | `<M-z>` hoac `<leader>gr` | Rollback thay doi tai cursor (JetBrains: `Ctrl+Alt+Z`) |
| Visual | `<M-z>` hoac `<leader>gr` | Rollback cac dong dang chon |
| Normal | `<leader>gp` | Preview thay doi tai cursor (float) |
| Normal | `]c` / `[c` | Den thay doi tiep theo / truoc (giu nguyen y nghia cu trong diff mode) |
| Command | `:JetGitRollback` | Rollback (nhan range, vi du `:10,20JetGitRollback`) |
| Command | `:JetGitPreviewHunk` | Preview hunk |
| Command | `:JetGitNextHunk` / `:JetGitPrevHunk` | Nhay giua cac hunk |
| Command | `:JetGitRefresh` | Refresh gutter marks va panel |

### Git tool window (Local Changes + Log)

| Mode | Phim/lenh | Tac dung |
|---|---|---|
| Normal | `<M-9>` hoac `<leader>gg` | Bat/tat Git tool window (JetBrains: `Alt+9`) |
| Normal | `<leader>gL` | Mo panel o section Log |
| Command | `:JetGit` | Toggle panel |
| Command | `:JetGitLog` | Mo panel o section Log |

Phim trong panel (nhan `?` de xem help):

| Phim | Tac dung |
|---|---|
| `Tab` | Chuyen giua Local Changes va Log |
| `Enter` | Local Changes: mo diff cua file / Log: xem commit (stat + patch) |
| `o` | Mo file trong editor |
| `s` | Stage/unstage file (voi conflict: danh dau da resolve) |
| `a` | Stage tat ca (`git add -A`) |
| `r` | Rollback file ve HEAD (file untracked: hoi xoa) |
| `m` | Mo 3-way merge view cho file conflict |
| `c` / `C` | Commit / amend commit truoc |
| `P` | Push |
| `u` | Pull (update project) |
| `f` | Fetch --all |
| `y` | Log: yank hash cua commit |
| `R` | Refresh |
| `q` | Dong panel |

### Diff viewer

| Mode | Phim/lenh | Tac dung |
|---|---|---|
| Normal | `<M-d>` hoac `<leader>gd` | Diff file hien tai voi index, mo tab moi (JetBrains: `Ctrl+D`) |
| Command | `:JetGitDiff` | Nhu tren |
| Trong tab diff | `q` | Dong tab diff (nhan tren buffer ben trai) |

File staged trong panel duoc diff HEAD vs index. File untracked duoc diff voi noi dung rong. Ben phai la file that, sua truc tiep duoc.

### Commit, push, pull

| Mode | Phim/lenh | Tac dung |
|---|---|---|
| Normal | `<M-k>` hoac `<leader>gc` | Commit, nhap message qua prompt (JetBrains: `Ctrl+K`) |
| Normal | `<leader>gP` | Push |
| Normal | `<leader>gu` | Pull |
| Normal | `<leader>gf` | Fetch --all |
| Command | `:JetGitCommit` / `:JetGitCommit!` | Commit / amend |
| Command | `:JetGitPush` / `:JetGitPull` / `:JetGitFetch` | Push / pull / fetch (chay async) |

Neu chua stage gi, commit se hoi co stage all khong.

### Resolve conflict (3-way merge)

| Mode | Phim/lenh | Tac dung |
|---|---|---|
| Normal | `<leader>gm` | Mo merge view cho file conflict hien tai: LOCAL \| RESULT \| REMOTE |
| Command | `:JetGitMerge` | Nhu tren |

Trong buffer RESULT (o giua) va trong file co conflict marker:

| Phim | Tac dung |
|---|---|
| `<leader>co` | Accept yours (phan cua ban) |
| `<leader>ct` | Accept theirs (phan cua nhanh kia) |
| `<leader>cb` | Accept ca hai |
| `]x` / `[x` | Den conflict tiep theo / truoc |
| `<leader>cd` | Xong: luu file, `git add`, dong tab merge |
| `q` | Dong tab merge (nhan tren buffer LOCAL/REMOTE) |

## Comment code

Config cai ca `vim-commentary` va `nerdcommenter`.

### vim-commentary

| Mode | Phim/lenh | Tac dung |
|---|---|---|
| Normal | `gcc` | Toggle comment dong hien tai |
| Normal | `gc` + motion | Toggle comment theo motion, vi du `gcap` |
| Visual | `gc` | Toggle comment doan dang chon |
| Command | `:Commentary` | Comment/uncomment range |

### NERDCommenter

Vi `<leader>` la `\`, vi du `<leader>cc` nghia la `\cc`.

| Mode | Phim | Tac dung |
|---|---|---|
| Normal/Visual | `<leader>cc` | Comment |
| Normal/Visual | `<leader>cu` | Uncomment |
| Normal/Visual | `<leader>c<Space>` | Toggle comment |
| Normal/Visual | `<leader>cm` | Minimal comment |
| Normal/Visual | `<leader>ci` | Invert comment |
| Normal/Visual | `<leader>cs` | Sexy/multiline comment |
| Normal/Visual | `<leader>cy` | Comment va yank |
| Normal | `<leader>c$` | Comment toi cuoi dong |
| Normal | `<leader>cA` | Append comment o cuoi dong |
| Normal/Visual | `<leader>cl` | Align left |
| Normal/Visual | `<leader>cb` | Align both |
| Normal | `<leader>ca` | Doi alternate delimiters |

## Emmet

| Mode | Phim/lenh | Tac dung |
|---|---|---|
| Insert/Normal/Visual | `<C-y>,` | Expand abbreviation |
| Insert/Normal | `<C-y>;` | Expand word |
| Insert/Normal/Visual | `<C-y>d` | Balance tag inward |
| Insert/Normal/Visual | `<C-y>D` | Balance tag outward |
| Insert/Normal | `<C-y>u` | Update tag |
| Insert/Normal | `<C-y>n` | Move next edit point |
| Insert/Normal | `<C-y>N` | Move previous edit point |
| Insert/Normal | `<C-y>i` | Lay kich thuoc image |
| Insert/Normal | `<C-y>I` | Encode image |
| Insert/Normal | `<C-y>/` | Toggle comment HTML/CSS |
| Insert/Normal | `<C-y>j` | Split/join tag |
| Insert/Normal | `<C-y>k` | Remove tag |
| Insert/Normal | `<C-y>a` | Anchorize URL |
| Insert/Normal | `<C-y>A` | Anchorize summary |
| Insert/Normal | `<C-y>m` | Merge lines |
| Visual | `<C-y>c` | Code pretty |
| Command | `:Emmet <abbr>` | Expand abbreviation bang command |
| Command | `:EmmetInstall` | Cai Emmet mapping vao buffer/mode hien tai |

## Minimap va highlight symbol

| Mode | Phim/lenh | Tac dung |
|---|---|---|
| Normal | `<leader>mm` | Toggle minimap (`mini.map`) |
| Command | `:IlluminateToggle` | Bat/tat illuminate |
| Command | `:IlluminatePause` | Tam dung illuminate |
| Command | `:IlluminateResume` | Tiep tuc illuminate |
| Command | `:IlluminateToggleBuf` | Bat/tat illuminate cho buffer hien tai |
| Command | `:IlluminatePauseBuf` | Tam dung illuminate cho buffer hien tai |
| Command | `:IlluminateResumeBuf` | Tiep tuc illuminate cho buffer hien tai |

Minimap tu dong an voi buffer qua ngan, buffer dac biet, `nerdtree`, `gitcommit`, `startuptime`.

## Auto-pairs, auto-save va fold

| Lenh/chuc nang | Tac dung |
|---|---|
| `auto-pairs` | Tu dong chen cap ngoac/nhay trong Insert mode |
| `vim-auto-save` | Dang bat san: `g:auto_save = 1`, silent mode |
| `:AutoSaveToggle` | Bat/tat auto-save |
| `SimpylFold` | Ho tro fold Python |
| `:SimpylFoldDocstrings` | Toggle fold docstrings Python |
| `:SimpylFoldImports` | Toggle fold imports Python |
| `zc` | Dong fold, phim mac dinh Vim |
| `zo` | Mo fold, phim mac dinh Vim |
| `za` | Toggle fold, phim mac dinh Vim |

## Theme, statusline va UI

| Lenh | Tac dung |
|---|---|
| `:colorscheme onedark` | Theme dang dung |
| `:colorscheme nightsky` | Doi sang nightsky neu muon |
| `:TransparentToggle` | Bat/tat transparent background |
| `:TransparentEnable` | Bat transparent |
| `:TransparentDisable` | Tat transparent |
| `:AirlineTheme <theme>` | Doi theme airline |
| `:AirlineRefresh` | Refresh airline |
| `:AirlineToggle` | Bat/tat airline |
| `:AirlineToggleWhitespace` | Bat/tat whitespace extension |
| `:AirlineExtensions` | Xem extension airline |

Airline hien dang dung theme `onedark`, co tabline, ten tab hien theo ten file.

## Dart va Flutter

`flutter-tools.nvim` duoc setup trong `init.lua`, nhung plugin nay chi tao cac command sau khi ban mo file `*.dart` hoac `pubspec.yaml`.

| Lenh | Tac dung |
|---|---|
| `:FlutterRun` | Chay project Flutter |
| `:FlutterDebug` | Chay debug mode |
| `:FlutterVisualDebug` | Bat/tat visual debug |
| `:FlutterDevices` | Chon device |
| `:FlutterEmulators` | Chon emulator |
| `:FlutterReload` | Hot reload |
| `:FlutterRestart` | Restart app |
| `:FlutterQuit` | Dung session |
| `:FlutterAttach` | Attach vao app dang chay |
| `:FlutterDetach` | Detach nhung giu app chay |
| `:FlutterOutlineToggle` | Bat/tat Flutter outline |
| `:FlutterOutlineOpen` | Mo Flutter outline |
| `:FlutterDevTools` | Chay Dart DevTools |
| `:FlutterDevToolsActivate` | Activate DevTools |
| `:FlutterOpenDevTools` | Mo DevTools |
| `:FlutterCopyProfilerUrl` | Copy profiler URL |
| `:FlutterPubGet` | Chay `flutter pub get` |
| `:FlutterPubUpgrade` | Chay `flutter pub upgrade` |
| `:FlutterLspRestart` | Restart Dart LSP |
| `:FlutterSuper` | Di toi super class/method |
| `:FlutterReanalyze` | Yeu cau Dart LSP reanalyze |
| `:FlutterRename` | Rename va update imports |
| `:FlutterLogToggle` | Bat/tat log buffer |
| `:FlutterLogClear` | Xoa log buffer |

## Cac plugin khong can phim rieng

| Plugin | Ghi chu |
|---|---|
| `nvim-web-devicons`, `vim-devicons` | Cung cap icon cho tree/statusline/plugin khac |
| `plenary.nvim`, `nui.nvim` | Thu vien phu thuoc cho Telescope/Neo-tree/plugin Lua |
| `dressing.nvim` | Cai thien UI input/select cua Neovim |
| `dart-vim-plugin` | Filetype/syntax/indent cho Dart |

## Lenh tu kiem tra trong Neovim

| Lenh | Tac dung |
|---|---|
| `:map` | Xem tat ca mapping |
| `:nmap` | Xem normal mappings |
| `:imap` | Xem insert mappings |
| `:vmap` | Xem visual mappings |
| `:verbose map <phim>` | Xem mapping do file/plugin nao tao |
| `:command` | Xem tat ca command |
| `:checkhealth` | Kiem tra suc khoe Neovim/plugin |
| `:messages` | Xem log thong bao |

## Ghi chu ve config hien tai

- `settings/vista.vim` chi con noi dung comment va plugin `vista.vim` khong duoc khai bao trong `init.lua`, nen khong dua vao danh sach lenh su dung chinh.
- Config vua co Neo-tree vua co NERDTree. Nen dung Neo-tree voi `<C-B>` neu khong co nhu cau rieng voi NERDTree.
- Config vua co `vim-commentary` vua co `NERDCommenter`. Nen dung `gcc`/`gc` cho nhanh; dung NERDCommenter khi can cac kieu comment nang cao.
- `<leader>` dang la `\`. Neu muon doi thanh Space, them `vim.g.mapleader = ' '` truoc khi khai bao keymap/plugin.
- Git plugin cu (`vim-fugitive`, `vim-rhubarb`, `vim-gitgutter`, `vim-mergetool`) da bi xoa, thay bang plugin local `jetgit` trong `local_plugged/` (khong quan ly boi vim-plug, duoc them vao runtimepath trong `init.lua`).
