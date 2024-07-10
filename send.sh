#!/bin/bash

docker compose exec iris mosquitto_pub -h "mqttbroker" -p 1883 -t /ID_123/XGH/EKG/PT -f /home/irisowner/share/SimpleClass.avro
docker compose exec iris mosquitto_pub -h "mqttbroker" -p 1883 -t /ID_123/XGH/EKG/PEX -f /home/irisowner/share/SimpleClass.avro
docker compose exec iris mosquitto_pub -h "mqttbroker" -p 1883 -t /ID_123/XGH/EKG/PEX2 -f /home/irisowner/share/SimpleClass.avro
docker compose exec iris mosquitto_pub -h "mqttbroker" -p 1883 -t /ID_123/XGH/EKG/PEX3 -f /home/irisowner/share/SimpleClass.avro
