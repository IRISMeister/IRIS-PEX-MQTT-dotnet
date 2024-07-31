from paho.mqtt import client as mqtt_client
from time import sleep

def on_publish(client, userdata, mid, reason_codes, properties):
  print("{0} ".format(mid), end=',')

if __name__ == '__main__':
  import sys
  args = sys.argv
  client = mqtt_client.Client(mqtt_client.CallbackAPIVersion.VERSION2,f'python_client',protocol=mqtt_client.MQTTv311)
  client.on_publish = on_publish 
  client.connect("localhost")

  f = open('compare.avro', 'rb')
  byte_data = f.read()

  client.loop_start()

  if 3 <= len(args):
    target=args[2]
  else:
    target='PYAVRO'

  if 2 <= len(args):
    if args[1].isdigit():
      for seq in range (0,int(args[1])):
        msginfo=client.publish("/XGH/EKG/ID_123/"+target+"/"+str(seq),byte_data,1)
  else:
    msginfo=client.publish("/XGH/EKG/ID_123/"+target+"/1",byte_data)

  client.loop_stop()

  print()