#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

# Ensure services table has at least three services
$PSQL "INSERT INTO services(service_id, name) VALUES (1, 'Cut') ON CONFLICT (service_id) DO NOTHING;"
$PSQL "INSERT INTO services(service_id, name) VALUES (2, 'Color') ON CONFLICT (service_id) DO NOTHING;"
$PSQL "INSERT INTO services(service_id, name) VALUES (3, 'Wash') ON CONFLICT (service_id) DO NOTHING;"

# Function to display available services
function show_services {
  echo -e "\nAvailable services:" 
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME; do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

# Get valid service selection
while true; do
  show_services
  echo -e "\nEnter the service ID you want:"
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -n "$SERVICE_NAME" ]]; then
    break
  else
    echo -e "\nInvalid service. Please select again."
  fi
done

# Get customer details
echo -e "\nEnter your phone number:"
read CUSTOMER_PHONE
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

if [[ -z "$CUSTOMER_NAME" ]]; then
  echo -e "\nYou are a new customer. Enter your name:"
  read CUSTOMER_NAME
  $PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE');"
fi

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

echo -e "\nEnter the appointment time:"
read SERVICE_TIME

$PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');"

echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
