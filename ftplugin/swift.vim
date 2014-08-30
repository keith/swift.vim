setlocal commentstring=//\ %s
" @-@ adds the literal @ to iskeyword for @IBAction and similar
setlocal iskeyword+=?,!,@-@,#
setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4
setlocal completefunc=syntaxcomplete#Complete
