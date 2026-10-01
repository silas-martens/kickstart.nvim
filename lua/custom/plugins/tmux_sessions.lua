local original_by_buf = {}

local function tmux(args)
  local output = vim.fn.system(vim.list_extend({ 'tmux' }, args))
  if vim.v.shell_error ~= 0 then
    error(vim.trim(output))
  end
  return output
end

local function list_sessions()
  local output = vim.fn.system({ 'tmux', 'list-sessions', '-F', '#{session_name}' })
  if vim.v.shell_error ~= 0 then
    return {}
  end
  return vim.split(output, '\n', { trimempty = true })
end

local function diff_sessions(old, new)
  local old_set, new_set = {}, {}
  for _, s in ipairs(old) do old_set[s] = true end
  for _, s in ipairs(new) do new_set[s] = true end

  local deletes = vim.tbl_filter(function(s) return not new_set[s] end, old)
  local creates = vim.tbl_filter(function(s) return not old_set[s] end, new)
  local renames = {}
  for i = 1, math.min(#deletes, #creates) do
    renames[i] = { from = deletes[i], to = creates[i] }
  end
  return renames,
    vim.list_slice(deletes, #renames + 1),
    vim.list_slice(creates, #renames + 1)
end

local function buf_lines(bufnr)
  local seen, result = {}, {}
  for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    line = vim.trim(line)
    if line ~= '' and not seen[line] then
      seen[line] = true
      table.insert(result, line)
    end
  end
  return result
end

local function apply_changes(bufnr)
  local old = original_by_buf[bufnr]
  if not old then
    return false
  end

  local renames, deletes, creates = diff_sessions(old, buf_lines(bufnr))

  local ok, err = pcall(function()
    for _, name in ipairs(deletes) do
      tmux({ 'kill-session', '-t', name })
    end
    for _, r in ipairs(renames) do
      tmux({ 'rename-session', '-t', r.from, r.to })
    end
    for _, name in ipairs(creates) do
      tmux({ 'new-session', '-d', '-s', name })
    end
  end)

  if not ok then
    vim.notify('Tmux session update failed: ' .. err, vim.log.levels.ERROR)
    return false
  end

  local refreshed = list_sessions()
  original_by_buf[bufnr] = refreshed
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, refreshed)
  vim.bo[bufnr].modified = false
  vim.notify('Tmux sessions updated', vim.log.levels.INFO)
  return true
end

local function switch_to_session(quit_all)
  local name = vim.trim(vim.api.nvim_get_current_line())
  if name == '' then
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].modified and not apply_changes(bufnr) then
    return
  end

  local ok, err = pcall(function()
    tmux({ 'has-session', '-t', name })
    if vim.env.TMUX then
      tmux({ 'switch-client', '-t', name })
    else
      vim.cmd('silent !tmux attach -t ' .. vim.fn.shellescape(name))
    end
  end)

  if not ok then
    vim.notify('Failed to switch tmux session: ' .. err, vim.log.levels.ERROR)
    return
  end

  vim.cmd(quit_all and 'wqa' or 'q')
end

local function open_tmux_sessions()
  if vim.fn.executable 'tmux' ~= 1 then
    vim.notify('tmux not found', vim.log.levels.ERROR)
    return
  end

  vim.cmd 'enew'
  local bufnr = vim.api.nvim_get_current_buf()

  vim.bo[bufnr].buftype = 'acwrite'
  vim.bo[bufnr].bufhidden = 'wipe'
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].filetype = 'tmuxsessions'
  vim.api.nvim_buf_set_name(bufnr, 'tmux-sessions://manager')

  local sessions = list_sessions()
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, sessions)
  original_by_buf[bufnr] = sessions

  vim.api.nvim_create_autocmd('BufWriteCmd', {
    buffer = bufnr,
    callback = function() apply_changes(bufnr) end,
  })

  local function buf_keymap(lhs, rhs, desc)
    vim.keymap.set('n', lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
  end
  buf_keymap('q', '<cmd>bd!<CR>', 'Close tmux sessions buffer')
  buf_keymap('<CR>', function() switch_to_session(false) end, 'Switch to tmux session')
  buf_keymap('<C-CR>', function() switch_to_session(true) end, 'Switch to tmux session and quit all')

  vim.notify('Edit lines and :w to create/rename/delete tmux sessions', vim.log.levels.INFO)
end

vim.api.nvim_create_user_command('TmuxSessions', open_tmux_sessions, { desc = 'Edit tmux sessions in a writable buffer' })
vim.keymap.set('n', '<leader>ts', '<cmd>TmuxSessions<CR>', { desc = '[T]mux [S]essions' })

return {}
