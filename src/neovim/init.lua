-- Gitlinker.nvim - Generate URLs for Git repository lines
-- Minimal Neovim integration for gitlinker CLI

local M = {}

-- Detect clipboard command
local function get_clipboard_cmd()
  if vim.fn.has("mac") == 1 then
    return "pbcopy"
  elseif vim.fn.executable("xsel") == 1 then
    return "xsel --input --clipboard"
  elseif vim.fn.executable("xclip") == 1 then
    return "xclip -in -selection clipboard"
  elseif vim.fn.executable("wl-copy") == 1 then
    return "wl-copy"
  elseif vim.fn.executable("clip.exe") == 1 then
    return "clip.exe"
  end
  return nil
end

-- Detect open command
local function get_open_cmd()
  if vim.fn.has("mac") == 1 then
    return "open"
  elseif vim.fn.executable("xdg-open") == 1 then
    return "xdg-open"
  elseif vim.fn.executable("wslview") == 1 then
    return "wslview"
  elseif vim.fn.executable("cmd.exe") == 1 then
    return 'cmd.exe /C start ""'
  end
  return nil
end

-- Copy text to clipboard
local function copy_to_clipboard(text)
  local cmd = get_clipboard_cmd()
  if not cmd then
    vim.notify("No clipboard command found", vim.log.levels.ERROR)
    return false
  end

  local handle = io.popen(cmd, "w")
  if handle then
    handle:write(text)
    handle:close()
    return true
  end
  return false
end

-- Open URL in browser
local function open_in_browser(url)
  local cmd = get_open_cmd()
  if not cmd then
    return false
  end

  vim.fn.jobstart(cmd .. " " .. vim.fn.shellescape(url), { detach = true })
  return true
end

-- Generate gitlinker URL
local function generate_url(start_line, end_line)
  local file = vim.fn.expand("%:p")

  if file == "" then
    vim.notify("No file in buffer", vim.log.levels.ERROR)
    return nil
  end

  local cmd = string.format("gitlinker run -f %s -s %d -e %d",
    vim.fn.shellescape(file), start_line, end_line)

  local handle = io.popen(cmd)
  if not handle then
    vim.notify("Failed to execute gitlinker", vim.log.levels.ERROR)
    return nil
  end

  local url = handle:read("*a"):gsub("%s+$", "")
  handle:close()

  if url:match("^https?://") then
    return url
  end

  return nil
end

-- Copy permalink to clipboard
function M.copy()
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")

  -- Ensure start <= end
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  local url = generate_url(start_line, end_line)

  if not url then
    vim.notify("Failed to generate permalink", vim.log.levels.ERROR)
    return
  end

  if copy_to_clipboard(url) then
    vim.notify("Permalink copied to clipboard: " .. url, vim.log.levels.INFO)
  else
    vim.notify("Permalink: " .. url, vim.log.levels.INFO)
  end
end

-- Open permalink in browser
function M.open()
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")

  -- Ensure start <= end
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  local url = generate_url(start_line, end_line)

  if not url then
    vim.notify("Failed to generate permalink", vim.log.levels.ERROR)
    return
  end

  if open_in_browser(url) then
    vim.notify("Opening permalink in browser", vim.log.levels.INFO)
  elseif copy_to_clipboard(url) then
    vim.notify("Cannot open browser. Permalink copied to clipboard", vim.log.levels.WARN)
  else
    vim.notify("Permalink: " .. url, vim.log.levels.INFO)
  end
end

-- Setup function for user configuration
function M.setup(opts)
  opts = opts or {}

  -- Create user commands
  vim.api.nvim_create_user_command("Gitlinker", function()
    M.copy()
  end, { range = true, desc = "Copy git permalink to clipboard" })

  vim.api.nvim_create_user_command("GitlinkerOpen", function()
    M.open()
  end, { range = true, desc = "Open git permalink in browser" })

  -- Set up default keymaps if requested
  if opts.mappings then
    local mappings = opts.mappings
    if mappings.copy then
      vim.keymap.set({ "n", "v" }, mappings.copy, M.copy, { desc = "Copy git permalink" })
    end
    if mappings.open then
      vim.keymap.set({ "n", "v" }, mappings.open, M.open, { desc = "Open git permalink" })
    end
  end
end

return M