scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:caption = "func_jump_button"
let s:caption2 = "func_jump_button"
let s:cflg = 0
let s:label = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
let s:labelcnt = 0
let s:buttons = ""
let s:bmanage = {
			\ "lst" : [],
			\ "all" : [],
			\ "tmp" : [],
			\ "manyflg" : 0,
			\}

function! func_jump_button#Init()
endfunction

" =================================================================
function! func_jump_button#SetButton(name, line, column)
	if a:name == "nul"
		let wd = expand("<cWORD>")
		if wd =~ "\\v<fu%[nction]\\!?>|<\\(?def%[ine]>"
			echo "Are you all right? " . wd
		endif
	else
		let wd = a:name
		if empty(wd) | let wd = "dmy" | endif
		let wd = wd . ":" . a:line 
	endif

	try
		let s:buttons = s:buttons . "\n&" . s:label[s:labelcnt] . " " . wd
	catch /.*/
		let s:buttons = s:buttons . "\n" . " " . wd
	endtry

	if s:buttons =~ "^\n"
		let s:buttons = s:buttons[1:len(s:buttons) - 1]
	endif
	let s:labelcnt += 1
endfunction

" =================================================================
function! func_jump_button#SetButtonAllFunc()
	let lines = getline(1, '$')
	let i = 1
	for line in lines
		if line =~ "\\v<fu%[nction]\\!?>"
			if line !~ "\\v\\("
				let i += 1
				continue
			endif
			if line !~ "\\vvar"
				if line !~ "\\v[\\(\\{\\+\\-\\!](function)@="
					let srt = match(line, "\\v\\S+\\(") 
					let endname = match(line, "\\v\\(")
				else
					let srt = 0
					let endname = match(line, "\\v\\(", 2)
				endif
			else
				let srt = matchend(line, "\\vvar\\s")
				let endname = match(line, "\\v\\s*\\=")
			endif
			let endname = endname - srt
			let funcname = strpart(line, srt, endname)
			call func_jump_button#SetButton(funcname, i, 1)
		endif
		let i += 1
	endfor
	let s:bmanage['all'] = split(s:buttons, "\n")
	let s:bmanage.tmp = deepcopy(s:bmanage.all)
	let length = len(s:bmanage.all)
	if length > 10
		let s:bmanage.manyflg = 1
		let s:caption = s:caption . "\nThere are " . length
					\ . " functions" . "\n<Esc> >>"
		let s:caption2 = strpart(s:caption, 0, strlen(s:caption) - 2)
	endif
endfunction

" =================================================================
function! func_jump_button#JumpButton()
	let default = &guioptions
	set guioptions+=v
	if s:bmanage.manyflg
		if !len(s:bmanage['all'])
			let s:bmanage['all'] = deepcopy(s:bmanage.tmp)
		endif
		try
			let s:bmanage.lst = remove(s:bmanage.all, 0, 10)
			let s:cflg = 1
		catch /.*/
			let s:bmanage.lst = remove(s:bmanage.all, 0, len(s:bmanage.all) - 1)
			let s:cflg = 0
		endtry
		let s:numls = [0]
		for btn in s:bmanage.lst
			call add(s:numls, matchstr(btn, "\\v\\d+"))
		endfor
		let s:buttons = join(s:bmanage.lst, "\n")
	else
		let s:numls = [0]
		for btn in s:bmanage['all']
			call add(s:numls, matchstr(btn, "\\v\\d+"))
		endfor
	endif
	let result = confirm(s:cflg ? s:caption : s:caption2, s:buttons)
	if empty(result)
		if s:bmanage.manyflg
			call func_jump_button#JumpButton()
		endif
		return
	else
		call extend(s:bmanage.lst, s:bmanage.all)
		let s:bmanage['all'] = deepcopy(s:bmanage.lst)
	endif
	try
		call cursor(s:numls[result], 1)
		normal zz
	catch /.*/
		throw "JumpButton: " . v:exception
		let &guioptions = default
		return
	endtry	

	let &guioptions = default
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
