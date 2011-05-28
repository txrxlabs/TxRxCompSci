(define first car)
(define second cadr)

(define (plus-var var)
  (lambda (x) (+ var x)))

(define plus-one (plus-var 1))

(plus-one 1)

(plus-one 2)

(define plus-two (plus-var 2))

(plus-two 1)

(plus-two 2)

(define id (lambda (x) x))

(define (make-obj lst)
  (lambda (getter)
         (getter lst)))

(define tmp-obj (make-obj '(1 2 3)))
(define (obj-set-car x)
  (lambda (lst)
    (set-car! lst x)))

(tmp-obj first)
;1

(tmp-obj (obj-set-car 2))

(tmp-obj first)
;2