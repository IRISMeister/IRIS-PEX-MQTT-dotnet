# 環境
ご参考までに私の環境は以下の通りです。
|用途|O/S|ホストタイプ|IP|
|:--|:--|:--|:--|
|クライアントPC|Windows10 Pro|物理ホスト|192.168.11.5/24|
|Docker環境|Ubuntsu 22.04.2 LTS|上記Windows10上の仮想ホスト(vmware)|192.168.11.48/24|

Ubuntsuは、[ubuntu-20.04.1-live-server-amd64.iso](http://old-releases.ubuntu.com/releases/20.04.1/ubuntu-20.04.1-live-server-amd64.iso)を使用して、最低限のサーバ機能のみをインストールしました。

# 起動方法
```
$ git clone https://github.com/IRISMeister/Samples-MQTT-EKG-Devices.git
$ cd Samples-MQTT-EKG-Devices
$ ./setup.sh
$ docker compose up -d
```

[管理ポータル](http://localhost:52873/csp/sys/%25CSP.Portal.Home.zen?$NAMESPACE=INTEROP)

_SYSTEM/SYS

# 停止(削除)方法
```
$ docker compose down
```

# MQTT受信用のビジネスサービスについて

|BS|Topic|送信先|備考|格納先テーブル|
|:--|:--|:--|:--|:--|
|From_MQTT_EXT|EXT|Process_MQTT|External Languageを明示使用する例。下記PEX利用を推奨||
|From_MQTT_PEX([dc.MQTTService](netgw/mylib1/MQTTService.cs))|PEX|Process_MQTT|PEX使用。myBytes配列を分割して、リレーショナル化する例|Solution.RAWDATA|
|From_MQTT_PEX2([dc.MQTTService2](netgw/mylib1/MQTTService2.cs))|PEX2|Process_MQTT|PEX使用。シリアライズ(文字列化)した配列を使用、応答メッセージを[PEXメッセージ](dotnet/mylib1/MQTTRequest.cs)で作成する例|PEX.Message|
|From_MQTT_PEX3([dc.MQTTService3](netgw/mylib1/MQTTService3.cs))|PEX3|Process_MQTT|PEX使用。シリアライズ(文字列化)した配列を使用、応答メッセージを[IRIS Native](src/Solution/SimpleClass.cls)で作成する例|MQTT.SimpleClass|
|~~From_MQTT_PEX4~~|~~PEX4~~|~~Process_MQTT~~|~~PEX使用。XEPで保存。応答メッセージを[IRIS Native](src/Solution/SimpleClassC.cls)で作成する例~~||
|From_MQTT_PT|PT|Decode_MQTT_PEX|標準のEnsLib.MQTT.Service.Passthroughサービスを使用|MQTT.SimpleClass|
|MQTT.BS.PYAVRO([MQTT.BS.PYAVRO](src\MQTT\BS\PYTHON.cls))|PY|N/A|埋め込みPython使用例|MQTT.SimpleClass|

# データの送信方法
## 送信する
```
# docker compose exec iris mosquitto_pub -h mqttbroker -p 1883 -t /ID_123/XGH/EKG/PT -f /home/irisowner/share/SimpleClass.avro
```
上記コマンドを実行すると、From_MQTT_PTがMQTTメッセージを受信し、その後の処理が実行されます。

ただし、各BSは、以下のTopicをSubscribeする設定になっています。いずれも[SimpleClass.avsc](datavol/share/SimpleClass.avsc)でエンコードされたデータを受け付けます。
|受信するBS|Topic|
|:--|:--|
|From_MQTT_EXT|/ID_123/XGH/EKG/EXT|  
|From_MQTT_PEX|/ID_123/XGH/EKG/PEX|
|From_MQTT_PEX2|/ID_123/XGH/EKG/PEX2|
|From_MQTT_PEX3|/ID_123/XGH/EKG/PEX3|
|From_MQTT_PEX4|/ID_123/XGH/EKG/PEX4|
|From_MQTT_PT|/ID_123/XGH/EKG/PT|
|MQTT.BS.PYAVRO|/ID_123/XGH/EKG/PY|

下記で、任意のメッセージを送信出来ますが、(当然ながら)AVROとしてデコードしようとしてエラーが発生します。
```
$ docker compose exec iris mosquitto_pub -h mqttbroker -p 1883 -t /ID_123/XGH/EKG/PT -m "anything"
```
必要に応じてサブスクライブ出来ます。
```
$ docker compose exec iris mosquitto_sub -v -h mqttbroker -p 1883 -t /ID_123/XGH/EKG/PT/#
```

## IRIS側のデータ

PEX3実行後のデータ。

```
$ docker compose exec iris iris sql iris -UINTEROP

SELECT ID,b.bytes
  FROM MQTT.SimpleClass as s,
       JSON_TABLE(s.myBytes, '$'
         COLUMNS (bytes BINARY path '*')
       ) as b
  WHERE ID=1

| ID | bytes |
| -- | -- |
| 1 | 1 |
| 1 | 2 |
| 1 | 3 |
| 1 | 4 |
| 1 | 5 |
| 1 | 6 |
| 1 | 7 |
| 1 | 8 |

SELECT ID,a.longs
  FROM MQTT.SimpleClass as s,
       JSON_TABLE(s.myArray, '$'
         COLUMNS (longs INTEGER path '*')
       ) as a
  WHERE ID=1

| ID | longs |
| -- | -- |
| 1 | 1 |
| 1 | 2 |
| 1 | 3 |
| 1 | 4 |
| 1 | 5 |
| 1 | 6 |
| 1 | 7 |
| 1 | 8 |

SELECT s.ID,b.bytes,a.longs
  FROM MQTT.SimpleClass as s,
       JSON_TABLE(s.myBytes, '$'
         COLUMNS (bytes BINARY path '*')
       ) as b,
       JSON_TABLE(s.myArray, '$'
         COLUMNS (longs INTEGER path '*')
       ) as a
       where ID=1

64行返ってくる(直積)。8行であってほしい。


SELECT * FROM MQTT.SimpleClass as s
| ID | myArray | myBool | myBytes | myDouble | myFloat | myInt | myLong | myString | seq | topic |
| -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |
| 1 | [1,2,3,4,5,6,7,8] | 1 | [1,2,3,4,5,6,7,8] | 3.1400000000000001243 | .0159000009298324585 | 1 | 2 | this is a 1st SimpleClass | 1 | /ID_123/XGH/EKG/PEX3 |
| 2 | [11,12,13,14,15,16,17,18] | 1 | [17,18,19,20,21,22,23,24] | 2.7099999999999999644 | .0159000009298324585 | 10 | 3 | this is a 2nd SimpleClass | 2 | /ID_123/XGH/EKG/PEX3 |
| 3 | [100,200,300,400,500,600,700,800] | 1 | [1,2,3,4,5,6,7,8] | 3.1400000000000001243 | .0159000009298324585 | 1 | 2 | this is a 1st SimpleClass | 3 | /ID_123/XGH/EKG/PEX3 |
| 4 | [900,1000,1100,1200,1300,1400,1500,1600] | 1 | [17,18,19,20,21,22,23,24] | 2.7099999999999999644 | .0159000009298324585 | 10 | 3 | this is a 2nd SimpleClass | 4 | /ID_123/XGH/EKG/PEX3 |

```

> 文字列化した配列から値を取り出良い方法が2024.1まで無かった。


## 送信用の(バイナリ)ファイルをエンコードする
バイナリファイルを下記で作成します。  
[BinaryEncoder.py](datavol/share/BinaryEncoder.py)はintの[配列](datavol/share/BinaryEncoder.avsc)がavroエンコードされたファイルを作成します。  
[SimpleClass-encoder.py](datavol/share/SimpleClass-encoder.py)は[record](datavol/share/SimpleClass.avsc)がavroエンコードされたファイルを作成します。  
[testdata.py](datavol/share/testdata.py)は単純なlong型の配列を様々なサイズで作成します(AVROは無関係)。

```
$ docker compose exec python bash
root@d20238018cbc:~# cd share/
root@d20238018cbc:~/share# python BinaryEncoder.py
root@d20238018cbc:~/share# python SimpleClassEncoder.py
root@d20238018cbc:~/share# python testdata.py
```

> 送信用の(バイナリ)ファイルをデコードする方法
```
root@d20238018cbc:~/share# python SimpleClassDecoder.py
```

# その他

## brokerのログ

```
docker compose exec mqttbroker tail -f /mosquitto/log/mosquitto.log
```

## MQTTクライアント機能を直接使用する方法
```
$ docker compose exec iris iris session iris
USER>set m=##class(%Net.MQTT.Client).%New("tcp://mqttbroker:1883")
USER>set tSC=m.Connect()
USER>set tSC=m.Subscribe("/ID_123/XGH/EKG/PT/#")
USER>set tSC=m.Receive(.topic,.message,10000)
USER>w topic
/ID_123/XGH/EKG/PT
USER>w message
90
USER>h
$
```

## PEXを使わずに.NETを呼び出す方法
```
$ docker compose exec iris iris session iris -U INTEROP
INTEROP>w $SYSTEM.external.getRemoteGateway("netgw",55556).new("System.DateTime",0).Now
2021-11-19 03:51:03.4967784

INTEROP>Set gw=$SYSTEM.external.getRemoteGateway("netgw",55556)
INTEROP>do gw.addToPath("/app/mylib1.dll")
INTEROP>set proxy = gw.new("dc.MyLibrary")
INTEROP>w proxy.GetNumber()
123
INTEROP>d proxy.XEPImport("dc.SimpleClass")
INTEROP>
```
Windows(非コンテナ環境)の場合も同様。事前にExternal Language Serverの%DotNet Serverを起動しておくこと。  
[SMP][システム管理][構成][接続性][External Language Servers]
```
USER>set gw=$SYSTEM.external.getRemoteGateway("localhost",53372)
USER>do gw.addToPath("C:\Users\irismeister\Source\repos\adonet\MyLibrary\bin\Release\MyLibrary.dll")
```
## Genericタイプ
ラッパー経由でのアクセスになります。
```
USER>set proxy = gw.new("dc.GenericList")
<THROW>%Constructor+25^%Net.Remote.Object.1 *%Net.Remote.Exception <GATEWAY> System.Exception InterSystems.Data.IRISClient.Gateway.Gateway.loadClass(String?className) Class not found: dc+GenericList
USER 4e1>q
USER>set proxy = gw.new("dc.GenericListWrapper")
USER>set l = proxy.GetIntList()
USER>d lint.Add(1)
1

USER>d lint.Add(2)
2
USER>set lstr = proxy.GetStringList()
USER>d lstr.Add("abc")
abc

USER>d lstr.Add("日本語")
日本語
```
## .NETアプリケーションの実行環境
```
$ docker compose exec netgw bash
root@f718a9177d25:/app# dotnet myapp.dll
もしくは
root@f718a9177d25:/app# ./myapp
```

> SDKは含まれないので、この環境ではbuildは出来ません。

## 単体実行用に.NETアプリケーションをビルドする環境

SDKが含まれています。
上記の.NETアプリケーション実行環境とは別の場所(donet-devコンテナ内)にデプロイされるので注意。

[SimpleClass.avsc](datavol/share/SimpleClass.avsc)を修正した場合、イメージビルド前に手作業でCSクラスを生成する必要がある。

[Apache.Avro.Tools](https://www.nuget.org/packages/Apache.Avro.Tools/)を使って、avro schemaからC#クラスを作成する。
```
$ docker compose exec dotnet-dev bash
root@aa9e6466578e:/source# ./gen-avro-cs.sh
```
生成されたCSは[SimpleClass.cs](netgw/mylib1/SimpleClass.cs)に出力される。

```
root@aa9e6466578e:/source# ./build.sh <== ごくシンプルなappの作成例
root@aa9e6466578e:/source# /app/ClassLibraryTest <== 同実行方法
Hello, World!
GetNumber():123
Establishing new connection.
    ・
    ・
    ・
root@aa9e6466578e:/source# ./build-netgw.sh <== netgwで使用するライブラリのビルド
root@aa9e6466578e:/source# /app/myapp <== 同実行方法
1
abc
dc.MyLibrary
106 bytes received.
Received ToString():dc.SimpleClass
Received GetType():dc.SimpleClass
Values read from EnsLib.MQTT.Message.
myString:this is a SimpleClass
myBytes: [1] [2] [3]
System.NullReferenceException: Object reference not set to an instance of an object.
   at InterSystems.Data.IRISClient.ADO.IRIS.CreateIRIS(IRISADOConnection conn)
   at dc.MyLibrary.DoSomethingNative(String mqtttopic, String mqttmsg) in /source/mylib1/MyLibrary.cs:line 36
Establishing new connection.
System.NullReferenceException: Object reference not set to an instance of an object.
   at InterSystems.Data.IRISClient.ADO.IRIS.CreateIRIS(IRISADOConnection conn)
   at dc.MyLibrary.DoSomethingSQL(String mqtttopic, String mqttmsg) in /source/mylib1/MyLibrary.cs:line 112
Establishing new connection.
Hit any key
root@aa9e6466578e:/source# dotnet /app/genavro.dll
Generating avro files.
2 objects found.
Class=System.String, Value=aaa
Class=System.String, Value=bbb
2 objects found.
Class=System.Single, Value=23.67
Class=System.Single, Value=22.78
5 objects found.
Class=System.Int32, Value=1
Class=System.Int32, Value=2
Class=System.Int32, Value=3
Class=System.Int32, Value=4
Class=System.Int32, Value=5
this is a ComplexClass
this is a SimpleClass
root@aa9e6466578e:/source# ls -l *.avro
-rw-r--r-- 1 root root 139 Dec 10 18:34 ComplexClass.avro
-rw-r--r-- 1 root root 106 Dec 10 18:34 SimpleClass.avro
```


## netgw環境からの実行方法

netgw/genavro/Program.csの実行
```
$ docker compose exec netgw /app/genavro
```

(参考) https://github.com/apache/avro.git


## 参考にしたコードサンプル
https://github.com/intersystems/Samples-PEX-Course

## mosquittoを自前でビルドする
ネット上のブローカmqtt.eclipseprojects.ioはwebsocketが有効になっているが、コンテナ提供されているイメージはwebsocketが無効化されている。そのままでは、[こちら](https://github.com/intersystems/Samples-MQTT-EKG-Devices)の簡易Webアプリ(ハートビートモニタ)は動作しない。

https://github.com/eclipse/mosquitto
> libwebsockets (libwebsockets-dev) - enable with make WITH_WEBSOCKETS=yes

```
sudo apt-get install build-essential libwebsockets-dev
git clone https://github.com/eclipse/mosquitto
cd mosquitto
make WITH_WEBSOCKETS=yes WITH_DOCS=no WITH_TLS=no WITH_CJSON=no
sudo make WITH_WEBSOCKETS=yes WITH_DOCS=no WITH_TLS=no WITH_CJSON=no install
ls /usr/local/sbin/ -l
total 2072
-rwxr-xr-x 1 root root 2120800 Nov 29 13:47 mosquitto
```

## irisとdotnet gatewayを同居させる場合
本例はdotnet gateway(コンテナnetgw)と、IRISを別のコンテナとして起動していますが、IRISに同居させることも可能です。その場合、Gatewayサーバの管理はIRISの管理下で行うのが便利です。

```
$ docker compose exec -u root iris bash
root@iris:/opt/irisbuild# apt update
root@iris:/opt/irisbuild# apt install -y dotnet6
root@iris:/opt/irisbuild# exit
```

.bashrcに修正を加え、いったんコンテナにログインし直した後、irisを再起動します。
```
$ docker compose exec iris bash
irisowner@iris:/opt/irisbuild$ echo "export DOTNET_ROOT=/usr/lib/dotnet" >> ~/.bashrc
irisowner@iris:/opt/irisbuild$ exec bash -l
irisowner@iris:/opt/irisbuild$ iris restart iris
irisowner@iris:/opt/irisbuild$ exit
```

Gatewayを利用します。IRIS管理下にあるGatewayは、API($system.external.getDotNetGateway())を利用時に自動起動します。
```
$ docker compose exec iris bash
irisowner@iris:/opt/irisbuild$ iris session iris
USER>w $system.external.getDotNetGateway().new("System.DateTime",0).Now
2022-12-12 06:38:36.3759392
USER>
```

## その他

### XEP
AVROのReflectReaderで期待されるc#クラスはset/getが必要な模様。無いと'Class SimpleClass doesnt contain property XXX'、というエラーになる。
```c#
    public int? myUInt { get; set; }
```
XEPはこのシンタックスを理解しない。具体的にはImportSchema()時のObjectScript側のクラスはこのような定義となる。
```ObjectScript
Property "<myUInt>k__BackingField" As %Library.Integer;
```
index定義の際は、この名称を使用する必要がある。また、SQLでのカラム値が冗長になる、メッセービューワで閲覧すると(XMLなので)<>内が表示されないという負の副作用を持つ。
```
[Index(name = "idx1", fields = new string[] { "<myLong>k__BackingField" }, type = IndexType.simple)]

```
別途、器となるクラスを用意して中身をCOPYしたほうが、健全かもしれない。  

### スキーマの変更への追随
XEPに限らないが、メッセージになるクラス(src/Solution/SimpleClass.cls)をコンパイルする際には、IRIS側のクラス(src/dc/SimpleClass.cls)が必要になる。そのため、既存メッセージが変更されたり、新しいメッセージが追加される際には、下記を動的に行う仕組みが必要となる。
- AVRO Schemaの変更を検知
- (Reflect用の) c# クラスの作成/変更
- 同c#クラスに対してのImportSchema()実行->IRIS側のクラス作成
- メッセージになるクラスの作成


https://qiita.com/akuroda/items/fd3efe9810e5fad9aec5