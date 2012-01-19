; -*- mode: lisp; package: xml-http-request; encoding: shift_jis -*-

;;; xml-http-request/response.l
;;
;; Copyright (c) 2008,2012 MIYAMUKO Katsuyuki.
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
       (unless (xhr-request-aborted-p ,gres)
         (if (http-response-p ,gres)
             (,(if enclose 'funcall 'progn)
              (or (,slot ,gres)
                  (setf (,slot ,gres)
                        (,(if enclose 'enclose 'progn)
                         (,getter (coerce-oledata ,gres))))))
           (,getter (coerce-oledata ,gres)))))))

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
  (let ((all (xhr-all-response-header-hash res)))
    (when all
      (identity (gethash header all)))))

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

;;; End
