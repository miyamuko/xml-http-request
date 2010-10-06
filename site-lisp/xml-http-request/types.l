;;;; -*- mode: lisp; package: xml-http-request -*-
;;;;
;;;; File: xml-http-request/types.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;;;
;;;;   xml-http-request is released under an MIT license.
;;;;   See xml-http-request/docs/MIT-LICENSE for full license.
;;;;

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

;;;; End
