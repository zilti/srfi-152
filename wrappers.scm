;;; Procedures implemented as wrappers around SRFI 13 forms.
;;; Mostly, SRFI 152 differs from 13 in that "pred" arguments
;;; must be procedures, whereas SRFI 13 allows them to be
;;; characters or character sets as well.

(: string-every ((char -> *) string #!optional integer integer -> *))
(define (string-every pred s . opt)
  (assert (procedure? pred))
  (apply srfi-13:string-every pred s opt))

(: string-any ((char -> *) string #!optional integer integer -> *))
(define (string-any pred s . opt)
  (assert (procedure? pred))
  (apply srfi-13:string-any pred s opt))

(: string-trim (string (char -> *) #!optional integer integer -> string))
(define (string-trim s pred . opt)
  (assert (procedure? pred))
  (apply srfi-13:string-trim s pred opt))

(: string-trim-right
   (string (char -> *) #!optional integer integer -> string))
(define (string-trim-right s pred . opt)
  (assert (procedure? pred))
  (apply srfi-13:string-trim-right s pred opt))

(: string-trim-both
   (string (char -> *) #!optional integer integer -> string))
(define (string-trim-both s pred . opt)
  (assert (procedure? pred))
  (apply srfi-13:string-trim-both s pred opt))

(: string-index
   (string (char -> *) #!optional integer integer -> (or integer false)))
(define (string-index s pred . opt)
  (assert (procedure? pred))
  (apply srfi-13:string-index s pred opt))

(: string-index-right
   (string (char -> *) #!optional integer integer -> (or integer false)))
(define (string-index-right s pred . opt)
  (assert (procedure? pred))
  (apply srfi-13:string-index-right s pred opt))

(: string-skip
   (string (char -> *) #!optional integer integer -> (or integer false)))
(define (string-skip s pred . opt)
  (assert (procedure? pred))
  (apply srfi-13:string-skip s pred opt))

(: string-skip-right
   (string (char -> *) #!optional integer integer -> (or integer false)))
(define (string-skip-right s pred . opt)
  (assert (procedure? pred))
  (apply srfi-13:string-skip-right s pred opt))

(: string-count
   (string (char -> *) #!optional integer integer -> integer))
(define (string-count s pred . opt)
  (assert (procedure? pred))
  (apply srfi-13:string-count s pred opt))

(: string-filter
   ((char -> *) string #!optional integer integer -> string))
(define (string-filter pred s . opt)
  (assert (procedure? pred))
  (apply srfi-13:string-filter pred s opt))

(: string-remove
   ((char -> *) string #!optional integer integer -> string))
(define (string-remove pred s . opt)
  (assert (procedure? pred))
  (apply srfi-13:string-delete pred s opt))  ; name changed
