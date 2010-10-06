;;;; -*- mode: lisp; package: xml-http-request -*-
;;;;
;;;; File: xml-http-request/dispatcher.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008,2010 MIYAMUKO Katsuyuki.
;;;;
;;;;   xml-http-request is released under an MIT license.
;;;;   See xml-http-request/docs/MIT-LICENSE for full license.
;;;;

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
  (when (= 1 (length *request-queue*))
    (start-dispatcher *event-dispatch-interval*)))

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
          (errbox req c "xml-http-request 内でエラーが発生しました")
          (setf *request-queue* (remove e *request-queue*))))))
  (when (endp *request-queue*)
    (stop-dispatcher)))

(defun fire-event (handler-alist event key res)
  (let ((handler (cdr (assoc event handler-alist))))
    (when handler
      (handler-case
          (apply handler (multiple-value-list
                          (funcall (or key 'identity) res)))
        (error (c)
          (errbox res c "~Aハンドラの実行中にエラーが発生しました" event)
          )))))

(defun errbox (transport c fmt &rest args)
  (message-box (format nil "~?~%URL: ~A~%~%~A: ~A~%~S"
                       fmt args
                       (http-transport-uri transport)
                       (si:*structure-definition-name (si:*structure-definition c))
                       (si:*condition-string c)
                       transport)
               nil '(:exclamation)))

(defun start-dispatcher (interval)
  (start-timer interval 'xhr-event-dispatch))

(defun stop-dispatcher ()
  (stop-timer 'xhr-event-dispatch))


(provide "xml-http-request/dispatcher")

;;;; End
