vim-instant-wavedrom
====================

This plugin renders [WaveDrom](https://wavedrom.com) timing diagrams from Vim
buffers of filenames ending in `.wavedrom.js`.

It is almost entirely of [suan](https://github.com/suan)'s excellent
[vim-instant-markdown](https://github.com/suan/vim-instant-markdown), with only
a few minor tweaks to connect to the supplied instant-wavedrom-d Node.js
server.


Installation
------------

1.  Ensure node.js and npm are installed.

2.  Open any file with the extension `.wavedrom.vim`.

The initial startup after installation will be a bit slow, as the script will
automatically set up the Node.js server.  All future startups will not, so long
as `node_modules/` is not removed.


Configuration
-------------

The following configuration options are retained from vim-instant-markdown.


### g:instant_wavedrom_slow

By default, vim-instant-wavedrom will update the display in realtime.  If that
taxes your system too much, you can specify

```
let g:instant_wavedrom_slow = 1
```

before loading the plugin (for example place that in your `~/.vimrc`). This
will cause vim-instant-wavedrom to only refresh on the following events:

- No keys have been pressed for a while
- A while after you leave insert mode
- You save the file being edited


### g:instant_wavedrom_autostart

By default, vim-instant-wavedrom will automatically launch the preview window
when you open a wavedrom file. If you want to manually control this behavior,
you can specify

```
let g:instant_wavedrom_autostart = 0
```

in your .vimrc. You can then manually trigger preview via the command
```:InstantWavedromPreview```. This command is only available inside WaveDrom
buffers and when the autostart option is turned off.
