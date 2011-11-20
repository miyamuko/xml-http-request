; -*- mode: lisp; package: xml-http-request; encoding: shift_jis -*-

;;; xml-http-request/future.l
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

(export '(xhr-future-p
          xhr-future-uri
          xhr-future-completed-p

          xhr-future-value
          ))

(defun create-future-and-complete-handler (req key)
  (let ((future (http-request->future req)))
    (values
     future
     #'(lambda (res)
         (unless (xhr-future-completed-p future)
           (setf (xhr-future-completed-p future) t
                 (xhr-future-result future)
                 #'(lambda ()
                     ;; key ‚ğˆê‰ñ‚µ‚©ŒÄ‚Î‚È‚¢‚æ‚¤‚ÉAfuture-result ‚ğ‘‚«Š·‚¦
                     (let ((r (multiple-value-list (funcall (or key 'identity) res))))
                       (setf (xhr-future-result future) (enclose r))
                       r))))
         ))))

(defun xhr-future-value (future &key nowait no-redraw sleep (timeout 3) (interval 0.3))
  (let ((start (get-internal-real-time)))
    (while (and (not (xhr-future-completed-p future))
                (not nowait)
                (or (not timeout)
                    (< (/ (- (get-internal-real-time) start) 1000.0)
                       timeout)))
      (if sleep
          (sleep-for interval)
        (sit-for interval no-redraw)))
    (when (xhr-future-completed-p future)
      (let ((r (xhr-future-result future)))
        (when r
          (values-list (funcall r)))))))


(provide "xml-http-request/future")

;;; End
