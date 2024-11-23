#!/bin/bash

INSTANCE_IP=$1

# Проверка на пустое значение
if [ -z "$INSTANCE_IP" ]; then
  echo "Ошибка: IP адрес не был передан."
  exit 1
fi

# Simple HTTP server test
response=$(curl -s -o /dev/null -w "%{http_code}" http://$INSTANCE_IP:8080)
if [ "$response" -eq 200 ]; then
  echo "HTTP server is running. Test passed."
  exit 0
else
  echo "HTTP server test failed. Response code: $response"
  exit 1
fi
