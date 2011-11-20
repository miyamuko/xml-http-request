; -*- mode: lisp; package: xml-http-request; encoding: shift_jis -*-

;;; xml-http-request/readystate.l
;;
;; Copyright (c) 2008,2010 MIYAMUKO Katsuyuki.
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

(export '(xhr-request-completed-p
          xhr-request-aborted-p
          xhr-request-waiting-p
          ))

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

;; request Ç™äÆóπÇµÇΩèÍçáÇ… t Çï‘Ç∑ (abort ÇµÇΩèÍçáÇÕ nil)
(defun xhr-request-completed-p (transport)
  (let ((xmlhttp (http-transport-xmlhttp transport)))
    (unless (xhr-request-aborted-p transport)
      (case (xmlhttp-progid xmlhttp)
        ;; WinHTTPRequest ÇÕ readyState Çé¿ëïÇµÇƒÇ¢Ç»Ç¢ÇÃÇ≈ WaitForResponse Ç≈îªíË
        (:winhttp
         (%wait-for-response (xmlhttp-oledata xmlhttp) 0))
        (t
         (xhr-ready-state-complete-p (xmlhttp-oledata xmlhttp)))))))

;; request Ç™ abort ÇµÇΩèÍçáÇ… t Çï‘Ç∑
(defun xhr-request-aborted-p (transport)
  (let ((xmlhttp (http-transport-xmlhttp transport)))
    (xmlhttp-aborted-p xmlhttp)))

;; request Ç™èàóùíÜÇ»ÇÁ t Çï‘Ç∑
(defun xhr-request-waiting-p (transport)
  (and (not (xhr-request-aborted-p transport))
       (not (xhr-request-completed-p transport))))


(provide "xml-http-request/readystate")

;;; End
