; -*- mode: lisp; package: xml-http-request; encoding: shift_jis -*-

;;; xml-http-request/ole.l
;;
;; Copyright (c) 2008,2010 MIYAMUKO Katsuyuki.
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
  (require "xml-http-request/package")
  )

(in-package :xml-http-request)

;; http://msdn.microsoft.com/en-us/library/aa384058(VS.85).aspx
(defconstant +HTTPREQUEST-SETCREDENTIALS-FOR-SERVER+  0)
(defconstant +HTTPREQUEST-SETCREDENTIALS-FOR-PROXY+ 1)

(defparameter *progid-alist*
  '((:xmlhttp "Msxml2.XMLHTTP" "Microsoft.XMLHTTP")
    (:serverxmlhttp "Msxml2.ServerXMLHTTP" "Microsoft.ServerXMLHTTP")
    (:winhttp "WinHttp.WinHttpRequest.5.1" "WinHttp.WinHttpRequest.5")))

(defparameter *default-progid* :xmlhttp)

(defvar *xhr-ole-create-object-hook* nil)
(defvar *xhr-ole-method-hook* nil)
(defvar *xhr-ole-getprop-hook* nil)

(defun create-xmlhttp (&key progid)
  (multiple-value-bind (progid-list progid)
      (make-progid-list progid)
    (multiple-value-bind (oledata progid-class)
        (try-create-object progid-list)
      (unless oledata
        (plain-error "この環境では XMLHttpRequest オブジェクトを利用できません: ~S" progid-list))
      (make-xmlhttp :oledata oledata :progid progid :progid-class progid-class ))))

(defun make-progid-list (progid-spec)
  (check-type progid-spec (or symbol string list))
  (cond ((null progid-spec)
         ;; progid 指定なし (デフォルト利用)
         ;; :progid nil
         (make-progid-list *default-progid*))
        ((listp progid-spec)
         ;; バージョン指定
         ;; :progid '(:serverxmlhttp . 6.0)
         ;; :progid '(:serverxmlhttp 6.0)
         ;; :progid '(:serverxmlhttp 6.0 7.0)
         ;; :progid '("Msxml2.ServerXMLHTTP" 6.0)
         (let ((versions (cdr progid-spec)))
           (unless versions
             (return-from make-progid-list (make-progid-list (car progid-spec))))
           (multiple-value-bind (progid-list type)
               (make-progid-list (car progid-spec))
             (when (atom versions)
               (setf versions (list versions)))
             (values (remove-duplicates
                      (mapcan #'(lambda (progid)
                                  (let ((base-progid (substitute-string progid "\\(\\.[0-9]\\)*$" "")))
                                    (mapcar #'(lambda (version)
                                                (format nil "~A.~A" base-progid version))
                                            versions)))
                              progid-list)
                      :test #'string-equal)
                     type))))
        ((symbolp progid-spec)
         ;; キーワード指定
         ;; :progid :serverxmlhttp
         (let ((alist (assoc progid-spec *progid-alist* :test #'string-equal)))
           (unless alist
             (plain-error "progidが不正です `~A': 有効な引数は (or :winhttp :serverxmlhttp :xmlhttp) です"
                          progid-spec))
           (values (cdr alist)
                   (car alist))))
        ((stringp progid-spec)
         ;; クラス名直接指定
         ;; :progid "Msxml2.ServerXMLHTTP.6.0"
         (values (list progid-spec)
                 (progid-type progid-spec)))
        ))

(defun progid-type (progid)
  (cond ((string-matchp "WinHttp" progid)
         :winhttp)
        ((string-matchp "ServerXMLHTTP" progid)
         :serverxmlhttp)
        (t
         :xmlhttp)))

(defun try-create-object (lst)
  (when lst
    (let ((progid (car lst)))
       (handler-case
           (values (%ole-create-object progid)
                   progid)
         (error (_)
           (try-create-object (cdr lst)))))))

(defun %ole-create-object (progid)
  (let ((obj (ole-create-object progid)))
    (run-hook-with-args '*xhr-ole-create-object-hook* obj progid)
    obj))


(defmacro hide-stacktrace (&body body)
  `(handler-case
       (let ((si:*trace-on-error* nil))
         ,@body)
     (error (c)
       (si:*throw-error c))))

(defmacro %ole-method (&rest args)
  `(progn
     (run-hook-with-args '*xhr-ole-method-hook* ,@args)
     (ole-method ,@args)))

(defmacro %ole-getprop (&rest args)
  `(progn
     (run-hook-with-args '*xhr-ole-getprop-hook* ,@args)
     (ole-getprop ,@args)))


(defun %open (oledata method uri &optional (async t) basic-auth)
  (if (not basic-auth)
      (%ole-method oledata :open method uri async)
    (multiple-value-bind (user password)
        (xhr-credential-values basic-auth)
      (hide-stacktrace
       (%ole-method oledata :open method uri async user password)))))

(defun %send (oledata &optional data)
  (%ole-method oledata :send data))

(defun %abort (oledata)
  (%ole-method oledata :abort))

(defun %set-request-header (oledata header value)
  (%ole-method oledata :setRequestHeader header value))

(defun %set-credentials (oledata basic-auth flags)
  (when basic-auth
    (multiple-value-bind (user password)
        (xhr-credential-values basic-auth)
      (hide-stacktrace
       (%ole-method oledata :setCredentials user password flags)))))

(defun %get-all-response-headers (oledata)
  (%ole-method oledata :getAllResponseHeaders))

(defun %get-response-header (oledata header)
  (%ole-method oledata :getResponseHeader header))

(defun %wait-for-response (oledata timeout)
  (%ole-method oledata :waitForResponse timeout))


(defun %ready-state (oledata)
  (%ole-getprop oledata :readyState))

(defun %status (oledata)
  (%ole-getprop oledata :status))

(defun %status-text (oledata)
  (%ole-getprop oledata :statusText))

(defun %response-text (oledata)
  (%ole-getprop oledata :responseText))

(defun %response-xml (oledata)
  (%ole-getprop oledata :responseXml))


(provide "xml-http-request/ole")

;;; End
