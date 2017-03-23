insert_form(){
  # Show the form
  OUTPUT=$(zenity --forms --title="Add a new task"\
                  --text="Enter task details"\
                  --separator=","\
                  --add-entry="Description"\
                  --add-calendar="Due date"\
                  --add-entry="Project"
                  )
  accepted=$?
  if ((accepted != 0)); then
      echo "something went wrong"
      exit 1
  fi
  echo $OUTPUT
}
