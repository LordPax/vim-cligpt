let g:cligptprg="cligpt"
" let g:preprompt="donne aucune explication"
let g:preprompt=""
let g:model="gpt-3.5-turbo"
let g:temperature=0.7

function! CliGPT(mode, is_selection, ...) range
    let l:instruction = a:0 ? a:1 : ""

    if l:instruction == ""
        if a:is_selection
            let l:lines = join(getline(a:firstline, a:lastline), "\n")
            let l:cmd = "echo ".shellescape(l:lines)." | ".g:cligptprg." -s -"
        else
            let l:cmd = g:cligptprg
        endif

        execute "vertical terminal ++close ".l:cmd
        return
    endif

    if a:is_selection
        let l:lines = join(getline(a:firstline, a:lastline), "\n")
        let l:cmd = g:cligptprg." -s ".shellescape(l:lines)." ".shellescape(l:instruction." ".g:preprompt)
        if a:mode == 0
            execute "normal! ".a:firstline."GV".a:lastline."Gc"
        else
            execute "normal! ".a:lastline."Go"
        endif
    else
        let l:cmd = g:cligptprg." ".shellescape(l:instruction." ".g:preprompt)
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

" function! CliGPTFile(file, ...)
"     " echo "file: ".a:file
"     let l:instruction = a:0 ? a:1 : ""
"     echo "instruction: ".l:instruction
"     let l:cmd = "cat ".a:file." | ".g:cligptprg." -s - ".shellescape(l:instruction." ".g:preprompt)
" endfunction

function! CliGPTListHitory()
    let l:cmd = g:cligptprg." -L"
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
    let l:cmd = g:cligptprg." -c"
    let l:result = system(l:cmd)

    if v:shell_error != 0
        echohl ErrorMsg | echo "Somthing wrong" | echohl None
        return
    endif

    echo "History cleared"
endfunction

command! -range -nargs=? Cligpt <line1>,<line2>call CliGPT(0, <range>, <f-args>)
command! -range -nargs=? CligptAdd <line1>,<line2>call CliGPT(1, <range>, <f-args>)
" command! -nargs=? CligptFile call CliGPTFile(file, <f-args>)
command! CligptHistory call CliGPTListHitory()
command! CligptClearHistory call CliGPTClearHistory()
