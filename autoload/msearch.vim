let s:patterns = get(s:, 'patterns', [])
let s:visual_patterns = get(s:, 'visual_patterns', [])
let s:palette = get(s:, 'palette', [])
let s:next_ind = get(s:, 'next_ind', 0)
let s:color_map = get(s:, 'color_map', {})
let s:highlight_defined = get(s:, 'highlight_defined', v:false)
let s:cur_search_pattern = get(s:, 'cur_search_pattern', '')
let s:op_times = 0

function! s:VisualSelection()
    if mode()=="v"
        let [line_start, column_start] = getpos("v")[1:2]
        let [line_end, column_end] = getpos(".")[1:2]
    else
        let [line_start, column_start] = getpos("'<")[1:2]
        let [line_end, column_end] = getpos("'>")[1:2]
    end
    if (line2byte(line_start)+column_start) > (line2byte(line_end)+column_end)
        let [line_start, column_start, line_end, column_end] =
        \   [line_end, column_end, line_start, column_start]
    end
    if line_start != line_end
        echoerr "Msearch does not support multiple line search"
    endif

    return escape(getline(line_start)[column_start-1:column_end-1], '\^[]')
endfunction

function! s:inc_op_times()
    let s:op_times += 1
    let w:msearch_op_times = get(w:, 'msearch_op_times', 0) + 1
endfunction

function! msearch#exclusive_add(visual)
    call msearch#clear()
    call msearch#toggle_add(a:visual)
endfunction

function! msearch#start_add_by_search(back)
    autocmd CursorMoved * ++once silent call msearch#end_add_by_search()
endfunction

function! msearch#end_add_by_search()
    let l:search_pat = getreg('/')
    if empty(l:search_pat)
        return
    endif

    let l:ind = index(msearch#list(), l:search_pat)
    if l:ind == -1
        call msearch#define_highlight(v:false)
        call msearch#add(l:search_pat, match(l:search_pat, '\\<.*\\>')>-1)
        let s:cur_search_pattern = l:search_pat
    endif
    let @/=""
endfunction

function! msearch#define_highlight(force)
    if !s:highlight_defined || a:force
        let s:palette = g:Msearch_palette_fn()
        for i in range(len(s:palette))
            exec 'highlight MSMatch'.i.' '.s:palette[i]
        endfor
        let s:highlight_defined = v:true
    endif
endfunction

function! s:AsWordPattern(p)
    return '\<'.a:p.'\>'
endfunction

function! msearch#toggle_add(visual)
    call msearch#define_highlight(v:false)

    call s:inc_op_times()
    if a:visual
        let l:pattern = s:VisualSelection()
    else
        let l:pattern = s:AsWordPattern(expand('<cword>'))
    endif

    let l:ind = index(s:patterns, l:pattern)
    if l:ind>-1
        call msearch#remove(l:pattern, l:ind, a:visual)
    else
        call msearch#add(l:pattern, a:visual)
    endif
endfunction

function! msearch#refresh_all_win()
    let l:orig_winnr = winnr()
    noautocmd wincmd W
    while winnr()!=orig_winnr
        call msearch#refresh_cur_win(0)
        noautocmd wincmd W
    endwhile
endfunction

function! msearch#matchadd(pattern, ind)
    let s:color_map[a:pattern] = a:ind
    let w:match_id_map = get(w:, 'match_id_map', {})
    let w:match_id_map[a:pattern] = matchadd('MSMatch'.a:ind, a:pattern)
    let s:cur_search_pattern = a:pattern
    call msearch#refresh_all_win()
endfunction

function! msearch#add(pattern, visual)
    call msearch#matchadd(a:pattern, s:next_ind)
    if s:next_ind == len(s:patterns)
        call add(s:patterns, a:pattern)
        let s:next_ind += 1
    else
        let s:patterns[s:next_ind] = a:pattern
        let s:next_ind += 1
        while s:next_ind < len(s:patterns)
            if empty(s:patterns[s:next_ind])
                break
            endif
            let s:next_ind += 1
        endwhile
    endif
    if a:visual
        call add(s:visual_patterns, a:pattern)
    endif
endfunction

function! msearch#remove(pattern, ind, visual)
    call matchdelete(w:match_id_map[a:pattern])
    unlet s:color_map[a:pattern]
    let s:patterns[a:ind] = ''
    let s:next_ind = index(s:patterns, '')
    if a:visual
        unlet s:visual_patterns[a:pattern]
    endif
    let s:cur_search_pattern = ''
endfunction

function! msearch#clear()
    call clearmatches()
    let w:match_id_map = {}
    let s:patterns = []
    let s:visual_patterns = []
    let s:color_map = {}
    let s:next_ind = 0
    call s:inc_op_times()
endfunction

function! msearch#list()
    return filter(copy(s:patterns), "v:val != ''")
endfunction

function! msearch#joint_pattern()
    return join(msearch#list(), '\|')
endfunction

let s:search_cur=get(s:, 'search_cur', v:true)
function! msearch#toggle_jump()
    let s:search_cur = !s:search_cur
endfunction

function! msearch#jump(...)
    let l:search_flag = a:0>0 ? a:1 : ''
    if s:search_cur
        call msearch#jump_cur(l:search_flag)
    else
        call msearch#jump_all(l:search_flag)
    endif
endfunction

function! msearch#jump_all(search_flag)
    call search(msearch#joint_pattern(), a:search_flag)
endfunction

function! msearch#jump_cur(search_flag)
    let l:cur_line = getline('.')

    let l:pat_under_cursor = s:AsWordPattern(expand('<cword>'))
    if index(s:patterns, l:pat_under_cursor)>-1
        let s:cur_search_pattern = l:pat_under_cursor
    else
        for p in s:visual_patterns
            if match(l:cur_line, p) > -1
                let s:cur_search_pattern = p
            endif
        endfor
    endif

    if s:cur_search_pattern == ''
        call msearch#jump_all(a:search_flag)
        let s:cur_search_pattern = matchstr(l:cur_line[col('.')-1:], msearch#joint_pattern())
        if s:cur_search_pattern == expand('<cword>')
            let s:cur_search_pattern = s:AsWordPattern(s:cur_search_pattern)
        endif
    else
        call search(s:cur_search_pattern, a:search_flag)
    endif
endfunction

function! msearch#refresh_cur_win(timer)
    if get(w:, 'msearch_op_times', 0) != s:op_times
        let w:msearch_op_times = s:op_times
        call clearmatches()
        let w:match_id_map = get(w:, 'match_id_map', {})
        for [p, c] in items(s:color_map)
            let w:match_id_map[p] = matchadd('MSMatch'.c, p)
        endfor
    endif
endfunction
