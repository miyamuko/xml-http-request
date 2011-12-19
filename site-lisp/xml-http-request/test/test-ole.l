; -*- mode: lisp; package: xml-http-request.test.ole; encoding: shift_jis -*-

;;; xml-http-request/test/test-ole.l
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

(require "xml-http-request")
(require "xml-http-request/test/helper")

(defpackage :xml-http-request.test.ole
  (:use :lisp :editor
   :lisp-unit :xml-http-request.test.helper
   :xml-http-request
   ))

(in-package :xml-http-request.test.ole)

(remove-all-tests :xml-http-request.test.ole)

(define-test xhr/create-xmlhttp/default
  (let ((xmlhttp (xhr::create-xmlhttp :progid nil)))
    (assert-type oledata (xhr::xmlhttp-oledata xmlhttp))
    (assert-eql :xmlhttp (xhr::xmlhttp-progid xmlhttp))
    (assert-string-matchp "XMLHTTP" (xhr::xmlhttp-progid-class xmlhttp)))

  (let ((xmlhttp (xhr::create-xmlhttp)))
    (assert-type oledata (xhr::xmlhttp-oledata xmlhttp))
    (assert-eql :xmlhttp (xhr::xmlhttp-progid xmlhttp))
    (assert-string-matchp "XMLHTTP" (xhr::xmlhttp-progid-class xmlhttp)))

  (let ((xhr::*default-progid* :serverxmlhttp))
    (let ((xmlhttp (xhr::create-xmlhttp)))
      (assert-type oledata (xhr::xmlhttp-oledata xmlhttp))
      (assert-eql :serverxmlhttp (xhr::xmlhttp-progid xmlhttp))
      (assert-string-matchp "ServerXMLHTTP" (xhr::xmlhttp-progid-class xmlhttp))))

  (let ((xhr::*default-progid* :winhttp))
    (let ((xmlhttp (xhr::create-xmlhttp)))
      (assert-type oledata (xhr::xmlhttp-oledata xmlhttp))
      (assert-eql :winhttp (xhr::xmlhttp-progid xmlhttp))
      (assert-string-matchp "WinHTTP" (xhr::xmlhttp-progid-class xmlhttp))))
  )

(define-test xhr/create-xmlhttp/progid
  (let ((xmlhttp (xhr::create-xmlhttp :progid :serverxmlhttp)))
    (assert-type oledata (xhr::xmlhttp-oledata xmlhttp))
    (assert-eql :serverxmlhttp (xhr::xmlhttp-progid xmlhttp))
    (assert-string-matchp "ServerXMLHTTP" (xhr::xmlhttp-progid-class xmlhttp)))

  (let ((xmlhttp (xhr::create-xmlhttp :progid :winhttp)))
    (assert-type oledata (xhr::xmlhttp-oledata xmlhttp))
    (assert-eql :winhttp (xhr::xmlhttp-progid xmlhttp))
    (assert-string-matchp "WinHttp" (xhr::xmlhttp-progid-class xmlhttp)))

  (let ((xmlhttp (xhr::create-xmlhttp :progid :xmlhttp)))
    (assert-type oledata (xhr::xmlhttp-oledata xmlhttp))
    (assert-eql :xmlhttp (xhr::xmlhttp-progid xmlhttp))
    (assert-string-matchp "XMLHTTP" (xhr::xmlhttp-progid-class xmlhttp)))
  )

(define-test xhr/create-xmlhttp/progid-with-version
  (when (progid-available-p "WinHttp.WinHttpRequest.5.1")
    (flet ((assert-xmlhttp (xmlhttp)
             (assert-eql :winhttp (xhr::xmlhttp-progid xmlhttp))
             (assert-equal "WinHttp.WinHttpRequest.5.1" (xhr::xmlhttp-progid-class xmlhttp))))
      (assert-xmlhttp (xhr::create-xmlhttp :progid :winhttp))
      (assert-xmlhttp (xhr::create-xmlhttp :progid '(:winhttp)))
      (assert-xmlhttp (xhr::create-xmlhttp :progid '(:winhttp . nil)))
      (assert-xmlhttp (xhr::create-xmlhttp :progid '(:winhttp . 5.1)))
      (assert-xmlhttp (xhr::create-xmlhttp :progid '(:winhttp 5.1)))
      (assert-xmlhttp (xhr::create-xmlhttp :progid '(:winhttp 100 5.1)))
      (assert-xmlhttp (xhr::create-xmlhttp :progid '(:winhttp 100 5.1 4.0)))
      (assert-xmlhttp (xhr::create-xmlhttp :progid '(:winhttp "5.1")))
      (assert-xmlhttp (xhr::create-xmlhttp :progid '(:winHTTP "5.1")))
      (assert-xmlhttp (xhr::create-xmlhttp :progid '(:winHTTP "5.1" "hogehoge")))
      (assert-xmlhttp (xhr::create-xmlhttp :progid "WinHttp.WinHttpRequest.5.1"))
      ))

  (when (progid-available-p "Msxml2.XMLHTTP.6.0")
    (flet ((assert-xmlhttp (xmlhttp)
             (assert-eql :xmlhttp (xhr::xmlhttp-progid xmlhttp))
             (assert-equal "Msxml2.XMLHTTP.6.0" (xhr::xmlhttp-progid-class xmlhttp))))
      (assert-xmlhttp (xhr::create-xmlhttp :progid '(:xmlhttp . 6.0)))
      (assert-xmlhttp (xhr::create-xmlhttp :progid '(:xmlhttp 6.0)))
      (assert-xmlhttp (xhr::create-xmlhttp :progid '(:xmlhttp 100 6.0)))
      (assert-xmlhttp (xhr::create-xmlhttp :progid '(:xmlhttp 100 6.0 5.0)))
      (assert-xmlhttp (xhr::create-xmlhttp :progid '(:xmlhttp "6.0")))
      (assert-xmlhttp (xhr::create-xmlhttp :progid '(:XMLHTTP "6.0")))
      (assert-xmlhttp (xhr::create-xmlhttp :progid '(:XMLHTTP "6.0" "hogehoge")))
      (assert-xmlhttp (xhr::create-xmlhttp :progid "Msxml2.XMLHTTP.6.0"))
      ))
  )

(define-test xhr/create-xmlhttp/invalid-progid
  (assert-error 'type-error
      (xhr::create-xmlhttp :progid 1.1))
  (assert-error 'plain-error
      (xhr::create-xmlhttp :progid :hoge))
  (assert-error 'plain-error
      (xhr::create-xmlhttp :progid "hoge"))
  )
