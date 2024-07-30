#!/bin/bash

docker compose exec iris mosquitto_pub -h "mqttbroker" -p 1883 -t /XGH/EKG/ID_123/PT -f /home/irisowner/share/SimpleClass.avro
docker compose exec iris mosquitto_pub -h "mqttbroker" -p 1883 -t /XGH/EKG/ID_123/PEX -f /home/irisowner/share/SimpleClass.avro
docker compose exec iris mosquitto_pub -h "mqttbroker" -p 1883 -t /XGH/EKG/ID_123/PEX2 -f /home/irisowner/share/SimpleClass.avro
docker compose exec iris mosquitto_pub -h "mqttbroker" -p 1883 -t /XGH/EKG/ID_123/PEX3 -f /home/irisowner/share/SimpleClass.avro
docker compose exec iris mosquitto_pub -h "mqttbroker" -p 1883 -t /XGH/EKG/ID_123/PYAVRO -f /home/irisowner/share/SimpleClass.avro
