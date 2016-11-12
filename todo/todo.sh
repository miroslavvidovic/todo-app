#!/usr/bin/env bash

# -------------------------------------------------------
# Info:
# 	Miroslav Vidovic
# 	todo.sh
# 	26.07.2016.-15:32:34
# -------------------------------------------------------
# Description:
#   Task application (todo app) made with sqlite
# Usage:
#
# -------------------------------------------------------
# Script:

# Colors
# Foregrounds
readonly RedText='\033[1;31m'
readonly GreenText='\033[1;32m'
readonly EndColor='\e[0m'
# Backgrounds
readonly RedBG='\e[101m'
readonly GrayBG='\e[100m'
readonly GreenBG='\e[42m'
readonly BlueBG='\e[44m'

database=../database/todo.sqlite
conf=../conf/.local_sqliterc

# Surround a variable with single quotes for db input
surround(){
  char=\'
  output=$char$1$char
  echo "$output"
}

# Insert a task to the sqlite database using a zenity form
insert_with_zenity(){
  # Show the form
  OUTPUT=$(zenity --forms --title="Add a new task"\
                  --text="Enter task details"\
                  --separator=","\
                  --add-entry="Title"\
                  --add-entry="Description"\
                  --add-calendar="Due date"\
                  --add-entry="Tags"
                  )
  accepted=$?
  if ((accepted != 0)); then
      echo "something went wrong"
      exit 1
  fi

  # Get the data from the form
  title=$(awk -F, '{print $1}' <<<$OUTPUT)
  description=$(awk -F, '{print $2}' <<<$OUTPUT)
  due_date=$(awk -F, '{print $3}' <<<$OUTPUT)
  tags=$(awk -F, '{print $4}' <<<$OUTPUT)

  # Add fixed data
  # created_date is today and completed is 0 (false)
  created_date=$(date +%d.%m.%Y.)
  completed=0

  # Surround the string data with single quotes
  due_date=$(surround "$due_date")
  title=$(surround "$title")
  description=$(surround "$description")
  tags=$(surround "$tags")
  created_date=$(surround "$created_date")

  # Save the data to the database
  sqlite3 $database "insert into tasks (title, description, created_date, due_date, completed, tags)
                      values ($title, $description, $created_date, $due_date, $completed, $tags)"
}

# TODO: add input checking
# Set a task as completed
# @param $1 - id
set_completed(){
  id=$1
  sqlite3 $database "update tasks set completed=1 where id=$id"
  echo "Task $1 marked as completed."
}

# Update a task
update(){
  sqlite3 $database "update tasks set title=$title, description=$description, created_date=$created_date,
                     due_date=$due_date, completed=$completed, tags=$tags where id=$id)"
}

# Delete a task
# @param $1 - id
delete_task(){
  id=$1
  sqlite3 $database "DELETE FROM tasks WHERE id=$id"

  echo "Task $1 deleted."
}

# Select one task from the db
# Detailed view
# @param $1 - id
select_one_task(){
  id=$1
  data=$(sqlite3 $database "select * from tasks where id=$id")

  # Split the string of data using a | as a delimiter and store data in an array
  IFS='|' read -r -a array <<< "$data"

cat <<EOF
  ID:         ${array[0]}
  TITLE:      ${array[1]}
  DESC:       ${array[2]}
  CREATED:    ${array[3]}
  DUE DATE:   ${array[4]}
  TAGS:       ${array[6]}
  COMPLETED:  ${array[5]}
EOF
}

# Select all active tasks from the database
select_all_active(){
  data=$(sqlite3 -init $conf $database "select id, title, created_date, due_date, tags  from tasks where completed = 0" 2>/dev/null)

  printf "\n\n ACTIVE TASKS \n\n"
  printf "$RedText %s $EndColor  \n\n" "$data"
}

# Show completed tasks
select_all_completed(){
  # 2>/dev/null suppress the message about the init conf file usage
  data=$(sqlite3 -init $conf $database "select id, title, created_date, due_date, tags  from tasks where completed = 1" 2>/dev/null)

  printf "\n\n COMPLETED TASKS \n\n"
  printf "$GreenText %s $EndColor  \n\n" "$data"
}

# Send a task to Google calendar
google_calendar(){
  due_date=${array[4]}
  title=${array[1]}
  day=$(echo "$due_date" | cut -d "." -f 1 | tr "'" " ")
  month=$(echo "$due_date" | cut -d "." -f 2)
  gcalcli --calendar 'vidovic.miroslav.vm@gmail.com' quick "$title at 12:00 $month/$day"
}

# Show help for the user
help(){
  cat<< heredoc
  Todo app - task manager

  Usage : $(basename $0) [options]

  Options:
    -a         Display all active tasks
    -c id      Mark a task with selected "id" as completed
    -d id      Delete a task with "id"
    -f         Display all finished tasks
    -g id      Send a task with "id" to Google calendar - requires gcalcli
    -n         Insert a new task via a Zenity form
    -h         Display this help message  
    -t id      Display details for task with "id"
heredoc
}

# Check if the user did not specify any flags when calling the script
# example: bash todo.sh was called
# and show help
check_for_empty_input(){
  if [ $# -eq 0 ];
  then
      help
      exit 0
    fi
}

# Main program
main(){
  while getopts 'ac:d:fg:hnt:' flag; do
    case "${flag}" in
      # Select all active tasks
      a)
        select_all_active
        ;;
      # Mark a task as completed
      c)
        id=${OPTARG}
        set_completed "$id"
        ;;
      # Delete a task from the database
      d)
        id=${OPTARG}
        delete_task "$id"
        ;;
      # Show all completed(finished) tasks
      f)
        select_all_completed
        ;;
      # Send a task to google calendar
      g)
        id=${OPTARG}
        select_one_task "$id"
        google_calendar
        ;;
      # Add a new task form a zenity form
      n)
        insert_with_zenity
        ;;
      h)
        help
        ;;
      t)
        id=${OPTARG}
        select_one_task "$id"
        ;;
      *) error "Unexpected option ${flag}" ;;
    esac
  done
}

check_for_empty_input "$@"
main "$@"

exit 0
