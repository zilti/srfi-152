(module srfi-152
  (string-null? string-every string-any string-tabulate string-unfold
   string-unfold-right reverse-list->string string-take string-drop
   string-take-right string-drop-right string-pad string-pad-right
   string-trim string-trim-right string-trim-both string-replace
   string-prefix-length string-suffix-length string-prefix?
   string-suffix? string-index string-index-right string-skip
   string-skip-right string-contains string-contains-right
   string-take-while string-take-while-right string-drop-while
   string-drop-while-right string-break string-span string-append
   string-concatenate string-concatenate-reverse string-join
   string-fold string-fold-right string-count string-filter
   string-remove string-replicate string-segment string-split
   string-length string-ref string-set! make-string string substring
   list->string string->list string-copy string-fill! string=? string<?
   string>? string<=? string>=? string-ci=? string-ci<? string-ci>?
   string-ci<=? string-ci>=? string->vector vector->string string-map
   string-for-each read-string write-string string-copy! write-string)

  (import (chicken platform)
          (chicken type)
          (rename (except scheme
                          string-length string-ref string-set! make-string
                          string substring string-copy string->list
                          list->string string-fill!)
                  (string=? base-string=?)
                  (string<? base-string<?)
                  (string>? base-string>?)
                  (string<=? base-string<=?)
                  (string>=? base-string>=?)
                  (string-ci=? base-string-ci=?)
                  (string-ci<? base-string-ci<?)
                  (string-ci>? base-string-ci>?)
                  (string-ci<=? base-string-ci<=?)
                  (string-ci>=? base-string-ci>=?))
          (only (chicken base) include error case-lambda open-input-string
                               open-output-string get-output-string
                               receive assert
                               let-optionals
                               )
          (only utf8 string-length string-ref string-set! make-string
                     string substring list->string display read-string
                     string-fill! string->list reverse-list->string
                     )
          ;; Some 152 procedures differ from their 13 counterparts.
          (except utf8-srfi-13
                  string-every string-any string-trim string-trim-right
                  string-trim-both string-index string-index-right
                  string-skip string-skip-right string-count
                  string-filter string-delete string-map string-for-each
                  )
          (prefix (only utf8-srfi-13
                        string-every string-any string-trim
                        string-trim-right string-trim-both string-index
                        string-index-right string-skip string-skip-right
                        string-count string-filter string-delete
                        string-map string-for-each)
                  srfi-13:))

  (register-feature! 'srfi-152)

  (include "wrappers.scm")
  (include "portable.scm")
  (include "extend-comparisons.scm")
  (include "r7rs-shim.scm")
)
