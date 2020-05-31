msearch.vim
=============

msearch.vim enables user to highlight multiple search patterns. It's useful for code tracing for source code with very long variable names. msearch.vim is highly inspired by the [vim-mark](https://github.com/inkarkat/vim-mark) plugin but is developed with a dedicated workflow bared in mind:

1. The mappings `/`, `?`, `n`, `N`, `*` should work as in vanilla vim.
2. Extend `/` and `?` maintaing a list of searched patterns.
3. Extend `n` and `N` with an extra mode to jump on multiple searched patterns.
4. Extend `*` with an extra mode to highlight multiple searched patterns.

The result is a more compact but easy-to-use user interface (possibly missing some functionalities in vim-mark which doesn't involve the aforementioned workflow). msearch.vim provides no default mapping, users can map all plugin mappings to suit their work-flow need. A suggested mapping is as follows:

```vim
" Mapping 8 might be controversial. But it's unlikely that you would use
" it as |count|. To goto a line, instead of 8|G|, you can do :8 instead.
nmap 8 <Plug>MSToggleAdd
nmap * <Plug>MSExclusiveAdd
vmap 8 <Plug>MSVisualToggleAdd
vmap * <Plug>MSVisualExclusiveAdd
nmap <leader>/ <Plug>MSClear

" If you don't mind remember two mappings for two searching modes...
nmap n <Plug>MSCurNext
nmap N <Plug>MSCurPrev
nmap <leader>n <Plug>MSAllNext
nmap <leader>N <Plug>MSAllPrev

" Otherwise, you might like the following setting which toggles the two
" searching modes with a single mapping.
nmap n <Plug>MSNext
nmap N <Plug>MSPrev
nmap <leader>n <Plug>MSToggleJump

nmap / <Plug>MSAddBySearchForward
nmap ? <Plug>MSAddBySearchBackward
```

## Installation
------------

Using vim-plug

```viml
Plug 'ipod825/msearch.vim'
```


## Related
------------
- [vim-mark](https://github.com/inkarkat/vim-mark)
