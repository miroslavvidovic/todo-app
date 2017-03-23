#!/bin/sh

# Insert function
# $1 - description
# $2 - created_date
# $3 - due_date
# $4 - completed_date
# $5 - project
database_insert(){
  sqlite3 $database "insert into tasks (description, created_date, due_date, completed, project)
                       values ($1, $2, $3, $4, $5)"
}

# Update function
# $1 - id
# $2 - description
# $3 - created_date
# $4 - due_date
# $5 - completed_date
# $6 - project
database_update(){
  sqlite3 $database "update tasks set description=$2, created_date=$3,
                     due_date=$4, completed=$5, project=$6 where id=$1"
}

# Update completed field to 1
# $1 - id
database_complete(){
  sqlite3 $database "update tasks set completed=1 where id=$1"
}

# Delete a task
# $1 - id
database_delete(){
  sqlite3 $database "DELETE FROM tasks WHERE id=$1"
}

# Select one task
# $1 - id
# creates a global array - one_task_array
database_select_one() {
  IFS='|'
  declare -ga one_task_array
  one_task_array=($(sqlite3 $database "select * from tasks where id=$1"))
}

# Select all tasks
# creates a global array - all_tasks_array
database_select_all() {
  # array separator
  IFS=$'\n'
  declare -ga all_tasks_array
  all_tasks_array=($(sqlite3 $database "select id, description, created_date, due_date, project, completed from tasks"))
}
