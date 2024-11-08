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

## 今回はPythonを選択

理由：c#は、あまりAVRO関連のサンプルが無いから。pythonを使うとあまりにも簡潔に実現できるから。
c#使うなら、デコード処理のためだけにc#を介在させるよりは、デコードだけではなく、INSERT文の組み立て・実行までを、c#側で実装するほうが自然だから。

c#のメリットは、AVROの定義からc#クラスを生成してくれるツールが存在すること。入力支援が有効になる。
Pythonのメリットは、ダイナミックであること。埋め込みPythonが使えること。
...と真逆の思想。

とはいえ、サンプル実装はあるので、興味がありましたらどうぞ...。

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
$ ll 
-rw-r--r-- 1 irismeister irismeister  955  8月  1 14:05 compare.avro
-rw-r--r-- 1 irismeister irismeister 2345  8月  1 14:05 compare.json
```

base64は24 bits(8 bits*3)を6 bits*4に変換するので、バイト配列は1.3倍程度の大きさになる。

double(64 bits 浮動小数点)も、有効精度次第でサイズの差が開く。下記の例だと18/8=2.25倍。

json:   0.6041420355438344 <== 18 bytes
binary: 8 bytes

## デコードと保存のコスト

AVROを連続保存
```
docker compose exec iris /usr/irissys/bin/irispython /datavol/share/SaveFastAVRO.py 3000
```

JSONを連続保存
```
docker compose exec iris /usr/irissys/bin/irispython /datavol/share/SaveJSON.py 3000
```

保存にかかった時間を取得する。
```
docker compose exec iris /usr/irissys/bin/irispython  /datavol/share/BenchReset.py
(実行内容 DELETE FROM MQTT.SimpleClass)

docker compose exec iris /usr/irissys/bin/irispython  /datavol/share/BenchMeasure.py
(実行内容 SELECT count(*),{fn TIMESTAMPDIFF(SQL_TSI_FRAC_SECOND,MIN(ReceiveTS),MAX(ReceiveTS))} FROM MQTT.SimpleClass)
```


実行手順と結果
```
AVRO
docker compose exec iris /usr/irissys/bin/irispython  /datavol/share/BenchReset.py
docker compose exec iris /usr/irissys/bin/irispython /datavol/share/SaveFastAVRO.py 3000
docker compose exec iris /usr/irissys/bin/irispython  /datavol/share/BenchMeasure.py
[0]: [3000, 444]

JSON
docker compose exec iris /usr/irissys/bin/irispython  /datavol/share/BenchReset.py
docker compose exec iris /usr/irissys/bin/irispython /datavol/share/SaveJSON.py 3000
docker compose exec iris /usr/irissys/bin/irispython  /datavol/share/BenchMeasure.py
[0]: [3000, 462]
```

JSON文字列からJSONへのデコードは軽い(ほぼ変換無しだから)。


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

JSONを送信
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

実行手順と結果

```
AVRO
docker compose exec iris /usr/irissys/bin/irispython  /datavol/share/BenchReset.py
python3 Pub-AVRO.py 3000
docker compose exec iris /usr/irissys/bin/irispython  /datavol/share/BenchMeasure.py
[0]: [3000, 6163]

JSON
docker compose exec iris /usr/irissys/bin/irispython  /datavol/share/BenchReset.py
python3 Pub-JSON.py 3000
docker compose exec iris /usr/irissys/bin/irispython  /datavol/share/BenchMeasure.py
[0]: [3000, 6785]
```

差が広がった。通信がlocalhost間でほぼ遅延無しなので、通信の影響が過小評価されている。

## ノード越えの送受信



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


## install to bare O/S

Azure: Standard D4s v3 (4 vcpu 数、16 GiB メモリ) 
Ununtu Server 22.04 LTS x64 Gen2、Diskは内蔵のみ、高速ネットワーク:有効 * 2台

IRIS+MQTT Broker
```
sudo apt update
wget -O get-docker.sh https://get.docker.com
sudo sh ./get-docker.sh
sudo usermod -aG docker $USER
git clone https://github.com/IRISMeister/IRIS-PEX-MQTT-dotnet.git
cd IRIS-PEX-MQTT-dotnet
./build.sh
./up.sh


mqtt client
```
sudo apt update
sudo apt install -y mosquitto-clients python3-pip
git clone https://github.com/IRISMeister/IRIS-PEX-MQTT-dotnet.git
cd IRIS-PEX-MQTT-dotnet/datavol/share
pip3 install avro fastavro paho-mqtt
vi Pub-AVRO.py localhost->linux1
python3 Pub-AVRO.py 1
```

SMPへのアクセス
ssh -i azure.pem -L 8882:localhost:8882 azureuser@x.x.x.x

========================================
デコード＋保存
azureuser@linux1:~/IRIS-PEX-MQTT-dotnet$ 
docker compose exec iris /usr/irissys/bin/irispython  /datavol/share/BenchReset.py
docker compose exec iris /usr/irissys/bin/irispython /datavol/share/SaveFastAVRO.py 50000
docker compose exec iris /usr/irissys/bin/irispython  /datavol/share/BenchMeasure.py
[0]: [50000, 12511]
[0]: [50000, 12565]

azureuser@linux1:~/IRIS-PEX-MQTT-dotnet$ 
docker compose exec iris /usr/irissys/bin/irispython  /datavol/share/BenchReset.py
docker compose exec iris /usr/irissys/bin/irispython /datavol/share/SaveJSON.py 50000
docker compose exec iris /usr/irissys/bin/irispython  /datavol/share/BenchMeasure.py
[0]: [50000, 13735]
[0]: [50000, 13711]

========================================
送受信+デコード＋保存

◎高速ネットワークを有効にした場合
azureuser@linux2:~/IRIS-PEX-MQTT-dotnet/datavol/share$ ping linux1
30 packets transmitted, 30 received, 0% packet loss, time 29046ms
rtt min/avg/max/mdev = 0.817/1.405/6.071/1.164 ms

avro
docker compose exec iris /usr/irissys/bin/irispython  /datavol/share/BenchReset.py
python3 Pub-AVRO.py 50000
docker compose exec iris /usr/irissys/bin/irispython  /datavol/share/BenchMeasure.py
[0]: [50000, 184079]

json
docker compose exec iris /usr/irissys/bin/irispython  /datavol/share/BenchReset.py
python3 Pub-JSON.py 50000
docker compose exec iris /usr/irissys/bin/irispython  /datavol/share/BenchMeasure.py
[0]: [50000, 184312]

参考：PEX3, Native経由で%New()で保存するスタイル。
python3 Pub-AVRO.py 50000 PEX3
[0]: [50000, 284105]

上記を繰り返し実行した結果。
azureuser@linux2:~/IRIS-PEX-MQTT-dotnet/datavol/share$ for i in {1..10} ; do python3 Pub-AVRO.py 50000 ; done
0,50000,106660
0,50000,102919
0,50000,107898
0,50000,105728
0,50000,102371
0,50000,107596
0,50000,107187
0,50000,112106
0,50000,109490
0,50000,111245

平均: 107320 (107秒)

azureuser@linux2:~/IRIS-PEX-MQTT-dotnet/datavol/share$ for i in {1..10} ; do python3 Pub-JSON.py 50000 ; done
0,50000,112897
0,50000,111966
0,50000,105887
0,50000,108504
0,50000,109766
0,50000,109334
0,50000,109909
0,50000,108872
0,50000,105355
0,50000,103369

平均: 108586 (109秒)

殆ど差はない。

では、ネットワークに負荷をかけている状態ではどうか？

sudo apt install iperf3
linux1:  iperf3 -s 
linux2:  iperf3 -c linux1 -N -t 7200 -P 100

azureuser@linux2:~/IRIS-PEX-MQTT-dotnet/datavol/share$ for i in {1..10} ; do python3 Pub-AVRO.py 50000 ; done
0,50000,122708
0,50000,121958
0,50000,136204
0,50000,131718
0,50000,132615
0,50000,121797
0,50000,127427
0,50000,139289
0,50000,120389
0,50000,105303
azureuser@linux2:~/IRIS-PEX-MQTT-dotnet/datavol/share$ for i in {1..10} ; do python3 Pub-JSON.py 50000 ; done
0,50000,144755
0,50000,136712
0,50000,140608
0,50000,142291
0,50000,144148
0,50000,154091
0,50000,158519
0,50000,152715
0,50000,114578
0,50000,160807

差が広がったことが確認できる。


◎高速ネットワークを無効にした場合
azureuser@linux2:~/IRIS-PEX-MQTT-dotnet/datavol/share$ ping linux1
30 packets transmitted, 30 received, 0% packet loss, time 29045ms
rtt min/avg/max/mdev = 0.804/1.124/2.537/0.404 ms

>ping は高速有効時よりむしろ早い...。
>同一ネットワーク構成内でのAVRO vs JSONの比率が大事なので、ここでは無視する。

送受信+デコード＋保存

avro
python3 Pub-AVRO.py 50000
[0]: [50000, 181848]   <==　なぜか無効のほうが速くなった...VM間の物理的な位置関係とか関係するのか？

json
python3 Pub-JSON.py 50000
[0]: [50000, 180092]

上記を繰り返し実行した結果。
azureuser@linux20:~/IRIS-PEX-MQTT-dotnet/datavol/share$ for i in {1..10} ; do python3 Pub-AVRO.py 50000 ; done
0,50000,104550
0,50000,102151
0,50000,107142
0,50000,103040
0,50000,101654
0,50000,106512
0,50000,107171
0,50000,109073
0,50000,107096
0,50000,103798
azureuser@linux20:~/IRIS-PEX-MQTT-dotnet/datavol/share$ for i in {1..10} ; do python3 Pub-JSON.py 50000 ; done
0,50000,107695
0,50000,108502
0,50000,104981
0,50000,106960
0,50000,106014
0,50000,107928
0,50000,104911
0,50000,105243
0,50000,102149
0,50000,99727

ネットワーク負荷をかけている状態では？

azureuser@linux20:~/IRIS-PEX-MQTT-dotnet/datavol/share$ for i in {1..10} ; do python3 Pub-AVRO.py 50000 ; done
0,50000,270904
0,50000,136672
0,50000,187577
0,50000,122451
0,50000,171286
0,50000,183192
0,50000,141121
0,50000,118685
0,50000,135554
0,50000,163419
azureuser@linux20:~/IRIS-PEX-MQTT-dotnet/datavol/share$ for i in {1..10} ; do python3 Pub-JSON.py 50000 ; done
0,50000,355495
0,50000,404830
0,50000,346125
0,50000,380983
0,50000,386643
0,50000,359443
0,50000,124576
0,50000,557044
    ・
    中断

差がより顕著に現れる。


結論
pythonのデコードの遅さが足を引っ張るのでfastavroが有力。JSONと比べた際のAVROにそれほどの優位性は認められなかった。
通信込みでも、通信トラフィックは増えているはずだが、パフォーマンス面でのAVRO, JSON間の差はほとんどない。
混雑したネットワーク環境化では、差がでる。
高速ネットワーク無効設定での混雑したネットワーク環境化では、差が顕著にでる。

データの内容によっては差は拡大・縮小する。逆転もあり得る。
(いつもの事ですが)要は使いどころ。

Pythonのさらなる高速化に期待
https://github.com/markshannon/faster-cpython/blob/master/plan.md

```

