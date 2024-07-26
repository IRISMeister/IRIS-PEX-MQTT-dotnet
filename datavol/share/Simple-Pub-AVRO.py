from paho.mqtt import client as mqtt_client
from time import sleep

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("Connected to MQTT Broker!")
    else:
        print("Failed to connect, return code %d\n", rc)

def on_publish(client, userdata, mid):
  print("{0} ".format(mid), end=',')

if __name__ == '__main__':
    client = mqtt_client.Client(mqtt_client.CallbackAPIVersion.VERSION1,f'client_id')
    client.on_connect = on_connect
    client.on_publish = on_publish 
    client.connect("localhost")

    f = open('compare.avro', 'rb')
    byte_data = f.read()

    for i in range(0, 100, 1):
        client.publish("/ID_123/XGH/EKG/PY",byte_data)

    print()