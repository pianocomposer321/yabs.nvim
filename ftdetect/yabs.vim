autocmd BufNewFile,BufRead .yabs setlocal ft=lua
autocmd BufWritePost .yabs YabsTrust <afile>
