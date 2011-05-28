(define (make-board board xsize ysize)
  (lambda (sym)
    (case sym
      ((dim) (list xsize ysize))
      ((xsize) xsize)
      ((ysize) ysize)
      ((board) board))))

(define tmp '((0 0 0 0 0 0 0 0 0 0)
                        (0 0 0 1 0 0 0 0 0 0)
                        (0 0 0 0 1 0 0 0 0 0)
                        (0 0 1 1 1 0 0 0 0 0)
                        (0 0 0 0 0 0 0 0 0 0)
                        (0 0 0 0 0 0 0 0 0 0)
                        (0 0 0 0 0 0 0 0 0 0)
                        (0 0 0 0 0 0 0 0 0 0)
                        (0 0 0 0 0 0 0 0 0 0)
                        (0 0 0 0 0 0 0 0 0 0)))

(define initial-board (make-board tmp 10 10))

(initial-board 'board)
(initial-board 'xsize)
(initial-board 'ysize)



