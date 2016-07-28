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

DateCreated=`date +%d.%m.%Y.`
Id=""
Name=""
Description=""
Tags=""
StartDate="undefined"
EndDate="undefined"
Status="active"

# Colors
# Text colors
RedText='\033[1;31m'
GreenText='\033[1;32m'
EndColor='\e[0m'
# Backgrounds
RedBG='\e[101m'
GrayBG='\e[100m'
GreenBG='\e[42m'
BlueBG='\e[44m'


database=~/Projekti/Bash/Sqlite_todo/todo.sqlite
conf=~/Projekti/Bash/Sqlite_todo/.local_sqliterc

# Surround a variable with single quotes for db input
surround(){
  char=\'
  output=$char$1$char
  echo $output
}

# Insert a task to the sqlit database
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

set_completed(){
  exit 0
}

update(){
  sqlite3 $database "update tasks set title=$title, description=$description, created_date=$created_date,
                     due_date=$due_date,completed=$completed, tags=$tags WHERE id=$id)"
}

delete(){
  exit 0
}
select_one(){
  exit 0
}

select_all_active(){
  data=$(sqlite3 -init $conf $database "select id, title, created_date, due_date, tags  from tasks where completed = 0")
  printf "$RedText $data $EndColor  \n\n"
}

help(){
  echo "some help"
}

# Check if the user did not specify any flags when calling the script
# example: bash tpad.sh was called
check_for_empty_input(){
  if [ $# -eq 0 ];
  then
      help
      exit 0
    fi
}

main(){
  #zenity_insert
  #select_all_active
  while getopts 'acd:m:nt:h' flag; do
    case "${flag}" in
      a)
        select_all_active
        ;;
      c)
        show_table_data
        ;;
      d)
        Id=${OPTARG}
        delete_one_line $Id
        ;;
      n)
        insert_with_zenity
        ;;
      m)
        Id=${OPTARG}
        modify_one_line $Id
        ;;
      t)
        Id=${OPTARG}
        echo "Get task with id $Id"
        select_one_line $Id
        ;;
      h)
        help
        ;;
      *) error "Unexpected option ${flag}" ;;
    esac
  done
}

check_for_empty_input "$@"
main "$@"

exit 0
