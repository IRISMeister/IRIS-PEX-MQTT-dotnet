#!/bin/bash
docker compose up -d
echo "SMP http://localhost:8882/csp/sys/%25CSP.Portal.Home.zen"
echo "see send.sh to send mqtt data"
