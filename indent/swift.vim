" Vim indent file
" Language: swift
" Author: Aaron Bohannon <bohannon@cis.upenn.edu>

" DESCRIPTION:
"
"   Provides indentation support for the Swift programming language.  This
"   plugin cannot stand entirely on its own.  It depends upon having support for
"   syntax highlighting so that it can determine whether any given bracket
"   character in the file should affect the indentation.  It will ignore bracket
"   characters that are in a syntax group with a name matching one of these
"   patterns: `swiftComment`, `swiftLineComment`, `swiftString`,
"   `swiftInterpolated*`.

" CONFIGURATION:
"
"   The following variables can be defined in order to control the indentation:
"
"     - g:swiftIndentAfterBrace             (default: 1 * shiftwidth())
"     - g:swiftIndentAfterSquareBracket     (default: 1 * shiftwidth())
"     - g:swiftIndentAfterParenthesis       (default: 2 * shiftwidth())
"     - g:swiftIndentAfterAngleBracket      (default: 4 * shiftwidth())
"     - g:swiftIndentSwitchCasePattern      (default: 0 * shiftwidth())
"     - g:swiftIndentSwitchCaseBody         (default: 1 * shiftwidth())
"     - g:swiftIndentStatementContinuation  (default: 2 * shiftwidth())
"
"   The values for `g:swiftIndentSwitchCasePattern` and for
"   `g:swiftIndentSwitchCaseBody` are both interpreted as relative to
"   the indentation of the `switch` keyword.  The value for
"   `g:swiftIndentStatementContinuation` applies to situations like those where
"   a line break occurs before the `where` keyword within a `case` statement or
"   `for` statement.

" KNOWN ISSUES:
"
"   - A line beginning with `#line` is always interpreted as a line control
"     statement (and assigned an indent of 0).  This is not necessarily correct
"     in every situation since `#line` can also be used as a literal within an
"     expression.
"
"   - No additional indentation is added as the result of a binary operator
"     occurring before or after a line break.  You can ensure that additional
"     indentation will be added after the line breaks within an expression by
"     wrapping the entire expression in parentheses.
"
"   - This plugin is designed to add extra indentation after line breaks that
"     occur between a pair of opening and closing angle brackets.  To achieve
"     this behavior, it is necessary for this plugin to determine whether a
"     given occurrence of `<` or `>` is functioning as a bracket around a type
"     parameter or as part of an operator token.  This ambiguity is
"     troublesome even for full-scale parser implementations, so this plugin
"     cannot be expected to correctly handle every case that is theoretically
"     possible.  However, you should always be able to get this plugin to
"     correctly interpret the meaning of the `<` and `>` symbols by adding or
"     removing whitespace or parentheses in an appropriate manner, and
"     alterations of that sort shouldn't be necessary for code that follows
"     common conventions.  You will not encounter any problems at all if you
"     follow three simple rules: (1) put whitespace on both sides of binary
"     operators, (2) don't begin a line with a binary operator, and (3) never
"     put whitespace before a closing `>` bracket.  However, there happen to be
"     a couple of common idioms in Swift that violate those rules (for instance,
"     expressions like `0..<5` or `a..<b`).  This plugin can be expected to
"     handle those idioms properly, but having that capability makes the
"     behavior of the plugin far more difficult to describe.  Here is a precise
"     description of Swift code that will be properly understood by this plugin:
"
"       * If the symbol `<` is intended to serve as a bracket, then one of the
"         following conditions must be met:
"
"           - it occurs at the end of a line beginning with the keyword `func`
"           - it is immediately preceded by the pattern `[A-Za-z0-9_]`
"           - it is immediately followed by the pattern `[A-Z_([]`
"
"         Otherwise, the symbol will be interpreted as part of an operator.
"
"       * If the symbol `>` is intended to serve as a bracket and it is *not*
"         the first character on a line, then it must either be immediately
"         preceded by a character matching `[A-Za-z0-9_>?!)\]]`.
"
"       * If the symbol `>` is the first character on a line and is intended to
"         serve as part of an operator, then one of the following conditions
"         must be met:
"
"           - it is followed by the pattern `>*[^>([:blank:]]` (i.e., it is part
"             of an operator that contains a character other than `>`)
"           - the previous line of code matches `^.*([^()]*$` (i.e., the
"             previous line of code contains an unclosed parenthesis)
"           - the previous line of code matches this regex: '^\s*>\+[^>,]\s*\S'
"             (i.e. the previous line of code also begins with an operator whose
"             first character is `>`)
"
"         Otherwise, the symbol will be interpreted as a bracket.
"
"   - When a closing `>` bracket appears at the start of a line, it will always
"     be indented as though it were an operator rather than indented in a manner
"     that matches situations in which other sorts of brackets appear at the
"     beginning of a line.
"
"   - This plugin might help you detect syntactic errors in your code, but it is
"     not designed for that purpose -- nor is it designed with error recovery in
"     mind.  It is designed to provide useful behavior only when the buffer
"     being edited contains the prefix of some valid Swift file.

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if exists('b:did_indent')
  finish
endif
let b:did_indent = 1

let s:save_cpo = &cpo
set cpo&vim

setlocal nosmartindent
setlocal indentkeys-=e
setlocal indentkeys-=:
setlocal indentkeys+=0]
setlocal indentkeys+=0)
setlocal indentkeys+=0>
setlocal indentkeys+==case
setlocal indentkeys+==default
setlocal indentexpr=GetSwiftIndent()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Configuration
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:indentAfterBrace = 1 * shiftwidth()
let s:indentAfterSquareBracket = 1 * shiftwidth()
let s:indentAfterParenthesis = 2 * shiftwidth()
let s:indentAfterAngleBracket = 4 * shiftwidth()
let s:indentSwitchCasePattern = 0 * shiftwidth()
let s:indentSwitchCaseBody = 1 * shiftwidth()
let s:indentStatementContinuation = 2 * shiftwidth()

function! s:GetRelativeIndent(type)
  return get(g:, 'swiftIndent' . a:type, s:indent{a:type})
endfunction

function! s:ExtraIndentForUnclosedBrackets(unclosedBrackets)
  let extraIndent = 0
  for bracket in a:unclosedBrackets
    if bracket == '{'
      let extraIndent += s:GetRelativeIndent('AfterBrace')
    elseif bracket == '['
      let extraIndent += s:GetRelativeIndent('AfterSquareBracket')
    elseif bracket == '('
      let extraIndent += s:GetRelativeIndent('AfterParenthesis')
    elseif bracket == '<'
      let extraIndent += s:GetRelativeIndent('AfterAngleBracket')
    endif
  endfor
  return extraIndent
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Memoization
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Performance improves dramatically if results from frequently called functions
" are memoized.  However, we want the results of memoization to persist across
" multiple independent invocations of the `GetSwiftIndent()` function if the
" buffer has not been changed.  This is a common situation since it occurs
" whenever the user reformats multiple lines at once.  So, we will store the
" memoized results of the function in a buffer-local cache that will be
" considered invalid after any change to `b:changedtick` or after we have
" entered insert mode.  (This latter case must be considered separately since
" entering insert mode and typing characters does not increment `b:changedtick`
" -- it is typically updated upon leaving insert mode.)

let b:swiftIndentResultCache = {}
let b:swiftIndentResultCacheValidThroughTick = -1

function! s:ResultCacheHasExpired()
  return (mode() =~# 'i\|R')
      \ || (b:swiftIndentResultCacheValidThroughTick < b:changedtick)
endfunction

function! s:PrepareResultCache()
  if s:ResultCacheHasExpired()
    let b:swiftIndentResultCache = {}
    let b:swiftIndentResultCacheValidThroughTick = b:changedtick
  endif
endfunction

" This function will be used to cache values associated with the position of a
" character in the buffer.  It describes the position in a way that is valid
" even after a line's indentation has has changed.
function! s:TextLocationID(lnum, cnum)
  return string([a:lnum, a:cnum - indent(a:lnum)])
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Character classification
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:TEXT_TYPE_NORMAL = 0
let s:TEXT_TYPE_BRACKET = 1
let s:TEXT_TYPE_STRING = 2
let s:TEXT_TYPE_CONFIGURATION = 3
let s:TEXT_TYPE_WHITESPACE = 4
let s:TEXT_TYPE_COMMENT = 5

function! s:TextTypeString(textType)
  if a:textType == s:TEXT_TYPE_NORMAL
    return "NORMAL"
  elseif a:textType == s:TEXT_TYPE_BRACKET
    return "BRACKET"
  elseif a:textType == s:TEXT_TYPE_STRING
    return "STRING"
  elseif a:textType == s:TEXT_TYPE_CONFIGURATION
    return "CONFIGURATION"
  elseif a:textType == s:TEXT_TYPE_WHITESPACE
    return "WHITESPACE"
  elseif a:textType == s:TEXT_TYPE_COMMENT
    return "COMMENT"
  else
    return "<unknown>"
  endif
endfunction

function! s:GetCharacter(lnum, cnum)
  return getline(a:lnum)[a:cnum - 1]
endfunction

function! s:SyntaxName(lnum, cnum)
  return synIDattr(synID(a:lnum, a:cnum, 0), 'name')
endfunction

function! s:SearchLineAtColumn(lnum, cnum, patternBefore, patternAt)
  let pattern = printf('\C%s\%%%dc%s', a:patternBefore, a:cnum, a:patternAt)
  return match(getline(a:lnum), pattern) >= 0
endfunction

function! s:SearchStartOfLineForOneOf(lnum, patterns)
  for pattern in a:patterns
    if getline(a:lnum) =~# ('^\s*' . pattern)
      return 1
    endif
  endfor
  return 0
endfunction

function! s:ComputeTextType(lnum, cnum)
  let character = s:GetCharacter(a:lnum, a:cnum)
  call s:DebugMsg('character at (%d, %d) is "%s"', a:lnum, a:cnum, character)
  let syntaxName = s:SyntaxName(a:lnum, a:cnum)
  call s:DebugMsg('syntax name is "%s"', syntaxName)

  if s:SearchStartOfLineForOneOf(a:lnum,
      \ ['#if\>', '#elseif\>', '#else\>', '#endif\>', '#line\>'])
    return s:TEXT_TYPE_CONFIGURATION
  endif
  if syntaxName =~# 'swift\%(Line\)\?Comment'
    return s:TEXT_TYPE_COMMENT
  elseif syntaxName =~# 'swiftString'
    return s:TEXT_TYPE_STRING
  elseif syntaxName =~# 'swiftInterpolated*'
    return s:TEXT_TYPE_STRING
  elseif character ==# '<'
    if s:SearchLineAtColumn(a:lnum, a:cnum, '\s*func\s.*', '<\s*\%(//.*\)\?$')
      return s:TEXT_TYPE_BRACKET
    elseif s:SearchLineAtColumn(a:lnum, a:cnum, '[A-Za-z0-9_]', '<')
      return s:TEXT_TYPE_BRACKET
    elseif s:SearchLineAtColumn(a:lnum, a:cnum, '', '<[A-Z_([]')
      return s:TEXT_TYPE_BRACKET
    else
      return s:TEXT_TYPE_NORMAL
    endif
  elseif character ==# '>'
    if s:SearchLineAtColumn(a:lnum, a:cnum, '[A-Za-z0-9_?!)\]]>*', '>')
      return s:TEXT_TYPE_BRACKET
    elseif s:SearchLineAtColumn(a:lnum, a:cnum, '^\s*>*', '>>*[^>([:blank:]]')
      return s:TEXT_TYPE_NORMAL
    elseif s:SearchLineAtColumn(a:lnum, a:cnum, '^\s*>*', '>')
      " Note: this next line can call this function recusively but will do so
      " only with a value of `a:lnum` that is strictly smaller.
      let previousLineText = getline(s:PreviousNormalLine(a:lnum))
      if previousLineText =~# '^.*([^()]*$'
        return s:TEXT_TYPE_NORMAL
      elseif previousLineText =~# '^\s*>\+[^>,]\s*\S'
        return s:TEXT_TYPE_NORMAL
      else
        return s:TEXT_TYPE_BRACKET
      endif
    else
      return s:TEXT_TYPE_NORMAL
    endif
  elseif stridx('[({})]', character) >= 0
    return s:TEXT_TYPE_BRACKET
  elseif character =~# '\s'
    return s:TEXT_TYPE_WHITESPACE
  else
    return s:TEXT_TYPE_NORMAL
  endif
endfunction

function! s:GetTextType(lnum, cnum)
  let key = s:TextLocationID(a:lnum, a:cnum)
  if has_key(b:swiftIndentResultCache, key)
    return b:swiftIndentResultCache[key]
  endif
  let lineKey = string(a:lnum)
  if has_key(b:swiftIndentResultCache, lineKey)
      \ && (b:swiftIndentResultCache[lineKey] != s:TEXT_TYPE_NORMAL)
    let result = b:swiftIndentResultCache[lineKey]
  else
    let result = s:ComputeTextType(a:lnum, a:cnum)
    if result == s:TEXT_TYPE_CONFIGURATION
      " In this one case, we know the result applies to the entire line.
      let b:swiftIndentResultCache[lineKey] = result
    endif
  endif
  let b:swiftIndentResultCache[key] = result
  return result
endfunction

function! s:GetLineType(lnum)
  let lineKey = string(a:lnum)
  if has_key(b:swiftIndentResultCache, lineKey)
    return b:swiftIndentResultCache[lineKey]
  endif
  if getline(a:lnum) =~# '^\s*$'
    let result = s:TEXT_TYPE_WHITESPACE
  else
    let type = s:GetTextType(a:lnum, indent(a:lnum) + 1)
    if (type == s:TEXT_TYPE_CONFIGURATION) || (type == s:TEXT_TYPE_COMMENT)
      let result = type
    else
      let result = s:TEXT_TYPE_NORMAL
    endif
  endif
  let b:swiftIndentResultCache[lineKey] = result
  return result
endfunction

" Returns the largest line number that is strictly smaller than `a:lnum` such
" that `s:GetLineType(a:lnum) == s:TEXT_TYPE_NORMAL`.  Returns 0 if no such line
" exists.
function! s:PreviousNormalLine(lnum)
  let l:lnum = a:lnum - 1
  while (l:lnum > 0) && (s:GetLineType(l:lnum) != s:TEXT_TYPE_NORMAL)
    let l:lnum -= 1
  endwhile
  return l:lnum
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Text inspection functions
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:GetCharacterUnderCursor()
  return getline('.')[col('.') - 1]
endfunction

function! s:CharacterUnderCursorIsNotBracket()
  return s:GetTextType(line('.'), col('.')) != s:TEXT_TYPE_BRACKET
endfunction

function! s:LineOfCodeEndsWithCharacter(lnum, character)
  let line = getline(a:lnum)
  " The regex below accounts for both trailing whitespace and line comments.
  let matchPos = match(line, '\S\s*\%(//.*\)\?$')
  if matchPos < 0
    return 0
  else
    return line[matchPos] ==# a:character
  endif
endfunction

function! s:PreviousLineWithSmallerIndent(lnum)
  if indent(a:lnum) == 0
    return 0
  endif
  let l:lnum = s:PreviousNormalLine(a:lnum)
  while indent(l:lnum) >= indent(a:lnum)
    let l:lnum = s:PreviousNormalLine(l:lnum)
  endwhile
  return l:lnum
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Code processing functions
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Returns non-zero if successful.  Finds opening brackets regardless of whether
" the buffer contains a matching closing bracket.
function! s:MoveCursorBackToEnclosingOpeningBracket(
    \ lnumStop, allowMatchAtCursor)
  let flags = a:allowMatchAtCursor ? 'bcW' : 'bW'
  return searchpair('[<([{]', '', '[}\])>]', flags,
      \ 's:CharacterUnderCursorIsNotBracket()', a:lnumStop)
endfunction

" Returns non-zero if successful.
function! s:MoveCursorBackToNearestClosingBracket(lnumStop, allowMatchAtCursor)
  let flags = a:allowMatchAtCursor ? 'bcW' : 'bW'
  " The implementation of this function is counter-intuitive.  One would expect
  " to see the `search()` function used here; however, using that function would
  " be difficult since it is crucial that the cursor not be moved if no
  " acceptable match is found.  Unlike the `search()` function, the
  " `searchpair()` function can be supplied with a pattern specifying which
  " matches should be ignored.  Thus, we (ab)use the `searchpair()` function
  " here, tricking it into thinking that closing brackets are actually unmatched
  " opening brackets.
  return searchpair('[}\])>]', '', '$^', flags,
      \ 's:CharacterUnderCursorIsNotBracket()', a:lnumStop)
endfunction

" Returns non-zero if successful.  This function is intended to be called only
" when the character under the cursor is a closing bracket.
function! s:MoveCursorBackToMatchingOpeningBracket()
  return searchpair('[<([{]', '', '[}\])>]', 'bW',
      \ 's:CharacterUnderCursorIsNotBracket()')
endfunction

" The term "clause" will be used to denote any contiguous sequence of lines in
" that contains a well-balanced sequence of brackets.  This function moves the
" cursor to the first line of the smallest clause that includes the cursor's
" initial location.  As it does this, every unmatched opening bracket that
" is encountered between the cursor's initial location and the beginning of the
" clause will be recorded.
function! s:MoveCursorToFirstLineOfClause(unclosedBrackets, firstInvocation)
  if s:MoveCursorBackToEnclosingOpeningBracket(line('.'), a:firstInvocation)
    call add(a:unclosedBrackets, s:GetCharacterUnderCursor())
    return s:MoveCursorToFirstLineOfClause(a:unclosedBrackets, 0)
  elseif s:MoveCursorBackToNearestClosingBracket(line('.'), a:firstInvocation)
    if s:MoveCursorBackToMatchingOpeningBracket()
      return s:MoveCursorToFirstLineOfClause(a:unclosedBrackets, 0)
    else
      " Indicates mismatched brackets.
      return 0
    endif
  else
    return line('.')
  endif
endfunction

" For the purposes of this plugin, a "statement" is a clause that meets four
" conditions:
"   A. with respect to its indentation, the first line of the clause is at the
"      top level of a block of code -- i.e., its nearest enclosing brackets (if
"      it has any) are braces (`{`/`}`), and no line between it and the previous
"      unclosed `{` (or the beginning of the file) has strictly less indentation
"   B. none of the lines of the clause is indented less than the first
"   C. the line immediately after the clause is not indented more than the last
"      line of the clause -- unless the line ends with a `:`
"   D. the line immediately after the clause does not begin with an opening
"      brace
"
" As an example, consider these four lines of code:
"
"   1:  for i in 0 ..< 10
"   2:       where (i % 2) == 0 {
"   3:    f(i)
"   4:  }
"
" Line 1 alone is a clause, and lines 2-4 are also a clause; however, neither of
" those two clauses are statements.  There are only two statements that can be
" identified: line 3 alone and lines 1-4 together.
"
" The function below is designed to find the first line of the smallest
" statement that includes the cursor's initial location -- and will return that
" line number -- but only in cases where the end of the smallest clause that
" includes the cursor's location is the suffix of some statement, as would be
" the case in the example above if the cursor began on line 2.  This function
" must only search backward from the cursor location, though.  So, it does not
" return 0 unless it is clear that the ending of the immediate clause could not
" somehow be made into the ending of a statement by adjusting the indentation of
" the following lines.  Regardless of the return value, the cursor will be moved
" to the nearest enclosing opening bracket relative to its initial location (if
" there is such an enclosing opening bracket).
function! s:FindFirstLineOfStatement()
  " We begin by addressing condition D.
  let lnumPrevCode = s:PreviousNormalLine(line('.'))
  while s:SearchStartOfLineForOneOf(line('.'), ['{'])
    call s:DebugMsg(
        \ 'searching upward past line %d for start of statement',
        \ line('.'))
    call cursor(lnumPrevCode, col([lnumPrevCode, '$']))
    if !s:MoveCursorToFirstLineOfClause([], 1)
      return 0
    endif
    let lnumPrevCode = s:PreviousNormalLine(line('.'))
  endwhile
  " Now we address condition A.
  let lnumCurrent = line('.')
  if s:MoveCursorBackToEnclosingOpeningBracket(1, 0)
    let bracket = s:GetCharacterUnderCursor()
    if bracket !=# '{'
      call s:DebugMsg('clause is enclosed by %s', bracket)
      return 0
    endif
    let lnumEnclosingScopeBoundary = line('.')
  else
    " We're already at the top level of the file.
    let lnumEnclosingScopeBoundary = 0
  endif
  " Now we address conditions B and C.
  let lnumParent = s:PreviousLineWithSmallerIndent(lnumCurrent)
  while lnumParent > lnumEnclosingScopeBoundary
      \ && !s:LineOfCodeEndsWithCharacter(lnumParent, ':')
    let lnumCurrent = lnumParent
    let lnumParent = s:PreviousLineWithSmallerIndent(lnumCurrent)
  endwhile
  return lnumCurrent
endfunction

" Returns a dictionary with the following fields:
"   - `unclosedBrackets`: List of unbalanced opening bracket characters
"     encountered between the cursor and the first line of the smallest clause
"     that includes the cursor's initial position.
"   - `lnumClause`: First line of the smallest clause that encompassed the
"     cursor's initial position.  If obvious syntax errors are encountered, this
"     will be 0.
"   - `lnumStatement`: First line of the smallest statement that encompassed the
"     cursor's initial position.  If the buffer contains no syntax errors and
"     this value is 0, it means that the cursor began in a context where
"     indentation can be determined without examining that statement.
"   - `lnumEnclosingStatement`: First line of the smallest statement that
"     includes the nearest enclosing brackets around `lnumStatement`.  If the
"     buffer contains no syntax errors and this value is 0, it means that the
"     cursor began in a context where indentation can be determined without
"     examining this statement.  The only reason to examine this statement is to
"     know whether we are inside a `switch` body, where special rules for
"     indentation are used.
function! s:GatherCursorContext()
  let result = {
      \ 'unclosedBrackets': [],
      \ 'lnumClause': 0,
      \ 'lnumStatement': 0,
      \ 'lnumEnclosingStatement': 0
      \ }
  let result.lnumClause = s:MoveCursorToFirstLineOfClause(
      \ result.unclosedBrackets, 1)
  if result.lnumClause > 0
    let result.lnumStatement = s:FindFirstLineOfStatement()
  endif
  if result.lnumStatement > 0
    let result.lnumEnclosingStatement = s:FindFirstLineOfStatement()
  endif

  call s:DebugMsg('unclosedBrackets = %s', string(result.unclosedBrackets))
  call s:DebugMsg('lnumClause = %d', result.lnumClause)
  call s:DebugMsg('lnumStatement = %d', result.lnumStatement)
  call s:DebugMsg('lnumEnclosingStatement = %d', result.lnumEnclosingStatement)

  return result
endfunction

function! s:FindCasePatternTerminationLine(lnumStart, lnumMax)
  if a:lnumStart >= a:lnumMax
    return -1
  elseif s:LineOfCodeEndsWithCharacter(a:lnumStart, ':')
    return a:lnumStart
  else
    return s:FindCasePatternTerminationLine(a:lnumStart + 1, a:lnumMax)
  endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" GetSwiftIndent()
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! GetSwiftIndent()
  call s:PrepareResultCache()
  let lnumCurrent = line('.')

  let lineType = s:GetLineType(lnumCurrent)
  if lineType == s:TEXT_TYPE_COMMENT
    call s:DebugMsg('---- line is a comment ----')
    return -1
  elseif lineType == s:TEXT_TYPE_CONFIGURATION
    call s:DebugMsg('---- line is a build configuration statement ----')
    return 0
  endif

  " In the test below, we ignore the possibility of a `>` bracket for simplicity
  " since a `>` may also appear at the start of a line as part of an operator.
  if s:SearchStartOfLineForOneOf(lnumCurrent, ['}', ']', ')'])
    normal! ^
    if s:MoveCursorBackToMatchingOpeningBracket() == 0
      return -1
    endif
    let context = s:GatherCursorContext()
    if context.lnumClause == 0
      return -1
    endif

    " We remove the first unclosed bracket from the list since it will be
    " matched by the closing bracket at the beginning of the line `lnumCurrent`.
    call remove(context.unclosedBrackets, 0)

    if s:SearchStartOfLineForOneOf(lnumCurrent, ['}'])
        \ && empty(context.unclosedBrackets)
        \ && (context.lnumStatement != 0)
      call s:DebugMsg('---- line terminates code block ----')
      return indent(context.lnumStatement)
    else
      call s:DebugMsg('---- line begins with }/]/) ----')
      return indent(context.lnumClause)
          \ + s:ExtraIndentForUnclosedBrackets(context.unclosedBrackets)
    endif
  endif

  if s:SearchStartOfLineForOneOf(lnumCurrent, ['\<case\>', '\<default\>'])
    normal! $
    let context = s:GatherCursorContext()
    if context.lnumClause == 0
      return -1
    endif

    if s:SearchStartOfLineForOneOf(
        \ context.lnumEnclosingStatement, ['\<switch\>'])
      call s:DebugMsg('---- line begins switch case pattern ----')
      return indent(context.lnumEnclosingStatement)
          \ + s:GetRelativeIndent('SwitchCasePattern')
    endif
  endif

  let lnumPrevCode = s:PreviousNormalLine(lnumCurrent)
  call cursor(lnumPrevCode, col([lnumPrevCode, '$']))
  let context = s:GatherCursorContext()
  if context.lnumClause == 0
    return -1
  endif

  if s:SearchStartOfLineForOneOf(lnumCurrent, ['{'])
    if empty(context.unclosedBrackets) && (context.lnumStatement != 0)
      call s:DebugMsg('---- line begins with { (statement level) ----')
      return indent(context.lnumStatement)
    else
      call s:DebugMsg('---- line begins with { (expression level) ----')
      return indent(context.lnumClause)
          \ + s:ExtraIndentForUnclosedBrackets(context.unclosedBrackets)
    endif
  endif

  if context.unclosedBrackets == ['{']
    if context.lnumStatement != 0
      call s:DebugMsg('---- first line of code block (statement level) ----')
      return indent(context.lnumStatement) + s:GetRelativeIndent('AfterBrace')
    else
      call s:DebugMsg('---- first line of code block (expression level) ----')
      return indent(context.lnumClause) + s:GetRelativeIndent('AfterBrace')
    endif
  endif

  if s:LineOfCodeEndsWithCharacter(lnumPrevCode, '}')
    if empty(context.unclosedBrackets)
        \ && (context.lnumStatement != 0)
      call s:DebugMsg('---- line follows code block (statement level) ----')
      return indent(context.lnumStatement)
    else
      " This would be quite peculiar.
      call s:DebugMsg('---- line follows code block (expression level) ----')
      return indent(context.lnumClause)
          \ + s:ExtraIndentForUnclosedBrackets(context.unclosedBrackets)
    endif
  endif

  if s:SearchStartOfLineForOneOf(context.lnumStatement, [
      \ '\<func\>',
      \ '\<for\>',
      \ '\<while\>',
      \ '\<repeat\>',
      \ '\<if\>',
      \ '\<else\>',
      \ '\<guard\>',
      \ '\<switch\>',
      \ '\<defer\>',
      \ '\<do\>',
      \ '\<catch\>',
      \ '\<deinit\>'
      \ ])
      \ && empty(context.unclosedBrackets)
    " This applies to lines of code that begin in a context where the
    " opening `{` for a code block is expected but has not yet occurred.
    call s:DebugMsg('---- line continues unfinished statement ----')
    return indent(context.lnumStatement)
        \ + s:GetRelativeIndent('StatementContinuation')
  endif

  if s:SearchStartOfLineForOneOf(
      \ context.lnumStatement, ['\<case\>', '\<default\>'])
      \ && s:SearchStartOfLineForOneOf(context.lnumEnclosingStatement,
      \    ['\<switch\>'])
      \ && empty(context.unclosedBrackets)
    if s:FindCasePatternTerminationLine(context.lnumStatement, lnumCurrent) < 0
      call s:DebugMsg('---- line continues an unfinished case pattern ----')
      return indent(context.lnumStatement)
          \ + s:GetRelativeIndent('StatementContinuation')
    else
      call s:DebugMsg('---- line in a switch case body ----')
      return indent(context.lnumEnclosingStatement)
          \ + s:GetRelativeIndent('SwitchCaseBody')
    endif
  endif

  " At this point, we should have exhausted all of the situations in which the
  " the surrounding statement differs from the surrounding clause and is
  " relevant to the indentation of this line.
  call s:DebugMsg('---- line continues previous clause (default) ----')
  return indent(context.lnumClause)
      \ + s:ExtraIndentForUnclosedBrackets(context.unclosedBrackets)
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Debugging
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:DebugMsg(...)
  if exists('s:debug') && s:debug
    if a:0 > 1
      echo call('printf', a:000)
    else
      echo a:1
    endif
  endif
endfunction

function! DebugSwiftTextType()
  let s:debug = 1
  let b:swiftIndentResultCache = {}
  let result = s:TextTypeString(s:GetTextType(line('.'), col('.')))
  unlet s:debug
  return result
endfunction

function! DebugSwiftIndent(...)
  let s:debug = 1
  let savedPosition = getcurpos()
  if a:0 > 0
    let lnumCurrent = a:1
    call cursor(lnumCurrent, 1)
  endif
  let result = GetSwiftIndent()
  call setpos('.', savedPosition)
  unlet s:debug
  return result
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
