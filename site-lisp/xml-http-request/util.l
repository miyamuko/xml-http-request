;;;; -*- mode: lisp; package: xml-http-request -*-
;;;;
;;;; File: xml-http-request/util.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;;;
;;;;   xml-http-request is released under an MIT license.
;;;;   See xml-http-request/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "xml-http-request/package")
  (require "xml-http-request/macros")
  )

(in-package :xml-http-request)

(defconstant +unix-epoch+
  (encode-universal-time 0 0 0 1 1 1970 0))

(defparameter *default-literal-chars* "0-9A-Za-z._~-")


(defun since (arg)
  (cond ((null arg) nil)
        ((stringp arg) arg)
        ((numberp arg) (rfc1123-format-date arg))
        ((eq :epoch arg) (since +unix-epoch+))
        (t
         (type-error '(or string number nil :epoch) arg))))

(defun rfc1123-format-date (universal-time &key gmt)
  (flet ((tz (ut)
           (nth 8 (multiple-value-list (decode-universal-time ut)))))
    (format-date-string "%a, %d %b %Y %H:%M:%S GMT"
                        (if gmt
                            universal-time
                          (+ universal-time (* (tz universal-time) 60 60))))))


(defun stringy (&rest args)
  (with-output-to-string (s)
    (dolist (o args)
      (princ o s))))

(defun join (sep lst)
  (format nil (concat "~{~A~^" sep "~}") (if (atom lst) (list lst) lst)))


(defun add-query-params (uri query &key encoding (literal-chars *default-literal-chars*))
  (add-query-string uri (url-encode query :encoding encoding :literal-chars literal-chars)))

(defun add-query-string (uri query-string)
  (if (or (not query-string) (string= query-string ""))
      uri
    (format nil "~A~A~A"
            uri
            (cond ((member (char uri (1- (length uri))) '(#\? #\&)) "")
                  ((find #\? uri) "&")
                  (t "?"))
            query-string)))

(defun url-encode (data &key encoding (literal-chars *default-literal-chars*))
  (cond ((stringp data)
         data)
        ((null data)
         "")
        ((listp data)
         (url-encode-alist (to-alist data) encoding literal-chars))
        (t
         (type-error '(or string list) data))))

(defun url-encode-alist (lst &optional encoding (literal-chars *default-literal-chars*))
  (url-join-params
   (mapcar #'(lambda (e)
               (url-encode-key-value e encoding literal-chars))
           lst)))

(defun url-encode-key-value (lst &optional encoding (literal-chars *default-literal-chars*))
  (url-join-key-value (url-encode-value (car lst) encoding literal-chars)
                      (url-encode-value (cdr lst) encoding literal-chars)))

(defun url-encode-value (v &optional encoding (literal-chars *default-literal-chars*))
  (let ((v (cond ((stringp v) v)
                 ((null v) "")
                 (t (format nil "~A" v)))))
    (si:www-url-encode (if encoding
                           (convert-encoding-from-internal encoding v)
                         v)
                       nil literal-chars)))

(defun url-join-params (params)
  (join "&" params))

(defun url-join-key-value (k v)
  (concat k "=" v))


(defun symbol-join (&rest args)
  (values (intern (join "" args))))

(defun singlep (lst)
  (and (consp lst) (not (cdr lst))))

(defun doublep (lst)
  (and (consp lst)
       (consp (cdr lst))
       (not (cddr lst))))

(defun dotp (lst)
  (and (consp lst)
       (atom (cdr lst))
       (not (null (cdr lst)))))

(defun to-alist (lst)
  (cond ((null lst)
         nil)
        ;; (to-alist '(:foo . 1))
        ((dotp lst)
         (list lst))
        ;; (to-alist '(:foo 1 ...))
        ((atom (car lst))
         (cons (cons (car lst) (cadr lst))
               (to-alist (cddr lst))))
        ;; (to-alist '((:foo . 1) ...)
        ((dotp (car lst))
         (cons (car lst)
               (to-alist (cdr lst))))
        ;; (to-alist '((:foo 1) ...)
        (t
         (cons (cons (caar lst) (cadar lst))
               (to-alist (cdr lst))))))

(defun set-alist! (k v alist &key test test-not key)
  (let ((obj (assoc k alist :test test :test-not test-not :key key)))
    (if obj
        (progn
          (setf (cdr obj) v)
          alist)
      (nconc alist (list (cons k v))))))

(defun update-alist! (alist &rest pairs)
  (reduce #'(lambda (acc pair)
              (set-alist! (car pair) (cdr pair) acc))
          (to-alist pairs)
          :initial-value (to-alist alist)))

(defun enclose (val)
  (if (functionp val)
      val
    #'(lambda () val)))


(defun dump-hash (hash)
  (let (r)
    (maphash #'(lambda (k v)
                 (push (list k v) r))
             hash)
    (msgbox "~{~{~S:\t~S~}~%~}" r)))


(provide "xml-http-request/util")

;;;; End
