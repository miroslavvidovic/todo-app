#!/bin/sh

database=../database/todo.sqlite

# Insert function
# @param $1 - description
# @param $2 - created_date
# @param $3 - due_date
# @param $4 - completed_date
# @param $5 - project
database_insert(){
  # Save the data to the database
  sqlite3 $database "insert into tasks (description, created_date, due_date, completed, project)
                       values ($1, $2, $3, $4, $5)"
}

# Update function
database_update(){
  sqlite3 $database "update tasks set description=$description, created_date=$created_date,
                     due_date=$due_date, completed=$completed, project=$project where id=$id"
}

# Update completed field to 1
# @param $1 - id
database_task_completed(){
  sqlite3 $database "update tasks set completed=1 where id=$1"
}

# Delete a task
# @param $1 - id
database_task_delete(){
  sqlite3 $database "DELETE FROM tasks WHERE id=$1"
}

database_task_select_one() {
  data=$(sqlite3 $database "select * from tasks where id=$id")
  echo $data
}

database_select_all() {
  declare -ga data_array
  if [[ $1 == 1 ]]; then
    data_array=($(sqlite3 $database "select id, description, created_date, due_date, project from tasks where completed = 1"))
  else
    data_array=($(sqlite3 $database "select id, description, created_date, due_date, project from tasks where completed = 0"))
  fi
}

