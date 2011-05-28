(require srfi/42)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;stephens pretty printing-modified by me
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (display-cell value)
  (if (= 0 value)
      (display ". ")
      (display "# ")))

(define (print-board-row row)
  (map display-cell row)
  (newline))

(define (print-board state)
  (map print-board-row state)
  (display "------------------\n")) 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Functional helper functions

(define (sum lst) (foldl + 0 lst))

(define (nest fn exp n)
  (if (zero? n)
      exp
      (nest fn (fn exp) (- n 1))))

(define (nest-list fn exp n)
  (if (zero? n)
      ()
      (cons exp (nest-list fn (fn exp) (- n 1)))))

(define (map-apply fn lst)
  (map (lambda (p) (apply fn p)) lst))

; Board helper functions

(define (board-in board x y)
  (let ((ysize (length board))
        (xsize (length (first board))))
    (if (or (< x 0) (< y 0) (>= x xsize) (>= y ysize))
        false
        true)))

(define (board-ref board x y)
  (if (board-in board x y)
      (list-ref (list-ref board y) x)
      0))

(define offsets (cdr (list-ec (: i '(0 1 -1)) (: j '(0 1 -1)) (list i j))))

(define (neigbors board x y)
  (let ((brb (lambda (dx dy) 
               (board-ref board (+ x dx) (+ y dy)))))
    (map-apply brb offsets)))

; old definition
;(define (neigbors board x y)
;  (list (board-ref board (+ x 1) y)
;        (board-ref board (- x 1) y)
;        (board-ref board x (+ y 1))
;        (board-ref board x (- y 1))
;        (board-ref board (+ x 1) (+ y 1))
;        (board-ref board (- x 1) (- y 1))
;        (board-ref board (- x 1) (+ y 1))
;        (board-ref board (+ x 1) (- y 1))))


(define (live-neigbors board x y)
  (sum (neigbors board  x y)))

(define (survivor? board x y)
  (let ((s (live-neigbors board  x y)))
    (if (= (board-ref board x y) 1)
        (cond
          ((< s 2) 0)
          ((>= 3 s 2) 1)
          ((> s 3) 0))
        (if (= s 3)
            1
            0))))

(define (iter board)
  (let ((ysize (length board))
        (xsize (length (first board))))
    (list-ec (: i ysize) (list-ec (: j xsize) (survivor? board j i)))))

(define initial-board '((0 0 0 0 0 0 0 0 0 0)
                        (0 0 0 1 0 0 0 0 0 0)
                        (0 0 0 0 1 0 0 0 0 0)
                        (0 0 1 1 1 0 0 0 0 0)
                        (0 0 0 0 0 0 0 0 0 0)
                        (0 0 0 0 0 0 0 0 0 0)
                        (0 0 0 0 0 0 0 0 0 0)
                        (0 0 0 0 0 0 0 0 0 0)
                        (0 0 0 0 0 0 0 0 0 0)
                        (0 0 0 0 0 0 0 0 0 0)))

; (nest-list iter initial-board 10) returns a list of boards from 0 iteration to 10
(map print-board (nest-list iter initial-board 10))


