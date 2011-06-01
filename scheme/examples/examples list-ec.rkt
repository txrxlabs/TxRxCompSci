(require srfi/42)
;srfi = Scheme Request for Implmentation
;require imports module srfi/42 which is an imp;mentation of the 42 srfi
;require ensures that if a module has already been imported it will not be
;imported again.

; I used the below to produce all of the offsets that where needed to check for
; neigbors.
;(define offsets (cdr (list-ec (: i '(0 1 -1)) (: j '(0 1 -1)) (list i j))))

(list-ec (: i '(0 1 -1)) (: j '(0 1 -1)) (list i j))
;((0 0) (0 1) (0 -1) (1 0) (1 1) (1 -1) (-1 0) (-1 1) (-1 -1))
; we do no want that first pair so I through it away with cdr

(cdr (list-ec (: i '(0 1 -1)) (: j '(0 1 -1)) (list i j)))
;((0 1) (0 -1) (1 0) (1 1) (1 -1) (-1 0) (-1 1) (-1 -1))

; Some simpler list-ec examples

(list-ec (: i 10) i)
;(0 1 2 3 4 5 6 7 8 9)

;you can also perform an operation on i
(list-ec (: i 10) (* i i))
;(0 1 4 9 16 25 36 49 64 81)

(list-ec (: i 2 10) i)
;(2 3 4 5 6 7 8 9)

;Generating pairs of numbers
(list-ec (: i 2 5) (: j 2 5) (list i j))
;((2 2) (2 3) (2 4) (3 2) (3 3) (3 4) (4 2) (4 3) (4 4))
; You can generat pairs, tripples, ...

;Instead of providing a range of numbers like (: i 2 5) a list of numbers can be
;provided instead.

(list-ec (: i '(-1 0 1)) i)
;(-1 0 1)

;What if I want all of the combinations that can be produced by picking from
; (-1 0 1) twice?
(list-ec (: i '(-1 0 1)) (: j '(-1 0 1)) (list i j))
;((-1 -1) (-1 0) (-1 1) (0 -1) (0 0) (0 1) (1 -1) (1 0) (1 1))

;Shoot but I do not want (0 0)
(list-ec (: i '(0 -1 1)) (: j '(0 -1 1)) (list i j))
;((0 0) (0 -1) (0 1) (-1 0) (-1 -1) (-1 1) (1 0) (1 -1) (1 1))

(cdr (list-ec (: i '(0 -1 1)) (: j '(0 -1 1)) (list i j)))
;((0 -1) (0 1) (-1 0) (-1 -1) (-1 1) (1 0) (1 -1) (1 1))


