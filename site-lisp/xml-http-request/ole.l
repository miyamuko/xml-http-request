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

(defconstant +winhttp-progid-list+
  '("WinHttp.WinHttpRequest.5.1"
    "WinHttp.WinHttpRequest.5"
    ))

(defconstant +xhr-server-progid-list+
  '("Msxml2.ServerXMLHTTP"
    "Microsoft.ServerXMLHTTP"
    ))

(defconstant +xhr-client-progid-list+
  '("Msxml2.XMLHTTP"
    "Microsoft.XMLHTTP"
    ))

;; http://msdn.microsoft.com/en-us/library/aa384058(VS.85).aspx
(defconstant +HTTPREQUEST-SETCREDENTIALS-FOR-SERVER+  0)
(defconstant +HTTPREQUEST-SETCREDENTIALS-FOR-PROXY+ 1)

(defvar *xhr-ole-create-object-hook* nil)
(defvar *xhr-ole-method-hook* nil)
(defvar *xhr-ole-getprop-hook* nil)

(defun create-xmlhttp (&key progid)
  (check-type progid (or symbol string))
  (multiple-value-bind (progid-list progid)
      (cond ((or (null progid)
                 (string-equal progid "xmlhttp"))
             (values +xhr-client-progid-list+ :xmlhttp))
            ((string-equal progid "serverxmlhttp")
             (values +xhr-server-progid-list+ :serverxmlhttp))
            ((string-equal progid "winhttp")
             (values +winhttp-progid-list+ :winhttp))
            (t
             (plain-error "progidが不正です `~A': 有効な引数は (or :winhttp :serverxmlhttp :xmlhttp) です" progid)))
    (make-xmlhttp :oledata (or (try-create-object progid-list)
                               (plain-error "この環境では XMLHttpRequest オブジェクトを利用できません: ~S" progid-list))
                  :progid progid)))

(defun try-create-object (lst)
  (when lst
    (let ((progid (car lst)))
      (or (ignore-errors (%ole-create-object progid))
          (try-create-object (cdr lst))))))

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
