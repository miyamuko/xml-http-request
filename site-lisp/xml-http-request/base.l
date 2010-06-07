;;;; -*- mode: lisp; package: user -*-
;;;;
;;;; File: xml-http-request/base.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;;;
;;;;   xml-http-request.l is released under an MIT license.
;;;;   See xml-http-request.l/docs/MIT-LICENSE for full license.
;;;;

(in-package :user)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "xml-http-request/package")
  (require "xml-http-request/macros")
  (require "xml-http-request/types")
  (require "xml-http-request/util")
  (require "xml-http-request/ole")
  )

(provide "xml-http-request/base")

;;;; End
