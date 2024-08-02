from paho.mqtt import client as mqtt_client
from time import sleep
import PubUtil as u

def on_publish(client, userdata, mid, reason_codes, properties):
  print("{0} ".format(mid), end=',')

if __name__ == '__main__':
  import sys
  args = sys.argv
  client = mqtt_client.Client(mqtt_client.CallbackAPIVersion.VERSION2,f'python_client',protocol=mqtt_client.MQTTv311)
  #client.on_publish = on_publish 
  client.connect("localhost")

  f = open('compare.json', 'rb')
  byte_data = f.read()
  # delete all records
  u.reset()

  client.loop_start()

  if 2 <= len(args):
    if args[1].isdigit():
      data_count=int(args[1])
      for seq in range (0,data_count):
        msginfo=client.publish("/XGH/EKG/ID_123/PYJSON/"+str(seq),byte_data,1)
  else:
    msginfo=client.publish("/XGH/EKG/ID_123/PYJSON/1",byte_data)
    data_count=1

  client.loop_stop()

  # 非同期なので、完了をループで待つ。
  # measure
  wait=10
  sleep(wait)
  json=u.measure()
  while json['Count'] < data_count:
    json=u.measure()
    sleep(wait)
  print(str(json['SQLCODE'])+","+str(json['Count'])+","+str(json['Diff']))
