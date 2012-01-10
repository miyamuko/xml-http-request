## History

---

### 2012-01-10 / 1.3.1

xml-http-request 1.3.1 リリース!

#### 新規機能

  * progid 引数で XMLHTTP オブジェクトのバージョンを指定できるようにした (#4)

    ```lisp
    (xhr:xhr-get "http://atnd.org/events/22889.rss"
                 :key #'xhr:xhr-response-xml
                 :progid '(:xmlhttp 6.0))
    (xhr:xhr-get "http://atnd.org/events/22889.rss"
                 :key #'xhr:xhr-response-xml
                 :progid "Msxml2.XMLHTTP.6.0")
    ```

#### 非互換を含む変更点

  * なし

#### バグ修正

  * Foo:Bar というセパレータ後に空白を含まない形式のヘッダを
    解析できていなかったのを修正

#### その他

  * なし

### 2011-11-20 / 1.3.0

xml-http-request 1.3.0 リリース!

#### 新規機能

  * `xhr-request-waiting-p`: リクエスト中なら t を返す
  * `xhr-request-complete-p`: リクエストが完了したなら t を返す (abort した場合も t)
  * `xhr-request-aborted-p`: リクエストを abort したなら t を返す

    ```lisp
    (let ((req (xhr:xhr-get-async "http://www.google.co.jp"
                                  :oncomplete #'(lambda (res) (msgbox "complete: ~S" req))
                                  :onabort #'(lambda (req) (msgbox "abort: ~S" req))
                                  )))
      (xhr:xhr-abort req)
      (list
       (xhr:xhr-request-waiting-p req)
       (xhr:xhr-request-completed-p req)
       (xhr:xhr-request-aborted-p req)
       ))
    ;=> (nil t t)
    ```

  * `xhr-get-async`, `xhr-head-async`, `xhr-post-async`, `xhr-request-async`:
    xhr-abort で中断した場合に呼ばれる onabort イベントハンドラを追加

#### 非互換を含む変更点

  * なし

#### バグ修正

  * 非同期 API のイベントハンドラ内で発生したエラーは
    メッセージ領域と `*Trace Output*` で通知するようにした
  * `*request-queue*` に値が入った状態でダンプした場合でも、
    イベントディスパッチタイマーが動くようにした (#1)
  * リクエストした順にコールバックを呼ぶようにした
  * `xhr-abort`: まったく動作していなかったのを直した

#### その他

  * なし

---

### 2008-07-12 / 1.2.1

xml-http-request 1.2.1 リリース!

#### 新規機能

  * なし

#### 非互換を含む変更点

  * なし

#### バグ修正

  * なし

#### その他

  * ライセンスファイルを同梱


---

### 2008-03-30 / 1.2.0

xml-http-request 1.2.0 リリース!

#### 新規機能

  * 各リクエストメソッドに basic-auth 引数を追加しました。

    Basic 認証のためのユーザ情報とパスワードを指定します。

    ```lisp
    (xhr-get "http://foo.com" :basic-auth (xhr-credential "user" "password"))
    ```

#### 非互換を含む変更点

  * basic-auth 引数を指定せずに Basic 認証が必要な URI に接続した場合
    認証情報を入力するダイアログが表示されます。

    1.0.0 〜 1.1.1 では認証ダイアログは表示されません。
    0.1 では表示されます。

#### バグ修正

  * 接続する URL の userinfo に認証情報を指定しても無視される問題を修正
    (楓月さんによる報告)

    ```lisp
    (xhr-get "http://user:password@foo.com")
    ```

    ※ basic-auth 引数を指定した場合は URL の userinfo は無視されます。


---

### 2008-03-03 / 1.1.1 / ひなまつり

xml-http-request 1.1.1 リリース!

#### 新規機能

  * post 以外のリクエスト関数に query と encoding キーワード引数を追加。
    query string をリストで指定できます。

#### 非互換を含む変更点

  * なし

#### バグ修正

  * xml-http-request 1.1.0 で利用する XMLHttpRequest オブジェクトを
    Msxml2.XMLHTTP.6.0 にこっそり更新していたが、
    xyzzy との組み合わせに問題があったので Msxml2.XMLHTTP に戻した。


---

### 2008-02-23 / 1.1.0

xml-http-request 1.1.0 リリース!

#### 新規機能

  * 各リクエスト関数に nomsg キーワード引数を追加。

    - nomsg に non-nil を指定するとメッセージを出力しません。

  * xhr-future-value に no-redraw と sleep キーワード引数を追加。

    - no-redraw に non-nil を指定すると待ち合わせ中に画面の再描画を行いません。
    - sleep に non-nil を指定すると待ち合わせ中に割り込みできないようにします。

#### 非互換を含む変更点

  * なし

#### バグ修正

  * なし


---

### 2008-02-11 / 1.0.1 / 建国記念の日

xml-http-request 1.0.1 リリース!

#### 新規機能

  * (xhr-abort): 既に通信が終了していたら何もせず nil を返す、
    通信を中断したなら t を返すようにした。

#### 非互換を含む変更点

  * (xhr-xxx-async): 戻り値に cancel-ticket を返すようにした。
    cancel-ticket は xhr-abort に指定して通信を中断可能。

  * (http-get, http-post): 非同期送信時は oledata を返す。

  * xhr-xxx-future に指定した key 関数の中でエラーが発生した場合、
    xhr-future-value した時点でエラーを通知。

#### バグ修正

  * なし


---

### 2008-02-11 / 1.0.0 / 建国記念の日

xml-http-request 1.0.0 リリース!

#### 新規機能

  * リニューアル

  * Future パターンのサポート

  * イベントハンドラのマクロ化

#### 非互換を含む変更点

  * xml-http-request 0.1 との互換層を用意しているので基本的には動くはずです。

#### バグ修正

  * たぶんなし


---

### 2006-06-13 / 0.1

xml-http-request 0.1 リリース!
