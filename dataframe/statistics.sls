(library (dataframe statistics)
  (export
   sum
   mean
   list-min
   list-max
   rle)

  (import (rnrs)
          (dataframe record-types)
          (only (dataframe helpers)
                add1
                na?
                remove-duplicates))

  (define sum
    (case-lambda
      [(lst) (sum lst #t)]
      [(lst na-rm) (sum/mean lst na-rm 'sum)]))

  (define mean
    (case-lambda
      [(lst) (mean lst #t)]
      [(lst na-rm) (sum/mean lst na-rm 'mean)]))
  
  (define (sum/mean lst na-rm type)
    (let loop ([lst lst]
               [total 0]
               [count 0])
      (cond [(null? lst)
             (if (symbol=? type 'sum) total (/ total count))]
            [(and (na? (car lst)) (not na-rm))
             'na]
            [(na? (car lst))
             (loop (cdr lst) total count)]
            [(and (boolean? (car lst)) (not (car lst)))
             (loop (cdr lst) total (add1 count))]
            [(and (boolean? (car lst)) (car lst))
             (loop (cdr lst) (add1 total) (add1 count))]
            [else
             (loop (cdr lst) (+ (car lst) total) (add1 count))])))

  ;; need different names for min/max
  (define list-min
    (case-lambda
      [(lst) (list-min lst #t)]
      [(lst na-rm) (min/max lst na-rm 'min)]))

  (define list-max
    (case-lambda
      [(lst) (list-max lst #t)]
      [(lst na-rm) (min/max lst na-rm 'max)]))

  (define (min/max lst na-rm type)
    ;; not including boolean here b/c seems less useful
    (let ([comp (if (symbol=? type 'min) < >)])
      (let loop ([lst lst]
                 [result (if (symbol=? type 'min) +inf.0 -inf.0)])
        (cond [(null? lst) result]
              [(and (na? (car lst)) (not na-rm)) 'na]
              [else
               (loop (cdr lst) (if (comp (car lst) result)
                                   (car lst)
                                   result))]))))
  
  (define (rle lst)
    ;; run length encoding
    ;; returns a list of pairs where the car and cdr of each pair
    ;; are the values and lengths of the runs, respectively, for the values in lst
    (let loop ([first (car lst)]
               [rest (cdr lst)]
               [n 1]
               [vals '()]
               [counts '()])
      (cond
       [(null? rest)
	(map cons
	     (reverse (cons first vals))
	     (reverse (cons n counts)))]
       [(equal? first (car rest))
	(loop (car rest) (cdr rest) (add1 n) vals counts)]
       [else
	(loop (car rest) (cdr rest) 1 (cons first vals) (cons n counts))])))
  
  )

