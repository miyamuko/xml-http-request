; -*- mode: lisp; package: xml-http-request; encoding: shift_jis -*-

;;; xml-http-request/header.l
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

(defparameter *default-content-type* "application/x-www-form-urlencoded")


(defun make-request-header (headers has-data since)
  (let ((h (make-header-hash headers)))
    (set-header-x-yzzy-version h)
    (when has-data
      (set-header-default-content-type-if-need h))
    (when since
      (set-header-if-modified-since h since))
    h))

(defun make-header-hash (headers)
  (let ((h (make-hash-table :test #'equalp)))
    (dolist (pair (to-alist headers))
      (when (and (car pair) (cdr pair))
        (setf (gethash (stringy (car pair)) h) (stringy (cdr pair)))))
    h))

(defun set-header-x-yzzy-version (header-hash)
  (setf (gethash "X-Yzzy-Version" header-hash) (software-version)))

(defun set-header-default-content-type-if-need (header-hash)
  (unless (gethash "Content-Type" header-hash)
    (setf (gethash "Content-Type" header-hash) *default-content-type*)))

(defun set-header-if-modified-since (header-hash since)
  (setf (gethash "If-Modified-Since" header-hash) (since since)))

(defun set-request-headers (req)
;  (dump-hash (http-request-header-hash req))
  (let ((oledata (coerce-oledata req)))
    (maphash #'(lambda (k v)
                 (%set-request-header oledata k v))
             (http-request-header-hash req))))


(defun parse-raw-header (raw-header)
  (mapcar #'split-field (split-header raw-header)))

(defun split-header (raw-header)
  (split-string (substitute-string raw-header "\r\n\\|\r\\|\n" "\n") #\LFD))

(defun split-field (header)
  (when (string-matchp "^\\([^:]+\\): +\\(.+\\)$" header)
    (cons (match-string 1) (match-string 2))))


(provide "xml-http-request/header")

;;; End
