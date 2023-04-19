#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"


PRINT_ELEMENT() {
  IFS=" | " read ATOMIC_NUMBER SYMBOL NAME <<< "$ELEMENT"
  IFS=" | " read ATOMIC_NUMBER_PROPERTIES ATOMIC_MASS MELTING_POINT BOILING_POINT TYPE_ID<<< "$PROPERTIES"
  TYPE=$($PSQL "SELECT type FROM types WHERE type_id = $TYPE_ID ")
  echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a$TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
}

# if there are no argument
if [ $# -eq 0 ] 
then
  echo "Please provide an element as an argument."
# if argument is number
elif [[ $1 =~ ^[0-9]+$ ]]
then
  ELEMENT=$($PSQL "SELECT atomic_number,symbol,name FROM elements WHERE atomic_number = $1")
  if [[ -z $ELEMENT ]] 
  then
    echo "I could not find that element in the database."
  else
    PROPERTIES=$($PSQL "SELECT atomic_number,atomic_mass,melting_point_celsius,boiling_point_celsius,type_id FROM properties WHERE atomic_number = $1")
    PRINT_ELEMENT
  fi 
# if argument is less than 4 letter / symbol
elif [ $# -eq 1 ] && [ -n "$1" ] && [ $(expr length "$1") -lt 4 ] 
then
  ELEMENT=$($PSQL "SELECT atomic_number,symbol,name FROM elements WHERE symbol = '$1'")
  if [[ -z $ELEMENT ]] 
  then
    echo "I could not find that element in the database."
  else
    ATOMIC_NUMBER_FOR_IDENTIFICATION=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$1'")
    PROPERTIES=$($PSQL "SELECT atomic_number,atomic_mass,melting_point_celsius,boiling_point_celsius,type_id FROM properties WHERE atomic_number = '$ATOMIC_NUMBER_FOR_IDENTIFICATION'")
    PRINT_ELEMENT
  fi
# if argument is a word
else
  ELEMENT=$($PSQL "SELECT atomic_number,symbol,name FROM elements WHERE name = '$1'")
  if [[ -z $ELEMENT ]] 
  then
    echo "I could not find that element in the database."
  else
    ATOMIC_NUMBER_FOR_IDENTIFICATION=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$1'")
    PROPERTIES=$($PSQL "SELECT atomic_number,atomic_mass,melting_point_celsius,boiling_point_celsius,type_id FROM properties WHERE atomic_number = '$ATOMIC_NUMBER_FOR_IDENTIFICATION'")
    PRINT_ELEMENT
  fi
fi