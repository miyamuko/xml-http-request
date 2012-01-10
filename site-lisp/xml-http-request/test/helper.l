; -*- mode: lisp; package: xml-http-request.test.helper; encoding: shift_jis -*-

;;; xml-http-request/test/test-helper.l
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

(require "lisp-unit")

(defpackage :xml-http-request.test.helper
  (:use :lisp :editor :lisp-unit))

(in-package :xml-http-request.test.helper)

(export '(assert-string-matchp
          progid-available-p
          ))

(defmacro assert-string-matchp (expected form &rest extras)
  (lisp-unit::expand-assert :equal form form expected extras :test #'string-matchp))

(defun progid-available-p (progid)
  (ignore-errors (ole-create-object progid)))


(provide "xml-http-request/test/helper")

;;; End