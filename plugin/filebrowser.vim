function! LSBufferSplit()
    silent! split <bar> enew
    call LSBufferLoad()
endfun 
function! LSBufferVertSplit()
    silent! vert split <bar> enew
    call LSBufferLoad()
endfun 
function! LSBufferLoad()
    if !exists("b:pwd")
        let b:pwd = getcwd()
    endif
    silent! exec "-1 read ! ls -a1 " b:pwd
    silent! exec ":$"
    silent! normal dd
    silent! exec ":3"
    silent! setlocal nomodifiable nonumber nomodified cursorline hidden
    nnoremap <buffer><nowait><silent> l <c-w>l
    nnoremap <buffer><nowait><silent> h <c-w>h
    nnoremap <buffer><nowait><silent> j :call LSBufferNav(1)<cr>
    nnoremap <buffer><nowait><silent> k :call LSBufferNav(-1)<cr>
    nnoremap <buffer><nowait><silent> <cr> :call LSBufferOpen()<cr>
    au WinClosed <buffer> bd %
    au BufEnter <buffer> let g:netrw_gx = b:pwd . "/<cfile>"
    au BufLeave <buffer> let g:netrw_gx = "<cfile>"
    setl statusline=%{b:pwd}
    let l:pwd = b:pwd
    let l:cur_win = win_getid()
    if !exists("t:ls_buffer_preview_window")
        vert split
        enew
        exec "-1 read ! stat " . l:pwd
        let t:ls_buffer_preview_window = win_getid()
        au WinClosed <buffer>  unlet t:ls_buffer_preview_window <bar> bd %
        silent! setlocal nomodifiable nonumber nomodified cursorline hidden
        setl statusline=Summary
        call win_gotoid(l:cur_win)
    endif
endfun
function! LSBufferOpen()
    " [bufnum, lnum, col, off, curswant]
    let l:lnum = getcurpos()[1]
    let l:target = b:pwd . "/" . getline(l:lnum)
    let l:target = systemlist("realpath " . l:target)[0]
    silent! vert split
    if isdirectory(l:target)
        silent! enew
        let b:pwd = l:target
        "exec "lcd " . b:pwd
        call LSBufferLoad()
    endif
    if filereadable(l:target)
        echo "Open"
        normal Vgx
    endif
endfun

function! LSBufferNav(direction)
    let l:pos = getcurpos()
    let l:pos[1] += a:direction
    let l:lnum = l:pos[1]
    call setpos('.', l:pos)
    let l:target = b:pwd . "/" . getline(l:lnum)
    let l:target = systemlist("realpath " . l:target)[0]
    silent! call LSBBufferLoadPreview(l:target)
endfunction

function! LSBBufferLoadPreview(target)
    if !exists("t:ls_buffer_preview_window")
        return
    endif
    let l:cur_win = win_getid()
    silent! call win_gotoid(t:ls_buffer_preview_window)
    silent! setlocal modifiable
    silent! exec ":%d"
    silent! exec "-1 read ! stat " . a:target
    silent! setlocal nomodifiable nomodified
    silent! call win_gotoid(l:cur_win)
endfun

nnoremap <leader>f :call LSBufferSplit()<cr>
