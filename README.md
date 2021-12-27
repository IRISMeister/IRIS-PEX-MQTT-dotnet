# 環境
ご参考までに私の環境は以下の通りです。
|用途|O/S|ホストタイプ|IP|
|:--|:--|:--|:--|
|クライアントPC|Windows10 Pro|物理ホスト|192.168.11.5/24|
|Docker環境|Ubuntsu 20.04.1 LTS|上記Windows10上の仮想ホスト(vmware)|192.168.11.48/24|

Ubuntsuは、[ubuntu-20.04.1-live-server-amd64.iso](http://old-releases.ubuntu.com/releases/20.04.1/ubuntu-20.04.1-live-server-amd64.iso)を使用して、最低限のサーバ機能のみをインストールしました。

また、Windowsのhostsファイルに、irishostを登録しています。 
```
192.168.11.48 irishost
```

# 起動方法
```
$ git clone https://github.com/IRISMeister/Samples-MQTT-EKG-Devices.git
$ cd Samples-MQTT-EKG-Devices
$ ./setup.sh
$ docker-compose up -d
```
# 停止(削除)方法
```
$ docker-compose down
```

# MQTT受信用のビジネスサービスについて

|BS|送信先|備考|
|:--|:--|:--|
|From_MQTT_EXT|Process_MQTT|External Language明示使用。下記PEX利用を推奨|
|From_MQTT_PEX|Process_MQTT|PEX使用。配列を完全にリレーショナル化する例|
|From_MQTT_PEX2|Process_MQTT|PEX使用。シリアライズ(文字列化)した配列を使用、応答メッセージをIRISで作成する例|
|From_MQTT_PEX3|Process_MQTT|PEX使用。シリアライズ(文字列化)した配列を使用、応答メッセージをPEXで作成する例|
|From_MQTT_PT|Decode_MQTT_PEX|標準のPassThroughサービスを使用|

# データの送信方法
## コマンドライン
```
$ docker-compose exec iris mosquitto_pub -h "mqttbroker" -p 1883 -t /ID_123/XGH/EKG/PT -m "90"
```
上記コマンドを実行すると、From_MQTT_PTがMQTTメッセージを受信し、その後の処理が実行されます。

ただし、各BSは以下のTopicをSubscribeする設定になっています。
|受信するBS|Topic|
|:--|:--|
|From_MQTT_EXT|/ID_123/XGH/EKG/EXT|  
|From_MQTT_PEX|/ID_123/XGH/EKG/PEX|
|From_MQTT_PEX2|/ID_123/XGH/EKG/PEX2|
|From_MQTT_PEX3|/ID_123/XGH/EKG/PEX3|
|From_MQTT_PT|/ID_123/XGH/EKG/PT|



必要に応じてサブスクライブも可能です。
```
$ docker-compose exec iris mosquitto_sub -v -h "mqttbroker" -p 1883 -t /ID_123/XGH/EKG/PT/#
```

## (バイナリ)ファイルを送る方法
バイナリファイルを下記で作成します。
[BinaryEncoder.py](datavol/share/BinaryEncoder.py)はintの[配列](datavol/share/BinaryEncoder.avsc)がavroエンコードされたファイルを作成します。  
[SimpleClass-decoder.py](datavol/share/SimpleClass-decoder.py)は[record](datavol/share/SimpleClass.avsc)がavroエンコードされたファイルを作成します。  
[testdata.py](datavol/share/testdata.py)は単純なlong型の配列です。
```
$ docker-compose exec python bash
root@d20238018cbc:~# cd share/
root@d20238018cbc:~/share# python testdata.py
root@d20238018cbc:~/share# python BinaryEncoder.py
root@d20238018cbc:~/share# python SimpleClass-decoder.py
```

```
# mosquitto_pub -h "mqttbroker" -p 1883 -t /ID_123/XGH/EKG/PT -f /home/irisowner/share/SimpleClass.avro
```

# その他
## MQTTクライアント機能を直接使用する方法
```
$ docker-compose exec iris iris session iris
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
$ docker-compose exec iris iris session iris -U INTEROP
INTEROP>w $SYSTEM.external.getRemoteGateway("netgw",55556).new("System.DateTime",0).Now
2021-11-19 03:51:03.4967784

INTEROP>Set gw=$SYSTEM.external.getRemoteGateway("netgw",55556)
INTEROP>do gw.addToPath("/app/MyLibrary.dll")
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
## .NETアプリケーションを呼び出す方法
SDKは含まれないのでbuildは出来ません。
```
$ docker-compose exec netgw bash
root@f718a9177d25:/app# dotnet myapp.dll
```
## 単体実行用に.NETアプリケーションをビルド
SDKが含まれています。
上記の.NETアプリケーションとは別の場所(donet-devコンテナ内)にデプロイされるので注意。
```
$ docker-compose exec dotnet-dev bash
root@aa9e6466578e:/source# ./build.sh
root@aa9e6466578e:/source# dotnet /app/myapp.dll
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

avro schemaからC#クラスを作成。(dotnet31-dev使用時のみ)
```
root@80352f0c46d2:~#. dotnet/tools/avrogen -s /share/SimpleClass.avsc ./gen --namespace foo:foo
```

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


