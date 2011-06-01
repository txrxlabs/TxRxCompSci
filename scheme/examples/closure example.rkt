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

(define (obj-set-car x)
  (lambda (lst)
    (set-car! lst x)))

(define obj-1 (make-obj '(1 2 3)))
(define obj-2 (make-obj '(1 2 3)))

(obj-1 first)
;1
(obj-2 first)
;1


(obj-1 (obj-set-car 2))

(obj-1 first)
;2
(obj-2 first)
;1