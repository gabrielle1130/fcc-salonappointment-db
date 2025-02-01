#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ My Salon ~~~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1" 
  fi

  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME Service"
  done

  read SERVICE_ID_SELECTED
  SERVICE_AVAILABILITY=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  
  if [[ -z $SERVICE_AVAILABILITY ]]
  then
    MAIN_MENU "I could not find that service. What would you like to do?"
    return
  fi

  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE 

  HAVE_CUST=$($PSQL "SELECT customer_id, name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $HAVE_CUST ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    INSERTED=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    CUST_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'") 
  else
    CUST_ID=$(echo "$HAVE_CUST" | awk '{print $1}')
    CUSTOMER_NAME=$(echo "$HAVE_CUST" | awk '{print substr($0, index($0,$2))}')
  fi

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED") 
  SERVICE_NAME_FORMATTED=$(echo "$SERVICE_NAME" | sed 's/\s//g' -E)
  CUSTOMER_NAME_FORMATTED=$(echo "$CUSTOMER_NAME" | sed 's/\s//g' -E)

  echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
  read SERVICE_TIME

  CREATE_APPOINTMENT
}

CREATE_APPOINTMENT(){
  INSERTED=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUST_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
}

MAIN_MENU
