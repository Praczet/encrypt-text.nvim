# Encrypt-text

**encrypt-text** is a lua plugin for Neovim / LunarVim for encrypting and decrypting text (I have no idea if it does work in pure Neovim).

## Intro

I have created this plugin (and let it be know this is my the very first plugin) to have functionality similar to [ QOwnNotes ](https://www.qownnotes.org/). Which is a feature to encrypt text in md file. So this plugin basically encrypt (and decrypt) the text (starting from the second line).
The first line is just the **Title**

## Usage

```vim
:Encrypt passkey
:Decrypt passkey
```

Or without passkey

```vim
:Encrypt
:Decrypt
```

In this case you will be asked for encryption's password. The advantage of not giving password is that the password won't be stored in the command history.
The plugin is using `inputsecret` you can read about it: `:help inputsecret`

## Installation

Ok For now I am new to all of it so I can tell only how to install it using Packer :D

```lua
{
    "Praczet/encrypt-text.nvim",
        config = function()
            require("encrypt-text").setup()
        end
},

```

## Bragging

I recommended my second plugin for Tagging notes... [Praczet/note-tags.nvim](https://github.com/Praczet/note-tags.nvim)
