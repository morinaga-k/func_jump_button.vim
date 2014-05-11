" Vim plugin to jump in the place of function definition when you push the button.
" Auther: mh_033 <y326045@yahoo.co.jp>
" (c) 2014 mh_033
" License: MIT license


scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

if exists('g:loaded_func_jump_button')
	finish
endif
let g:loaded_func_jump_button = 1

" Commands
if !exists(':FuncJumpButton')
	command FuncJumpButton call func_jump_button#JumpButton() 
endif
if !exists(':FuncSetButton')
	command -nargs=+ FuncSetButton call func_jump_button#SetButton(<f-args>)
endif

" FileType 
augroup func_jump_button_all
	autocmd! 
	autocmd FileType vim,javascript,php,smarty
				\ call func_jump_button#SetButtonAllFunc()
augroup END	

" Offer plugs
nnoremap <silent> <Plug>(func_jump_button) :<c-u>FuncJumpButton<cr>
nnoremap <silent> <Plug>(func_set_button) :<c-u>FuncSetButton nul 0 0<cr>

" Default key mappings
if !hasmapto('<Plug>(func_jump_button)')
	nmap <unique> <silent> <C-j><C-b> <Plug>(func_jump_button)
endif
if !hasmapto('<Plug>(func_set_button)')
	nmap <unique> <silent> <C-s><C-b> <Plug>(func_set_button)
endif


let &cpo = s:save_cpo
unlet s:save_cpo


