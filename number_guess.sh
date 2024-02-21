#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=guessing_game -t --no-align -c"

GEN_NUMBER=$(($RANDOM % 1001 ))

echo -e "\n~~~~Number Guessing Game~~~\n"
echo -e "\nEnter your username:"
read USERNAME

USER_RETURN=$($PSQL "Select username from users where username = '$USERNAME'")

if [[ -z $USER_RETURN ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    RECORD_USER=$($PSQL "Insert into users(username) VALUES('$USERNAME')")
  else
    GAMES_PLAYED=$($PSQL "Select games_played from users where username = '$USERNAME'")
    BEST_GAME=$($PSQL "Select best_game from users where username = '$USERNAME'")

    echo "Welcome back, $USER_RETURN! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo -e "\nGuess the secret number between 1 and 1000:"
read GUESS

COUNT=1

  while [ "$GEN_NUMBER" != "$GUESS" ]
  do
    #COUNT=$(( $COUNT + 1 ))
    if [[ ! "$GUESS" =~ ^[0-9]+$ ]]
      then
        echo "That is not an integer, guess again:"
        read GUESS
        COUNT=$(( $COUNT - 1 ))
    elif [[ "$GUESS" -lt "$GEN_NUMBER" ]]
      then
        echo -e "\nIt's higher than that, guess again:"
        read GUESS
        COUNT=$(( $COUNT + 1 ))
    elif [[ "$GUESS" -gt "$GEN_NUMBER" ]]
      then
        echo -e "\nIt's lower than that, guess again:"
        read GUESS
        COUNT=$(( $COUNT + 1 ))
    fi
  done

if [[ $GEN_NUMBER = $GUESS ]]
then
  #echo -e "\nYou guessed it in $COUNT tries. The secret number was $GEN_NUMBER. Nice job!"
  GAME_UPDATE=$($PSQL "Update users set games_played = (games_played + 1) where username = '$USERNAME'")
  if [[ -z $USER_RETURN ]]
    then
      BEST_UPDATE=$($PSQL "Update users set best_game = '$COUNT' Where username = '$USERNAME'")
  elif [[ $COUNT -lt $BEST_GAME ]]
    then
      BEST_UPDATE=$($PSQL "Update users set best_game = '$COUNT' Where username = '$USERNAME'")
  fi
  echo "You guessed it in $COUNT tries. The secret number was $GEN_NUMBER. Nice job!"
fi
