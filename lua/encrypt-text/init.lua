local M = {}
local dic = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

-- Encrypts note. Not whole note but just note's text started from line:2 (I like to have in the first line a title)
-- It can take one argument - password, if argument is not provided `inputsecret` will be used to ask for one
local function encrypt(...)
  local text = table.concat(vim.api.nvim_buf_get_lines(0, 1, -1, false), "\n")
  local cipher = {}
  local key = ''
  if select("#", ...) > 0 then
    key = select(1, ...)
  else
    key = vim.fn.inputsecret('Enter password: ')
    if key == '' then
      print('Password can not be empty!!! - I am leaving you!!! ')
      return
    end
  end
  -- print(text)
  print(cipher)
  for i = 1, #text do
    local byte = string.byte(text, i)
    local key_byte = string.byte(key, (i - 1) % #key + 1)
    table.insert(cipher, string.char(bit.bxor(byte, key_byte)))
  end
  local encrypted_text = "<!-- ENCRYPTED TEXT --\n" ..
      M.b64encode(table.concat(cipher)) .. "\n-- /ENCRYPTED TEXT -->"
  vim.api.nvim_buf_set_lines(0, 1, -1, false, vim.split(encrypted_text, "\n", true))
end

-- Decrypts note. Not whole note but just text between `<!-- ENCRYPTED TEXT --` and `-- /ENCRYPTED TEXT-->`
-- It can take one argument - password, if argument is not provided `inputsecret` will be used to ask for one
local function decrypt(...)
  local key = ''
  if select("#", ...) > 0 then
    key = select(1, ...)
  else
    key = vim.fn.inputsecret('Enter password: ')
    if key == '' then
      print('Password can not be empty!!! - I am leaving you!!! ')
      return
    end
  end
  local encrypted_lines = vim.api.nvim_buf_get_lines(0, 1, -1, false)
  local start_comment = "<!-- ENCRYPTED TEXT --"
  local end_comment = "-- /ENCRYPTED TEXT -->"
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
  local cipher = M.b64decode(encrypted_text)
  local plain = {}
  for i = 1, #cipher do
    local byte = string.byte(cipher, i)
    local key_byte = string.byte(key, (i - 1) % #key + 1)
    table.insert(plain, string.char(bit.bxor(byte, key_byte)))
  end
  vim.api.nvim_buf_set_lines(0, start_line, end_line + 1, false, vim.split(table.concat(plain), "\n", true))
end

-- Encodes string (data)
-- Credits goes to http://lua-users.org/wiki/BaseSixtyFour
-- @param data string to encode
local function b64encode(data)
  return (
      (data:gsub('.', function(x)
        local r, b = '', x:byte()
        for i = 8, 1, -1 do
          r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and '1' or '0')
        end
        return r
      end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if #x < 6 then
          return ''
        end
        local c = 0
        for i = 1, 6 do
          c = c + (x:sub(i, i) == '1' and 2 ^ (6 - i) or 0)
        end
        return dic:sub(c + 1, c + 1)
      end) .. ({ '', '==', '=' })[#data % 3 + 1]
      )
end

-- Decodes given string
-- Credits goes to http://lua-users.org/wiki/BaseSixtyFour
-- @param data String to decode
local function b64decode(data)
  data = string.gsub(data, '[^' .. dic .. '=]', '')
  return (
      data
      :gsub('.', function(x)
        if x == '=' then
          return ''
        end
        local r, f = '', (dic:find(x) - 1)
        for i = 6, 1, -1 do
          r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and '1' or '0')
        end
        return r
      end)
      :gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if #x ~= 8 then
          return ''
        end
        local c = 0
        for i = 1, 8 do
          c = c + (x:sub(i, i) == '1' and 2 ^ (8 - i) or 0)
        end
        return string.char(c)
      end)
      )
end

-- Adds Command Encrypt and Decrypt
-- - `:Encrypt [password]` - password is optional if not provided User will be asked for one
-- - `:Decrypt [password]` - password is optional if not provided User will be asked for one
function M.setup()
  vim.cmd([[
    command! -nargs=? Encrypt lua require('encrypt-text').encrypt(<f-args>)
    command! -nargs=? Decrypt lua require('encrypt-text').decrypt(<f-args>)
  ]])
end

M.encrypt = encrypt
M.decrypt = decrypt
M.b64encode = b64encode
M.b64decode = b64decode

-- TODO: Make a decision if we need all 4 function to be public?
-- and also if not use this metatable... for now let it be as it is
return M
