;;;; -*- mode: lisp; package: xml-http-request -*-
;;;;
;;;; File: xml-http-request/credential.l
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
  (require "xml-http-request/ole")
  )

(in-package :xml-http-request)

(export '(xhr-credential
          ))

;; *Trace Output* バッファにユーザ名とパスワードを出力しないように
;; クロージャでラップする

(defstruct credential
  v)

(defun xhr-credential (user password)
  (make-credential
   :v #'(lambda () (list user password))))

(defun xhr-credential-values (credential)
  (when credential
    (unless (credential-p credential)
      (plain-error "Invalid credential `~S'~%Usage: (xhr-credential \"user\" \"password\")"
                   credential))
    (values-list
     (funcall (credential-v credential)))))


(provide "xml-http-request/credential")

;;;; End
