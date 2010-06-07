;;;; -*- mode: lisp; package: xml-http-request -*-
;;;;
;;;; File: xml-http-request/compat.l
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

;;;; End
