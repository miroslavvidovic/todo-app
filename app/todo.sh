#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Info:
#   author:    Miroslav Vidovic
#   file:      todo.sh
#   created:   26.07.2016.-15:32:34
#   revision:  22.03.2016.
#   version:   2.0
# -----------------------------------------------------------------------------
# Requirements:
#   sqlite3, zenity
# Description:
#   Task application (todo app) made with sqlite, bash and zenity.
# Usage:
#   todo.sh
# -----------------------------------------------------------------------------
# Script:

# Includes
source ./functions/sqlite-queries.sh
source ./functions/task.sh
source ./functions/zenity-guis.sh
source ./functions/helpers.sh

# Path to database
database=../database/todo.sqlite

main_menu
