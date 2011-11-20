; -*- mode: lisp; package: xml-http-request; encoding: shift_jis -*-

;;; xml-http-request/dom.l
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
  )

(in-package :xml-http-request)

;; dom -> sexp

(defconstant +element-node+           1)
(defconstant +attribute-node+         2)
(defconstant +text-node+              3)
(defconstant +cdata-section-node+     4)
(defconstant +entity-reference-node+  5)
(defconstant +entity-node+            6)
(defconstant +processing-instruction+ 7)
(defconstant +comment-node+           8)
(defconstant +document-node+          9)
(defconstant +document-type-node+     10)
(defconstant +document-fragment-node+ 11)
(defconstant +notation-node+          12)

(defun dom->sexp (xml)
  (let ((type (ole-getprop xml :NodeType)))
    (cond ((= type +document-node+)
           (dom-list->sexp xml :ChildNodes))
          ((= type +element-node+)
           (nconc (list (ole-getprop xml :NodeName)
                        (dom-list->sexp xml :Attributes))
                  (dom-list->sexp xml :ChildNodes)))
          ((= type +attribute-node+)
           (cons (ole-getprop xml :Name)
                 (ole-getprop xml :Value)))
          ((or (= type +text-node+)
               (= type +cdata-section-node+)
               (= type +entity-node+))
           (ole-getprop xml :NodeValue))
;; xml-parse-modoki ŒÝŠ·‚É‚·‚é‚½‚ß‚Æ‚è‚ ‚¦‚¸–³Ž‹
;          ((= type +processing-instruction+)
;           (list (ole-getprop xml :NodeName)
;                 (ole-getprop xml :NodeValue)))
          (t
           ;; ignore
           nil))))

(defun dom-list->sexp (oledata prop)
  (remove-if #'null
             (mapcar #'dom->sexp
                     (ole-collection->list (ole-getprop oledata prop)))))

(defun ole-collection->list (collection)
  (let ((result)
        (len (ole-getprop collection :Length)))
    (do ((i 0 (1+ i)))
        ((not (< i len)))
      (push (ole-method collection :Item i) result))
    (nreverse result)))


(provide "xml-http-request/dom")

;;; End
