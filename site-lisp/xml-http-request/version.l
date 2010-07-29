;;;; -*- mode: lisp; package: xml-http-request -*-
;;;;
;;;; File: xml-http-request/version.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008,2010 MIYAMUKO Katsuyuki.
;;;;
;;;;   xml-http-request is released under an MIT license.
;;;;   See xml-http-request/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "xml-http-request/package")
  )

(in-package :xml-http-request)

(export '(xml-http-request-version
          ))

(defconstant +xml-http-request-version+ "1.3.0")

(defun xml-http-request-version ()
  +xml-http-request-version+)


(provide "xml-http-request/version")

;;;; End
