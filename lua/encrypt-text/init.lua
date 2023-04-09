local M = {}

local function encrypt(key)
  local text = table.concat(vim.api.nvim_buf_get_lines(0, 1, -1, false), "\n")
  local cipher = crypto.encrypt("aes-256-cbc", key, text)
  local encrypted_text = "<!--- ENCRYPTED TEXT --->\n" .. vim.b64encode(cipher) .. "\n<!--- /ENCRYPTED TEXT --->\n"
  vim.api.nvim_buf_set_lines(0, 1, -1, false, vim.split(encrypted_text, "\n", true))
end

local function decrypt(key)
  local encrypted_lines = vim.api.nvim_buf_get_lines(0, 1, -1, false)
  local start_comment = "<!--- ENCRYPTED TEXT --->"
  local end_comment = "<!--- /ENCRYPTED TEXT --->"
  local start_line, end_line = 0, 0
  for i, line in ipairs(encrypted_lines) do
    if line == start_comment then
      start_line = i
    elseif line == end_comment then
      end_line = i
      break
    end
  end
  if start_line == 0 or end_line == 0 then
    print("Error: encrypted text not found")
    return
  end
  local encrypted_text = table.concat(encrypted_lines, "\n", start_line + 1, end_line - 1)
  local cipher = vim.b64decode(encrypted_text)
  local plain = crypto.decrypt("aes-256-cbc", key, cipher)
  vim.api.nvim_buf_set_lines(0, start_line, end_line - 1, false, vim.split(plain, "\n", true))
end

function M.setup()
  vim.cmd([[
    command! -nargs=1 Encrypt lua require('encrypt-text').encrypt(<f-args>)
    command! -nargs=1 Decrypt lua require('encrypt-text').decrypt(<f-args>)
  ]])
end

M.encrypt = encrypt
M.decrypt = decrypt

return M
