local api = vim.api
local fn = vim.fn

local M = {}

local default_config = {
  close_delay = 700,
  max_visible = 10,
  min_width = 36,
  max_width = 96,
  border = 'rounded',
  keymaps = true,
  modes = { 'n', 'i', 'v' },
  key_forward = '<C-i>',
  key_backward = '<C-S-i>',
}

local cleanup_group = api.nvim_create_augroup('TabSwitcherCleanup', { clear = true })

local state = {
  buf = nil,
  win = nil,
  timer = nil,
  items = {},
  index = 1,
  top = 1,
  active = false,
  config = vim.deepcopy(default_config),
  ns = api.nvim_create_namespace('TabSwitcher'),
}

local function ensure_buf()
  if state.buf and api.nvim_buf_is_valid(state.buf) then
    return
  end
  state.buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_option(state.buf, 'bufhidden', 'wipe')
  api.nvim_buf_set_option(state.buf, 'filetype', 'TabSwitcher')
end

local function stop_timer()
  if state.timer then
    state.timer:stop()
  end
end

local function ensure_timer()
  if not state.timer then
    state.timer = vim.loop.new_timer()
  end
end

local function dispose_timer()
  if state.timer then
    state.timer:stop()
    state.timer:close()
    state.timer = nil
  end
end

local function close_window()
  stop_timer()
  if state.win and api.nvim_win_is_valid(state.win) then
    api.nvim_win_close(state.win, true)
  end
  if state.buf and api.nvim_buf_is_valid(state.buf) then
    pcall(api.nvim_buf_delete, state.buf, { force = true })
  end
  state.win = nil
  state.buf = nil
  state.active = false
end

local function reset_positions()
  state.items = {}
  state.index = 1
  state.top = 1
end

local function collect_items()
  local buffers = fn.getbufinfo({ buflisted = 1 })
  if #buffers == 0 then
    return {}
  end

  table.sort(buffers, function(a, b)
    return (a.lastused or 0) > (b.lastused or 0)
  end)

  local items = {}
  for idx, buf in ipairs(buffers) do
    local filename = buf.name ~= '' and fn.fnamemodify(buf.name, ':t') or '[No Name]'
    local dir = ''
    if buf.name ~= '' then
      dir = fn.fnamemodify(buf.name, ':~:.:h')
      if dir == '.' then
        dir = ''
      end
    end
    local modified = buf.changed == 1 and ' [+]' or ''
    local suffix = dir ~= '' and ('  •  ' .. dir) or ''
    local text = string.format('%2d  %s%s%s', idx, filename, modified, suffix)
    table.insert(items, { bufnr = buf.bufnr, text = text })
  end

  return items
end

local function open_window(width, height)
  ensure_buf()
  local row = math.floor((vim.o.lines - height) / 2 - 1)
  local col = math.floor((vim.o.columns - width) / 2)
  row = math.max(row, 0)
  col = math.max(col, 0)

  local cfg = {
    relative = 'editor',
    style = 'minimal',
    width = width,
    height = height,
    row = row,
    col = col,
    border = state.config.border,
  }

  if state.win and api.nvim_win_is_valid(state.win) then
    api.nvim_win_set_config(state.win, cfg)
  else
    state.win = api.nvim_open_win(state.buf, false, cfg)
    api.nvim_win_set_option(state.win, 'winhl', 'Normal:NormalFloat,FloatBorder:FloatBorder')
  end
  state.active = true
end

local function render()
  local total = #state.items
  if total == 0 then
    M.cancel()
    return
  end

  local width = state.config.min_width
  for _, item in ipairs(state.items) do
    width = math.max(width, fn.strdisplaywidth(item.text) + 4)
  end
  width = math.min(width, state.config.max_width)

  local capacity = math.min(total, state.config.max_visible)
  if state.index < state.top then
    state.top = state.index
  elseif state.index > state.top + capacity - 1 then
    state.top = state.index - capacity + 1
  end

  local lines, visible = {}, {}
  for i = state.top, math.min(total, state.top + capacity - 1) do
    table.insert(lines, state.items[i].text)
    table.insert(visible, i)
  end

  open_window(width, #lines)
  api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
  api.nvim_buf_clear_namespace(state.buf, state.ns, 0, -1)

  for row_idx, idx in ipairs(visible) do
    local hl = idx == state.index and 'TabLineSel' or 'Normal'
    api.nvim_buf_add_highlight(state.buf, state.ns, hl, row_idx - 1, 0, -1)
  end
end

local function schedule_close()
  ensure_timer()
  state.timer:stop()
  state.timer:start(state.config.close_delay, 0, vim.schedule_wrap(function()
    M.confirm()
  end))
end

function M.cycle(direction)
  direction = direction or 1
  state.items = collect_items()
  local total = #state.items
  if total == 0 then
    return
  end

  if not state.active then
    state.index = 1
    state.top = 1
  end

  state.index = ((state.index - 1 + direction) % total) + 1
  render()
  schedule_close()
end

function M.confirm()
  if not state.active then
    return
  end
  local target = state.items[state.index]
  close_window()
  if target and api.nvim_buf_is_valid(target.bufnr) then
    vim.cmd('buffer ' .. target.bufnr)
  end
  reset_positions()
end

function M.cancel()
  if not state.active then
    return
  end
  close_window()
  reset_positions()
end

function M.setup(opts)
  opts = opts or {}
  state.config = vim.tbl_deep_extend('force', vim.deepcopy(default_config), opts)

  api.nvim_clear_autocmds({ group = cleanup_group })
  api.nvim_create_autocmd('VimLeavePre', {
    group = cleanup_group,
    callback = dispose_timer,
  })

  if not state.config.keymaps then
    return
  end

  local modes = state.config.modes or default_config.modes
  local forward = state.config.key_forward or default_config.key_forward
  local backward = state.config.key_backward or default_config.key_backward

  if forward and forward ~= '' then
    vim.keymap.set(modes, forward, function()
      require('custom.tab_switcher').cycle(1)
    end, { silent = true, desc = 'Tab switcher forward' })
  end

  if backward and backward ~= '' then
    vim.keymap.set(modes, backward, function()
      require('custom.tab_switcher').cycle(-1)
    end, { silent = true, desc = 'Tab switcher backward' })
  end
end

return M
