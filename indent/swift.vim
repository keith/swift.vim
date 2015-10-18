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

setlocal indentkeys-=0{
setlocal indentkeys-=0}
setlocal indentkeys-=:
setlocal indentkeys-=e
setlocal indentkeys+=0[,0]
setlocal indentexpr=SwiftIndent(v:lnum)

function! s:NumberOfMatches(char, string)
  let regex = "[^" . a:char . "]"
  return strlen(substitute(a:string, regex, "", "g"))
endfunction

function! s:IsComment()
  return synIDattr(synID(line("."), col("."), 0), "name") ==# "swiftComment"
endfunction

function! s:IsCommentLine(lnum)
    return synIDattr(synID(a:lnum,
          \     match(getline(a:lnum), "\S") + 1, 0), "name")
          \ ==# "swiftComment"
endfunction

function! SwiftIndent(lnum)
  let line = getline(a:lnum)
  let previousNum = prevnonblank(a:lnum - 1)
  while s:IsCommentLine(previousNum) != 0
    let previousNum = prevnonblank(previousNum - 1)
  endwhile

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
    return previousIndent + shiftwidth()
  endif

  if currentCloseSquare > 0
    let openingSquare = searchpair("\[", "", "\]", "bWn", "s:ISComment()")

    return indent(openingSquare)
  endif

  if s:IsComment()
    return previousIndent
  endif

  if line =~ ":$"
    let switch = search("switch", "bWn")
    return indent(switch)
  elseif previous =~ ":$"
    return previousIndent + shiftwidth()
  endif

  if numOpenParens == numCloseParens
    if numOpenBrackets > numCloseBrackets
      if currentCloseBrackets > currentOpenBrackets
        let line = line(".")
        let column = col(".")
        let openingBracket = searchpair("{", "", "}", "bWn", "s:IsComment()")
        call cursor(line, column)
        return indent(openingBracket)
      endif

      return previousIndent + shiftwidth()
    elseif previous =~ "}.*{"
      return previousIndent + shiftwidth()
    elseif line =~ "}.*{"
      let openingBracket = searchpair("{", "", "}", "bWn", "s:IsComment()")
      return indent(openingBracket)
    elseif currentCloseBrackets > currentOpenBrackets
      let openingBracket = searchpair("{", "", "}", "bWn", "s:IsComment()")
      let bracketLine = getline(openingBracket)

      let numOpenParensBracketLine = s:NumberOfMatches("(", bracketLine)
      let numCloseParensBracketLine = s:NumberOfMatches(")", bracketLine)
      if numCloseParensBracketLine > numOpenParensBracketLine
        let line = line(".")
        let column = col(".")
        call cursor(openingParen, column)
        let openingParen = searchpair("(", "", ")", "bWn", "s:IsComment()")
        call cursor(line, column)
        return indent(openingParen)
      endif
      return indent(openingBracket)
    else
      return previousIndent
    endif
  endif

  if numCloseParens > 0
    if currentOpenBrackets > 0 || currentCloseBrackets > 0
      if currentOpenBrackets > 0
        if numOpenBrackets > numCloseBrackets
          return previousIndent + shiftwidth()
        endif

        if line =~ "}.*{"
          let openingBracket = searchpair("{", "", "}", "bWn", "s:IsComment()")
          return indent(openingBracket)
        endif

        if numCloseParens > numOpenParens
          let line = line(".")
          let column = col(".")
          call cursor(line - 1, column)
          let openingParen = searchpair("(", "", ")", "bWn", "s:IsComment()")
          call cursor(line, column)
          return indent(openingParen)
        endif

        return previousIndent
      endif

      if currentCloseBrackets > 0
        let openingBracket = searchpair("{", "", "}", "bWn", "s:IsComment()")
        return indent(openingBracket)
      endif

      return cindent
    endif

    if numCloseParens < numOpenParens
      if numOpenBrackets > numCloseBrackets
        return previousIndent + shiftwidth()
      endif

      let previousParen = match(previous, "(")
      return previousParen + 1
    endif

    if numOpenBrackets > numCloseBrackets
      let line = line(".")
      let column = col(".")
      call cursor(previousNum, column)
      let openingParen = searchpair("(", "", ")", "bWn", "s:ISComment()")
      call cursor(line, column)
      return indent(openingParen) + shiftwidth()
    endif

    let line = line(".")
    let column = col(".")
    call cursor(previousNum, column)
    let openingParen = searchpair("(", "", ")", "bWn", "s:ISComment()")
    call cursor(line, column)

    return indent(openingParen)
  endif

  if numOpenParens > 0
    let previousParen = match(previous, "(")
    return previousParen + 1
  endif

  return cindent
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save
