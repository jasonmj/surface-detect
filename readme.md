### Description
Simple package to switch between elixir-mode and web-mode when viewing .ex files. Checks the current cursor position on an interval to determine if inside a code block that starts with the ~F sigil. This is a global minor mode.

### Getting Started
Clone from this GitHub repository (later we hope to have the package listed on MELPA).

If you've cloned the repository, follow these instructions:
1. Place surface-detect.el somewhere on your Emacs load path with `(add-to-list 'load-path "/path/to/surface-detect/")
2. Add `(require 'surface-detect)` to your Emacs configuration.
3. Add `(surface-detect-mode 1)` to your Emacs configuration.

### Customization
There are several options for customizing this package:

##### Hook: surface-detect-switched
Hooks run when surface-detect changes major modes.

##### Variable: surface-detect-timer-interval
The interval at which the cursor position should be checked.
