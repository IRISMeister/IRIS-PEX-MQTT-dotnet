例えば、どういうことをしたいのかの全貌。

AVROとは
wikipedia, 
https://github.com/intersystems-community/irisdemo-demo-kafka How does the Demo uses AVRO and AVRO Schemas
多言語対応

MQTTについて
多言語対応

IRISについて
多言語対応

つまり、組み合わせは自在

|MQTTクライアント|AVROデコード|DBへの保存|形式|備考|
|:--|:--|:--|:--|:--|
|java/c#など| java/c#など| JDBC/ADO経由| IRISは単なるRDBMS|互換性最大|
|IRIS| c#/Java(PEX) | IRIS Native API経由 | c#は別サーバでも実行可能|c#/Javaの手持ちのライブラリの活用|
|IRIS| c#/Java(PEX) | IRIS上で実行 | AVROデコードのみc#/Javaで実行する方法|処理が冗長な分オーバヘッドが大きい|
|IRIS| Python(埋め込み) | IRIS上で実行 | 簡潔 |


今回はc# と Pythonを選択
c#のメリットは、AVROの定義からc#クラスを生成してくれるツールが存在すること。入力支援が有効。
Pythonのメリットは、ダイナミックであること。埋め込みPythonが使えること。

javaの例
https://github.com/intersystems-community/irisdemo-demo-kafka
かなりボリュームがある。Spring Framework使用の本格的なjavaサーバを使用。


Windowsでの飛ばし方
"\Program Files"\mosquitto\mosquitto_pub -h localhost -p 1883 -t /ID_123/XGH/EKG/PY -f C:\git\IRIS-PEX-MQTT-dotnet\datavol\share\SimpleClass.avro


# いろいろ
## python
- 埋め込みpythonのpyの配置場所
- バイナリの渡し方
- __main__の勧め(デバッグしやすい)

## Production

BSだけのProductionもOK。大量レコードの処理時にはメッセージは不向き。1000件/秒で発生するようなメッセージをメッセージビューワで閲覧、目検でデバッグするのは非現実的。


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


```

CREATE TABLE Senators ( person VARCHAR(1000),
                        extra VARCHAR (1000),
                        state VARCHAR(2) )

INSERT INTO Senators ( person, extra, state ) 
SELECT person,extra, state
    FROM JSON_TABLE(%Net.GetJson('https://www.govtrack.us/api/v2/role?current=true&role_type=senator','{"SSLConfiguration":"ISC.FeatureTracker.SSL.Config"}'),
  '$.content.objects'
      COLUMNS ( person VARCHAR(100) PATH '$.person',
                extra VARCHAR(100) PATH '$.extra',
                state VARCHAR(50) PATH '$.state'
      )
    )

SELECT jtp.name, state, jtp.birth_date, jte.address
  FROM Senators as Sen,
       JSON_TABLE(Sen.person, '$'
         COLUMNS ( name VARCHAR(60) path '$.sortname',
                   birth_date VARCHAR(10) path '$.birthday'
         )
       ) as jtp,
       JSON_TABLE(Sen.extra, '$'
         COLUMNS ( address VARCHAR(100) path '$.address' )
       ) as jte
       
100行 <== なぜ100*100行にならない？ Literal Joinだから？

SELECT jtp.name, state, jtp.birth_date
  FROM Senators as Sen,
       JSON_TABLE(Sen.person, '$'
         COLUMNS ( name VARCHAR(60) path '$.sortname',
                   birth_date VARCHAR(10) path '$.birthday'
         )
       ) as jtp
100行

SELECT state,  jte.address
  FROM Senators as Sen,
       JSON_TABLE(Sen.extra, '$'
         COLUMNS ( address VARCHAR(100) path '$.address' )
       ) as jte
100行
```