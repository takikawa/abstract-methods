#lang racket

(require racket/flonum
         plot
         plot/utils
         plot/common/contract
         plot/common/contract-doc
         ;plot/common/axis-transform
         )

(x-axis-ticks? #f)
(y-axis-ticks? #f)

(values
 (parameterize ([plot-x-transform  log-transform])
   (plot (list (function values 1 5)
               (function cos 1 5 #:color 3))))
 (parameterize ([plot-x-transform  cbrt-transform])
   (plot (list (function values -2 2)
               (function cos -2 2 #:color 3))))
 (parameterize ([plot-x-transform  log-transform]
                [plot-y-transform  cbrt-transform])
   (define xs (nonlinear-seq 1 5 20 log-transform))
   (define ys (nonlinear-seq -1 5 20 cbrt-transform))
   (plot (points (map vector xs ys)))))

(let ()
  (define trans1 (hand-drawn-transform 25))
  (define trans2 (hand-drawn-transform 100))
  (values
   (parameterize ([plot-x-transform  trans1])
     (plot (list (function values -2 2)
                 (function cos -2 2 #:color 3))))
   (parameterize ([plot-x-transform  trans2])
     (plot (list (function values -2 2)
                 (function cos -2 2 #:color 3))))
   (parameterize ([plot-x-transform  trans1]
                  [plot-y-transform  trans2])
     (define xs (nonlinear-seq -2 2 20 trans1))
     (define ys (nonlinear-seq -2 2 20 trans2))
     (plot (points (map vector xs ys))))))

(let ()
  (define trans1 (stretch-transform -1/2 1/2 4))
  (define trans2 (stretch-transform -1/2 1/2 1/4))
  (values
   (parameterize ([plot-x-transform  trans1]
                  [plot-y-transform  trans2])
     (plot (list (y-axis -1/2) (y-axis 1/2)
                 (x-axis -1/2) (x-axis 1/2)
                 (function values -2 2)
                 (function cos -2 2 #:color 3))))
   (parameterize ([plot-x-transform  trans1]
                  [plot-y-transform  trans2])
     (define xs (nonlinear-seq -2 2 20 trans1))
     (define ys (nonlinear-seq -2 2 20 trans2))
     (plot (points (map vector xs ys))))))

(let ()
  (define trans1 (axis-transform-compose id-transform (stretch-transform -1 1 1/4)))
  (define trans2 (axis-transform-compose (stretch-transform -1 1 1/4) id-transform))
  (values
   (parameterize ([plot-x-transform  trans1])
     (plot (list (y-axis -1) (y-axis 1)
                 (function values -2 2)
                 (function cos -2 2 #:color 3))))
   (parameterize ([plot-x-transform  trans2])
     (plot (list (y-axis -1) (y-axis 1)
                 (function values -2 2)
                 (function cos -2 2 #:color 3))))
   (parameterize ([plot-x-transform  trans1]
                  [plot-y-transform  trans2])
     (define xs (nonlinear-seq -2 2 20 trans1))
     (define ys (nonlinear-seq -2 2 20 trans2))
     (plot (points (map vector xs ys))))))

(let ()
  (define t1 (stretch-transform -2 -1 4))
  (define t2 (stretch-transform 1 2 4))
  (values
   (parameterize ([plot-x-transform  (axis-transform-compose t1 t2)]
                  [plot-x-ticks      (ticks-add (plot-x-ticks) '(-1 1))])
     (plot (list (y-axis -2) (y-axis -1)
                 (y-axis 1) (y-axis 2)
                 (function values -3 3)
                 (function cos -3 3 #:color 3))))
   (parameterize ([plot-x-transform  (axis-transform-compose t2 t1)]
                  [plot-x-ticks      (ticks-add (plot-x-ticks) '(-1 1))])
     (plot (list (y-axis -2) (y-axis -1)
                 (y-axis 1) (y-axis 2)
                 (function values -3 3)
                 (function cos -3 3 #:color 3))))
   (parameterize ([plot-x-transform  (axis-transform-compose t2 t1)]
                  [plot-y-transform  (axis-transform-compose t1 t2)])
     (define xs (nonlinear-seq -3 3 20 (axis-transform-compose t2 t1)))
     (define ys (nonlinear-seq -3 3 20 (axis-transform-compose t1 t2)))
     (plot (points (map vector xs ys))))))

(let ()
  (define t1 (stretch-transform -2 0 4))
  (define t2 (stretch-transform -1 1 1/4))
  (define t3 (stretch-transform 2 3 4))
  (define trans1 (axis-transform-compose (axis-transform-compose t3 t2) t1))
  (define trans2 (axis-transform-compose (axis-transform-compose t2 t1) t3))
  (values
   (parameterize ([plot-x-transform  trans1])
     (plot (list (y-axis -2) (y-axis 0)
                 (y-axis -1) (y-axis 1)
                 (y-axis 2) (y-axis 3)
                 (function values -3 4)
                 (function cos -3 4 #:color 3))))
   (parameterize ([plot-x-transform  trans2])
     (plot (list (y-axis -2) (y-axis 0)
                 (y-axis -1) (y-axis 1)
                 (y-axis 2) (y-axis 3)
                 (function values -3 4)
                 (function cos -3 4 #:color 3))))
   (parameterize ([plot-x-transform  trans1]
                  [plot-y-transform  trans2])
     (define xs (nonlinear-seq -3 4 20 trans1))
     (define ys (nonlinear-seq -3 4 20 trans2))
     (plot (points (map vector xs ys))))))

(let ()
  (define trans1 (axis-transform-compose (stretch-transform 2 3 4) log-transform))
  (define trans2 (axis-transform-compose log-transform (stretch-transform 2 3 4)))
  (values
   (parameterize ([plot-x-transform  trans1])
     (plot (list (y-axis 2) (y-axis 3)
                 (function values 1 5)
                 (function cos 1 5 #:color 3))))
   (parameterize ([plot-x-transform  trans2])
     (plot (list (y-axis 2) (y-axis 3)
                 (function values 1 5)
                 (function cos 1 5 #:color 3))))
   (parameterize ([plot-x-transform  trans1]
                  [plot-y-transform  trans2])
     (define xs (nonlinear-seq 1 5 20 trans1))
     (define ys (nonlinear-seq 1 5 20 trans2))
     (plot (points (map vector xs ys))))))

(let ()
  (define trans (collapse-transform -1 1))
  (values
   (parameterize ([plot-x-transform  trans])
     (plot (list (y-axis 1)
                 (function values -2 2)
                 (function cos -2 2 #:color 3))))
   (parameterize ([plot-x-transform  trans]
                  [plot-y-transform  trans])
     (define xs (nonlinear-seq -2 2 20 trans))
     (plot (points (map vector xs xs))))))

(let ()
  (define trans1 (axis-transform-compose (collapse-transform 2 3) log-transform))
  (define trans2 (axis-transform-compose log-transform (collapse-transform 2 3)))
  (values
   (parameterize ([plot-x-transform  trans1])
     (plot (list (y-axis 3)
                 (function values 1 5)
                 (function cos 1 5 #:color 3))))
   (parameterize ([plot-x-transform  trans2])
     (plot (list (y-axis 3)
                 (function values 1 5)
                 (function cos 1 5 #:color 3))))
   (parameterize ([plot-x-transform  trans1]
                  [plot-y-transform  trans2])
     (define xs (nonlinear-seq 1 5 20 trans1))
     (define ys (nonlinear-seq 1 5 20 trans2))
     (plot (points (map vector xs ys))))))

(let ()
  (define trans1 (axis-transform-compose (stretch-transform -1 1 4)
                                         (collapse-transform -1/2 1/2)))
  (define trans2 (axis-transform-compose (collapse-transform -1/2 1/2)
                                         (stretch-transform -1 1 4)))
  (values
   (parameterize ([plot-x-transform  trans1])
     (plot (list (y-axis -1) (y-axis 1)
                 (y-axis -1/2) (y-axis 1/2)
                 (function values -2 2)
                 (function cos -2 2 #:color 3))))
   (parameterize ([plot-x-transform  trans2])
     (plot (list (y-axis -1) (y-axis 1)
                 (y-axis -1/2) (y-axis 1/2)
                 (function values -2 2)
                 (function cos -2 2 #:color 3))))
   (parameterize ([plot-x-transform  trans1]
                  [plot-y-transform  trans2])
     (define xs (nonlinear-seq -2 2 20 trans1))
     (define ys (nonlinear-seq -2 2 20 trans2))
     (plot (points (map vector xs ys))))))

(let ()
  (define trans1 (axis-transform-compose (collapse-transform -1 1) (collapse-transform -1/2 1/2)))
  (define trans2 (axis-transform-compose (collapse-transform -1/2 1/2) (collapse-transform -1 1)))
  (values
   (parameterize ([plot-x-transform  trans1])
     (plot (list (y-axis 1) (y-axis 1/2)
                 (function values -2 2)
                 (function cos -2 2 #:color 3))))
   (parameterize ([plot-x-transform  trans2])
     (plot (list (y-axis 1) (y-axis 1/2)
                 (function values -2 2)
                 (function cos -2 2 #:color 3))))
   (parameterize ([plot-x-transform  trans1]
                  [plot-y-transform  trans2])
     (define xs (nonlinear-seq -2 2 20 trans1))
     (define ys (nonlinear-seq -2 2 20 trans2))
     (plot (points (map vector xs ys))))))

(parameterize ([plot-x-transform  (collapse-transform -1 1)])
  (plot (function values 0 2)))

(parameterize ([plot-x-transform  (collapse-transform -1 1)])
  (plot (function values -2 0)))

(parameterize ([plot-x-transform  (axis-transform-append id-transform log-transform 0.1)])
  (plot (function sin -4 4)))

(let ()
  (define trans (axis-transform-append id-transform log-transform 2))
  (define ticks (log-ticks #:base 10))
  (values
   (parameterize ([plot-x-transform  trans]
                  [plot-x-ticks      ticks])
     (plot (list (function values 1 15)
                 (function cos 1 15 #:color 3))))
   (parameterize ([plot-x-transform  trans]
                  [plot-y-transform  trans])
     (define xs (nonlinear-seq 1 15 20 trans))
     (plot (points (map vector xs xs))))))

(let ()
  (define t1 (stretch-transform 2 3 4))
  (define t2 (stretch-transform 7 8 4))
  (define trans1 (axis-transform-compose (axis-transform-append t1 t2 5) log-transform))
  (define trans2 (axis-transform-compose log-transform (axis-transform-append t1 t2 5)))
  (values
   (parameterize ([plot-x-transform  trans1])
     (plot (list (for/list ([x  (in-list '(2 3 7 8))]) (y-axis x))
                 (function values 1 9))))
   (parameterize ([plot-x-transform  trans2])
     (plot (list (for/list ([x  (in-list '(2 3 7 8))]) (y-axis x))
                 (function values 1 9))))
   (parameterize ([plot-x-transform  trans1]
                  [plot-y-transform  trans2])
     (define xs (nonlinear-seq 1 9 50 trans1))
     (define ys (nonlinear-seq 1 9 50 trans2))
     (plot (points (map vector xs ys))))))

(let ()
  (define trans1 (axis-transform-append log-transform id-transform 5))
  (define trans2 (axis-transform-append id-transform log-transform 5))
  (values
   (parameterize ([plot-x-transform  trans1])
     (plot (list (y-axis 5)
                 (function values 6 10)
                 (function cos 6 10 #:color 3))))
   (parameterize ([plot-x-transform  trans2])
     (plot (list (y-axis 5)
                 (function values 6 10)
                 (function cos 6 10 #:color 3))))
   (parameterize ([plot-x-transform  trans1]
                  [plot-y-transform  trans2])
     (define xs (nonlinear-seq 6 10 20 trans1))
     (define ys (nonlinear-seq 6 10 20 trans2))
     (plot (points (map vector xs ys))))
   (parameterize ([plot-x-transform  trans1])
     (plot (list (y-axis 5)
                 (function values 1 4)
                 (function cos 1 4 #:color 3))))
   (parameterize ([plot-x-transform  trans2])
     (plot (list (y-axis 5)
                 (function values 1 4)
                 (function cos 1 4 #:color 3))))
   (parameterize ([plot-x-transform  trans1]
                  [plot-y-transform  trans2])
     (define xs (nonlinear-seq 1 4 20 trans1))
     (define ys (nonlinear-seq 1 4 20 trans2))
     (plot (points (map vector xs ys))))))

(parameterize ([plot-x-transform  (axis-transform-compose (collapse-transform 2 6)
                                                          log-transform)]
               [plot-x-ticks      (ticks-add (log-ticks) '(2 6))])
  (plot (list (y-axis 2) (y-axis 6)
              (function values 1 10))))

(let ()
  (define trans1 (axis-transform-bound log-transform 0.1 5))
  (define trans2 (axis-transform-bound (stretch-transform 1 2 4) 1 2))
  (values
   (parameterize ([plot-x-transform  trans1])
     (plot (list (y-axis 0.1) (y-axis 5)
                 (function values -3 9))))
   (parameterize ([plot-x-transform  trans2])
     (plot (list (y-axis 1) (y-axis 2)
                 (function values 0 3))))
   (parameterize ([plot-x-transform  trans1]
                  [plot-y-transform  trans2])
     (define xs (nonlinear-seq -3 9 20 trans1))
     (define ys (nonlinear-seq 0 3 20 trans2))
     (plot (points (map vector xs ys))))))