let g:cligptprg=$HOME."/.vim/plugged/vim-cligpt/cligpt/cligpt"
" let g:cligptprg="cligpt"
let g:preprompt=""
let g:model="gpt-3.5-turbo"
let g:temperature="0.7"
let g:cligptcmd=g:cligptprg." text -m ".g:model." -t ".g:temperature
let g:cligptcmdInerte=g:cligptprg." -i text -m ".g:model." -t ".g:temperature

function! CliGPT(mode, is_selection, ...) range
    let l:instruction = a:0 ? a:1 : ""

    if l:instruction == ""
        if a:is_selection
            let l:lines = join(getline(a:firstline, a:lastline), "\n")
            let l:cmd = g:cligptprg." -i text -s ".shellescape(l:lines)

            call system(l:cmd)

            if v:shell_error != 0
                echohl ErrorMsg | echo "Somthing wrong" | echohl None
                return
            endif
        endif

        execute "vertical terminal ++close ".g:cligptcmd
        return
    endif

    if a:is_selection
        let l:lines = join(getline(a:firstline, a:lastline), "\n")
        let l:cmd = g:cligptcmd." -s ".shellescape(l:lines)." ".shellescape(l:instruction." ".g:preprompt)

        let l:exec = a:mode == 0 
            \? "normal! ".a:firstline."GV".a:lastline."Gc"
            \: "normal! ".a:lastline."Go"

        execute l:exec
    else
        let l:cmd = g:cligptcmd." ".shellescape(l:instruction." ".g:preprompt)
    endif

    echo "Processing please wait ..."
    let l:result = system(l:cmd)

    if v:shell_error != 0
        echohl ErrorMsg | echo "Somthing wrong" | echohl None
        return
    endif

    let l:insert = a:is_selection ? "i" : "o"
    execute "normal! ".l:insert.l:result
endfunction

function! CliGPTFile(...)
    if a:0 == 0
        echohl ErrorMsg | echo "No file specified" | echohl None
        return
    endif

    let l:splited = split(a:1, " ")
    let l:file = l:splited[0]
    let l:instruction = join(l:splited[1:], " ")

    if filereadable(l:file) == 0
        echohl ErrorMsg | echo "File not found" | echohl None
        return
    endif

    if l:instruction == ""
        let l:cmd = "cat ".l:file." | ".g:cligptprg." -i text -s -"
        call system(l:cmd)

        if v:shell_error != 0
            echohl ErrorMsg | echo "Somthing wrong" | echohl None
            return
        endif

        execute "vertical terminal ++close ".g:cligptcmd
        return
    endif

    let l:cmd = "cat ".l:file." | ".g:cligptcmd." -s - ".shellescape(l:instruction." ".g:preprompt)
    echo "Processing please wait ..."
    let l:result = system(l:cmd)

    if v:shell_error != 0
        echohl ErrorMsg | echo "Somthing wrong" | echohl None
        return
    endif

    execute "normal! o".l:result
endfunction

function! CliGPTListHitory()
    let l:cmd = g:cligptprg." text -l"
    let l:result = system(l:cmd)

    if v:shell_error != 0
        echohl ErrorMsg | echo "Somthing wrong" | echohl None
        return
    endif

    if l:result == ""
        echohl ErrorMsg | echo "History is empty" | echohl None
        return
    endif

    execute "new"
    setlocal buftype=nofile
    setlocal filetype=json
    execute "normal! i".l:result
endfunction

function! CliGPTClearHistory()
    let l:cmd = g:cligptprg." text -c"
    call system(l:cmd)

    if v:shell_error != 0
        echohl ErrorMsg | echo "Somthing wrong" | echohl None
        return
    endif

    echo "History cleared"
endfunction

function! CliGPTSpeech(...)
    let l:cmd = g:cligptprg." -q speech"

    if a:0 == 1
        let l:cmd = l:cmd." -l ".a:1
    endif

    echo "Recording audio (Ctrl+C to stop) ..."
    let l:result = system(l:cmd)

    if v:shell_error != 0
        echohl ErrorMsg | echo "Somthing wrong" | echohl None
        return
    endif

    execute "normal! a".l:result
endfunction

command! -range -nargs=? Cligpt <line1>,<line2>call CliGPT(0, <range>, <f-args>)
command! -range -nargs=? CligptAdd <line1>,<line2>call CliGPT(1, <range>, <f-args>)
command! -nargs=? -complete=file CligptFile call CliGPTFile(<f-args>)
command! -nargs=? CligptSpeech call CliGPTSpeech(<f-args>)
command! CligptHistory call CliGPTListHitory()
command! CligptClearHistory call CliGPTClearHistory()
