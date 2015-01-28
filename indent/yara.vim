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
	" get previous non-blank line
	let pnum = prevnonblank(v:lnum - 1)
	if pnum == 0
		return 0
	endif

	let line = getline(v:lnum)
	let pline = getline(pnum)
	let ind = indent(pnum)

	if pline =~ '^\s*\/\/'
		" Previous line is a comment, no change.
		return ind
	endif

	if pline =~ '^{' && line !~ '^\s*}'
		" Previous line is open brace. Increase indent.
		let ind += &sw
	elseif pline =~ '^\s*\(meta\|strings\|condition\):'
		" Previous line is keyword. Increase indent.
		let ind += &sw
	endif

	if line =~ '^}'
		" Current line is closing brace. Decrease indent.
		let ind = indent(s:OpenBrace(v:lnum))
	elseif line =~ '^\s*\(meta\|strings\|condition\)' && pline !~ '^{'
		" Current line is keyword, and not preceeded by line with open
		" brace. Decrease indent.
		let ind -= &sw
	endif

	return ind
endfunction
