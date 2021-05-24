"
" There are three types of buffers we need to handle:
"   - Mail Boxes List (`MBlazeMailBoxes`)
"   - Messages List   (`MBlazeMailList`)
"   - Message View    (`MBlazeMessage`)
"
" FileTypes:
"
"                                       mblazemailboxes-mappings
"  This buffer allows only for `j` `k` navigation and `<cr>` to 
"  select a box to see it's list.
"
"                                        mblazemaillist-mappings
"  This buffer allows only for `j` `k` navigation and `<cr>` to 
"  select an email to read it in a `split`.
"
"                                         mblazemessage-mappings
"  - Pending
"
" Tab Mode:
"
"   This Mode is invoked with the command `:MBlazeTab` (a call to
"   `MBlazeTab`).
"   It will save the window id at `t:mail_list_win` to use that default window 
"   view for the mail list.
"   Then it will toggle (by default there is no `t:mail_boxes_win` variable, so it
"   will open a `split` at `topleft`. (right side of the screen), with a 
"   tree for all your mail boxes at the directory specified at
"   `g:mail_directory`.
"
" let g:TreeDrawShift_list = [ " ─  ", " │  ", " └─ ", " ├─ "]
"

let g:TreeDrawShift = ["  ", "  ", "  ", "  "]
let g:mail_directory = $HOME . "/.cache/mail"
let g:MBlazeScanFormat = "\"%R\t,%c%u%r %-3n %20D %20f %t %2i%150s\""

function! GoToWinOrVSplit(winid)
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

function! TreeDraw(data, level, shift)
    let l:returnable = []
    if len(a:data) == 0
        return l:returnable
    endif
    let l:keys = sort(keys(a:data), 'i')
    if len(keys) > 1 
        for key in keys[:-2]
            let l:shift = a:shift . g:TreeDrawShift[3]. key
            let l:tree = TreeDraw(a:data[key], a:level + 1, a:shift . g:TreeDrawShift[1])
            call add(l:returnable, l:shift)
            call extend(l:returnable, l:tree) 
        endfor
    endif
    let key = l:keys[-1]
    let l:shift = a:shift . g:TreeDrawShift[2]. key
    let l:tree = TreeDraw(a:data[key], a:level + 1, a:shift . g:TreeDrawShift[0])
    call add(l:returnable, l:shift)
    call extend(l:returnable, l:tree) 
    return l:returnable
endfun

function! ListBufferNav(direction)
    let l:pos = getcurpos()
    let l:pos[1] += a:direction
    call setpos('.', l:pos)
endfun

function! MBlazeMailMessageLoad()
    let l:message_file = b:message_file
    enew!
    let b:message_file = l:message_file
    echo b:message_file
    let l:appendable = systemlist("mshow " . b:message_file)
    " let b:status = systemlist("mscan " . b:message_file)[0]
    call append("^", l:appendable)
    call cursor(1,1)
    silent! setlocal nonumber nowrap nomodifiable nomodified readonly tabstop=8
    let t:message_view = win_getid()
    au BufUnload <buffer> unlet t:message_view
endfun

function! MBlazeMailBoxesMappings()
    nnoremap <buffer><nowait><silent> l <c-w>l
    nnoremap <buffer><nowait><silent> h <c-w>h
    nnoremap <buffer><nowait><silent> <cr> :call MBlazeMailBoxesSelect()<cr>
    nnoremap <buffer><nowait><silent> j :call ListBufferNav(1)<cr>
    nnoremap <buffer><nowait><silent> k  :call ListBufferNav(-1)<cr>
endfun

function! MBlazeMailListNav(direction)
    call ListBufferNav(a:direction)
    if exists("b:nav_preview")
        call MBlazeMailListSelect()
    endif
endfun

function! MBlazeMailListClearAndCarry()
    let l:mail_directory = b:mail_directory
    unlet b:mail_directory
    if exists("b:mail_list_filter")
        let l:mail_list_filter = b:mail_list_filter
        unlet b:mail_list_filter
    endif
    if exists("b:mail_list_ignore")
        let l:mail_list_ignore = b:mail_list_ignore
        unlet b:mail_list_ignore
    endif 
    if exists("b:mail_list_date_start")
        let l:mail_list_date_start = b:mail_list_date_start
        unlet b:mail_list_date_start
    endif 
    if exists("b:mail_list_date_end")
        let l:mail_list_date_end = b:mail_list_date_end
        unlet b:mail_list_date_end
    endif 
    enew!
    let b:mail_directory = l:mail_directory
    if exists("l:mail_list_filter")
        let b:mail_list_filter = l:mail_list_filter
    endif
    if exists("l:mail_list_ignore")
        let b:mail_list_ignore = l:mail_list_ignore
    endif 
    if exists("l:mail_list_date_start")
        let b:mail_list_date_start = l:mail_list_date_start
    endif
    if exists("l:mail_list_date_end")
        let b:mail_list_date_end = l:mail_list_date_end
    endif 
endfun

function! MBlazeMailListGetFile()
    let l:lnum = line(".")
    let l:box = getline(".")
    let l:tab_idx = strridx(l:box, "\t")
    return l:box[:l:tab_idx]
endfun

function! MBlazeMailListMappings()
    nnoremap <buffer><nowait><silent> <F5> :call MBlazeMailListLoad()<cr>
    nnoremap <buffer><nowait><silent> l <c-w>l
    nnoremap <buffer><nowait><silent> h <c-w>h
    nnoremap <buffer><nowait><silent> <cr> :call MBlazeMailListSelect()<cr>
    nnoremap <buffer><nowait><silent> j :call MBlazeMailListNav(1)<cr>
    nnoremap <buffer><nowait><silent> k  :call MBlazeMailListNav(-1)<cr>
    command -nargs=+ -buffer MailListDateRange call MBlazeMailListFilterDate(<f-args>)
endfun

function! MBlazeMailListCommandArgs()
    let l:largs = " "
    let l:pargs = " "
    let l:sargs = "-r -d"
    if exists("b:mail_list_filter")
        let l:largs = toupper(b:mail_list_filter[0])
        if exists("b:mail_list_ignore")
            let l:largs = tolower(b:mail_list_filter[0])
        endif
        let l:largs = " -" . l:largs
    endif
    if exists("b:mail_list_date_start")
        let l:pargs_test = " date >= \"" . b:mail_list_date_start . "\""
    end
    if exists("b:mail_list_date_end")
        if exists("l:pargs_test")
            let l:pargs_test .= " && "
        else
            let l:pargs_test = ""
        endif
        let l:pargs_test .= " date <= \"" . b:mail_list_date_end . "\""
    end
    if exists("l:pargs_test")
        let l:pargs = "-t '" . l:pargs_test . "'"
    endif
    let returnable = [l:largs, l:pargs, l:sargs]
    echo returnable 
    return returnable 
endfun

function! MBlazeMailListLoad()
    call MBlazeMailListClearAndCarry()
    let [l:largs, l:pargs, l:sargs] = MBlazeMailListCommandArgs()
    let l:command = (
      \ "mlist" . l:largs . " " . b:mail_directory . 
      \ " | mpick    " . l:pargs . 
      \ " | msort    " . l:sargs . 
      \ " | mscan -f " . g:MBlazeScanFormat )
    echom l:command
    let l:mail_list = systemlist(l:command)
    "echo len(l:mail_list)
    "echo l:mail_list
    call append(0, l:mail_list)
    delete
    call cursor(1,1)
    call MBlazeMailListMappings()
    call MBlazeMailListStatusLine()
    syn region mblazeMailFile start=/^/ end=/\t,/ conceal
    silent! setlocal conceallevel=3
    silent! setlocal concealcursor=nvic
    silent! setlocal nonumber nowrap nomodifiable nomodified readonly
endfun

function! MBlazeMailListSelect()
    let l:curwin = win_getid()
    let l:message_file = MBlazeMailListGetFile()
    if !exists("t:message_view")
        split
        let t:message_view= win_getid()
    endif
    call win_gotoid(t:message_view)
    let b:message_file = l:message_file
    call MBlazeMailMessageLoad()
    call win_gotoid(l:curwin)
endfun

function! MBlazeMailListStatusLine()
    let b:statusline_mail_directory = ""
    let b:statusline_date_range = ""
    let b:statusline_filter = ""
    if exists("b:mail_directory") 
        if exists("g:mail_directory")
            let b:statusline_mail_directory =b:mail_directory[len(g:mail_directory):]
        else
            let b:statusline_mail_directory =b:mail_directory
        endif
    endif
    if exists("b:mail_list_filter")
        let b:statusline_filter = b:mail_list_filter
        if exists("b:mail_list_ignore")
            let b:statusline_filter .= "(ignore)"
        else
            let b:statusline_filter .= "(only)"
        endif
    endif
    if exists("b:mail_list_date_end")
        let b:statusline_date_range .= b:mail_list_date_end
    endif
    if exists("b:mail_list_date_start")
        if exists("b:mail_list_date_end")
            let b:statusline_date_range .= " / "
        endif
        let b:statusline_date_range .= b:mail_list_date_start
    endif
    silent! setl statusline=MailBox
    silent! setl statusline +=:%{b:statusline_mail_directory}%=
    silent! setl statusline +=%{b:statusline_date_range}
    silent! setl statusline +=\ %{b:statusline_filter}
    silent! setl statusline +=%l/%L
    return
    if exists("b:mail_list_date_start")
        let l:returnable .= "\-From:" . b:mail_list_date_start
    endif
    if exists("b:mail_list_date_end")
        let l:returnable .= "\-To:" . b:mail_list_date_end
    endif
endfun

function! MBlazeLoadChannels(mail_directory)
    let l:returnable = {}
    let l:root = a:mail_directory
    let l:ls_command = "ls " .  shellescape(l:root) . " | sort --ignore-case"
    let l:maildir_list = systemlist(l:ls_command)
    if index(l:maildir_list, 'cur') == -1
        for l:dir in l:maildir_list
            let l:subdir = l:root . '/' . l:dir
            let l:returnable[dir] = MBlazeLoadChannels(l:subdir)
        endfor
    endif
    return l:returnable
endfun

function! MBlazeMailListOpen(mail_directory)
    echo a:mail_directory
    let b:mail_directory = g:mail_directory . "/" . a:mail_directory
    call MBlazeMailListLoad()
endfun

function! MBlazeMailBoxesLoad()
    exec "topleft vertical 25 new"
    let l:maildirs = MBlazeLoadChannels(g:mail_directory)
    for [key, value] in items(l:maildirs)
        let l:tree = TreeDraw(value, 0, '')
        call append("^", l:tree)
        call append("^", key)
    endfor
    "call append("^", "\" Channels")
    silent! setlocal statusline=Mail\ Boxes
    silent! setlocal wfw nonumber nomodifiable nomodified readonly
    silent! setlocal tabstop=2 shiftwidth=2 foldmethod=indent foldlevel=99 wfw
    call cursor(1,1)
    call MBlazeMailBoxesMappings()
    let t:mail_boxes_win = win_getid()
    au BufUnload <buffer> unlet t:mail_boxes_win 
endfun


function! MBlazeMailBoxesToggle()
    if exists("t:mail_boxes_win")
        call win_gotoid(t:mail_boxes_win)
        bd!
    else
        call MBlazeMailBoxesLoad()
    endif
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


function! MBlazeMailListFilterDate(...)
    if !exists("a:1")
        let  b:mail_list_date_start = 0
        unlet  b:mail_list_date_start 
        return
    endif
    let b:mail_list_date_start = systemlist(
        \ "date --iso --date=\"" . a:1 .  "\""
        \ )[0]
    if exists("a:2")
        let b:mail_list_date_end = systemlist(
            \ "date --iso --date=\"" . a:2 .  "\""
            \ )[0]
    else
        let  b:mail_list_date_end= 0
        unlet  b:mail_list_date_end
    endif
    call MBlazeMailListLoad()
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
    let l:mail_directory = ""
    for elem in reverse(l:res)
        let l:boxname = elem[1][elem[-1]:]
        let l:mail_directory.=  l:boxname. "/"
    endfor
    if exists("t:mail_list_win") && getwininfo(t:mail_list_win) != []
        call win_gotoid(t:mail_list_win)
    else
        vsp | enew!
        let t:mail_list_win = win_getid()
    endif
    call MBlazeMailListOpen(l:mail_directory)
endfun

function! MBlazeMailTab()
    tabnew
    let t:mail_list = win_getid()
    call MBlazeMailBoxesToggle()
endfun

command! -nargs=0 MailTab call MBlazeMailTab()
command! -nargs=0 MailBoxes call MBlazeMailBoxesToggle()
command! -nargs=1 MailBox call MBlazeMailListOpen(<f-args>)
