#lang racket/base
(require racket/contract/base
         racket/string
         "geometry.rkt")

#|
inet, cidr = family:byte bits:byte is_cidr:byte addrlen:byte addr:be-integer
  is_cidr is ignored

box = x1 y1 x2 y2 (all float8)
circle = x y rad (all float8)
line = not yet implemented
lseg = x1 y1 x2 y2 (all float8)
path = closed?:byte #points:int4 (x y : float8)*
point = x y (all float8)
polygon = #points:int4 (x y : float8)*
|#

(struct pg-box (ne sw)
        #:transparent
        #:guard (lambda (ne sw _n)
                  (let ([x1 (point-x ne)]
                        [x2 (point-x sw)]
                        [y1 (point-y ne)]
                        [y2 (point-y sw)])
                    (values (point (max x1 x2) (max y1 y2))
                            (point (min x1 x2) (min y1 y2))))))

(struct pg-circle (center radius)
        #:transparent
        #:guard (lambda (center radius _n)
                  (values center (exact->inexact radius))))

(struct pg-path (closed? points)
        #:transparent
        #:guard (lambda (closed? points _n)
                  (values (and closed? #t)
                          points)))

(struct pg-array (dimensions dimension-lengths dimension-lower-bounds contents)
        #:transparent
        #:guard (lambda (ndim counts lbounds vals _n)
                  (unless (= (length counts) ndim)
                    (error 'pg-array
                           "expected list of ~s integers for dimension-lengths, got: ~e"
                           ndim counts))
                  (unless (= (length lbounds) ndim)
                    (error 'pg-array
                           "expected list of ~s integers for dimension-lower-bounds, got: ~e"
                           ndim lbounds))
                  (let loop ([counts* counts] [vals* vals])
                    (when (pair? counts*)
                      (unless (and (vector? vals*)
                                   (= (vector-length vals*) (car counts*)))
                        (error 'pg-array "bad array contents: ~e" vals))
                      (for ([sub (in-vector vals*)])
                        (loop (cdr counts*) sub))))
                  (values ndim counts lbounds vals)))

(define (pg-array-ref arr . indexes)
  (unless (= (pg-array-dimensions arr) (length indexes))
    (error 'pg-array-ref "expected ~s indexes, got: ~e" indexes))
  (let* ([counts (pg-array-dimension-lengths arr)]
         [lbounds (pg-array-dimension-lower-bounds arr)]
         [ubounds (map (lambda (c lb) (+ c lb -1)) counts lbounds)])
    (unless (for/and ([index indexes] [lbound lbounds] [ubound ubounds])
              (<= lbound index ubound))
      (error 'pg-array-ref
             "index ~s of of range (~a)"
             indexes
             (string-join (for/list ([lbound lbounds] [ubound ubounds])
                            (format "[~a,~a]" lbound ubound))
                          ", ")))
    (let loop ([indexes (map - indexes lbounds)]
               [vals (pg-array-contents arr)])
      (cond [(pair? indexes)
             (let ([index (car indexes)])
               (loop (cdr indexes)
                     (vector-ref vals index)))]
            [else vals]))))

(define (pg-array->list arr)
  (unless (= (pg-array-dimensions arr) 1)
    (raise-type-error 'pg-array->list "pg-array of dimension 1" arr))
  (vector->list (pg-array-contents arr)))

(define (list->pg-array lst)
  (cond [(zero? (length lst))
         (pg-array 0 '() '() '#())]
        [else (pg-array 1 (list (length lst)) '(1) (list->vector lst))]))

(provide/contract
 [struct pg-box ([ne point?] [sw point?])]
 [struct pg-circle ([center point?] [radius (and/c real? (not/c negative?))])]
 [struct pg-path ([closed? any/c] [points (listof point?)])]

 [struct pg-array ([dimensions exact-nonnegative-integer?]
                   [dimension-lengths (listof exact-positive-integer?)]
                   [dimension-lower-bounds (listof exact-integer?)]
                   [contents vector?])]
 [pg-array-ref
  (->* (pg-array?) () #:rest (non-empty-listof exact-integer?) any)]
 [pg-array->list
  (-> pg-array? list?)]
 [list->pg-array
  (-> list? pg-array?)])
