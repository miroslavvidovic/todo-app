#!/bin/sh


# Main menu options
main_menu(){
  OUTPUT=$(
          zenity --width="400" --height="300"\
          --list \
          --title="Task manager" \
          --column="#" --column="Option"\
          1 "Add a new task" \
          2 "Change a task to completed"\
          3 "List active tasks" \
          4 "Delete a task" \
          5 "Update a task" \
          6 "List completed tasks"\
          7 "Exit"
          )
  accepted=$?
  if ((accepted != 0)); then
      echo "exiting ..."
      exit 1
  fi

  case $OUTPUT in
      1 )
        insert_form
        main_menu
      ;;
      2 )
        complete_form
        main_menu
      ;;
      3 )
        active_tasks_form
        main_menu
        ;;
      4 )
        delete_form
        main_menu
      ;;
      5 )
        update_form
        main_menu
      ;;
      6 )
        completed_tasks_form
        main_menu
      ;;
      7 )
        echo "Exiting ..."
        exit 0
      ;;
  esac
}

# Zenity form for adding tasks
insert_form(){
  DATA=$(zenity --forms --title="Add a new task"\
                  --text="Enter task details"\
                  --separator=","\
                  --add-entry="Description"\
                  --add-calendar="Due date"\
                  --add-entry="Project"
                  )
  accepted=$?
  if ((accepted != 0)); then
      echo "action canceled"
      main_menu
  fi

  insert_task "$DATA"
}

# Active tasks zenity list
active_tasks_form(){
  select_all_active

  OUTPUT=$(
          zenity --width="600" --height="400"\
          --list \
          --title="Active tasks" \
          --column="ID" --column="Created" --column="Description" --column="Project" --column="Status"\
          "${DATA_ACTIVE[@]}"
          )
  accepted=$?
  if ((accepted != 0)); then
      echo "action canceled"
      main_menu
  fi

  one_task_form "$OUTPUT"
}

# Completed tasks zenity list
completed_tasks_form(){
  select_all_completed

  OUTPUT=$(
          zenity --width="600" --height="400"\
          --list \
          --title="Completed tasks" \
          --column="ID" --column="Created" --column="Description" --column="Project" --column="Status"\
          "${DATA_COMPLETED[@]}"
          )
  accepted=$?
  if ((accepted != 0)); then
      echo "action canceled"
      main_menu
  fi

  one_task_form "$OUTPUT"
}

delete_form(){
  ID=$(zenity --forms --title="Task manager"\
                  --text="Delete a task with ID"\
                  --add-entry="Task ID"\
                  )
  accepted=$?
  if ((accepted != 0)); then
      echo "action canceled"
      main_menu
  fi

  delete_task $ID
}

complete_form(){
  ID=$(zenity --forms --title="Task manager"\
                  --text="Update a task to completed"\
                  --add-entry="Task ID"\
                  )
  accepted=$?
  if ((accepted != 0)); then
      echo "action canceled"
      main_menu
  fi

  complete_task $ID
}

update_form(){
  DATA=$(zenity --forms --title="Task manager"\
                  --text="Update a task"\
                  --separator=","\
                  --add-entry="Task ID"\
                  --add-entry="Description"\
                  --add-calendar="Due date"\
                  --add-entry="Project"
                  )
  accepted=$?
  if ((accepted != 0)); then
      echo "action canceled"
      main_menu
  fi

  update_task "$DATA"
}

one_task_form(){
  select_one_task "$1"

  OUTPUT=$(
          zenity --width="700" --height="150"\
          --list \
          --title="Task manager" \
          --column="ID" --column="Description" --column="Created" --column="Due date" --column="Project" --column="Completed"\
          "${one_task_array[@]}"
          )
  accepted=$?
  if ((accepted != 0)); then
      echo "action canceled"
      main_menu
  fi
}
