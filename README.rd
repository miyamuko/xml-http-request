=begin

= xml-http-request - �񓯊� HTTP �ʐM���C�u����

  * Author: �݂�ނ� ���䂫 ((<URL:mailto:miyamuko@gmail.com>))
  * Home URL: ((<URL:http://miyamuko.s56.xrea.com/xyzzy/xml-http-request/intro.htm>))
  * Version: 1.2.1


== SYNOPSIS

    (in-package :your-cool-app)

    (require "xml-http-request")
    (use-package :xml-http-request)

    ;;; ���� API

    (let ((res (xhr-get "http://www.google.co.jp/")))
      (msgbox "~S" (xhr-response-text res)))

    (multiple-value-bind (response http-status header)
        (xhr-get "http://www.google.com/search"
                 :query '(:hl "ja" :lr "lang_ja" :ie "UTF-8" :oe "UTF-8" :num 50
                          :q "xyzzy �ǂݕ�")
                 :encoding *encoding-utf8n*
                 :since :epoch
                 :key 'xhr-response-values)
      (msgbox "~S~%~S" http-status header))


    ;;; �񓯊� API (Future �p�^�[��)

    (let ((future (xhr-get-future "http://www.google.co.jp/")))
      (msgbox "do something~%~S" future)
      (let ((res (xhr-future-value future)))
        (msgbox "~S~%~S" (xhr-response-text res) future)))


    ;;; �񓯊� API (�}�N��)

    (with-xhr-post-async ("http://www.excite.co.jp/world/english/"
                          '(:wb_lp "JAEN" :before "�����Ⴊ�~��܂����B\n�e�������ł��B"))
      (on 200 (res)
          (when (string-match
                 "<textarea cols=36 rows=15 name=\"after\".*?>\\([^<>]+?\\)</textarea>"
                 (xhr-response-text res))
            (msgbox "~A" (match-string 1))))
      (on :success (res)
          (msgbox "�������܂���"))
      (on :failure (res)
          (msgbox "���s���܂���... orz"))
      (on :complete (res)
          (msgbox "�I�����܂���")
          (msgbox "~A~%~A" (xhr-response-header res "Server") (xhr-status res))))


    ;; �񓯊� API (�֐�)

    (xhr-post-async "http://search.hatena.ne.jp/questsearch"
                    '(:wb_lp "ENJA" :before "xyzzy is awesome!")
                    :oncomplete #'(lambda (res)
                                    (msgbox "�I�����܂���")
                                    (msgbox "http status: ~A" (xhr-status res))
                                    (msgbox "response text: ~A" (xhr-response-text res))))


== DESCRIPTION

xml-http-request �� HTTP �ʐM���s�����߂̃��C�u�����ł��B
�񓯊��ʐM���s����̂� xyzzy ���~�߂邱�ƂȂ��ʐM�ł��܂��B

�܂��AWindows ���񋟂��� XMLHttpRequest �I�u�W�F�N�g�𗘗p���Ă��邽��
Proxy �� Basic �F�؁ASSL �ɂ��Ή����Ă��܂��B

Cookie ��L���b�V���̊Ǘ��� XMLHttpRequest �����ōs���܂��B
������ IE �Ƌ��L����܂��B


== INSTALL

=== NetInstaller �ŃC���X�g�[��

(1) ((<NetInstaller|URL:http://www7a.biglobe.ne.jp/~hat/xyzzy/ni.html>))
    �� xml-http-request ���C���X�g�[�����܂��B

=== NetInstaller ���g�킸�ɃC���X�g�[��

(1) �A�[�J�C�u���_�E�����[�h���܂��B

    ((<URL:http://miyamuko.s56.xrea.com/xyzzy/archives/xml-http-request.zip>))

(2) �A�[�J�C�u��W�J���āA$XYZZY/site-lisp �z���Ƀt�@�C�����R�s�[���܂��B



== MODULE

=== PACKAGE

xml-http-request �͈ȉ��̃p�b�P�[�W�𗘗p���Ă��܂��B

* xml-http-request

  nickname �� xhr �� msxml �ł��B


=== VARIABLE

�Ȃ��B


=== CONSTANT

�Ȃ��B


=== CODITION

--- xhr-error

    xml-http-request ���ʒm����R���f�B�V�����̐e�R���f�B�V�����ł��B
    xhr-error ���̂��ʒm����邱�Ƃ͂���܂���B

--- xhr-open-error

    �w�肵�� URL �ɐڑ��ł��Ȃ��ꍇ�ɒʒm�����R���f�B�V�����ł��B

    �񓯊� API �̎��͒ʒm����܂���B

--- xhr-too-long-url-error

    �w�肵�� URL ����������ꍇ�ɒʒm�����R���f�B�V�����ł��B

    �񓯊� API �̎��͒ʒm����܂���B


=== COMMAND

�Ȃ��B


=== FUNCTION

--- xhr-get URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING

    �w�肳�ꂽ URL �̃��\�[�X�� get ���܂��B

    ���� API �͓��� API �ł��B
    get ���I������܂Ńu���b�N�����X�|���X�I�u�W�F�N�g��Ԃ��܂��B

    * BASIC-AUTH �ɂ�
      ((<xhr-credential|xhr-credential USER PASSWORD>))
      �ō쐬���� Basic �F�ؗp�̏����w�肵�܂��B

        (defun gmail-unread (tag user password)
          (xhr-get (concat "https://mail.google.com/mail/feed/atom/" tag)
                   :basic-auth (xhr-credential user password)
                   :key 'xhr-response-xml
                   :since :epoch))

    * NOMSG �� non-nil ���w�肷��ƃ��b�Z�[�W���o�͂��܂���B

      nil �̏ꍇ���b�Z�[�W�̈�ɒʐM��Ԃ�\�����܂��B
      �f�t�H���g�� nil �ł��B

    * KEY �Ɋ֐����w�肷��ƁA���̊֐������X�|���X�I�u�W�F�N�g�ɓK�p�������ʂ�Ԃ��܂��B

        (xhr-get "http://www.google.co.jp/")                  ;=> #S(xml-http-request::http-response ...)
        (xhr-get "http://www.google.co.jp/" :key 'xhr-status) ;=> 200

    * SINCE �ɂ͑��M���� If-Modified-Since �w�b�_���w�肵�܂��B

      SINCE �ɂ͈ȉ��̒l���w��ł��܂��B

      : :epoch
          Unix epoch (1970-01-01 00:00:00) �𑗐M���܂��B
          ���̒l���w�肷��ƃL���b�V�����g�킸�Ƀl�b�g���[�N����擾���܂��B

      : <���l>
          ���l���w�肵���ꍇ�̓��[�J�����Ԃ� universal-time �ƌ��Ȃ���
          ������ɕϊ����܂��B

      : <������>
          ��������w�肵���ꍇ�͂��̂܂ܑ��M���܂��B

    * HEADERS �ɂ͑��M���� HTTP �w�b�_�����X�g�Ŏw�肵�܂��B

      HEADERS �� If-Modified-Since ���w�肵�A���� SINCE �������Ɏw�肵���ꍇ��
      SINCE �̎w�肪�L���ɂȂ�܂��B

    * QUERY �� query string �𕶎���܂��̓��X�g�Ŏw�肵�܂��B

      �w�肵�� query string �� URL ���ɒ��ڋL�q���Ă��� query string
      �Ƃ��킹�� URL �ɒǉ�����܂��B

        (xhr-get "http://www.google.com/search?hl=ja&lr=lang_ja"
                 :query '(:ie "UTF-8" :oe "UTF-8" :num 50
                          :q "xyzzy �ǂݕ�")
                 :encoding *encoding-utf8n*)
        ;;=> GET from http://www.google.com/search?hl=ja&lr=lang_ja&ie=UTF-8&oe=UTF-8&num=50&q=xyzzy%20%E8%AA%AD%E3%81%BF%E6%96%B9

      ��������w�肷��Ƃ��̂܂� URL �ɒǉ����܂��B
      si:www-url-encode �ȂǂœK�؂ɃG���R�[�h�����l���w�肵�Ă��������B

      �L�[�ƒl����Ȃ郊�X�g���w�肷��Ǝ����I�ɃG���R�[�h���܂��B
      ENCODING ���w�肷��ƕ����R�[�h��ϊ�������� RFC3986 �ɂ�����x�]�� url �G���R�[�h���܂�
      (si:www-url-encode �̃f�t�H���g�Ƃ͈Ⴂ�܂�)�B
      ENCODING ���w�肵�Ȃ��ꍇ Shift_JIS �̂܂܃G���R�[�h���܂��B

    ��:
        (xhr-response-text
         (xhr-get "http://www.google.co.jp/"
                  ;; alist �Ŏw�肵�Ă� ok
                  :headers '(:User-Agent "Firefox"
                             :Accept-Language "en, ja")
                  :since :epoch))


    �Ȃ��AX-Yzzy-Version �Ƃ����w�b�_���K�����M����܂� (�l�� xyzzy �̃o�[�W����)�B

--- xhr-get-async URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING ONSUCCESS ONFAILURE ONCOMPLETE HANDLER

    �w�肳�ꂽ URL �̃��\�[�X�� get ���܂��B

    ���� API �͔񓯊� API �ł��B
    API ���Ăяo���Ƃ����ɐ����Ԃ��A�L�����Z���I�u�W�F�N�g��Ԃ��܂��B

    ���N�G�X�g���~�������ꍇ�̓L�����Z���I�u�W�F�N�g��
    ((<xhr-abort|xhr-abort TRANSPORT>))
    �Ɏw�肵�܂��B

    get ���I������Ǝw�肳�ꂽ callback ���Ăяo���܂��B

    * BASIC-AUTH NOMSG, KEY, SINCE, HEADERS �̎w����@��
      ((<xhr-get|xhr-get URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING>))
      ���Q�Ƃ��Ă��������B

      KEY ���w�肷��� KEY �̖߂�l���C�x���g�n���h���Ɏw�肳��܂��B
      KEY �����l��Ԃ��ꍇ�́A���l�̒l���C�x���g�n���h���̂��ꂼ��̈����Ɏw�肳��܂��B

      ��:
        (xhr-get-async "http://www.google.co.jp/"
                       :key #'(lambda (res)
                                (values (xhr-requested-uri res)
                                        (xhr-status res)))
                       :oncomplete #'(lambda (uri status)
                                       (msgbox "~S => ~S" uri status)))


    * �C�x���g�n���h���� ONSUCCESS ONFAILURE ONCOMPLETE HANDLER �Ŏw�肵�܂��B

      * ONSUCCESS

        ����I�� (http status �� 20x) �����ꍇ�ɌĂ΂�܂��B

      * ONFAILURE

        �ُ�I�� (http status �� 20x �ȊO) �����ꍇ�ɌĂ΂�܂��B

      * ONCOMPLETE

        �ʐM�I����ɏ�ɌĂ΂�܂��BONSUCCESS, ONFAILURE ����ɌĂ΂�܂��B

      * HANDLER

        HTTP �X�e�[�^�X���ƂɃC�x���g�n���h�������s�������ꍇ�� HANDLER �Ŏw�肵�܂��B

    ��:
        (xhr-get-async "http://www.google.co.jp/"
                       :headers '(:User-Agent "Mozilla Firefox"
                                  :Accept-Language "ja")
                       :since :epoch
                       :oncomplete #'(lambda (res)
                                       (msgbox "~D ~A"
                                               (xhr-status res)
                                               (xhr-status-text res)))
                       :handler (list
                                 200 #'(lambda (res) (msgbox "OK"))
                                 304 #'(lambda (res) (msgbox "not modified"))
                                 404 #'(lambda (res) (msgbox "not found"))))

    �Ȃ��AX-Yzzy-Version �Ƃ����w�b�_���K�����M����܂� (�l�� xyzzy �̃o�[�W����)�B

--- xhr-get-future URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING

    �w�肳�ꂽ URL �̃��\�[�X�� get ���܂��B

    ���� API �͔񓯊� API �ł��B
    API ���Ăяo���Ƃ����ɐ����Ԃ��AFuture �I�u�W�F�N�g��Ԃ��܂��B
    ((<xhr-future-value|xhr-future-value FUTURE &KEY NOWAIT NO-REDRAW SLEEP TIMEOUT INTERVAL>))
    �� Future �I�u�W�F�N�g����l���擾���悤�Ƃ������_�ł܂� get ���������Ă��Ȃ��ꍇ�̓u���b�N���܂��B

    ���N�G�X�g���~�������ꍇ�� Future �I�u�W�F�N�g��
    ((<xhr-abort|xhr-abort TRANSPORT>))
    �Ɏw�肵�܂��B

    * BASIC-AUTH, NOMSG, KEY, SINCE, HEADERS �̎w����@��
      ((<xhr-get|xhr-get URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING>))
      ���Q�Ƃ��Ă��������B

    * �߂�l�� Future �I�u�W�F�N�g��Ԃ��܂��B

    ��:
        (let ((future (xhr-get-future "http://www.google.co.jp/"
                                      :key 'xhr-status-text
                                      :since :epoch)))
          (msgbox "do something~%~S" future)
          (msgbox "~S~%~S"
                  (xhr-future-value future :timeout 10)
                  future))

    �Ȃ��AX-Yzzy-Version �Ƃ����w�b�_���K�����M����܂� (�l�� xyzzy �̃o�[�W����)�B

    See Also:

    * ((<xhr-future-p|xhr-future-p OBJ>))
    * ((<xhr-future-completed-p|xhr-future-completed-p FUTURE>))
    * ((<xhr-future-value|xhr-future-value FUTURE &KEY NOWAIT NO-REDRAW SLEEP TIMEOUT INTERVAL>))

--- xhr-head URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING

    �w�肳�ꂽ URL �� HEAD ���N�G�X�g�𓯊��I�ɑ��M���܂��B

    �ڍׂ�
    ((<xhr-get|xhr-get URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING>))
    ���Q�Ƃ��Ă��������B

--- xhr-head-async URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING ONSUCCESS ONFAILURE ONCOMPLETE HANDLER

    �w�肳�ꂽ URL �� HEAD ���N�G�X�g��񓯊��ɑ��M���܂��B

    �ڍׂ�
    ((<xhr-get-async|xhr-get-async URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING ONSUCCESS ONFAILURE ONCOMPLETE HANDLER>))
    ���Q�Ƃ��Ă��������B

--- xhr-head-future URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING
    �w�肳�ꂽ URL �� HEAD ���N�G�X�g��񓯊��ɑ��M���܂��B

    �ڍׂ�
    ((<xhr-get-future|xhr-get-future URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING>))
    ���Q�Ƃ��Ă��������B

--- xhr-post URL DATA &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS ENCODING

    �w�肳�ꂽ URL �� DATA �𓯊��I�� POST ���܂��B

    * DATA �͕�����܂��̓��X�g�Ŏw�肵�܂��B

      ��������w�肷��Ƃ��̂܂ܑ��M���܂��B
      si:www-url-encode �ȂǂœK�؂ɃG���R�[�h�����l���w�肵�Ă��������B

      �L�[�ƒl����Ȃ郊�X�g���w�肷��Ǝ����I�ɃG���R�[�h���܂��B
      ENCODING ���w�肷��ƕ����R�[�h��ϊ�������� RFC3986 �ɂ�����x�]�� url �G���R�[�h���܂�
      (si:www-url-encode �̃f�t�H���g�Ƃ͈Ⴂ�܂�)�B
      ENCODING ���w�肵�Ȃ��ꍇ�͂��̂܂� url �G���R�[�h���܂��B

      �ȉ��� 2 �̌Ăяo���͓����ł��B

        (xhr-post "https://www.hatena.ne.jp/login"
                  "name=foo&password=bar&persistent=1"
                  :key 'xhr-response-text
                  :since :epoch)

        (xhr-post "https://www.hatena.ne.jp/login"
                  '(:name "foo" :password "bar" :persistent 1)
                  :key 'xhr-response-text
                  :since :epoch)

    * HEADERS �� Content-Type ���w�肳��Ă��Ȃ��ꍇ��
      application/x-www-form-urlencoded �������I�ɃZ�b�g����܂��B

        (xhr-post url
                  octet-data
                  :headers '(:Content-Type "application/octet-stream"))


    ���̑��̈�������і߂�l��
    ((<xhr-get|xhr-get URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING>))
    �Ɠ����ł��B

--- xhr-post-async URL DATA &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS ENCODING ONSUCCESS ONFAILURE ONCOMPLETE HANDLER

    �w�肳�ꂽ URL �� DATA ��񓯊��� POST ���܂��B

    �ڍׂ͈ȉ����Q�Ƃ��Ă��������B

    * ((<xhr-post|xhr-post URL DATA &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS ENCODING>))
    * ((<xhr-get-async|xhr-get-async URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING ONSUCCESS ONFAILURE ONCOMPLETE HANDLER>))

--- xhr-post-future URL DATA &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS ENCODING

    �w�肳�ꂽ URL �� DATA ��񓯊��� POST ���܂��B

    �ڍׂ͈ȉ����Q�Ƃ��Ă��������B

    * ((<xhr-post|xhr-post URL DATA &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS ENCODING>))
    * ((<xhr-get-future|xhr-get-future URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING>))

--- xhr-request METHOD URL DATA &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING

    �w�肳�ꂽ HTTP METHOD �𑗐M���܂��B
    DATA ���Ȃ��ꍇ�� nil ���w�肵�Ă��������B

    ���̑��̈�����
    ((<xhr-post|xhr-post URL DATA &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS ENCODING>))
    �Ɠ����ł��B

    ��:

        (xhr-request "OPTIONS" url  nil
                     :key #'(lambda (res)
                              (split-string (or (xhr-response-header res "Allow") "") #\,)))
        ;=> ("GET" "HEAD" "OPTIONS" "POST")

--- xhr-request-async METHOD URL DATA &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING HANDLER ONSUCCESS ONFAILURE ONCOMPLETE

    �w�肳�ꂽ URL �� METHOD ��񓯊��ɑ��M���܂��B

    �ڍׂ͈ȉ����Q�Ƃ��Ă��������B

    * ((<xhr-request|xhr-request METHOD URL DATA &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING>))
    * ((<xhr-get-async|xhr-get-async URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING ONSUCCESS ONFAILURE ONCOMPLETE HANDLER>))

--- xhr-request-future METHOD URL DATA &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING

    �w�肳�ꂽ URL �� METHOD ��񓯊��ɑ��M���܂��B

    �ڍׂ͈ȉ����Q�Ƃ��Ă��������B

    * ((<xhr-request|xhr-request METHOD URL DATA &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING>))
    * ((<xhr-get-future|xhr-get-future URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING>))

--- xhr-future-p OBJ

    �w�肳�ꂽ OBJ �� Future �I�u�W�F�N�g�Ȃ� non-nil ��Ԃ��܂��B

--- xhr-future-uri FUTURE

    �w�肳�ꂽ Future �I�u�W�F�N�g���烊�N�G�X�g��� URI ���擾���܂��B

--- xhr-future-completed-p FUTURE

    �w�肳�ꂽ Future �I�u�W�F�N�g�̃��N�G�X�g���������Ă����� non-nil ��Ԃ��܂��B

--- xhr-future-value FUTURE &KEY NOWAIT NO-REDRAW SLEEP TIMEOUT INTERVAL

    �w�肳�ꂽ Future �I�u�W�F�N�g���猋�ʂ��擾���܂��B
    ���ʂ̓��N�G�X�g���M���Ɏw�肵�� KEY ���K�p���ꂽ���ʂ��Ԃ�܂��B

    ���N�G�X�g���������Ă��Ȃ��ꍇ�͊�����҂����킹�܂��B

    * NOWAIT �� non-nil ���w�肷��ƃ��N�G�X�g���������Ă��Ȃ��ꍇ��
      �҂����킹�������ɂ����� nil ��Ԃ��܂��B

      �f�t�H���g�� nil �ł��B

    * NO-REDRAW �� non-nil ���w�肷��ƃ��N�G�X�g�̊����҂�����
      ��ʂ̍ĕ`����s���܂���B

      �f�t�H���g�� nil �ł��B

    * SLEEP �� non-nil ���w�肷��ƃ��N�G�X�g�̊����҂�����
      �L�[���͂������Ă����f���܂���B

      SLEEP �� nil �̏ꍇ�L�[���͂���������҂����킹�𒆒f���܂��B
      ���f���_�Ń��N�G�X�g�������Ă��Ȃ��ꍇ�� nil ��Ԃ��܂��B

      SLEEP ���w�肵���ꍇ�͉�ʂ̍ĕ`����s���܂���B

      �f�t�H���g�� nil �ł��B

    * TIMEOUT ���w�肷��Ǝw�肵���b���ȓ��Ƀ��N�G�X�g���������Ȃ��ꍇ�A
      nil ��Ԃ��܂��B

      TIMEOUT �� nil ���w�肷��ƃ^�C���A�E�g�����ɖ����ɑ҂����킹�܂��B

      �f�t�H���g�� 3 �b�ł��B

    * INTERVAL �͊Ď��Ԋu�ł��B

      �f�t�H���g�� 0.3 �b�ł��B

--- xhr-requested-uri RES

    �w�肳�ꂽ���X�|���X�I�u�W�F�N�g���� URI ���擾���܂��B

      (xhr-requested-uri (xhr-get "http://www.google.co.jp/"))
      ;=> http://www.google.co.jp/

--- xhr-all-response-header RES

    ���ׂĂ� HTTP �w�b�_���擾���܂��B
    �߂�l�͑S�w�b�_���܂Ƃ߂�������ŕԂ��܂��B

--- xhr-all-response-header-alist RES

    ���ׂĂ� HTTP �w�b�_�� alist �Ŏ擾���܂��B

--- xhr-all-response-header-hash RES

    ���ׂĂ� HTTP �w�b�_�� hashtable �Ŏ擾���܂��B

--- xhr-response-header RES HEADER

    �w�肵�� HTTP �w�b�_���擾���܂��B
    header �ɂ� "Content-Length" �� "Last-Modified" �Ȃǂ��w�肵�܂��B

--- xhr-response-text RES

    HTTP �ʐM�̌��� (body) ���擾���܂��B

--- xhr-response-xml RES

    �擾���� XML �� S���ŕԂ��܂��B
    S ���� xml-parser-modoki �ƌ݊���������܂��i���Ԃ�j�B

    �擾��̃��\�[�X�� XML �łȂ��ꍇ nil ��Ԃ��܂��B
    XML ���e�L�X�g�`���Ŏ擾�������ꍇ��
    ((<xhr-response-text|xhr-response-text RES>))
    ���g�p���Ă��������B

--- xhr-response-values RES

    �ȉ��̒l�𑽒l�ŕԂ��܂��B
    * ((<"���X�|���X�{��"|xhr-response-text RES>))
    * ((<"HTTP �X�e�[�^�X"|xhr-status RES>))
    * ((<"���X�|���X�w�b�_ (alist)"|xhr-all-response-header-alist RES>))

--- xhr-status RES

    HTTP status ���擾���܂��B

--- xhr-status-text RES

    HTTP status �̕�����\�����擾���܂��B

--- xhr-abort TRANSPORT

    �w�肵�����N�G�X�g���~���܂��B

    �����ɂ� Future �I�u�W�F�N�g (xhr-xxx-future �̖߂�l)�A
    �L�����Z���I�u�W�F�N�g (xhr-xxx-async �̖߂�l) ���w��\�ł��B

    �ʐM�𒆒f�����Ȃ� t ��Ԃ��܂��B
    ���ɒʐM���I�����Ă����牽������ nil ��Ԃ��܂��B

    ��:

        ;; 5 �b�ȓ��Ɍ��ʂ��Ԃ�Ȃ���΃R�l�N�V������ؒf���ė�O�𓊂���
        (let ((future (xhr-get-future url)))
          (let ((v (xhr-future-value future :timeout 5)))
            (unless (xhr-future-completed-p future)
              (xhr-abort future)
              (plain-error "timeout"))
            v))

--- xhr-credential USER PASSWORD

    �e���N�G�X�g�֐��� :basic-auth �����Ɏw�肷�邽�߂�
    ���[�U�F�ؗp�̏����쐬���܂��B

--- xml-http-request-version

    �{���C�u�����̃o�[�W������Ԃ��܂��B
    �o�[�W������ major.minor.teeny �Ƃ����`���ł��B

    ���ꂼ��̔ԍ��͕K�� 1 ���ɂ���̂ŁA�ȉ��̂悤�ɔ�r���邱�Ƃ��ł��܂��B

        (if (string<= "1.1.0" (xml-http-request-version))
            (1.1.0 �ȍ~�ŗL���ȏ���)
          (1.1.0 ���O�̃o�[�W�����ł̏���))


=== MACRO

--- with-xhr-get-async (URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING>) &BODY HANDLER

    ((<xhr-get-async|xhr-get-async URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING ONSUCCESS ONFAILURE ONCOMPLETE HANDLER>))
    �̃��b�p�[�}�N���ł��B

    �}�N���̖{�̂ɂ͈ȉ��̌`���ŃC�x���g�n���h�����L�q�ł��܂��B

      (on <(or HTTP�X�e�[�^�X :success :failure :complete)> (<������>...)
          <�C�x���g�n���h���̖{��>)

    ��)

      (with-xhr-get-async ("http://www.google.co.jp/" :since :epoch)
        (on 200 (res)
            (msgbox "200 OK"))
        (on :success (res)
            (msgbox "�������܂��� ~S" (xhr-response-header res "Server")))
        (on :failure (res)
            (msgbox "���s���܂���... orz"))
        (on :complete (res)
            (msgbox "�I�����܂���")
            (msgbox "http status: ~A" (xhr-status res))))

    on �̒��g�̓N���[�W���ɕϊ������̂ňȉ��̂悤�Ȃ��Ƃ��ł��܂��B

      (setf result (let ((r nil))
                     (with-xhr-get-async ("http://www.google.co.jp/"
                                          :key 'xhr-response-values)
                       (on :complete (text status header)
                           (setf r (list status header text))))
                     #'(lambda () r)))
      (funcall result)

--- with-xhr-head-async (URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING) &BODY HANDLER

    ((<xhr-head-async|xhr-head-async URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING ONSUCCESS ONFAILURE ONCOMPLETE HANDLER>))
    �̃��b�p�[�}�N���ł��B

--- with-xhr-post-async (URL BODY &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS ENCODING) &BODY HANDLER

    ((<xhr-post-async|xhr-post-async URL DATA &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS ENCODING ONSUCCESS ONFAILURE ONCOMPLETE HANDLER>))
    �̃��b�p�[�}�N���ł��B

--- with-xhr-request-async (METHOD URL BODY &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING) &BODY HANDLER

    ((<xhr-request-async|xhr-request-async METHOD URL DATA &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING HANDLER ONSUCCESS ONFAILURE ONCOMPLETE>))
    �̃��b�p�[�}�N���ł��B


=== OBSOLETE FUNCTION

--- http-get URL &KEY HEADERS ONFAILURE ONSUCCESS ONCOMPLETE

    ����͌݊����̂��߂Ɏc����Ă��� �񐄏� API �ł��B

    �ς���
    ((<xhr-get|xhr-get URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING>))�A
    ((<xhr-get-async|xhr-get-async URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING ONSUCCESS ONFAILURE ONCOMPLETE HANDLER>))
    ���g���Ă��������B

--- http-post URL DATA &KEY HEADERS ONFAILURE ONSUCCESS ONCOMPLETE

    ����͌݊����̂��߂Ɏc����Ă��� �񐄏� API �ł��B

    �ς���
    ((<xhr-post|xhr-post URL DATA &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS ENCODING>))�A
    ((<xhr-post-async|xhr-post-async URL DATA &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS ENCODING ONSUCCESS ONFAILURE ONCOMPLETE HANDLER>))
    ���g���Ă��������B

--- response-text TRANSPORT

    ����͌݊����̂��߂Ɏc����Ă��� �񐄏� API �ł��B

    �ς���
    ((<xhr-response-text|xhr-response-text RES>))
    ���g���Ă��������B

--- status TRANSPORT

    ����͌݊����̂��߂Ɏc����Ă��� �񐄏� API �ł��B

    �ς���
    ((<xhr-status|xhr-status RES>))
    ���g���Ă��������B

--- status-text TRANSPORT

    ����͌݊����̂��߂Ɏc����Ă��� �񐄏� API �ł��B

    �ς���
    ((<xhr-status-text|xhr-status-text RES>))
    ���g���Ă��������B

--- abort TRANSPORT

    ����͌݊����̂��߂Ɏc����Ă��� �񐄏� API �ł��B

    �ς���
    ((<xhr-abort|xhr-abort TRANSPORT>))
    ���g���Ă��������B

--- all-response-headers TRANSPORT

    ����͌݊����̂��߂Ɏc����Ă��� �񐄏� API �ł��B

    �ς���
    ((<xhr-all-response-header|xhr-all-response-header RES>))
    ���g���Ă��������B

--- response-header TRANSPORT HEADER

    ����͌݊����̂��߂Ɏc����Ă��� �񐄏� API �ł��B

    �ς���
    ((<xhr-response-header|xhr-response-header RES HEADER>))
    ���g���Ă��������B


== TODO

* �t�b�N
* �g���[�X���O
* Msxml2.ServerXMLHTTP
  * proxycfg
  * netsh (vista)
  * oledata �̍ė��p
    * xhr-agent ?


== KNOWN BUGS

* �󔒕����� + �ł͂Ȃ� %20 �ɃG���R�[�h����܂��B

* �T�[�o���� charset ��Ԃ������� UTF-8 �ȊO�̏ꍇ�͕����������܂��B

  �� ((<URL:http://d.hatena.ne.jp/miyamuko/20050913#p1>))

* ������� xyzzy ������ Shift_JIS �ɕϊ�����܂��B

  Shift_JIS �O�̕����� ? �ɉ����܂� (�p��Ɠ��{��ȊO�͂܂Ƃ��Ɉ����܂���)�B


== AUTHOR

�݂�ނ� ���䂫 (((<URL:mailto:miyamuko@gmail.com>)))


== SEE ALSO

�Ȃ��B


== COPYRIGHT

xml-http-request �� MIT/X ���C�Z���X�Ɋ�Â��ė��p�\�ł��B

See xml-http-request/docs/MIT-LICENSE for full license.


== NEWS

<<<NEWS.rd

=end
