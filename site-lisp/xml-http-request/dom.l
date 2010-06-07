;;;; -*- mode: lisp; package: xml-http-request -*-
;;;;
;;;; File: xml-http-request/dom.l
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
  (let ((type (ole-getprop xml 'NodeType)))
    (cond ((= type +document-node+)
           (dom-list->sexp xml 'ChildNodes))
          ((= type +element-node+)
           (nconc (list (ole-getprop xml 'NodeName)
                        (dom-list->sexp xml 'Attributes))
                  (dom-list->sexp xml 'ChildNodes)))
          ((= type +attribute-node+)
           (cons (ole-getprop xml 'Name)
                 (ole-getprop xml 'Value)))
          ((or (= type +text-node+)
               (= type +cdata-section-node+)
               (= type +entity-node+))
           (ole-getprop xml 'NodeValue))
;; xml-parse-modoki ŒÝŠ·‚É‚·‚é‚½‚ß‚Æ‚è‚ ‚¦‚¸–³Ž‹
;          ((= type +processing-instruction+)
;           (list (ole-getprop xml 'NodeName)
;                 (ole-getprop xml 'NodeValue)))
          (t
           ;; ignore
           nil))))

(defun compact (lst)
  (remove-if #'null lst))

(defun dom-list->sexp (oledata prop)
  (compact (mapcar #'dom->sexp (ole-collection-to-list (ole-getprop oledata prop)))))

(defun ole-collection-to-list (collection)
  (let ((result)
        (len (ole-getprop collection 'length)))
    (do ((i 0 (1+ i)))
        ((not (< i len)))
      (push (ole-method collection 'item i) result))
    (reverse result)))


(provide "xml-http-request/dom")

;;;; End
