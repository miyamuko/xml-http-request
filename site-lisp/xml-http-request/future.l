;;;; -*- mode: lisp; package: xml-http-request -*-
;;;;
;;;; File: xml-http-request/future.l
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

;;;; End
