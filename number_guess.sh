#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

USERNAME_INPUT=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")
GAME_PLAY_COUNT=$($PSQL "SELECT COUNT(*) FROM users INNER JOIN games USING(user_id) WHERE username = '$USERNAME'")
BEST_SCORE=$($PSQL "SELECT MIN(number_guess) FROM users INNER JOIN games USING(user_id) WHERE username = '$USERNAME'")

if [[ -z $USERNAME_INPUT ]]
then
  INSERT_USERNAME=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  echo "Welcome back, $USERNAME! You have played $GAME_PLAY_COUNT games, and your best game took $BEST_SCORE guesses."
fi

RANDOM_NUMBER=$((1 + $RANDOM % 1000))
GUESS_COUNT=1
echo "Guess the secret number between 1 and 1000:"

while read NUMBER
do
  if [[ ! $NUMBER =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    if [[ $NUMBER -eq $RANDOM_NUMBER ]]
    then
      break;
    else
      if [[ $NUMBER -gt $RANDOM_NUMBER ]]
      then
        echo "It's lower than that, guess again:"
      elif [[ $NUMBER -lt $RANDOM_NUMBER ]]
      then
        echo "It's higher than that, guess again:"
      fi
    fi
  fi
  GUESS_COUNT=$(( $GUESS_COUNT + 1 ))
done

echo "You guessed it in $GUESS_COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
INSERT_GAME=$($PSQL "INSERT INTO games(number_guess, user_id) VALUES($GUESS_COUNT, $USER_ID)")
