;;; SRFI 130 string library reference implementation		-*- Scheme -*-
;;; Olin Shivers 7/2000
;;; John Cowan 4/2016
;;;
;;; Copyright (c) 1988-1994 Massachusetts Institute of Technology.
;;; Copyright (c) 1998, 1999, 2000 Olin Shivers.
;;; Copyright (c) 2016 John Cowan.

;;; Edited by WCM to include only forms not found in SRFI 13.
;;; Aside from the following macro and its support, only code
;;; added by John remains.

(define-syntax let-string-start+end
  (syntax-rules ()
    ((let-string-start+end (start end) proc s-exp args-exp body ...)
     (receive (start end) (string-parse-final-start+end proc s-exp args-exp)
       body ...))
    ((let-string-start+end (start end rest) proc s-exp args-exp body ...)
     (receive (rest start end) (string-parse-start+end proc s-exp args-exp)
       body ...))))

;;; This one parses out a *pair* of final start/end indices.
;;; Not exported; for internal use.
(define-syntax let-string-start+end2
  (syntax-rules ()
    ((l-s-s+e2 (start1 end1 start2 end2) proc s1 s2 args body ...)
     (let ((procv proc)) ; Make sure PROC is only evaluated once.
       (let-string-start+end (start1 end1 rest) procv s1 args
         (let-string-start+end (start2 end2) procv s2 rest
           body ...))))))

;;; Returns three values: rest start end

(define (string-parse-start+end proc s args)
  (assert (string? s) "Non-string value" proc s)
  (let ((slen (string-length s)))
    (if (pair? args)

	(let ((start (car args))
	      (args (cdr args)))
	  (assert (and (integer? start) (exact? start) (>= start 0))
	          "Illegal substring START spec" proc start s)
	  (receive (end args)
		(if (pair? args)
		    (let ((end (car args))
			  (args (cdr args)))
		      (assert (and (integer? end) (exact? end) (<= end slen))
			      "Illegal substring END spec" proc end s)
		      (values end args))
		    (values slen args))
	    (assert (<= start end)
		    "Illegal substring START/END spec" proc start end s)
	    (values args start end)))

	(values '() 0 slen))))

(define (string-parse-final-start+end proc s args)
  (receive (rest start end) (string-parse-start+end proc s args)
    (assert (null? rest) "Extra arguments to procedure" proc rest)
    (values start end)))

;;; Split out so that other routines in this library can avoid arg-parsing
;;; overhead for END parameter.
(define (%substring s start end)
  (if (and (zero? start) (= end (string-length s))) s
      (substring s start end)))

;;; Useful hacks added for SRFI 152

(: string-take-while
   (string (char -> *) #!optional integer integer --> string))
(define (string-take-while s criterion . maybe-start+end)
  (let-string-start+end (start end) string-take-while s maybe-start+end
    (let ((idx (string-skip s criterion start end)))
      (if idx
          (%substring s 0 idx)
          ""))))

(: string-take-while-right
   (string (char -> *) #!optional integer integer --> string))
(define (string-take-while-right s criterion . maybe-start+end)
  (let-string-start+end (start end) string-take-while s maybe-start+end
    (let ((idx (string-skip-right s criterion start end)))
      (if idx
          (%substring s (+ idx 1) (string-length s))
          ""))))

(: string-drop-while
   (string (char -> *) #!optional integer integer --> string))
(define (string-drop-while s criterion . maybe-start+end)
  (let-string-start+end (start end) string-drop-while s maybe-start+end
    (let ((idx (string-skip s criterion start end)))
      (if idx
          (%substring s idx (string-length s))
          s))))

(: string-drop-while-right
   (string (char -> *) #!optional integer integer --> string))
(define (string-drop-while-right s criterion . maybe-start+end)
  (let-string-start+end (start end) string-drop-while s maybe-start+end
    (let ((idx (string-skip-right s criterion start end)))
      (if idx
          (%substring s 0 (+ idx 1))
          s))))

(: string-span
   (string (char -> *) #!optional integer integer --> string string))
(define (string-span s criterion . maybe-start+end)
  (let-string-start+end (start end) string-span s maybe-start+end
    (let ((idx (string-skip s criterion start end)))
      (if idx
        (values (%substring s 0 idx) (%substring s idx (string-length s)))
        (values "" s)))))

(: string-break
   (string (char -> *) #!optional integer integer --> string string))
(define (string-break s criterion . maybe-start+end)
  (let-string-start+end (start end) string-break s maybe-start+end
    (let ((idx (string-index s criterion start end)))
      (if idx
        (values (%substring s 0 idx) (%substring s idx (string-length s)))
        (values s "")))))

(: string-count
   (string (char -> *) #!optional integer integer --> integer))
(define (string-count s criterion . maybe-start+end)
  (let-string-start+end (start end) string-count s maybe-start+end
	   (do ((i start (+ i 1))
		(count 0 (if (criterion (string-ref s i)) (+ count 1) count)))
	       ((>= i end) count))))

(: string-contains-right
   (string string #!optional integer integer integer integer -->
    (or integer false)))
(define (string-contains-right text pattern . maybe-starts+ends)
  (let-string-start+end2 (t-start t-end p-start p-end)
                         string-contains-right text pattern maybe-starts+ends
    (let* ((t-len    (string-length text))
           (p-len    (string-length pattern))
           (p-size   (- p-end p-start))
           (rt-start (- t-len t-end))
           (rt-end   (- t-len t-start))
           (rp-start (- p-len p-end))
           (rp-end   (- p-len p-start))
           (res      (string-contains (string-reverse text)
                                      (string-reverse pattern)
                                      rt-start
                                      rt-end
                                      rp-start
                                      rp-end)))
      (and res (- t-len res p-size)))))

(: string-segment (string integer --> (list-of string)))
(define (string-segment str k)
  (assert (>= k 1) "minimum segment size is 1" k)
  (let ((len (string-length str)))
    (let loop ((start 0)
               (result '()))
      (if (= start len)
        (reverse result)
        (let ((end (min (+ start k) len)))
          (loop end (cons (%substring str start end) result)))))))

;;; string-split s delimiter [grammar limit start end] -> list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Returns a list of the words contained in the substring of string from
;;; start (inclusive) to end (exclusive). Delimiter specifies a string
;;; whose characters are to be used as the word separator. The returned
;;; list will then have one more item than the number of non-overlapping
;;; occurrences of the delimiter in the string. If delimiter is an
;;; empty string, then the returned list contains a list of strings,
;;; each of which contains a single character.  Grammar is a symbol with
;;; the same meaning as in the string-join procedure. If it is infix,
;;; which is the default, processing is done as described above, except
;;; that an empty s produces the empty list; if it is strict-infix,
;;; an empty s signals an error. The values prefix and suffix cause a
;;; leading/trailing empty string in the result to be suppressed.
;;;
;;; If limit is a non-negative exact integer, at most that many splits
;;; occur, and the remainder of string is returned as the final element
;;; of the list (thus, the result will have at most limit+1 elements). If
;;; limit is not specified or is #f, then as many splits as possible
;;; are made. It is an error if limit is any other value.
;;;
;;; Thanks to Shiro Kawai for the following code.

(: string-split
   (string string #!optional symbol integer integer -> (list-of string)))
(define (string-split s delimiter . args)
  ;; The argument checking part might be refactored with other srfi-130
  ;; routines.
  (assert (string? s) "string expected" s)
  (assert (string? delimiter) "string expected" delimiter)
  (let ((slen (string-length s)) (no-limit #f))
    (let-optionals args ((grammar 'infix)
                         (limit #f)
                         (start 0)
                         (end slen))
      (assert (memq grammar '(infix strict-infix prefix suffix))
              "grammar must be one of (infix strict-infix prefix suffix)"
              grammar)
      (if (not limit) (set! no-limit #t))
      (assert (or no-limit
                  (and (integer? limit) (exact? limit) (>= limit 0)))
              "limit must be an exact nonnegative integer or #f" limit)
      (assert (and (integer? start) (exact? start))
              "start argument must be exact integer" start)
      (assert (<= 0 start slen) "start argument out of range" start)
      (assert (<= 0 end slen) "end argument out of range" end)
      (assert (<= start end)
              "start argument is greater than end argument"
              (list start end))

      (cond ((= start end)
             (if (eq? grammar 'strict-infix)
               (error "empty string cannot be spilt with strict-infix grammar")
               '()))
            ((string-null? delimiter)
             (%string-split-chars s start end limit))
            (else (%string-split s start end delimiter grammar limit))))))

(define (%string-split-chars s start end limit)
  (if (not limit)
    (map string (string->list s start end))
    (let loop ((r '()) (c start) (n 0))
      (cond ((= c end) (reverse r))
            ((>= n limit) (reverse (cons (substring s c end) r)))
            (else (loop (cons (string (string-ref s c)) r)
                        (+ c 1)
                        (+ n 1)))))))

(define (%string-split s start end delimiter grammar limit)
  (let ((dlen (string-length delimiter)))
    (define (finish r c)
      (let ((rest (substring s c end)))
        (if (and (eq? grammar 'suffix) (string-null? rest))
          (reverse r)
          (reverse (cons rest r)))))
    (define (scan r c n)
      (if (and limit (>= n limit))
        (finish r c)
        (let ((i (string-contains s delimiter c end)))
          (if i
            (let ((fragment (substring s c i)))
              (if (and (= n 0) (eq? grammar 'prefix) (string-null? fragment))
                (scan r (+ i dlen) (+ n 1))
                (scan (cons fragment r)
                      (+ i dlen)
                      (+ n 1))))
            (finish r c)))))
    (scan '() start 0)))
