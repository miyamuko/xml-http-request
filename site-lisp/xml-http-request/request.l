; -*- mode: lisp; package: xml-http-request; encoding: shift_jis -*-

;;; xml-http-request/request.l
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
  (require "xml-http-request/base")
  (require "xml-http-request/readystate")
  (require "xml-http-request/conditions")
  (require "xml-http-request/dispatcher")
  (require "xml-http-request/future")
  (require "xml-http-request/greeting")
  (require "xml-http-request/header")
  (require "xml-http-request/credential")
  )

(in-package :xml-http-request)

(export '(xhr-request
          xhr-request-future
          xhr-request-async
          with-xhr-request-async

          xhr-abort
          ))

(defparameter *xhr-max-url-length* 2084)

(defmacro define-xhr-request-method (method &key data exports)
  (flet ((keyword-args (names)
           (mapcan #'(lambda (name)
                       (list (intern (symbol-name name) :keyword) name))
                   names)))
    (let* ((sync (symbol-join "xhr-" method))
           (future (symbol-join "xhr-" method "-future"))
           (async (symbol-join "xhr-" method "-async"))
           (with-async (symbol-join "with-" async))
           (req-args (if data '(url data) '(url)))
           (req-args2 (if data '(url data) '(url nil)))
           (key-args (if data
                         '(basic-auth nomsg key progid since headers encoding)
                       '(basic-auth nomsg key progid since headers query encoding))))
      `(progn
         (defun ,sync (,@req-args &key ,@key-args)
           (xhr-request ,method ,@req-args2
                        ,@(keyword-args key-args)
                        ))

         (defun ,future (,@req-args &key ,@key-args key)
           (xhr-request-future ,method ,@req-args2
                               ,@(keyword-args key-args)
                               ))

         (defun ,async (,@req-args &key ,@key-args onsuccess onfailure oncomplete onabort handler)
           (xhr-request-async ,method ,@req-args2
                              :handler handler
                              :onsuccess onsuccess
                              :onfailure onfailure
                              :oncomplete oncomplete
                              :onabort onabort
                               ,@(keyword-args key-args)
                               ))

         (defmacro ,with-async ((,@req-args &key ,@key-args) &body handler)
           `(,',async ,,@req-args
                      :handler (list ,@(process-event-handler-form handler))
                      ,,@(keyword-args key-args)
                      ))
         (setf (get ',with-async 'ed::lisp-indent-hook) 1)

         ,(when exports
            `(export '(,sync ,future ,async ,with-async)))
         ))))

(defun xhr-request (method url data &key basic-auth nomsg key progid since headers query encoding)
  (xhr-do-request method url data basic-auth nomsg key progid since headers query encoding))

(defun xhr-request-future (method url data &key basic-auth nomsg key progid since headers query encoding)
  (xhr-do-request method url data basic-auth nomsg key progid since headers query encoding
                  :future t))

(defun xhr-request-async (method url data
                                 &key basic-auth nomsg key progid since headers query encoding
                                 handler onsuccess onfailure oncomplete onabort)
  (let ((handler (to-alist handler)))
    (flet ((h (k v)
             (when v
               (setf handler (set-alist! k v handler)))))
      (h :success onsuccess)
      (h :failure onfailure)
      (h :complete oncomplete)
      (h :abort onabort)
      (xhr-do-request method url data basic-auth nomsg key progid since headers query encoding
                      :async t
                      :async-handler handler))))

(defmacro with-xhr-request-async ((method url data
                                          &key basic-auth nomsg key progid since headers query encoding)
                                  &body handler)
  `(xhr-request-async ,method ,url ,data
                      :basic-auth ,basic-auth
                      :nomsg ,nomsg
                      :key ,key
                      :progid ,progid
                      :since ,since
                      :headers ,headers
                      :query ,query
                      :encoding ,encoding
                      :handler (list ,@(process-event-handler-form handler))))
(setf (get 'with-xhr-request-async 'ed::lisp-indent-hook) 1)


(defun xhr-do-request (method url data basic-auth nomsg key progid since headers query encoding
                              &key future async async-handler)
  (let ((req (make-http-request
              :uri (add-query-params url query :encoding encoding)
              :method (format nil "~:@(~A~)" method)
              :header-hash (make-request-header headers (not (null data)) since)
              :data (url-encode data :encoding encoding)
              :xmlhttp (create-xmlhttp :progid progid)))
        (key (or key 'identity)))
    (flet ((send! ()
             (greeting req :nomsg nomsg)
             (xhr-send req)))
      (xhr-open req (or future async) basic-auth)
      (set-request-headers req)
      (cond (future
             (multiple-value-bind (future oncomplete)
                 (create-future-and-complete-handler req key)
               (send!)
               (register-handler req nil (list (cons :complete oncomplete)) nomsg)
               future))
            (async
             (send!)
             (register-handler req key async-handler nomsg)
             (http-request->cancel-ticket req))
            (t
             (send!)
             (greeting req :done t :nomsg nomsg)
             (let ((res (http-request->response req)))
               (run-hook-with-args '*xhr-response-hook* res)
               (funcall key res)))
            ))))

(defun xhr-open (req async basic-auth)
  (case (xmlhttp-progid (http-request-xmlhttp req))
    (:winhttp
     ;; WinHttp.WinHttpRequest
     (%open (coerce-oledata req)
            (http-request-method req)
            (http-request-uri req)
            (not (null async)))
     (%set-credentials (coerce-oledata req)
                       basic-auth
                       +HTTPREQUEST-SETCREDENTIALS-FOR-SERVER+)
     )
    (t
     ;; Msxml2.ServerXMLHTTP or Msxml2.XMLHTTP
     (%open (coerce-oledata req)
            (http-request-method req)
            (http-request-uri req)
            (not (null async))
            basic-auth))))

(defun xhr-send (req)
  (handler-case
      (%send (coerce-oledata req)
             (http-request-data req))
    (error (c)
      (let ((uri (http-request-uri req)))
        (if (< (length uri) *xhr-max-url-length*)
            (error 'xhr-open-error
                   :msg (format nil "接続できません: ~A" uri))
          (error 'xhr-too-long-url-error
                 :msg (format nil "URL が長すぎます (~A文字)" (length uri))))))))

(defun xhr-abort (req-or-future)
  (when (and (not (xhr-request-completed-p req-or-future))
             (not (xhr-request-aborted-p req-or-future)))
    (let ((xmlhttp (http-transport-xmlhttp req-or-future)))
      (setf (xmlhttp-aborted-p xmlhttp) t)
      (%abort (xmlhttp-oledata xmlhttp))
      t)))


(define-xhr-request-method "get" :exports t)
(define-xhr-request-method "head" :exports t)
(define-xhr-request-method "post" :exports t :data t)


(provide "xml-http-request/request")

;;; End
