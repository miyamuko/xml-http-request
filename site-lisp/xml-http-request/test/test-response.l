; -*- mode: lisp; package: xml-http-request.test.response; encoding: shift_jis -*-

;; Copyright (c) 2012 MIYAMUKO Katsuyuki.
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

(require "xml-http-request")
(require "lisp-unit")

(defpackage :xml-http-request.test.response
  (:use :lisp :editor
   :lisp-unit
   :xml-http-request
   ))

(in-package :xml-http-request.test.response)

(remove-all-tests :xml-http-request.test.response)

(define-test xhr/abort-response-getter
  (let ((req (xhr:xhr-get-async "http://localhost/")))
    (assert-eq t (xhr:xhr-abort req))
    (assert-eq nil (xhr:xhr-status req))
    (assert-eq nil (xhr:xhr-status-text req))
    (assert-eq nil (xhr:xhr-response-text req))
    (assert-eq nil (xhr:xhr-response-xml req))
    (assert-eq nil (xhr:xhr-response-header req "Content-Type"))
    (assert-eq nil (xhr:xhr-all-response-header req))
    (assert-eq nil (xhr:xhr-all-response-header-alist req))
    (assert-eq nil (xhr:xhr-all-response-header-hash req))
    )
  )

(define-test xhr/abort-callback-with-key
  (let* ((onabort-called-p)
         (onabort-arg)
         (req (xhr:xhr-get-async "http://localhost/"
                                :key 'xhr:xhr-response-text
                                :onabort #'(lambda (text)
                                             (setf onabort-called-p t
                                                   onabort-arg text))
                                 )))
    (assert-eq t (xhr:xhr-abort req))
    (sleep-for 0.3)
    (assert-eq t onabort-called-p)
    (assert-eq nil onabort-arg)
    )
  (let* ((onabort-called-p)
         (onabort-arg)
         (req (xhr:xhr-get-async "http://localhost/"
                                :key 'xhr:xhr-requested-uri
                                :onabort #'(lambda (text)
                                             (setf onabort-called-p t
                                                   onabort-arg text))
                                 )))
    (assert-eq t (xhr:xhr-abort req))
    (sleep-for 0.3)
    (assert-eq t onabort-called-p)
    (assert-equal "http://localhost/" onabort-arg)
    )
  )
