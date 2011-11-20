; -*- mode: lisp; package: xml-http-request; encoding: shift_jis -*-

;;; xml-http-request/debug.l
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
  (require "xml-http-request/ole")
  (require "xml-http-request/request")
  )

(in-package :xml-http-request)

(defmacro with-trace-buffer (&rest body)
  `(let ((buffer (get-buffer-create "*xhr:debug*")))
     (setup-temp-buffer buffer)
     (with-output-to-buffer (buffer (buffer-size buffer))
       ,@body)))
(setf (get 'with-trace-buffer 'ed:lisp-indent-hook) 'with-output-to-buffer)

(defmacro puts (&rest args)
  `(progn
     (format t ,@args)
     (terpri)
     ))

(defun puts-header (title)
  (puts "")
  (puts "#### ~A ~A ##############################"
        (format-date-string "[%Y-%m-%d %H:%M:%S]") title))

(defun puts-basicauth (user password)
  (puts "Authorization: Basic ~A" (remove #\LFD (si:base64-encode (format nil "~A:~A" user password)))))

(defun xhr-trace-create-object (oledata progid)
  (with-trace-buffer
   (puts-header "Initialize")
   (puts "Create ~A object" progid)))

(defun xhr-trace-method (oledata method &rest args)
  (with-trace-buffer
   (case method
     (:open
      (multiple-value-bind (http-method uri async user password)
          (values-list args)
        (puts-header "Request")
        (puts "~A ~A HTTP/1.0" http-method uri)
        (when user
          (puts-basicauth user password))))
     (:setCredentials
      (puts-basicauth (car args) (cadr args)))
     (:setRequestHeader
      (puts "~A: ~A" (car args) (cadr args)))
     (:send
      (when (and (car args) (< 0 (length (car args))))
        (puts "")
        (puts "~A" (car args)))
      (puts "")))))

(defun xhr-trace-response (xhr)
  (with-trace-buffer
   (puts-header "Response")
   (puts "HTTP/1.0 ~A ~A" (xhr-status xhr) (xhr-status-text xhr))
   (dolist (h (xhr-all-response-header-alist xhr))
     (puts "~A: ~A" (car h) (cdr h)))
   (puts "")
   (puts "~A" (xhr-response-text xhr))))

(defun xhr-trace-abort (xhr)
  (with-trace-buffer
   (puts-header "Abort")
   (puts "ABORT ~A" (http-transport-uri xhr))))

(defun enable-trace ()
  (interactive)
  (add-hook '*xhr-ole-method-hook* 'xhr-trace-method)
  (add-hook '*xhr-ole-create-object-hook* 'xhr-trace-create-object)
  (add-hook '*xhr-response-hook* 'xhr-trace-response)
  (add-hook '*xhr-abort-hook* 'xhr-trace-abort)
  (message "XHR Trace: On")
  )

(defun disable-trace ()
  (interactive)
  (delete-hook '*xhr-ole-method-hook* 'xhr-trace-method)
  (delete-hook '*xhr-ole-create-object-hook* 'xhr-trace-create-object)
  (delete-hook '*xhr-response-hook* 'xhr-trace-response)
  (delete-hook '*xhr-abort-hook* 'xhr-trace-abort)
  (message "XHR Trace: Off")
  )


(provide "xml-http-request/debug")

;;; End
