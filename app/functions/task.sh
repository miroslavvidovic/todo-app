# @param $1 data -> Task description, 22.03.2017., Project name
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
}

# @param $1 - task id
complete_task(){
  id="$1"
  database_task_completed "$id"
  echo "Task $id marked as completed."
}

# Delete a task
# @param $1 - id
delete_task(){
  id=$1
  database_task_delete "$id"
  echo "Task $1 deleted."
}

# One task detailed view
# @param $1 - id
select_one_task(){
  id=$1

  data=$(database_task_select_one)

  # Split the string of data using a | as a delimiter and store data in an array
  IFS='|' read -r -a array <<< "$data"

cat <<EOF
  $BOLD Task ID:           ${array[0]} $RESET
  $FG_GREEN Description:$RESET       ${array[1]}
  $FG_GREEN Created:    $RESET       ${array[2]}
  $FG_GREEN Due date:   $RESET       ${array[3]}
  $FG_GREEN Project:    $RESET       ${array[4]}
  $FG_GREEN Completed:  $RESET       ${array[5]}
EOF

}

select_all_active(){
  printf "$FG_GREEN[active tasks]\n\n"
  printf "$FG_GREEN%-7s %-15s %-40s %s$RESET\n" "Id" "Created" "Description" "Project"
  printf "$FG_GREEN%-7s %-15s %-40s %s$RESET\n" "----" "------------" "------------------" "----------"
  IFS=$'\n'

  database_select_all 0

  for item in "${data_array[@]}"
  do
    IFS='|' read -r -a array <<< "$item"
    printf "$FG_RED%-6s $RESET %-15s$FG_BLUE %-40s $RESET%s\n" "${array[0]}" "${array[2]}" "${array[1]}" "${array[4]}"
  done
}

# Show completed tasks
select_all_completed(){
  printf "$FG_GREEN[completed tasks]\n\n"
  printf "$FG_GREEN%-7s %-15s %-40s %s$RESET\n" "Id" "Created" "Description" "Tags"
  printf "$FG_GREEN%-7s %-15s %-40s %s$RESET\n" "----" "------------" "------------------" "------------------"
  IFS=$'\n'

  database_select_all 1

  for item in "${data_array[@]}"
  do
    IFS='|' read -r -a array <<< "$item"
    printf "$FG_GREEN%-6s $RESET %-15s$FG_BLUE %-40s $RESET%s\n" "${array[0]}" "${array[2]}" "${array[1]}" "${array[4]}"
  done
}
