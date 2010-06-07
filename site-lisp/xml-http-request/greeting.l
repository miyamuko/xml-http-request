;;;; -*- mode: lisp; package: xml-http-request -*-
;;;;
;;;; File: xml-http-request/greeting.l
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

(defun greeting (req &key done nomsg)
  (when nomsg
    (return-from greeting nil))
  (let ((uri (http-transport-uri req))
        (method (http-request-method req)))
    (if done
        (message "Done ~A" uri)
      (message "~A ~A ..." method uri))))


(provide "xml-http-request/greeting")

;;;; End
