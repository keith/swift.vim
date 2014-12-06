" File: swift.vim
" Author: Keith Smiley
" Description: The indent file for Swift
" Last Modified: December 05, 2014

if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

let s:cpo_save = &cpo
set cpo&vim

" setlocal indentexpr=SwiftIndent()

" setlocal cindent
" setlocal cinkeys+=*<Return>,<>>,=let,=func,=in
" setlocal cinwords+=let,func,in
" setlocal cinoptions+=:1,=4

setlocal indentkeys+=0[,0]
setlocal indentexpr=Foo(v:lnum)

function! s:NumberOfMatches(char, string)
  let regex = "[^" . a:char . "]"
  return strlen(substitute(a:string, regex, "", "g"))
endfunction

function! s:SyntaxGroup()
  return synIDattr(synID(line("."), col("."), 0), "name")
endfunction

function! s:IsComment()
  return s:SyntaxGroup() ==# 'swiftComment'
endfunction

function! Foo(lnum)
  let line = getline(a:lnum)
  let previousNum = prevnonblank(a:lnum - 1)
  let previous = getline(previousNum)
  let cindent = cindent(a:lnum)
  let previousIndent = indent(previousNum)

  let numOpenParens = s:NumberOfMatches("(", previous)
  let numCloseParens = s:NumberOfMatches(")", previous)
  let numOpenBrackets = s:NumberOfMatches("{", previous)
  let numCloseBrackets = s:NumberOfMatches("}", previous)

  let currentOpenBrackets = s:NumberOfMatches("{", line)
  let currentCloseBrackets = s:NumberOfMatches("}", line)

  let numOpenSquare = s:NumberOfMatches("[", previous)
  let numCloseSquare = s:NumberOfMatches("]", previous)

  let currentCloseSquare = s:NumberOfMatches("]", line)
  if numOpenSquare > numCloseSquare

    echom "squares"
    return previousIndent + shiftwidth()
  endif

  if currentCloseSquare > 0
    echom "close square"
    let openingSquare = searchpair('\[', '', '\]', 'bWn')
    echom "openiung sqaure " . openingSquare

    return indent(openingSquare)
  endif

  " if previous =~ ":$" && line !~ ":$"
  "   echom "30"
  "   return previousIndent + shiftwidth()
  " endif

  if s:IsComment()
    return previousIndent
  endif

  if line =~ ":$"
    echom "31"
    let switch = search('switch', 'bWn')
    return indent(switch)
    " return previousIndent
    " if indent(v:lnum) > indent(previousNum)
    "   echom "31"
    "   return indent(v:lnum) - &tabstop
    " else
    "   echom "32"
    "   return cindent
    " endif
  elseif previous =~ ":$"
    echom "previous case"
    return previousIndent + shiftwidth()
  endif

  if numOpenParens == numCloseParens
    if numOpenBrackets > numCloseBrackets

      if currentCloseBrackets > currentOpenBrackets
      echom "1"
        normal! mi
        " execute "normal! " . previousNum . "G"
        let openingBracket = searchpair("{", "", "}", "bWn")
        echom "openiung " . openingBracket
        normal! `i

        return indent(openingBracket)

      endif
      echom "15"
      " echom numOpenBrackets
      " echom numCloseBrackets
      " return cindent
      return previousIndent + shiftwidth()
    elseif currentCloseBrackets > currentOpenBrackets
      echom "2"
      normal! mi
      " execute "normal! " . previousNum . "G"
      let openingBracket = searchpair("{", "", "}", "bWn")
      echom "openiung " . openingBracket
      normal! `i

      return indent(openingBracket)
      " return cindent
    elseif previous =~ "}.*{"
      echom "machines"
      return previousIndent + shiftwidth()
    else
      echom "3"
      " echom numCloseBrackets
      " echom numOpenBrackets
      return previousIndent
    endif
  endif

  if numCloseParens > 0
    if currentOpenBrackets > 0 || currentCloseBrackets > 0
      if currentOpenBrackets > 0
        if numOpenBrackets > numCloseBrackets

          echom "100"
          return previousIndent + shiftwidth()
        endif

        if line =~ "}.*{"
          echom "101"

          normal! mi
          " execute "normal! " . previousNum . "G"
          let openingBracket = searchpair("{", "", "}", "bWn")
          echom "openiung " . openingBracket
          normal! `i

          return indent(openingBracket)
        endif

        if numCloseParens > numOpenParens
          echom "103"

          normal! mi
          normal! k
          let openingParen = searchpair("(", "", ")", "bWn")
          echom "openiung " . openingParen
          normal! `i
          return indent(openingParen)
        endif

        echom "102"
        return previousIndent
      endif

      if currentCloseBrackets > 0
        echom "104"
        " return previousIndent - shiftwidth()
        let openingBracket = searchpair("{", "", "}", "bWn")
        echom "openiung " . openingBracket
        " normal! `i

        return indent(openingBracket)
      endif
      echom "brackets"
      return cindent
    endif

    if numCloseParens < numOpenParens
      if numOpenBrackets > numCloseBrackets
        echom "21"
        return previousIndent + shiftwidth()
      endif

      echom "20"
      let previousParen = match(previous, "(")
      return previousParen + 1
    endif


    echom "22"
    normal! mi
    execute "normal! " . previousNum . "G"
    let openingParen = searchpair("(", "", ")", "bWn")
    echom "openiung " . openingParen
    normal! `i

    return indent(openingParen)
  endif

  if numOpenParens > 0
    echom "had one opening before"
    let previousParen = match(previous, "(")
    return previousParen + 1
  endif



  echom "4"
  return cindent
endfunction

function! SwiftIndent()
  let line = getline(v:lnum)
  let previousNum = prevnonblank(v:lnum - 1)
  let previous = getline(previousNum)

  if previous =~ "{" && previous !~ "}" && line !~ "}" && line !~ ":$"
    normal! mi
    if previous =~ ")"
      normal! k
    elseif getline(previousNum - 1) =~ ")" && getline(previousNum - 1) !~ ")"
      normal! kk
    else
      return indent(previousNum) + &tabstop
    endif

    let openingParen = searchpair("(", "", ")", "bW")
    normal! `i
    return indent(openingParen) + &tabstop
  endif

  if previous =~ "[" && previous !~ "]" && line !~ "]" && line !~ ":$"
    return indent(previousNum) + &tabstop
  endif

  if line =~ "^\\s*],\\?$"
    return indent(previousNum) - &tabstop
  endif

  " Indent multi line declarations see #19
  " Allow statements to also be in parens
  let numOpenParens = s:NumberOfMatches("(", previous)
  let numCloseParens = s:NumberOfMatches(")", previous)
  if numOpenParens != 0 && (numOpenParens > numCloseParens)
    let previousParen = match(previous, "(")
    " Indent second line 1 space past above paren
    return previousParen + 1
    " Indent it one tabstop in
    " return indent(previousNum) + &tabstop
  elseif numCloseParens > 0
    " Indent lines with only { on them
    if line =~ "^\\s*{\\s*$"
      normal! mik
      let startingIndent = indent(searchpair("(", "", ")", "bW"))
      normal! `i
      return startingIndent
    else
      " Indent lines after multi-line arguments
      return indent(searchpair("(", "", ")", "bW"))
    endif
  endif

  if previous =~ ":$" && line !~ ":$"
    return indent(previousNum) + &tabstop
  endif

  if line =~ ":$"
    if indent(v:lnum) > indent(previousNum)
      return indent(v:lnum) - &tabstop
    else
      return indent(v:lnum)
    endif
  endif

  " Correctly indent bracketed things when using =
  if line =~ "}"
    let newIndent = &tabstop
    " The line match fixes issues here brackets in strings affect indentation
    if previous =~ "{" || line =~ "{"
      let newIndent = 0
    endif
    return indent(previousNum) - newIndent
  endif

  return indent(previousNum)
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save
