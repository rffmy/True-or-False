#!/usr/bin/env bash

RANDOM=4096
CHEERS=("Perfect!" "Awesome!" "You are a genius!" "Wow!" "Wonderful!")

CREDS=$(curl -s "http://0.0.0.0:8000/download/file.txt")
U=$(grep -Po '"username":\s*"\K[^"]+' <<< $CREDS)
P=$(grep -Po '"password":\s*"\K[^"]+' <<< $CREDS)
# https://linuxize.com/post/bash-redirect-stderr-stdout/
curl http://0.0.0.0:8000/login --user "$U:$P" --silent --cookie-jar cookie.txt &> /dev/null

get_question() {
  curl http://0.0.0.0:8000/game --silent --cookie cookie.txt
}

random_cheers() {
    # https://www.linux.com/topic/desktop/all-about-curly-braces-bash/
    echo "${CHEERS[$((RANDOM % ${#CHEERS[@]}))]}"
}

play() {
    local name question answer score
    echo "What is your name?" && read name
    score=0
    while true; do
        question=$(get_question)
        answer=$(grep -Po '"answer":\s*"\K[^"]+' <<< $question)
        grep -Po '"question":\s*"\K[^"]+' <<< $question
        echo "True or False?" && read
        if [[ $REPLY = $answer ]]; then
            random_cheers
            let score++
        else
            echo "Wrong answer, sorry!"
            echo "$name you have $score correct answer(s)."
            echo "Your score is $((score * 10)) points."
            save_scores $name $((score * 10))
            break
        fi
    done
}

save_scores() {
    #Save the player's score in the scores.txt file;
    #Use the format User: hyper, Score: 20, Date: 2022-04-23 
    #and add each new score line to the end of the score file;
    echo "User: $1, Score: $2, Date: $(date +%Y-%m-%d)" >> scores.txt
}

display_scores() {
    if [ -s scores.txt ]; then
        echo "Player scores"
        cat scores.txt
    else
        echo "File not found or no scores in it!"
    fi
}

reset_scores() {
    if [ -s scores.txt ]; then
        rm scores.txt
        echo "File deleted successfully!"
    else
        echo "File not found or no scores in it!"
    fi  
}

echo "Welcome to the True or False Game!"
while true; do
  echo """
0. Exit
1. Play a game
2. Display scores
3. Reset scores
Enter an option:""" && read
  case $REPLY in
    "0" ) echo "See you later!"; break;;
    "1" ) play;;
    "2" ) display_scores;;
    "3" ) reset_scores;;
     *  ) echo "Invalid option!";;
  esac
done
