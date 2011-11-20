; -*- mode: lisp; package: xml-http-request; encoding: shift_jis -*-

;;; xml-http-request/dispatcher.l
;;
;; Copyright (c) 2008,2010-2011 MIYAMUKO Katsuyuki.
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
  (require "xml-http-request/readystate")
  (require "xml-http-request/greeting")
  )

(in-package :xml-http-request)

;; XMLHttpRequest の onreadystatechange を使う方法が良く分からないので
;; ポーリングして監視。

(defvar *xhr-response-hook* nil)
(defvar *xhr-abort-hook* nil)

(defvar *event-dispatch-interval* 0.1
  "xml-http-request: 非同期通信の終了を監視する間隔 (秒)")

(defparameter *request-queue* nil)


(defun process-event-handler-form (forms)
  (mapcar #'(lambda (form)
              (multiple-value-bind (method event args)
                  (values-list form)
                (when (or (string/= (symbol-name method) "on")
                          (not (and event (atom event))))
                  (error 'bad-macro-form :datum form))
                (unless args
                  (error 'too-few-arguments :datum form))
                `(cons ,event #'(lambda ,args ,@(cdddr form)))))
          forms))

(defun register-handler (req key handler nomsg)
  (pushnew (list req key handler nomsg) *request-queue*)
  (dispatch-later))

(defun xhr-event-dispatch ()
  (dolist (e (reverse *request-queue*))
    (multiple-value-bind (req key handler nomsg)
        (values-list e)
      (handler-case
          (cond ((xhr-request-aborted-p req)
                 (setf *request-queue* (remove e *request-queue*))
                 (greeting req :abort t :nomsg nomsg)
                 (run-hook-with-args '*xhr-abort-hook* req))
                ((xhr-request-completed-p req)
                 (setf *request-queue* (remove e *request-queue*))
                 (let ((res (http-request->response req)))
                   (greeting req :done t :nomsg nomsg)
                   (run-hook-with-args '*xhr-response-hook* res)
                   (let ((events (list (xhr-status res)
                                       (if (response-success-p res) :success :failure)
                                       :complete)))
                     (dolist (event events)
                       (fire-event handler event key res))))))
        (error (c)
          (process-error req c "xml-http-request 内でエラーが発生しました")
          (setf *request-queue* (remove e *request-queue*))))))
  (when *request-queue*
    (dispatch-later)))

(defun fire-event (handler-alist event key res)
  (let ((handler (cdr (assoc event handler-alist))))
    (when handler
      (handler-case
          (apply handler (multiple-value-list
                          (funcall (or key 'identity) res)))
        (error (c)
          (process-error res c "~Aハンドラの実行中にエラーが発生しました" event)
          )))))

(defun process-error (transport c fmt &rest args)
  (let ((msg (format nil "~?~%URL: ~A~%~%~A: ~A~%~S"
                     fmt args
                     (http-transport-uri transport)
                     (si:*structure-definition-name (si:*structure-definition c))
                     (si:*condition-string c)
                     transport)))
    (message msg)
    (warn msg)))

(defun dispatch-later (&optional (interval *event-dispatch-interval*))
  (start-timer interval 'xhr-event-dispatch t))


(provide "xml-http-request/dispatcher")

;;; End
