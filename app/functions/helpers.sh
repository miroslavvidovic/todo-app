# Surround a variable with single quotes for database input
# @param $1 - variable to surround
surround(){
  char=\'
  output=$char$1$char
  echo "$output"
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

# Send a task to Google calendar
google_calendar(){
  due_date=${array[4]}
  title=${array[1]}
  day=$(echo "$due_date" | cut -d "." -f 1 | tr "'" " ")
  month=$(echo "$due_date" | cut -d "." -f 2)
  gcalcli --calendar 'vidovic.miroslav.vm@gmail.com' quick "$title at 12:00 $month/$day"
}
