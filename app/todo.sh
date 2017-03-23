#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Info:
#   author:    Miroslav Vidovic
#   file:      todo.sh
#   created:   26.07.2016.-15:32:34
#   revision:  22.03.2016.
#   version:   1.1
# -----------------------------------------------------------------------------
# Requirements:
#   sqlite3, zenity
# Description:
#   Task application (todo app) made with sqlite
# Usage:
#   todo.sh
#
# -----------------------------------------------------------------------------
# Script:

# Includes
source ./functions/colors.sh
source ./functions/sqlite-queries.sh
source ./functions/task.sh
source ./functions/zenity-guis.sh
source ./functions/helpers.sh

# Path to database
database=../database/todo.sqlite

# Show help for the user
help(){
  cat<< heredoc
  Todo app - task manager

  Usage : $(basename "$0") [options]

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

main(){
  while getopts 'ac:d:fg:hnt:' flag; do
    case "${flag}" in
      a)
        # Select all active tasks
        select_all_active
        ;;
      c)
        # Mark a task as completed
        id=${OPTARG}
        complete_task "$id"
        ;;
      d)
        # Delete a task from the database
        id=${OPTARG}
        delete_task "$id"
        ;;
      f)
        # Show all completed(finished) tasks
        select_all_completed
        ;;
      g)
      # Send a task to google calendar
        id=${OPTARG}
        select_one_task "$id"
        google_calendar
        ;;
      n)
        # Add a new task form a zenity form
        # Get the data from the form
        data=$(insert_form)
        # Save the task
        insert_task $data
        ;;
      h)
        help
        ;;
      t)
        # One task detailed view
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
