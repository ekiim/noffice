let g:MBlaze = {}
let g:MBlazeChannelsDir = $HOME . "/.cache/mail"
let g:MBlazeChannels = {}

let g:MBlazeScanFormat = "'%R\t,%c%u%r %-3n %20D %20f %t %2i%150s'"
"let g:MBlazeScanFormat = "'%c%u%r %-3n %20D %20f %t %2i%50s'"

function! MBlazeMailListNav(direction)
    let l:pos = getcurpos()
    let l:pos[1] += a:direction
    let l:lnum = l:pos[1]
    call setpos('.', l:pos)
    call MBlazeMailListSelect()
endfun

function! MBlazeMailPreview(mailfile)
    enew!
    echo 
    let b:mailfile = a:mailfile
    let l:appendable = extend(
        \ extend(systemlist("mhdr " . a:mailfile),
        \ systemlist("mshow -t " . a:mailfile)), [])
    call append("^", l:appendable)
    call cursor(1,1)
    setl tabstop=8
    let l:status = systemlist("mscan " . a:mailfile)[0]
endfun

function! MBlazeMailListSelect()
    let l:curwin = win_getid()
    let l:lnum = line(".")
    let l:box = getline(".")
    let l:tab_idx = strridx(l:box, "\t")
    let l:msg_file = l:box[:l:tab_idx]
    if !exists("t:mblaze_preview_win")
        split
        let t:mblaze_preview_win = win_getid()
        let l:prev_buffer = bufnr("%")
    endif
    call win_gotoid(t:mblaze_preview_win)
    call MBlazeMailPreview(l:msg_file)
    silent! setlocal nonumber nowrap nomodifiable nomodified readonly
    call win_gotoid(l:curwin)
endfun

function! MBlazeMailListStatus()
    if exists("b:dir") && exists("g:MBlazeChannelsDir")
        return b:dir[len(g:MBlazeChannelsDir):]
    endif
    return b:dir
endfun

function! MBlazeMailListShow(dir)
    enew!
    let b:dir = a:dir
    let l:command = "mlist " . a:dir . " | msort -r -d  | mscan -f " . g:MBlazeScanFormat
    let l:mail_list = systemlist(l:command)
    call append(0, l:mail_list)
    setl statusline=%{MBlazeMailListStatus()}
    silent! setlocal nonumber nowrap nomodifiable nomodified readonly
    syn region mblazeMailFile start=/^/ end=/\t,/ conceal
    setl conceallevel=3
    setl concealcursor=nvic
    call cursor(1,1)
    nnoremap <buffer><nowait><silent> l <c-w>l
    nnoremap <buffer><nowait><silent> h <c-w>h
    nnoremap <buffer><nowait><silent> <cr> :call MBlazeMailListSelect()<cr>
    nnoremap <buffer><nowait><silent> j :call MBlazeMailListNav(1)<cr>
    nnoremap <buffer><nowait><silent> k  :call MBlazeMailListNav(-1)<cr>
endfun


function! MBlazeLoadChannels(root)
    let l:returnable = {}
    let l:ls_command = "ls " .  shellescape(a:root) . " | sort --ignore-case"
    let l:maildir_list = systemlist(l:ls_command)
    if index(l:maildir_list, 'cur') == -1
        for l:dir in l:maildir_list
            let l:subdir = a:root . '/' . l:dir
            let l:returnable[dir] = MBlazeLoadChannels(l:subdir)
        endfor
    endif
    return l:returnable
endfun

function! MBlazeMailTab()
    tabnew
    let t:list_win = win_getid()
    call MBlazeMailBoxesSetupContent()
    let t:boxes_win = win_getid()
endfun

function! MBlazeMailBoxesSetupContent()
    exec "topleft vertical 25 new"
    setlocal statusline=Mail
    setlocal statusline+=\ Boxes
    let l:maildirs = MBlazeLoadChannels(g:MBlazeChannelsDir)
    for [key, value] in items(l:maildirs)
        let l:tree = TreeDraw(value, 0, '')
        call append("^", l:tree)
        call append("^", key)
    endfor
    call append("^", "\" Channels")
    silent! setlocal 
        \ wfw
        \ nonumber
        \ nomodifiable
        \ nomodified
        \ readonly
    setl tabstop=2 shiftwidth=2 foldmethod=indent foldlevel=99 wfw
    call cursor(1,1)
    nnoremap <buffer><nowait><silent> <cr> :call MBlazeMailBoxesSelect()<cr>
endfun

function! MBlazeMailBoxesIndentLevel(key, box)
    let l:loop = 1
    let l:level = 0
    let l:box_list = str2list(a:box)
    while l:loop
        if l:box_list[l:level] == 32
            let l:level = l:level + 1
        else
            let l:loop = 0
        endif
    endwhile
    return [a:key, a:box, l:level]
endfun

function! MBlazeMailBoxesSelect()
    let l:lnum = line(".")
    let l:box = getline(".")
    let l:parents = map(getline(0, "."), function("MBlazeMailBoxesIndentLevel"))
    let l:res = [parents[-1]] 
    for elem in reverse(l:parents)
        if elem[-1] < l:res[-1][-1]
            let l:res = add(l:res, elem) 
        endif
    endfor
    let l:maildir = ""
    for elem in reverse(l:res)
        let l:boxname = elem[1][elem[-1]:]
        let l:maildir .=  l:boxname. "/"
    endfor
    call MBlazeListLoad(l:maildir)
endfun

function! MBlazeListLoad(mailbox)
    call win_gotoid(t:list_win)
    enew!
    let l:target_dir = g:MBlazeChannelsDir . "/" . a:mailbox
    call MBlazeMailListShow(l:target_dir)
endfun

function! TreeFold(lnum)
    let l:curline = getline(a:lnum)
    let l:len = len(l:curline)
    let l:cur = 0
    for i in range(l:len/4)
        let l:curblock = l:curline[i*4:(i+1)*4-1]
        if index(g:TreeDrawShift_list, l:curblock) != -1
            let l:cur += 1
        endif 
    endfor
    return l:cur
endfun

"let g:TreeDrawShift_list = [
"    \ " ─  ",
"    \ " │  ",
"    \ " ├─ ",
"    \ " └─ ",
"    \ ]
let g:TreeDrawShift_list = [
    \ "  ",
    \ "  ",
    \ "  ",
    \ "  ",
    \ ]

let g:TreeDrawShift_zero  = g:TreeDrawShift_list[0]
let g:TreeDrawShift_one   = g:TreeDrawShift_list[1]
let g:TreeDrawShift_three = g:TreeDrawShift_list[2]
let g:TreeDrawShift_two   = g:TreeDrawShift_list[3]

function! TreeFold()
    let l:current_line = getline(v:lnum)
    if matchstr(l:current_line, "├", 0)
        return "="
    endif
    if matchstr(l:current_line, "└", 0)
        return "="
    endif
endfun

function! TreeDraw(data, level, shift)
    let l:returnable = []
    if len(a:data) == 0
        return l:returnable
    endif
    let l:keys = sort(keys(a:data), 'i')
    if len(keys) > 1 
        for key in keys[:-2]
            let l:shift = a:shift . g:TreeDrawShift_three. key
            call add(l:returnable, l:shift)
            call extend(l:returnable, TreeDraw(a:data[key], a:level + 1, a:shift . g:TreeDrawShift_one)) 
        endfor
    endif
    let key = l:keys[-1]
    let l:shift = a:shift . g:TreeDrawShift_two . key
    call add(l:returnable, l:shift)
    call extend(l:returnable, TreeDraw(a:data[key], a:level + 1, a:shift . g:TreeDrawShift_zero)) 
    return l:returnable
endfun

" startify buffer options
"  silent! setlocal
"        \ bufhidden=wipe
"        \ colorcolumn=
"        \ foldcolumn=0
"        \ matchpairs=
"        \ modifiable
"        \ nobuflisted
"        \ nocursorcolumn
"        \ nocursorline
"        \ nolist
"        \ nonumber
"        \ noreadonly
"        \ norelativenumber
"        \ nospell
"        \ noswapfile
"        \ signcolumn=no
"        \ synmaxcol&

"command! -nargs=1 MBlazeList call 
command! -nargs=0 MBlazeTab call MBlazeMailTab()
