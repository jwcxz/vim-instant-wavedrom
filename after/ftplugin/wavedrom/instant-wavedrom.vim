" # Configuration
if !exists('g:instant_wavedrom_slow')
    let g:instant_wavedrom_slow = 0
endif

if !exists('g:instant_wavedrom_autostart')
    let g:instant_wavedrom_autostart = 1
endif

" https://stackoverflow.com/questions/18048841/how-can-i-get-a-vim-plugins-directory-from-within-that-plugin
let s:plugindir = expand('<sfile>:p:h:h:h:h')
let s:instant_wavedrom_d = s:plugindir . '/instant-wavedrom-d/start-instant-wavedrom-d'

" # Utility Functions
" Simple system wrapper that ignores empty second args
function! s:system(cmd, stdin)
    if strlen(a:stdin) == 0
        call system(a:cmd)
    else
        call system(a:cmd, a:stdin)
    endif
endfu

" Wrapper function to automatically execute the command asynchronously and
" redirect output in a cross-platform way. Note that stdin must be passed as a
" List of lines.
function! s:systemasync(cmd, stdinLines)
    if has('win32') || has('win64')
        call s:winasync(a:cmd, a:stdinLines)
    else
        let cmd = a:cmd . '&>/dev/null &'
        call s:system(cmd, join(a:stdinLines, "\n"))
    endif
endfu

" Executes a system command asynchronously on Windows. The List stdinLines will
" be concatenated and passed as stdin to the command. If the List is empty,
" stdin will also be empty.
function! s:winasync(cmd, stdinLines)
    " To execute a command asynchronously on windows, the script must use the
    " "!start" command. However, stdin can't be passed to this command like
    " system(). Instead, the lines are saved to a file and then piped into the
    " command.
    if len(a:stdinLines)
        let tmpfile = tempname()
        call writefile(a:stdinLines, tmpfile)
        let command = 'type ' . tmpfile . ' | ' . a:cmd
    else
        let command = a:cmd
    endif
    exec 'silent !start /b cmd /c ' . command . ' > NUL'
endfu

function! s:refreshView()
    let bufnr = expand('<bufnr>')
    call s:systemasync("curl -X PUT -T - http://localhost:8091",
                \ s:bufGetLines(bufnr))
endfu

function! s:startDaemon(initialWDLines)
    call s:systemasync(s:instant_wavedrom_d, a:initialWDLines)
endfu

function! s:initDict()
    if !exists('s:buffers')
        let s:buffers = {}
    endif
endfu

function! s:pushBuffer(bufnr)
    call s:initDict()
    let s:buffers[a:bufnr] = 1
endfu

function! s:popBuffer(bufnr)
    call s:initDict()
    call remove(s:buffers, a:bufnr)
endfu

function! s:killDaemon()
    call s:systemasync("curl -s -X DELETE http://localhost:8091", [])
endfu

function! s:bufGetLines(bufnr)
  return getbufline(a:bufnr, 1, "$")
endfu

" I really, really hope there's a better way to do this.
fu! s:myBufNr()
    return str2nr(expand('<abuf>'))
endfu

" # Functions called by autocmds
"
" ## push a new wavedrom buffer into the system.
"
" 1. Track it so we know when to garbage collect the daemon
" 2. Start daemon if we're on the first WD buffer.
" 3. Initialize changedtickLast, possibly needlessly(?)
fu! s:pushWavedrom()
    let bufnr = s:myBufNr()
    call s:initDict()
    if len(s:buffers) == 0
        call s:startDaemon(s:bufGetLines(bufnr))
    endif
    call s:pushBuffer(bufnr)
    let b:changedtickLast = b:changedtick
endfu

" ## pop a wavedrom buffer
"
" 1. Pop the buffer reference
" 2. Garbage collection
"     * daemon
"     * autocmds
fu! s:popWavedrom()
    let bufnr = s:myBufNr()
    silent au! instant-wavedrom * <buffer=abuf>
    call s:popBuffer(bufnr)
    if len(s:buffers) == 0
        call s:killDaemon()
    endif
endfu

" ## Refresh if there's something new worth showing
"
" 'All things in moderation'
fu! s:temperedRefresh()
    if !exists('b:changedtickLast')
        let b:changedtickLast = b:changedtick
    elseif b:changedtickLast != b:changedtick
        let b:changedtickLast = b:changedtick
        call s:refreshView()
    endif
endfu

fu! s:previewWavedrom()
  call s:startDaemon(getline(1, '$'))
  aug instant-wavedrom
    if g:instant_wavedrom_slow
      au CursorHold,BufWrite,InsertLeave <buffer> call s:temperedRefresh()
    else
      au CursorHold,CursorHoldI,CursorMoved,CursorMovedI <buffer> call s:temperedRefresh()
    endif
    au BufWinLeave <buffer> call s:cleanUp()
  aug END
endfu

fu! s:cleanUp()
  call s:killDaemon()
  au! instant-wavedrom * <buffer>
endfu

if g:instant_wavedrom_autostart
    " # Define the autocmds "
    aug instant-wavedrom
        au! * <buffer>
        au BufEnter <buffer> call s:refreshView()
        if g:instant_wavedrom_slow
          au CursorHold,BufWrite,InsertLeave <buffer> call s:temperedRefresh()
        else
          au CursorHold,CursorHoldI,CursorMoved,CursorMovedI <buffer> call s:temperedRefresh()
        endif
        au BufWinLeave <buffer> call s:popWavedrom()
        au BufwinEnter <buffer> call s:pushWavedrom()
    aug END
else
    command! -buffer InstantWavedromPreview call s:previewWavedrom()
endif

set syntax=javascript
