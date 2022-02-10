command! -nargs=1 YabsTask
        \ lua require("yabs"):run_task(<q-args>)

command! YabsDefaultTask
        \ lua require("yabs"):run_default_task()

command! -bang -nargs=1 -complete=file YabsTrust
        \ lua require("yabs.db"):load():trust(<f-args>, "<bang>" ~= "!"):save()

command! -nargs=1 -complete=file YabsTrustReset
        \ lua require("yabs.db"):load():reset(<f-args>):save()

command! YabsTrustResetAll
        \ lua require("yabs.db"):load():reset_all():save()
