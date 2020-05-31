if exists('g:msearch#loaded')
  finish
endif

let g:msearch#loaded = 1

let s:save_cpo = &cpo
set cpo&vim

noremap <silent> <unique> <script> <Plug>MSToggleAdd :call msearch#toggle_add(v:false)<cr>
noremap <silent> <unique> <script> <Plug>MSExclusiveAdd :call msearch#exclusive_add(v:false)<cr>
noremap <silent> <unique> <script> <Plug>MSVisualToggleAdd :<c-u>call msearch#toggle_add(v:true)<cr>
noremap <silent> <unique> <script> <Plug>MSVisualExclusiveAdd :<c-u>call msearch#exclusive_add(v:true)<cr>
noremap <silent> <unique> <script> <Plug>MSClear :call msearch#clear()<cr>
noremap <silent> <unique> <script> <Plug>MSToggleJump :call msearch#toggle_jump()<cr>
noremap <silent> <unique> <script> <Plug>MSNext :call msearch#jump()<cr>
noremap <silent> <unique> <script> <Plug>MSPrev :call msearch#jump('b')<cr>
noremap <silent> <unique> <script> <Plug>MSAllNext :call msearch#jump_all('')<cr>
noremap <silent> <unique> <script> <Plug>MSAllPrev :call msearch#jump_all('b')<cr>
noremap <silent> <unique> <script> <Plug>MSCurNext :call msearch#jump_cur('')<cr>
noremap <silent> <unique> <script> <Plug>MSCurPrev :call msearch#jump_cur('b')<cr>
noremap <unique> <script> <Plug>MSAddBySearchForward :call msearch#start_add_by_search(v:false)<cr>/
noremap <unique> <script> <Plug>MSAddBySearchBackward :call msearch#start_add_by_search(v:true)<cr>?

let g:Msearch_palette_fn = get(g:,'Msearch_palette_fn', function('msearch#palettes#default'))

augroup MSearchAugroup
    autocmd!
    autocmd! WinEnter * call timer_start(20, 'msearch#refresh_cur_win')
    autocmd! TabEnter * call msearch#refresh_all_win()
    autocmd! ColorScheme * call msearch#define_highlight(v:true)
augroup END


let &cpo = s:save_cpo
unlet s:save_cpo
