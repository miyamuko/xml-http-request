;;;; -*- mode: lisp; package: xml-http-request -*-
;;;;
;;;; File: xml-http-request/response.l
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
  (require "xml-http-request/request")
  (require "xml-http-request/dom")
  )

(in-package :xml-http-request)

(export '(xhr-response-values
          xhr-requested-uri

          xhr-status
          xhr-status-text
          xhr-response-header
          xhr-all-response-header
          xhr-all-response-header-hash
          xhr-all-response-header-alist
          xhr-response-text
          xhr-response-xml
          ))

(defmacro fetch (res slot getter &key enclose)
  (with-gensyms (gres)
    `(let ((,gres ,res))
       (if (http-response-p ,gres)
           (,(if enclose 'funcall 'progn)
            (or (,slot ,gres)
                (setf (,slot ,gres)
                      (,(if enclose 'enclose 'progn)
                       (,getter (coerce-oledata ,gres))))))
         (,getter (coerce-oledata ,gres))))))

(defun xhr-response-values (res)
  (values
   (xhr-response-text res)
   (xhr-status res)
   (xhr-all-response-header-alist res)))

(defun xhr-requested-uri (res)
  (http-transport-uri res))

(defun xhr-status (res)
  (fetch res http-response-status %status))

(defun xhr-status-text (res)
  (fetch res http-response-status-text %status-text))

(defun xhr-all-response-header (res)
  (fetch res http-response-raw-header %get-all-response-headers :enclose t))

(defun xhr-all-response-header-hash (res)
  (flet ((raw-header->hash (oledata)
           (make-header-hash (parse-raw-header (%get-all-response-headers oledata)))))
    (fetch res http-response-header-hash raw-header->hash :enclose t)))

(defun xhr-all-response-header-alist (res)
  (parse-raw-header (xhr-all-response-header res)))

(defun xhr-response-header (res header)
  (identity (gethash header (xhr-all-response-header-hash res))))

(defun xhr-response-text (res)
  (fetch res http-response-text %response-text :enclose t))

(defun xhr-response-xml (res)
  (flet ((response-xml->sexp (oledata)
           (dom->sexp (%response-xml oledata))))
    (fetch res http-response-xml response-xml->sexp :enclose t)))


;;;; private

(defun response-success-p (res)
  (let ((status (xhr-status res)))
    (and (<= 200 status) (< status 300))))


(provide "xml-http-request/response")

;;;; End
