#!/bin/sh


# Insert a task
# $1 data -> Task description, 22.03.2017., Project name
insert_task(){
  data="$1"

  # Get the data from the input
  description=$(echo $data | awk -F, '{print $1}')
  due_date=$(echo $data | awk -F, '{print $2}')
  project=$(echo $data | awk -F, '{print $3}')

  # Add fixed data
  # created_date is today and completed is 0 (false)
  created_date=$(date +%d.%m.%Y.)
  completed=0

  # Surround the string data with single quotes
  due_date=$(surround "$due_date")
  description=$(surround "$description")
  project=$(surround "$project")
  created_date=$(surround "$created_date")

  database_insert $description $created_date $due_date $completed $project

  echo  "Task $description $created_date $due_date $completed $project saved."
}

# Update a task
# $1 data -> ID, Task description, 22.03.2017., Project name
update_task(){
  data="$1"

  # Get the data from the input
  id=$(echo $data | awk -F, '{print $1}')
  description=$(echo $data | awk -F, '{print $2}')
  due_date=$(echo $data | awk -F, '{print $3}')
  project=$(echo $data | awk -F, '{print $4}')

  # Add fixed data
  # created_date is today and completed is 0 (false)
  created_date=$(date +%d.%m.%Y.)
  completed=0

  # Surround the string data with single quotes
  due_date=$(surround "$due_date")
  description=$(surround "$description")
  project=$(surround "$project")
  created_date=$(surround "$created_date")

  database_update $id $description $created_date $due_date $completed $project

  echo  "Task $id updated."
}

# Select all active tasks
# Creates a global DATA array for the zenity list
select_all_active(){
  declare -ga DATA_ACTIVE=()

  # creates a global all_tasks_array
  database_select_all 

  for item in "${all_tasks_array[@]}"
  do
    IFS='|' array=($item)
    # If task is active add it to options
    if [[ ${array[5]} == 0 ]]; then
      DATA_ACTIVE+=(${array[0]} "${array[2]}" "${array[1]}" "${array[4]}" "active")
    fi
  done

  unset all_tasks_array
}

# Select all completed tasks
# Creates a global DATA array for the zenity list
select_all_completed(){
  declare -ga DATA_COMPLETED=()

  # creates a global all_tasks_array
  database_select_all 

  for item in "${all_tasks_array[@]}"
  do
    IFS='|' array=($item)
    # If task is active add it to options
    if [[ ${array[5]} == 1 ]]; then
      DATA_COMPLETED+=(${array[0]} "${array[2]}" "${array[1]}" "${array[4]}" "completed")
    fi
  done

  unset all_tasks_array
}

# Delete a task
# $1 - id
delete_task(){
  id="$1"
  database_delete "$id"
  echo "Task $1 deleted."
}

# Change the task status to completed
# $1 - task id
complete_task(){
  id="$1"
  database_complete "$id"
  echo "Task $id updated to completed."
}

# One task detailed view
# @param $1 - id
select_one_task(){
  id="$1"
  database_select_one "$id"
}
