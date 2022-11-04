#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ Salon appointment scheduler ~~~~~\n"

MAIN_MENU(){
  if [[ ! -z $1 ]]
  then 
    echo -e "\n$1"
  fi
  
  # get the services list
  # display them in #) <service> format
  echo "services we offer:"
  echo "$($PSQL "SELECT * FROM services")" | sed 's/ *//; s/ |/)/'
  
  echo -e "\nEnter the id of haircut that you want:"
  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in 
  1 | 2 | 3 | 4 | 5 | 6 | 7) EXECUTE_CODE ;;
  *) MAIN_MENU "we don't have that service."
  esac
  
}
EXECUTE_CODE(){
  echo -e "Enter your phone number:"
  read CUSTOMER_PHONE

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  echo $CUSTOMER_ID
  # if phone number not exists
  if [[ -z $CUSTOMER_ID ]]
  then
    # ask customer name
    echo -e "Enter your name:"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    # get custmer id
    GET_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name = '$CUSTOMER_NAME'")
    ASK_SERVICE_TIME

    # get appointment result
    GET_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, name, time) VALUES($GET_CUSTOMER_ID, $SERVICE_ID_SELECTED, '$CUSTOMER_NAME', '$SERVICE_TIME')")
    SHOW_MESSAGE
  
    # phone number exists
  else
    ASK_SERVICE_TIME

    # get customer name
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id='$CUSTOMER_ID'")

    # register the customer id, service id, name, time in appointments table
    GET_INSERT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, name, time) VALUES( $CUSTOMER_ID, $SERVICE_ID_SELECTED, '$CUSTOMER_NAME', '$SERVICE_TIME')")
    SHOW_MESSAGE
  fi
}
ASK_SERVICE_TIME(){
  echo -e "\nEnter your service time:"
  read SERVICE_TIME
}

SHOW_MESSAGE(){
  SERVICE=$($PSQL "SELECT name FROM services WHERE service_id ='$SERVICE_ID_SELECTED'")
  echo I have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME.
}
MAIN_MENU

