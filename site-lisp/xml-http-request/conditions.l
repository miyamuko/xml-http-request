; -*- mode: lisp; package: xml-http-request; encoding: shift_jis -*-

;;; xml-http-request/conditions.l
;;
;; Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;
;; Permission is hereby granted, free of charge, to any person obtaining
;; a copy of this software and associated documentation files (the
;; "Software"), to deal in the Software without restriction, including
;; without limitation the rights to use, copy, modify, merge, publish,
;; distribute, sublicense, and/or sell copies of the Software, and to
;; permit persons to whom the Software is furnished to do so, subject to
;; the following conditions:
;;
;; The above copyright notice and this permission notice shall be
;; included in all copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
;; LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
;; OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
;; WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

;;; Code:

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "xml-http-request/base")
  )

(in-package :xml-http-request)

(export '(xhr-error
          xhr-open-error
          xhr-too-long-url-error
          ))


(define-condition xhr-error (network-error)
  (msg)
  (:report (lambda (c s)
             (format s "HTTP error: ~A" (xhr-error-msg c)))))

(define-condition xhr-open-error (xhr-error)
  ()
  (:report (lambda (c s)
             (format s "open error: ~A" (xhr-open-error-msg c)))))

(define-condition xhr-too-long-url-error (xhr-error)
  ()
  (:report (lambda (c s)
             (format s "too long URL: ~A" (xhr-too-long-url-error-msg c)))))


(provide "xml-http-request/conditions")

;;; End
