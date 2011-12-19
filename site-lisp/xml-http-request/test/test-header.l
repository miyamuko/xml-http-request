; -*- mode: lisp; package: xml-http-request.test.header; encoding: shift_jis -*-

;;; xml-http-request/test/test-header.l
;;
;; Copyright (c) 2011 MIYAMUKO Katsuyuki.
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

(defpackage :xml-http-request.test.header
  (:use :lisp :editor
   :lisp-unit
   :xml-http-request
   ))

(in-package :xml-http-request.test.header)

(remove-all-tests :xml-http-request.test.header)

(define-test xhr/parse-raw-header
  (assert-equalp '()
      (xhr::parse-raw-header nil))
  (assert-equalp '()
      (xhr::parse-raw-header ""))
  (assert-equalp '()
      (xhr::parse-raw-header "  "))
  (assert-equalp '()
      (xhr::parse-raw-header "hoge"))
  (assert-equalp '(("Content-Type" . "text/html"))
      (xhr::parse-raw-header "Content-Type: text/html"))
  (assert-equalp '(("Content-Type" . "text/html"))
      (xhr::parse-raw-header "Content-Type:text/html"))
  (assert-equalp '(("Content-Type" . "text/html"))
      (xhr::parse-raw-header "Content-Type : text/html"))
  (assert-equalp '(("Content-Type" . "text/html"))
      (xhr::parse-raw-header "Content-Type        :                   text/html"))
  (assert-equalp '(("Content-Type" . "text/html")
                  ("Content-Length" . "1"))
      (xhr::parse-raw-header "Content-Type: text/html\nContent-Length:1"))
  )
