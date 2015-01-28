if exists("b:did_indent")
	finish
endif
let b:did_indent = 1

setlocal autoindent smartindent
setlocal indentexpr=GetYaraIndent()
setlocal indentkeys+=0=metadata,0=strings,0=condition

if exists("*GetYaraIndent")
	finish
endif

function! s:OpenBrace(lnum)
	call cursor(a:lnum, 1)
	return searchpair('{\|\[\|(', '', '}\|\]\|)', 'nbW')
endfunction

function! GetYaraIndent()
	let pnum = prevnonblank(v:lnum - 1)
	if pnum == 0
		return 0
	endif

	let line = getline(v:lnum)
	let pline = getline(pnum)
	let ind = indent(pnum)

	if pline =~ '^\s*//'
		return ind
	endif

	if pline =~ '^{'
		let ind += &sw
	elseif pline =~ '^\s\+\(meta\|strings\|condition\):'
		let ind += &sw
	endif

	if line =~ '^}'
		let ind = indent(s:OpenBrace(v:lnum))
	elseif line =~ '^\s\+\(meta\|strings\|condition\):'
		let ind -= &sw
	endif

	return ind
endfunction
