;;;; -*- mode: lisp; package: xml-http-request -*-
;;;;
;;;; File: xml-http-request/conditions.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;;;
;;;;   xml-http-request is released under an MIT license.
;;;;   See xml-http-request/docs/MIT-LICENSE for full license.
;;;;

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

;;;; End
