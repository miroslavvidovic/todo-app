# Surround a variable with single quotes for database input
# $1 - variable
# returns '$1'
surround(){
  char=\'
  output=$char$1$char
  echo "$output"
}
