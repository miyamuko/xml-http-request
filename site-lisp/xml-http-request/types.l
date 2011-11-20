; -*- mode: lisp; package: xml-http-request; encoding: shift_jis -*-

;;; xml-http-request/types.l
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
  (require "xml-http-request/package")
  (require "xml-http-request/util")
  (require "xml-http-request/ole")
  )

(in-package :xml-http-request)

(defstruct xmlhttp
  oledata progid aborted-p)

(defstruct http-transport
  uri xmlhttp)

(defstruct (http-request (:include http-transport))
  method
  header-hash
  data
  )

(defstruct (http-response (:include http-transport))
  status status-text
  raw-header header-hash
  text xml
  )

(defstruct (xhr-cancel-ticket (:include http-transport))
  )

(defstruct (xhr-future (:include http-transport))
  completed-p result)


(defun coerce-oledata (obj)
  (cond ((oledatap obj)
         obj)
        ((http-transport-p obj)
         (xmlhttp-oledata (http-transport-xmlhttp obj)))
        (t
         (type-error '(or oledata http-transport) obj))))

(defun http-request->response (req)
  (make-http-response
   :uri (http-transport-uri req)
   :xmlhttp (http-transport-xmlhttp req)))

(defun http-request->cancel-ticket (req)
  (make-xhr-cancel-ticket
   :uri (http-transport-uri req)
   :xmlhttp (http-transport-xmlhttp req)))

(defun http-request->future (req)
  (make-xhr-future
   :uri (http-transport-uri req)
   :xmlhttp (http-transport-xmlhttp req)))


(provide "xml-http-request/types")

;;; End
