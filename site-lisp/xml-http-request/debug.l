;;;; -*- mode: lisp; package: xml-http-request -*-
;;;;
;;;; File: xml-http-request/debug.l
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
  (require "xml-http-request/ole")
  )

(in-package :xml-http-request)

(defun xhr-trace (oledata method &rest args)
  (let ((buffer (get-buffer-create "*xhr:debug*")))
    (setup-temp-buffer buffer)
    (with-output-to-buffer (buffer (buffer-size buffer))
      (case method
        (:open
         (multiple-value-bind (http-method uri async user password)
             (values-list args)
           (format t "~A~%" (format-date-string "---- [%Y-%m-%d %H:%M:%S] ----"))
           (format t "~A ~A~%" http-method uri)
           (when user
             (format t "Authorization: Basic ~A~%" (si:base64-encode (format nil "~A:~A" user password))))))
        (:setRequestHeader
         (format t "~A: ~A~%" (car args) (cadr args)))
        (:send
         (if (and (car args) (< 0 (length (car args))))
             (format t "~%~A~%~%" (car args))
           (format t "~%")))))))

(defun enable-trace ()
  (add-hook '*xhr-ole-method-hook* 'xhr-trace))

(defun disable-trace ()
  (delete-hook '*xhr-ole-method-hook* 'xhr-trace))


(provide "xml-http-request/debug")

;;;; End
