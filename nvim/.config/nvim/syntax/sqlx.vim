" Vim syntax file
" Language:    SQLX (Dataform)
"
" A .sqlx file is SQL with a JavaScript header: `config { ... }` and `js { ... }`
" blocks up top, `${ ... }` interpolation in the body. The tree-sitter `sql`
" grammar collapses that whole header into one ERROR node, so this layers Vim's
" bundled SQL and JavaScript rules instead. Setting the filetype to `sqlx` keeps
" tree-sitter out of the buffer (LazyVim only starts it when a parser exists).

if exists("b:current_syntax")
  finish
endif

" Base: Vim's SQL rules. sql.vim dispatches on g:sql_type_default and defaults to
" the Oracle dialect; the BigQuery keywords it lacks are added at the bottom.
runtime! syntax/sql.vim
unlet! b:current_syntax

" SQL was defined under `syn case ignore`, which `syn include` does not reset.
" Flip it back so JavaScript keywords stay case-sensitive.
syn case match
syn include @sqlxJs syntax/javascript.vim
unlet! b:current_syntax

" javascript.vim matches braces with a bare `syn match javaScriptBraces "[{}\[\]]"`.
" That consumes a closing brace before the enclosing region's `end` is tested, so
" every block would run away to EOF. javaScriptEmbed likewise competes with our own
" ${} rule. Drop both and own brace nesting ourselves.
syn cluster sqlxJs remove=javaScriptBraces,javaScriptEmbed

" Drop the browser-era globals: `alert confirm prompt status`, `self window top
" parent`, `document event location`, `escape unescape`. None mean anything in
" Dataform's Node context, and because keywords outrank matches they hijack config
" keys of the same name -- `status:` was highlighting unlike every sibling key.
" This also lets Dataform's own self() fall through to sqlxJsFunc.
syn cluster sqlxJs remove=javaScriptMessage,javaScriptGlobal,javaScriptMember,javaScriptDeprecated

" Recursive brace region: keeps nested objects (bigquery: {}, assertions: {}) from
" ending the block early, and ignores braces inside JS strings and comments since
" those rules match first.
syn region sqlxBrace start="{" end="}" contained transparent
      \ contains=@sqlxJs,sqlxBrace,sqlxProperty,sqlxJsFunc

syn match sqlxProperty "\<\h\w*\ze\s*:" contained

" javascript.vim's only notion of a function is the literal `function` keyword,
" so call sites (ref(), require(), self(), helpers.devExpire()) render plain.
" Keywords outrank matches in Vim, so `if (` and friends are unaffected.
syn match sqlxJsFunc "\<\h\w*\ze\s*(" contained

" config { ... } and js { ... } hold JavaScript. Anchored to the start of a line
" and required to be followed by a brace, so a column named `config` or `js` in
" the SQL body is not mistaken for a block keyword.
syn match sqlxBlockName "^\s*\zs\<\(config\|js\)\>\ze\_s*{"
      \ nextgroup=sqlxJsBlock skipwhite skipempty
syn region sqlxJsBlock matchgroup=sqlxDelim start="{" end="}" contained fold
      \ contains=@sqlxJs,sqlxBrace,sqlxProperty,sqlxJsFunc

" pre_operations / post_operations hold SQL, so fall through to the top-level rules.
syn match sqlxBlockName "^\s*\zs\<\(pre_operations\|post_operations\)\>\ze\_s*{"
      \ nextgroup=sqlxSqlBlock skipwhite skipempty
syn region sqlxSqlBlock matchgroup=sqlxDelim start="{" end="}" contained transparent fold
      \ contains=TOP

" ${ ... } interpolation, including inside SQL string literals.
syn region sqlxInterp matchgroup=sqlxDelim start="\${" end="}"
      \ contains=@sqlxJs,sqlxBrace,sqlxJsFunc containedin=sqlString

" Vim's SQL rules are Oracle-flavoured and declare ~180 function names as bare
" keywords, so a column named to_number, decode, nvl or rank lights up as a call.
" Require a following paren instead: real calls still highlight -- including the
" BigQuery functions Oracle's list has never heard of -- while bare identifiers
" in a SELECT list stay plain. Keywords outrank matches, so IN (, OVER ( and
" friends keep their own groups.
syn clear sqlFunction
syn match sqlFunction "\<\h\w*\ze\s*("

" BigQuery keywords missing from Vim's Oracle-flavoured SQL rules.
syn case ignore
syn keyword sqlxBqStatement declare merge assert export
syn keyword sqlxBqKeyword qualify unnest except replace window pivot unpivot
      \ over partition
      \ recursive struct array offset ordinal safe_offset safe_ordinal
      \ tablesample rows range following preceding unbounded
syn keyword sqlxBqType int64 float64 numeric bignumeric bool bytes datetime
      \ geography json interval

hi def link sqlxBlockName   Statement
hi def link sqlxDelim       Delimiter
hi def link sqlxProperty    Identifier
hi def link sqlxJsFunc      Function
hi def link sqlxBqStatement sqlStatement
hi def link sqlxBqKeyword   sqlKeyword
hi def link sqlxBqType      sqlType

let b:current_syntax = "sqlx"
