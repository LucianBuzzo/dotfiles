
"=====[ Replace the field name under the cursor with an export array ]=====
"
let s:path = fnamemodify(resolve(expand('<sfile>:p')), ':h')

function! DrupalExportField()
  let fieldName = expand("<cword>")
  let drupalRoot = system("drush eval 'echo getcwd()'")
  let exportCode = system('drush --root=' . drupalRoot . ' ' . s:path . '/drush/fieldexport.drush --field=' . fieldName)
  set paste
  execute "normal! mqciw" . exportCode . "\<esc>'q=i{"
  set nopaste
endfunction

"=====[ Clear all caches via drush ]=====

function! DrupalDrushCCall()
  let drupalRoot = system("drush eval 'echo getcwd()'")
  echom system('drush --root=' . drupalRoot . ' cc all')
endfunction

