## 例えば、どういうことをしたいのかの全貌。

PEX(C#)は参考程度に。主はpython。

AVROとは
wikipedia, 
https://github.com/intersystems-community/irisdemo-demo-kafka How does the Demo uses AVRO and AVRO Schemas
多言語対応

## MQTTについて
多言語対応

## IRISについて
サーバサイドでのロジック記述に使用できる言語(c#, java, python, c/c++, ObjectScript)

つまり、組み合わせは自在

|MQTTクライアント|AVROデコード|DBへの保存|形式|備考|
|:--|:--|:--|:--|:--|
|java/c#など| java/c#など| JDBC/ADO経由| IRISは単なるRDBMS|互換性最大|
|IRIS| c#/Java(PEX) | IRIS Native API経由 | c#は別サーバでも実行可能|c#/Javaの手持ちのライブラリの活用|
|IRIS| c#/Java(PEX) | IRIS上で実行 | AVROデコードのみc#/Javaで実行する方法|処理が冗長な分オーバヘッドが大きい|
|IRIS| Python(埋め込み) | IRIS上で実行 | 簡潔 |

## 今回はc# と Pythonを選択

理由：c#は、あまりサンプルが無いから。pythonはあまりに簡潔に実現できるから。さらに

c#のメリットは、AVROの定義からc#クラスを生成してくれるツールが存在すること。入力支援が有効になる。

Pythonのメリットは、ダイナミックであること。埋め込みPythonが使えること。

派生例としては、BSで受信後デコードせずに、ただちに保存(GlobalあるいはO/Sファイル)だけする。別のBSでデコード->INSERTする。
この際、FIFOを考慮したデコード処理の並列化を検討すべき。
「インターオペラビリティ機能のビジネスプロセスを理解する」のFIFOについてのくだりを参照ください。
https://www.youtube.com/watch?v=RUxeT4cTy4k

javaの例
https://github.com/intersystems-community/irisdemo-demo-kafka
かなりボリュームがある。Spring Framework使用の本格的なjavaサーバを使用。

# AVRO vs JSON

AVRO

サイズがより小さい、スキーマを定義できる、データ型が豊富、マシンリーダブル。

https://fastavro.readthedocs.io/en/latest/ 
> pythonの場合,fastavroじゃないと遅すぎる。


JSON

スキーマレス(変更に強い)、データ型は文字と数値、ヒューマンリーダブル。


特定の用途への向き不向きは、これらの性質により決まる。

AVROは、もともとHadoopのデータ保存形式なので、Hadoop/Spark由来のDBMS製品では自然に読み書きができる。

印象ですが

固定的なフォーマットだが、大量にデータが発生する、IoT系(センサーデータ)や金融等はAVRO。 

非常に複雑なフォーマットになりがちな医療(診療)情報系はJSON(FHIR)。


## サイズ

どれくらい小さいか？

```
$ python3 CompareSize.py
 
-rw-r--r-- 1 irismeister irismeister  2644  7月 26 12:25 compare.avro
-rw-r--r-- 1 irismeister irismeister  4449  7月 26 12:25 compare.json
```

base64は24 bits(8 bits*3)を6 bits*4に変換するので、一番サイズが大きい要素であるバイト配列は1.3倍程度の大きさになる。

long(64 bits=8 bytesの整数)も、数値が大きいとサイズの差が開く。下記の例だと19/8=2.4倍程度。
>>> 2**60
1152921504606846976 <== 19 bytes

## デコードのコスト

AVROを連続保存
```
docker compose exec iris /usr/irissys/bin/irispython /datavol/share/SaveAVRO.py 3000
```

JSONを連続保存
```
docker compose exec iris /usr/irissys/bin/irispython /datavol/share/SaveJSON.py 3000
```

保存にかかった時間を取得する。
```
SELECT COUNT(*),{fn TIMESTAMPDIFF(SQL_TSI_FRAC_SECOND,MIN(ReceiveTS),MAX(ReceiveTS))} 
FROM (SELECT TOP 3000 ReceiveTS FROM MQTT.SimpleClass WHERE topic like '/XGH/EKG/ID_123/PYAVRO/%' ORDER BY ID DESC)
Aggregate_1	Expression_2
3000	2945

SELECT COUNT(*),{fn TIMESTAMPDIFF(SQL_TSI_FRAC_SECOND,MIN(ReceiveTS),MAX(ReceiveTS))} 
FROM (SELECT TOP 3000 ReceiveTS FROM MQTT.SimpleClass WHERE topic like '/XGH/EKG/ID_123/PYJSON/%' ORDER BY ID DESC)

Aggregate_1	Expression_2
3000	792
```

JSONのほうがかなり速いという結果に。JSON文字列からJSONへのデコードは軽い(ほぼ変換無しだから)という事。


## 送受信＋デコードのコスト

Pythonで使用したライブラリ
https://eclipse.dev/paho/files/paho.mqtt.python/html/client.html

どの程度送受信に時間を要するかを比較しようと思ったが、QoS=0では100件全てをとれてなかった。QoS=1にするとさらに減って19件に...。
==>  client.loop_start()を追加したら期待した動作(100件取得)となった。QoS=0に戻した。
==> 3000件送ると取りこぼす。==> confにmax_queued_messages 0を追加して対処(0=No limiは非推奨らしいが、それが目的ではないので良しとする)

AVROを送信
```
単独送信
docker compose exec iris mosquitto_pub -h "mqttbroker" -p 1883 -t /XGH/EKG/ID_123/PYAVRO -f /home/irisowner/share/compare.avro
連続送信
python3 Pub-AVRO.py 3000

受信側
IRISのMQTT.BS.PYAVRO
あるいは
docker compose exec iris mosquitto_sub -F %t -h mqttbroker -p 1883 -t /XGH/EKG/ID_123/PYAVRO/#

```

JSONを連続送信
```
単独送信
docker compose exec iris mosquitto_pub -h "mqttbroker" -p 1883 -t /XGH/EKG/ID_123/PYJSON -f /home/irisowner/share/compare.json
連続送信
python3 Pub-JSON.py 3000

受信側
IRISのMQTT.BS.PYJSON
あるいは
docker compose exec iris mosquitto_sub -F %t -h mqttbroker -p 1883 -t /XGH/EKG/ID_123/PYJSON/#
```

実行後に
```
SELECT COUNT(*),{fn TIMESTAMPDIFF(SQL_TSI_FRAC_SECOND,MIN(ReceiveTS),MAX(ReceiveTS))} FROM (SELECT TOP 3000 ReceiveTS FROM MQTT.SimpleClass WHERE topic like '/XGH/EKG/ID_123/PYAVRO/%' ORDER BY ID DESC)
Aggregate_1	Expression_2
3000	9033

SELECT COUNT(*),{fn TIMESTAMPDIFF(SQL_TSI_FRAC_SECOND,MIN(ReceiveTS),MAX(ReceiveTS))} FROM (SELECT TOP 3000 ReceiveTS FROM MQTT.SimpleClass WHERE topic like '/XGH/EKG/ID_123/PYJSON/%' ORDER BY ID DESC)
Aggregate_1	Expression_2
3000	6752
```
差は縮まったが、まだ、JSONのほうが速い。通信がlocalhost間でほぼ遅延無しだからか？

## ノード越えの送受信

Azure
```
AVRO
| Aggregate_1 | Expression_2 |
| -- | -- |
| 3000 | 13313 |

JSON
| Aggregate_1 | Expression_2 |
| -- | -- |
| 3000 | 9912 |


JSON
| Aggregate_1 | Expression_2 |
| -- | -- |
| 1000 | 5184 |

```

JSONのほうが速い。デコードのコストの低さが、通信コストの高さに勝っている模様。ネットワークが空いているせいもある？



## スキーマを定義

スキーマエボリューション対応。

## データ型

使用言語次第で、データの精度を維持できる。

```
>>> 0.1+0.2
0.30000000000000004
>>>
```
これで説明付くか？

## マシンリーダブル

jsonやxmlはマシンリーダブルかつヒューマンリーダブル。

# いろいろハマったところ

## どこが根を上げるか？

あるデータタイプの配列が非常に大きい場合、どの程度のサイズまで処理できるか。
> センサーデータなどを想定。

MQTTのパケットサイズの上限: 268435455 Bytes = 256 MB
```
docker compose exec iris mosquitto_pub -h "mqttbroker" -p 1883 -t /XGH/EKG/ID_123/PYAVRO -f /home/irisowner/share/400MB.avro
Error: File must be less than 268435455 bytes.
```

AVROのサイズ上限

詳細不明。MQTTのパケットサイズ上限以上なので、深入りせず。

IRISの上限

MQTTの受信データは全体がいったん EnsLib.MQTT.MessageのStringValueに保存されるので、恐らくこれが上限になる。

> IRIS ローカル変数、戻り値の最大サイズ: 3,641,144 文字 (Ascii文字なら3.5MB程度)


5.3MBのパケットを受信した場合、IRIS内でエラー発生。
```
ERROR #5002: ObjectScript error: <NULL VALUE>Receive+6 ^%Net.MQTT.Client.1
```

3.2MB程度のパケットは正常に受信可能。

つまり、パケットサイズは3.5MB以下に抑えるのが安全。
> 8バイトの浮動小数点換算で、45万データポイント。1秒に100回データ取得している場合でも、10秒間で8KBでしかないので十分？



## python
### 埋め込みpythonのpyの配置場所
### バイナリの扱い方
Python内でのファイル操作時のbinaryモード使用
IRIS->Python
### __main__の勧め(デバッグしやすい)

情報元として「ObjectScript と組み込み Python 間のギャップを埋める」が有益です。
https://docs.intersystems.com/supplychain20241/csp/docbookj/DocBook.UI.Page.cls?KEY=GEPYTHON_sharedata

### カレントディレクトリの場所(open()時に気づく)

基本は、現在のネームスペースが使用するデータベースの位置。

Python起点でのアクセス時の初期状態はUSERデータベースの位置 (正確にはユーザの「開始ネームスペース」の設定に紐づくデータベース)


## Production

BSだけのProductionもOK。大量レコードの処理時にはメッセージは不向き。1000件/秒で発生するようなメッセージをメッセージビューワで閲覧、目検でデバッグするのは非現実的。


Windowsでの実行

```
mqtt server
"\Program Files"\mosquitto\mosquitto -v
mqtt client
"\Program Files"\mosquitto\mosquitto_pub -h localhost -p 1883 -t /XGH/EKG/ID_123/PYAVRO -f C:\git\IRIS-PEX-MQTT-dotnet\datavol\share\SimpleClass.avro
```


```
(XEPを使いたかったので)自前作成のSimpleClass.csを使っていたが、XEPの線が消えたので、avrogenで生成されたcsを使用するように修正中。
(そもそも使用していなかったが)mapがうまく動作しない点を除けば動作している。

クラスは下記要領で作成し、netgw/mylib1/SimpleClass.csに配置する。
$ docker compose exec dotnet-dev bash
dotnet tool install --global Apache.Avro.Tools --version 1.11.3
export PATH="$PATH:/root/.dotnet/tools"
avrogen -s /share/SimpleClass.avsc ./gen --namespace foo:dc

netgw/genavro/Program.csの実行
docker compose exec netgw /app/genavro

netgw/myapp/Program.csの実行
docker compose exec netgw /app/myapp
```


