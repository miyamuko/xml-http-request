;;;; -*- mode: lisp; package: user -*-
;;;;
;;;; File: xml-http-request/package.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;;;
;;;;   xml-http-request is released under an MIT license.
;;;;   See xml-http-request/docs/MIT-LICENSE for full license.
;;;;

(unless (find-package :xml-http-request)
  (defpackage :xml-http-request
    (:nicknames :xhr :msxml)
    (:use
     :lisp
     :editor ;; ole-create-object ‚È‚Ç
     )))


(provide "xml-http-request/package")

;;;; End
