; -*- mode: lisp; package: xml-http-request; encoding: shift_jis -*-

;;; xml-http-request/compat.l
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
  (require "xml-http-request/base")
  (require "xml-http-request/api")
  )

(in-package :xml-http-request)

(export '(http-get
          http-post
          abort
          status
          status-text
          response-text
          response-header
          all-response-headers
          ))

(defun compat-response-text-and-status (res)
  (values
   (xhr-response-text res)
   (xhr-status res)))

(defun http-get (url &key headers onfailure onsuccess oncomplete)
  (if (or onfailure onsuccess oncomplete)
      (coerce-oledata
       (xhr-get-async url
                      :key 'coerce-oledata
                      :headers headers
                      :handler `((:complete . ,oncomplete)
                                 (:failure . ,onfailure)
                                 (:success . ,onsuccess))))
    (xhr-get url :headers headers :key 'compat-response-text-and-status)))

(defun http-post (url data &key headers onfailure onsuccess oncomplete)
  (if (or onfailure onsuccess oncomplete)
      (coerce-oledata
       (xhr-post-async url data
                       :key 'coerce-oledata
                       :headers headers
                       :handler `((:complete . ,oncomplete)
                                  (:failure . ,onfailure)
                                  (:success . ,onsuccess))))
    (xhr-post url data :headers headers :key 'compat-response-text-and-status)))

(alias abort %abort)
(alias status %status)
(alias status-text %status-text)
(alias response-text %response-text)
(alias response-header %get-response-header)
(alias all-response-headers %get-all-response-headers)


(provide "xml-http-request/compat")

;;; End
