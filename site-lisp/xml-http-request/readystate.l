;;;; -*- mode: lisp; package: xml-http-request -*-
;;;;
;;;; File: xml-http-request/readystate.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008,2010 MIYAMUKO Katsuyuki.
;;;;
;;;;   xml-http-request is released under an MIT license.
;;;;   See xml-http-request/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "xml-http-request/base")
  )

(in-package :xml-http-request)

(defmacro define-ready-state (name value)
  (let ((const (intern (format nil "xhr-ready-state-~A" name)))
        (fun (intern (format nil "xhr-ready-state-~A-p" name))))
    `(progn
       (defconstant ,const ,value)
       (defun ,fun (transport)
         (eq (xhr-ready-state transport) ,value)))))

(define-ready-state uninitialized 0)
(define-ready-state loading       1)
(define-ready-state loaded        2)
(define-ready-state interactive   3)
(define-ready-state complete      4)

(defun xhr-ready-state (transport)
  (%ready-state (coerce-oledata transport)))

(defun xhr-request-complete-p (res)
  (let ((xmlhttp (http-response-xmlhttp res)))
    (case (xmlhttp-progid xmlhttp)
      ;; WinHTTPRequest ‚Í readyState ‚ðŽÀ‘•‚µ‚Ä‚¢‚È‚¢‚Ì‚Å WaitForResponse ‚Å”»’è
      (:winhttp
       (%wait-for-response (xmlhttp-oledata xmlhttp) 0))
      (t
       (xhr-ready-state-complete-p (xmlhttp-oledata xmlhttp))))))


(provide "xml-http-request/readystate")

;;;; End
