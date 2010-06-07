=begin

= xml-http-request - 非同期 HTTP 通信ライブラリ

  * Author: みやむこ かつゆき ((<URL:mailto:miyamuko@gmail.com>))
  * Home URL: ((<URL:http://miyamuko.s56.xrea.com/xyzzy/xml-http-request/intro.htm>))
  * Version: 1.2.1


== SYNOPSIS

    (in-package :your-cool-app)

    (require "xml-http-request")
    (use-package :xml-http-request)

    ;;; 同期 API

    (let ((res (xhr-get "http://www.google.co.jp/")))
      (msgbox "~S" (xhr-response-text res)))

    (multiple-value-bind (response http-status header)
        (xhr-get "http://www.google.com/search"
                 :query '(:hl "ja" :lr "lang_ja" :ie "UTF-8" :oe "UTF-8" :num 50
                          :q "xyzzy 読み方")
                 :encoding *encoding-utf8n*
                 :since :epoch
                 :key 'xhr-response-values)
      (msgbox "~S~%~S" http-status header))


    ;;; 非同期 API (Future パターン)

    (let ((future (xhr-get-future "http://www.google.co.jp/")))
      (msgbox "do something~%~S" future)
      (let ((res (xhr-future-value future)))
        (msgbox "~S~%~S" (xhr-response-text res) future)))


    ;;; 非同期 API (マクロ)

    (with-xhr-post-async ("http://www.excite.co.jp/world/english/"
                          '(:wb_lp "JAEN" :before "今日雪が降りました。\nテラ寒いです。"))
      (on 200 (res)
          (when (string-match
                 "<textarea cols=36 rows=15 name=\"after\".*?>\\([^<>]+?\\)</textarea>"
                 (xhr-response-text res))
            (msgbox "~A" (match-string 1))))
      (on :success (res)
          (msgbox "成功しました"))
      (on :failure (res)
          (msgbox "失敗しました... orz"))
      (on :complete (res)
          (msgbox "終了しました")
          (msgbox "~A~%~A" (xhr-response-header res "Server") (xhr-status res))))


    ;; 非同期 API (関数)

    (xhr-post-async "http://search.hatena.ne.jp/questsearch"
                    '(:wb_lp "ENJA" :before "xyzzy is awesome!")
                    :oncomplete #'(lambda (res)
                                    (msgbox "終了しました")
                                    (msgbox "http status: ~A" (xhr-status res))
                                    (msgbox "response text: ~A" (xhr-response-text res))))


== DESCRIPTION

xml-http-request は HTTP 通信を行うためのライブラリです。
非同期通信を行えるので xyzzy を止めることなく通信できます。

また、Windows が提供する XMLHttpRequest オブジェクトを利用しているため
Proxy や Basic 認証、SSL にも対応しています。

Cookie やキャッシュの管理は XMLHttpRequest 内部で行われます。
これらは IE と共有されます。


== INSTALL

=== NetInstaller でインストール

(1) ((<NetInstaller|URL:http://www7a.biglobe.ne.jp/~hat/xyzzy/ni.html>))
    で xml-http-request をインストールします。

=== NetInstaller を使わずにインストール

(1) アーカイブをダウンロードします。

    ((<URL:http://miyamuko.s56.xrea.com/xyzzy/archives/xml-http-request.zip>))

(2) アーカイブを展開して、$XYZZY/site-lisp 配下にファイルをコピーします。



== MODULE

=== PACKAGE

xml-http-request は以下のパッケージを利用しています。

* xml-http-request

  nickname は xhr と msxml です。


=== VARIABLE

なし。


=== CONSTANT

なし。


=== CODITION

--- xhr-error

    xml-http-request が通知するコンディションの親コンディションです。
    xhr-error 自体が通知されることはありません。

--- xhr-open-error

    指定した URL に接続できない場合に通知されるコンディションです。

    非同期 API の時は通知されません。

--- xhr-too-long-url-error

    指定した URL が長すぎる場合に通知されるコンディションです。

    非同期 API の時は通知されません。


=== COMMAND

なし。


=== FUNCTION

--- xhr-get URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING

    指定された URL のリソースを get します。

    この API は同期 API です。
    get が終了するまでブロックしレスポンスオブジェクトを返します。

    * BASIC-AUTH には
      ((<xhr-credential|xhr-credential USER PASSWORD>))
      で作成した Basic 認証用の情報を指定します。

        (defun gmail-unread (tag user password)
          (xhr-get (concat "https://mail.google.com/mail/feed/atom/" tag)
                   :basic-auth (xhr-credential user password)
                   :key 'xhr-response-xml
                   :since :epoch))

    * NOMSG に non-nil を指定するとメッセージを出力しません。

      nil の場合メッセージ領域に通信状態を表示します。
      デフォルトは nil です。

    * KEY に関数を指定すると、その関数をレスポンスオブジェクトに適用した結果を返します。

        (xhr-get "http://www.google.co.jp/")                  ;=> #S(xml-http-request::http-response ...)
        (xhr-get "http://www.google.co.jp/" :key 'xhr-status) ;=> 200

    * SINCE には送信時の If-Modified-Since ヘッダを指定します。

      SINCE には以下の値を指定できます。

      : :epoch
          Unix epoch (1970-01-01 00:00:00) を送信します。
          この値を指定するとキャッシュを使わずにネットワークから取得します。

      : <数値>
          数値を指定した場合はローカル時間の universal-time と見なして
          文字列に変換します。

      : <文字列>
          文字列を指定した場合はそのまま送信します。

    * HEADERS には送信時の HTTP ヘッダをリストで指定します。

      HEADERS に If-Modified-Since を指定し、かつ SINCE も同時に指定した場合は
      SINCE の指定が有効になります。

    * QUERY は query string を文字列またはリストで指定します。

      指定した query string は URL 中に直接記述している query string
      とあわせて URL に追加されます。

        (xhr-get "http://www.google.com/search?hl=ja&lr=lang_ja"
                 :query '(:ie "UTF-8" :oe "UTF-8" :num 50
                          :q "xyzzy 読み方")
                 :encoding *encoding-utf8n*)
        ;;=> GET from http://www.google.com/search?hl=ja&lr=lang_ja&ie=UTF-8&oe=UTF-8&num=50&q=xyzzy%20%E8%AA%AD%E3%81%BF%E6%96%B9

      文字列を指定するとそのまま URL に追加します。
      si:www-url-encode などで適切にエンコードした値を指定してください。

      キーと値からなるリストを指定すると自動的にエンコードします。
      ENCODING を指定すると文字コードを変換した上で RFC3986 にある程度従い url エンコードします
      (si:www-url-encode のデフォルトとは違います)。
      ENCODING を指定しない場合 Shift_JIS のままエンコードします。

    例:
        (xhr-response-text
         (xhr-get "http://www.google.co.jp/"
                  ;; alist で指定しても ok
                  :headers '(:User-Agent "Firefox"
                             :Accept-Language "en, ja")
                  :since :epoch))


    なお、X-Yzzy-Version というヘッダが必ず送信されます (値は xyzzy のバージョン)。

--- xhr-get-async URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING ONSUCCESS ONFAILURE ONCOMPLETE HANDLER

    指定された URL のリソースを get します。

    この API は非同期 API です。
    API を呼び出すとすぐに制御を返し、キャンセルオブジェクトを返します。

    リクエストを停止したい場合はキャンセルオブジェクトを
    ((<xhr-abort|xhr-abort TRANSPORT>))
    に指定します。

    get が終了すると指定された callback を呼び出します。

    * BASIC-AUTH NOMSG, KEY, SINCE, HEADERS の指定方法は
      ((<xhr-get|xhr-get URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING>))
      を参照してください。

      KEY を指定すると KEY の戻り値がイベントハンドラに指定されます。
      KEY が多値を返す場合は、多値の値がイベントハンドラのそれぞれの引数に指定されます。

      例:
        (xhr-get-async "http://www.google.co.jp/"
                       :key #'(lambda (res)
                                (values (xhr-requested-uri res)
                                        (xhr-status res)))
                       :oncomplete #'(lambda (uri status)
                                       (msgbox "~S => ~S" uri status)))


    * イベントハンドラは ONSUCCESS ONFAILURE ONCOMPLETE HANDLER で指定します。

      * ONSUCCESS

        正常終了 (http status が 20x) した場合に呼ばれます。

      * ONFAILURE

        異常終了 (http status が 20x 以外) した場合に呼ばれます。

      * ONCOMPLETE

        通信終了後に常に呼ばれます。ONSUCCESS, ONFAILURE より後に呼ばれます。

      * HANDLER

        HTTP ステータスごとにイベントハンドラを実行したい場合は HANDLER で指定します。

    例:
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

    なお、X-Yzzy-Version というヘッダが必ず送信されます (値は xyzzy のバージョン)。

--- xhr-get-future URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING

    指定された URL のリソースを get します。

    この API は非同期 API です。
    API を呼び出すとすぐに制御を返し、Future オブジェクトを返します。
    ((<xhr-future-value|xhr-future-value FUTURE &KEY NOWAIT NO-REDRAW SLEEP TIMEOUT INTERVAL>))
    で Future オブジェクトから値を取得しようとした時点でまだ get が完了していない場合はブロックします。

    リクエストを停止したい場合は Future オブジェクトを
    ((<xhr-abort|xhr-abort TRANSPORT>))
    に指定します。

    * BASIC-AUTH, NOMSG, KEY, SINCE, HEADERS の指定方法は
      ((<xhr-get|xhr-get URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING>))
      を参照してください。

    * 戻り値は Future オブジェクトを返します。

    例:
        (let ((future (xhr-get-future "http://www.google.co.jp/"
                                      :key 'xhr-status-text
                                      :since :epoch)))
          (msgbox "do something~%~S" future)
          (msgbox "~S~%~S"
                  (xhr-future-value future :timeout 10)
                  future))

    なお、X-Yzzy-Version というヘッダが必ず送信されます (値は xyzzy のバージョン)。

    See Also:

    * ((<xhr-future-p|xhr-future-p OBJ>))
    * ((<xhr-future-completed-p|xhr-future-completed-p FUTURE>))
    * ((<xhr-future-value|xhr-future-value FUTURE &KEY NOWAIT NO-REDRAW SLEEP TIMEOUT INTERVAL>))

--- xhr-head URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING

    指定された URL に HEAD リクエストを同期的に送信します。

    詳細は
    ((<xhr-get|xhr-get URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING>))
    を参照してください。

--- xhr-head-async URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING ONSUCCESS ONFAILURE ONCOMPLETE HANDLER

    指定された URL に HEAD リクエストを非同期に送信します。

    詳細は
    ((<xhr-get-async|xhr-get-async URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING ONSUCCESS ONFAILURE ONCOMPLETE HANDLER>))
    を参照してください。

--- xhr-head-future URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING
    指定された URL に HEAD リクエストを非同期に送信します。

    詳細は
    ((<xhr-get-future|xhr-get-future URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING>))
    を参照してください。

--- xhr-post URL DATA &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS ENCODING

    指定された URL に DATA を同期的に POST します。

    * DATA は文字列またはリストで指定します。

      文字列を指定するとそのまま送信します。
      si:www-url-encode などで適切にエンコードした値を指定してください。

      キーと値からなるリストを指定すると自動的にエンコードします。
      ENCODING を指定すると文字コードを変換した上で RFC3986 にある程度従い url エンコードします
      (si:www-url-encode のデフォルトとは違います)。
      ENCODING を指定しない場合はそのまま url エンコードします。

      以下の 2 つの呼び出しは等価です。

        (xhr-post "https://www.hatena.ne.jp/login"
                  "name=foo&password=bar&persistent=1"
                  :key 'xhr-response-text
                  :since :epoch)

        (xhr-post "https://www.hatena.ne.jp/login"
                  '(:name "foo" :password "bar" :persistent 1)
                  :key 'xhr-response-text
                  :since :epoch)

    * HEADERS で Content-Type が指定されていない場合は
      application/x-www-form-urlencoded が自動的にセットされます。

        (xhr-post url
                  octet-data
                  :headers '(:Content-Type "application/octet-stream"))


    その他の引数および戻り値は
    ((<xhr-get|xhr-get URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING>))
    と同じです。

--- xhr-post-async URL DATA &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS ENCODING ONSUCCESS ONFAILURE ONCOMPLETE HANDLER

    指定された URL に DATA を非同期に POST します。

    詳細は以下を参照してください。

    * ((<xhr-post|xhr-post URL DATA &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS ENCODING>))
    * ((<xhr-get-async|xhr-get-async URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING ONSUCCESS ONFAILURE ONCOMPLETE HANDLER>))

--- xhr-post-future URL DATA &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS ENCODING

    指定された URL に DATA を非同期に POST します。

    詳細は以下を参照してください。

    * ((<xhr-post|xhr-post URL DATA &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS ENCODING>))
    * ((<xhr-get-future|xhr-get-future URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING>))

--- xhr-request METHOD URL DATA &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING

    指定された HTTP METHOD を送信します。
    DATA がない場合は nil を指定してください。

    その他の引数は
    ((<xhr-post|xhr-post URL DATA &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS ENCODING>))
    と同じです。

    例:

        (xhr-request "OPTIONS" url  nil
                     :key #'(lambda (res)
                              (split-string (or (xhr-response-header res "Allow") "") #\,)))
        ;=> ("GET" "HEAD" "OPTIONS" "POST")

--- xhr-request-async METHOD URL DATA &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING HANDLER ONSUCCESS ONFAILURE ONCOMPLETE

    指定された URL に METHOD を非同期に送信します。

    詳細は以下を参照してください。

    * ((<xhr-request|xhr-request METHOD URL DATA &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING>))
    * ((<xhr-get-async|xhr-get-async URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING ONSUCCESS ONFAILURE ONCOMPLETE HANDLER>))

--- xhr-request-future METHOD URL DATA &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING

    指定された URL に METHOD を非同期に送信します。

    詳細は以下を参照してください。

    * ((<xhr-request|xhr-request METHOD URL DATA &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING>))
    * ((<xhr-get-future|xhr-get-future URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING>))

--- xhr-future-p OBJ

    指定された OBJ が Future オブジェクトなら non-nil を返します。

--- xhr-future-uri FUTURE

    指定された Future オブジェクトからリクエスト先の URI を取得します。

--- xhr-future-completed-p FUTURE

    指定された Future オブジェクトのリクエストが完了していたら non-nil を返します。

--- xhr-future-value FUTURE &KEY NOWAIT NO-REDRAW SLEEP TIMEOUT INTERVAL

    指定された Future オブジェクトから結果を取得します。
    結果はリクエスト送信時に指定した KEY が適用された結果が返ります。

    リクエストが完了していない場合は完了を待ち合わせます。

    * NOWAIT に non-nil を指定するとリクエストが完了していない場合は
      待ち合わせをせずにすぐに nil を返します。

      デフォルトは nil です。

    * NO-REDRAW に non-nil を指定するとリクエストの完了待ち中に
      画面の再描画を行いません。

      デフォルトは nil です。

    * SLEEP に non-nil を指定するとリクエストの完了待ち中に
      キー入力があっても中断しません。

      SLEEP が nil の場合キー入力があったら待ち合わせを中断します。
      中断時点でリクエスト完了していない場合は nil を返します。

      SLEEP を指定した場合は画面の再描画を行いません。

      デフォルトは nil です。

    * TIMEOUT を指定すると指定した秒数以内にリクエストが完了しない場合、
      nil を返します。

      TIMEOUT に nil を指定するとタイムアウトせずに無限に待ち合わせます。

      デフォルトは 3 秒です。

    * INTERVAL は監視間隔です。

      デフォルトは 0.3 秒です。

--- xhr-requested-uri RES

    指定されたレスポンスオブジェクトから URI を取得します。

      (xhr-requested-uri (xhr-get "http://www.google.co.jp/"))
      ;=> http://www.google.co.jp/

--- xhr-all-response-header RES

    すべての HTTP ヘッダを取得します。
    戻り値は全ヘッダをまとめた文字列で返します。

--- xhr-all-response-header-alist RES

    すべての HTTP ヘッダを alist で取得します。

--- xhr-all-response-header-hash RES

    すべての HTTP ヘッダを hashtable で取得します。

--- xhr-response-header RES HEADER

    指定した HTTP ヘッダを取得します。
    header には "Content-Length" や "Last-Modified" などを指定します。

--- xhr-response-text RES

    HTTP 通信の結果 (body) を取得します。

--- xhr-response-xml RES

    取得した XML を S式で返します。
    S 式は xml-parser-modoki と互換性があります（たぶん）。

    取得先のリソースが XML でない場合 nil を返します。
    XML をテキスト形式で取得したい場合は
    ((<xhr-response-text|xhr-response-text RES>))
    を使用してください。

--- xhr-response-values RES

    以下の値を多値で返します。
    * ((<"レスポンス本文"|xhr-response-text RES>))
    * ((<"HTTP ステータス"|xhr-status RES>))
    * ((<"レスポンスヘッダ (alist)"|xhr-all-response-header-alist RES>))

--- xhr-status RES

    HTTP status を取得します。

--- xhr-status-text RES

    HTTP status の文字列表現を取得します。

--- xhr-abort TRANSPORT

    指定したリクエストを停止します。

    引数には Future オブジェクト (xhr-xxx-future の戻り値)、
    キャンセルオブジェクト (xhr-xxx-async の戻り値) を指定可能です。

    通信を中断したなら t を返します。
    既に通信が終了していたら何もせず nil を返します。

    例:

        ;; 5 秒以内に結果が返らなければコネクションを切断して例外を投げる
        (let ((future (xhr-get-future url)))
          (let ((v (xhr-future-value future :timeout 5)))
            (unless (xhr-future-completed-p future)
              (xhr-abort future)
              (plain-error "timeout"))
            v))

--- xhr-credential USER PASSWORD

    各リクエスト関数の :basic-auth 引数に指定するための
    ユーザ認証用の情報を作成します。

--- xml-http-request-version

    本ライブラリのバージョンを返します。
    バージョンは major.minor.teeny という形式です。

    それぞれの番号は必ず 1 桁にするので、以下のように比較することができます。

        (if (string<= "1.1.0" (xml-http-request-version))
            (1.1.0 以降で有効な処理)
          (1.1.0 より前のバージョンでの処理))


=== MACRO

--- with-xhr-get-async (URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING>) &BODY HANDLER

    ((<xhr-get-async|xhr-get-async URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING ONSUCCESS ONFAILURE ONCOMPLETE HANDLER>))
    のラッパーマクロです。

    マクロの本体には以下の形式でイベントハンドラを記述できます。

      (on <(or HTTPステータス :success :failure :complete)> (<仮引数>...)
          <イベントハンドラの本体>)

    例)

      (with-xhr-get-async ("http://www.google.co.jp/" :since :epoch)
        (on 200 (res)
            (msgbox "200 OK"))
        (on :success (res)
            (msgbox "成功しました ~S" (xhr-response-header res "Server")))
        (on :failure (res)
            (msgbox "失敗しました... orz"))
        (on :complete (res)
            (msgbox "終了しました")
            (msgbox "http status: ~A" (xhr-status res))))

    on の中身はクロージャに変換されるので以下のようなこともできます。

      (setf result (let ((r nil))
                     (with-xhr-get-async ("http://www.google.co.jp/"
                                          :key 'xhr-response-values)
                       (on :complete (text status header)
                           (setf r (list status header text))))
                     #'(lambda () r)))
      (funcall result)

--- with-xhr-head-async (URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING) &BODY HANDLER

    ((<xhr-head-async|xhr-head-async URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING ONSUCCESS ONFAILURE ONCOMPLETE HANDLER>))
    のラッパーマクロです。

--- with-xhr-post-async (URL BODY &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS ENCODING) &BODY HANDLER

    ((<xhr-post-async|xhr-post-async URL DATA &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS ENCODING ONSUCCESS ONFAILURE ONCOMPLETE HANDLER>))
    のラッパーマクロです。

--- with-xhr-request-async (METHOD URL BODY &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING) &BODY HANDLER

    ((<xhr-request-async|xhr-request-async METHOD URL DATA &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING HANDLER ONSUCCESS ONFAILURE ONCOMPLETE>))
    のラッパーマクロです。


=== OBSOLETE FUNCTION

--- http-get URL &KEY HEADERS ONFAILURE ONSUCCESS ONCOMPLETE

    これは互換性のために残されている 非推奨 API です。

    変わりに
    ((<xhr-get|xhr-get URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING>))、
    ((<xhr-get-async|xhr-get-async URL &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS QUERY ENCODING ONSUCCESS ONFAILURE ONCOMPLETE HANDLER>))
    を使ってください。

--- http-post URL DATA &KEY HEADERS ONFAILURE ONSUCCESS ONCOMPLETE

    これは互換性のために残されている 非推奨 API です。

    変わりに
    ((<xhr-post|xhr-post URL DATA &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS ENCODING>))、
    ((<xhr-post-async|xhr-post-async URL DATA &KEY BASIC-AUTH NOMSG KEY SINCE HEADERS ENCODING ONSUCCESS ONFAILURE ONCOMPLETE HANDLER>))
    を使ってください。

--- response-text TRANSPORT

    これは互換性のために残されている 非推奨 API です。

    変わりに
    ((<xhr-response-text|xhr-response-text RES>))
    を使ってください。

--- status TRANSPORT

    これは互換性のために残されている 非推奨 API です。

    変わりに
    ((<xhr-status|xhr-status RES>))
    を使ってください。

--- status-text TRANSPORT

    これは互換性のために残されている 非推奨 API です。

    変わりに
    ((<xhr-status-text|xhr-status-text RES>))
    を使ってください。

--- abort TRANSPORT

    これは互換性のために残されている 非推奨 API です。

    変わりに
    ((<xhr-abort|xhr-abort TRANSPORT>))
    を使ってください。

--- all-response-headers TRANSPORT

    これは互換性のために残されている 非推奨 API です。

    変わりに
    ((<xhr-all-response-header|xhr-all-response-header RES>))
    を使ってください。

--- response-header TRANSPORT HEADER

    これは互換性のために残されている 非推奨 API です。

    変わりに
    ((<xhr-response-header|xhr-response-header RES HEADER>))
    を使ってください。


== TODO

* フック
* トレースログ
* Msxml2.ServerXMLHTTP
  * proxycfg
  * netsh (vista)
  * oledata の再利用
    * xhr-agent ?


== KNOWN BUGS

* 空白文字は + ではなく %20 にエンコードされます。

* サーバ側が charset を返さずかつ UTF-8 以外の場合は文字化けします。

  → ((<URL:http://d.hatena.ne.jp/miyamuko/20050913#p1>))

* 文字列は xyzzy 内部で Shift_JIS に変換されます。

  Shift_JIS 外の文字は ? に化けます (英語と日本語以外はまともに扱えません)。


== AUTHOR

みやむこ かつゆき (((<URL:mailto:miyamuko@gmail.com>)))


== SEE ALSO

なし。


== COPYRIGHT

xml-http-request は MIT/X ライセンスに基づいて利用可能です。

See xml-http-request/docs/MIT-LICENSE for full license.


== NEWS

<<<NEWS.rd

=end
