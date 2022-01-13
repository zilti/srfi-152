(define (vector->string vector . maybe-start+end)
  (let ((start 0) (end (vector-length vector)))
    (case (length maybe-start+end)
      ((1) (set! start (car maybe-start+end)))
      ((2) (set! end (cadr maybe-start+end))))
    (let ((s (make-string (- end start))))
      (do ((i (- end 1) (- i 1)))
          ((< i start) s)
        (string-set! s (- i start) (vector-ref vector i))))))

(define (string-map f x . rest)

  (define (string-map1 f x)
    (list->string (map f (string->list x))))

  (define (string-map2 f x y)
    (list->string (map f (string->list x) (string->list y))))

  (define (string-mapn f lists)
    (list->string (apply map f (map string->list lists))))

  (case (length rest)
    ((0)  (string-map1 f x))
    ((1)  (string-map2 f x (car rest)))
    (else (string-mapn f (cons x rest)))))

(define (string-for-each f s . rest)

  (define (for-each1 i n)
    (if (< i n)
	(begin (f (string-ref s i))
	       (for-each1 (+ i 1) n))
	(if #f #f)))

  (define (for-each2 s2 i n)
    (if (< i n)
	(begin (f (string-ref s i) (string-ref s2 i))
	       (for-each2 s2 (+ i 1) n))
	(if #f #f)))

  (define (for-each-n revstrings i n)
    (if (< i n)
        (do ((rev revstrings (cdr rev))
             (chars '() (cons (string-ref (car rev) i) chars)))
            ((null? rev)
             (apply f chars)
             (for-each-n revstrings (+ i 1) n)))
	(if #f #f)))

  (let ((n (string-length s)))
    (cond ((null? rest)
           (for-each1 0 n))
          ((and (null? (cdr rest))
                (string? (car rest))
                (= n (string-length (car rest))))
           (for-each2 (car rest) 0 n))
          (else
           (let ((args (cons s rest)))
             (do ((ss rest (cdr ss)))
                 ((null? ss)
                  (for-each-n (reverse args) 0 n))
               (let ((x (car ss)))
                 (if (or (not (string? x))
                         (not (= n (string-length x))))
                     (error
                                          "illegal-arguments"
                                          (cons f args))))))))))

;; Chicken's write-string is incompatible with R7RS
(define write-string
  (case-lambda
    ((str) (display str))
    ((str port) (display str port))
    ((str port start) (write-string str port start (string-length str)))
    ((str port start end) (display (%substring str start end) port))))

(define (eof-object) #!eof)
