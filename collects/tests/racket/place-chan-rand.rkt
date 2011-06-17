#lang racket/base
(require racket/place 
         redex
         racket/runtime-path)

(define-language L
  (legal-message m i)
  
  (m (vector f ...)
     (shared-flvector fl ...)
     (shared-fxvector fx ...)
     (shared-bytes byte ...)
     str)
  
  (i (cons i i)
     (vector-immutable i ...)
     (string->immutable-string str) 
     f)
  
  (f '()
     #f
     #t
     num
     (string-ref one-len-str 0))
  (str (string-append one-len-str ...))
  (one-len-str "a" "b" "λ" "龍")
  (num fx
       fl
       1/2 1/3 1/4
       (sqrt num)
       (+ num num)
       (* num 0+1i)
       (- num))
  (fx byte (- byte) (expt 2 32) (expt 2 64) (- (expt 2 32)) (- (expt 2 64)))
  (fl 1.1 1.2 1.3 0.0 1e12 -1e33 1e-11 -1e-22 +inf.0 -inf.0 +nan.0)
  (byte 0 1 2 8 100 255))
  
(define-runtime-path return-place.rkt "place-chan-rand-help.rkt")
(define pch (dynamic-place return-place.rkt 'start))

(define ns (make-base-namespace))
(parameterize ([current-namespace ns])
  (namespace-require 'racket/flonum)
  (namespace-require 'racket/fixnum))

(define (try-message msg-code)
  ;; (printf "trying ~s\n" msg-code) ;; helpful when crashing ...
  (define msg (eval msg-code ns))
  (equal? msg (place-channel-put/get pch msg)))

(redex-check L legal-message 
             (try-message (term legal-message))
             #:attempts 10000)