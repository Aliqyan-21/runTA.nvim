# runTA.nvim

Welcome to `runTA.nvim`, the ultimate Neovim plugin that supercharges your coding workflow by seamlessly integrating code execution right within your Neovim editor!

## Why You'll Love `runTA.nvim`

- Are you tired of switching between Neovim and a terminal to test your code?
- Do you program in various programming languages or continously trying to learn new languges?

Say goodbye to context-switching and hello to uninterrupted productivity! `runTA.nvim` brings the power of code execution directly into Neovim with an elegant floating terminal window.

## Key Features

- **Seamless Code Execution**: Run your code in a sleek floating terminal window without ever leaving Neovim. Your output is always at your fingertips!
- **Customizable Floating Terminal**: Tailor the floating terminal to fit your workflow with configurable size, position and transparency settings. Choose from center, top, bottom, left, right, or even custom placements!
- **Transparency Options**: Create a distraction-free coding environment with optional transparency settings for the floating window. Focus on your code, not on unnecessary distractions.
- **Automatic Language Detection**: It automatically detects the language of current buffer and run code accordingly.

- **Languages Currently Supported**:
  - c
  - c++

## Installation

Getting started with `runTA.nvim` is easy! Simply install it using your favorite plugin manager. For example, with [packer.nvim](https://github.com/wbthomason/packer.nvim), add the following line to your configuration:

```lua
use {
    "aliqyan-21/runTA.nvim"
    config = function()
    require("runTA.commands").setup()
    end,
}
```

for [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
return {
    "aliqyan-21/runTA.nvim"
    config = function()
    require("runTA.commands").setup()
    end,
}
```

## Configuration

Customize runTA.nvim to fit your needs by adding the following configuration to your Neovim setup:

```lua
runTA.setup({
    output_window_configs = {

    width = 80, -- Width of the floating window
    height = 20, -- Height of the floating window
    position = "center", -- Position of the floating window ("center", "top", "bottom", "left", "right", "custom")
    custom_col = nil, -- Custom column position (optional)
    custom_row = nil, -- Custom row position (optional)

    transparent = false, -- Set to true for a transparent background
    },
})
end
```

## Usage

With runTA.nvim, running your code is as simple as executing a command. Just use `:RunCode` in Neovim or set keymap to trigger the command, and watch as your code runs in the floating terminal window with all output displayed right where you need it!

## Contribution

Contributions are welcome to make runTA.nvim even better!
Submit issue or pull request to add more languages or features

## License

runTA.nvim is licensed under the MIT License.

## Acknowledgements

Special thanks to Neovim for providing a powerful and extensible platform such as this.