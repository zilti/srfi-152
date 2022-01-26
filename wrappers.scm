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

(: string-trim (string #!optional (char -> *) integer integer -> string))
(define (string-trim s . opt)
  (assert (if (pair? opt) (procedure? (car opt)) #t))
  (apply srfi-13:string-trim s opt))

(: string-trim-right
   (string #!optional (char -> *) integer integer -> string))
(define (string-trim-right s . opt)
  (assert (if (pair? opt) (procedure? (car opt)) #t))
  (apply srfi-13:string-trim-right s opt))

(: string-trim-both
   (string #!optional (char -> *) integer integer -> string))
(define (string-trim-both s . opt)
  (assert (if (pair? opt) (procedure? (car opt)) #t))
  (apply srfi-13:string-trim-both s opt))

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

;; Aside from the name-change, the `to` argument is now mandatory.
(: string-replicate
   (string integer integer #!optional integer integer -> string))
(define (string-replicate s from to . opt)
  (apply xsubstring s from to opt))
