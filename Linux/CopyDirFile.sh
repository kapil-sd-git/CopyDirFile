#!/bin/bash

#################
# +--------------------------------------------------+
# |  Copyright by Gracjan Mika ( https://gmika.pl )  |
# |              CopyDirFile for Linux               |
# +--------------------------------------------------+
# 
#  YOU USE IT AT YOUR OWN RISK
#  I am not responsible for any damage or loss of data suffered as a result of using this program.
#  By using this, you confirm that you agree with the above.
#  If you disagree with the above, you must do not use this.
# 
#  This script is created in spare time and may contain bugs or be underdeveloped.
#  If you found any bugs that I could miss or you would like to give advice, I would be grateful for this information.
# 
#################

#################
# BEGINNING OF CONFIGURATION VARIABLES
# 
# Set CHECK_IF_DESTINATION_EXISTS value to "false" if you do not want to check that the destination path exists
# Default: CHECK_IF_DESTINATION_EXISTS=true
CHECK_IF_DESTINATION_EXISTS=true

# Stores the location of the file containing the list of copy tasks
# Default: FILE_TASKS="$( realpath ~/.CopyDirFile.tasks )"
FILE_TASKS="$( realpath ~/.CopyDirFile.tasks )"

# Location of the file containing the list of currently running copy/mirror tasks
# Default: FILE_TASKS_RUNNING="$( realpath ~/.CopyDirFile_running.tasks )"
FILE_TASKS_RUNNING="$( realpath ~/.CopyDirFile_running.tasks )"

# Location and name of the folder in which logs of running copy/mirror tasks will be created
# Default: FILE_TASKS_LOGS_DIR="$( realpath ~/ )/CopyDirFile_Logs"
FILE_TASKS_LOGS_DIR="$( realpath ~/ )/CopyDirFile_Logs"
# 
# END OF CONFIGURATION VARIABLES
#################

# Stores name of this current script
# Default: SCRIPT_NAME="$( basename $0 )"
SCRIPT_NAME="$( basename $0 )"

# Script Version
VERSION="2.0"

if [[ ! -d "$FILE_TASKS_LOGS_DIR" ]]; then
  mkdir "$FILE_TASKS_LOGS_DIR"
fi

declare -a TASKS=()

if test -f "$FILE_TASKS" ; then
  while IFS= read -r line
  do
    eval "for command in $line; do TASKS+=( \"\$command\" ); done"
  done < "$FILE_TASKS"

  if [ "$((${#TASKS[@]}%6))" -gt "0" ]; then
    echo "[ERROR] An error was found in the number of parameters in the file containing the tasks!"
    exit 3
  fi
fi

declare -a RUNNING_TASKS=()

if test -f "$FILE_TASKS_RUNNING" ; then
  while IFS= read -r line
  do
    TEMP_ARRAY=()
    eval "for command in $line; do TEMP_ARRAY+=( \"\$command\" ); done"
    ps -p ${TEMP_ARRAY[0]} > /dev/null && RUNNING_TASKS+=( "${TEMP_ARRAY[0]}" "${TEMP_ARRAY[1]}" )
  done < "$FILE_TASKS_RUNNING"

  > "$FILE_TASKS_RUNNING"
  for (( i=0; i<$((${#RUNNING_TASKS[@]}/2)); i++ ))
  do
    echo "${RUNNING_TASKS[$(($i*2))]} ${RUNNING_TASKS[$(($i*2+1))]}" >> "$FILE_TASKS_RUNNING"
  done

  if [ "$((${#RUNNING_TASKS[@]}%2))" -gt "0" ]; then
    echo "[ERROR] An error was found in the number of parameters in the file containing the running tasks!"
    exit 3
  fi
fi

USAGE_ADD="
USAGE:

  $SCRIPT_NAME add <type> <source> <destination> <refresh_time> [<two_directions>]

DESCRIPTION:
  
  Creates a new copy/mirror task

- type - type of task being created
  Available types are:
    copy - copy elements from destination path to source
    mirror - replicates the contents of the source to the destination path
- source - file or dir which you want to copy
- destination - file or dir where you want to copy source
- refresh_time - sets the time after which the task is executed again. The syntax can be as follows: <number><time_prefix>
  Time prefixes:
    s - seconds (recommended if changes need to be saved frequently)
    m - minutes (recommended for normal usage)
    h - hours (recommended if changes are rarely made)
- two_directions - (optional - used only if task type=copy) parameter can only be used if the source and destination paths are the same type (DIR <--> DIR, File <--> File)!
  Type \"true\" if you want program to copy in two directions (from source to destination and from destination to source), if not, type \"false\". Default value if not specified is \"false\"

EXAMPLES:

 If you want to create new in two directions copy task thich will copy the contents of the directory without the folder itself, add the \".\" to the end of the path:

   $SCRIPT_NAME add copy /home/user/. /home/copy/ 1h true

 Create mirror task type which replicates the contents of the source to the destination. If the path contains spaces, insert it between quotation marks:

   $SCRIPT_NAME add mirror /home/user/. \"/home/user/t e s t/\" 30m

 If you want to copy the file to another place:

   $SCRIPT_NAME add copy /home/user/file.txt /home/copy/ 1h
"

USAGE_SHOW="
USAGE:
  
  $SCRIPT_NAME show <all|running|task_ID> [<copy|mirror>]

DESCRIPTION:
  
  Displays a list of created or running copy/mirror tasks

- all - displays all created copy and/or mirror tasks
- running - displays all copy/mirror tasks which are already running
- task_ID - display created copy/mirror task with given ID

- copy - optional parameter that can be used only if you want to display all running or created copy tasks
- mirror - optional parameter that can be used only if you want to display all running or created mirror tasks

EXAMPLES:

 If you want to display all created copy and mirror tasks:

   $SCRIPT_NAME show all

 If you want to display all already running mirror type tasks:

   $SCRIPT_NAME show running mirror

 If you want to display task with given ID (in this example, ID = 2):

   $SCRIPT_NAME show 2
"

USAGE_START="
USAGE:

  $SCRIPT_NAME start <all|task_ID> [<copy|mirror>]

DESCRIPTION:

  Runs copy/mirror tasks

- all - starts all the copy and/or mirror tasks that are in the program
- task_ID - starts the copy/mirror task with specified ID

- copy - optional parameter that can be used only if you want to run all created copy tasks
- mirror - optional parameter that can be used only if you want to run all created mirror tasks

EXAMPLES:

 If you want to run all created copy and mirror tasks:

   $SCRIPT_NAME start all

 If you want to run all mirror type tasks:

   $SCRIPT_NAME start all mirror

 If you want to run task with given ID (in this example, ID = 2):

   $SCRIPT_NAME start 2
"

USAGE_STOP="
USAGE:

  $SCRIPT_NAME stop <all|task_ID> [<copy|mirror>]

DESCRIPTION:

  Stops all or specified running copy/mirror tasks

- all - stops all copy and/or mirror tasks that are currently running
- task_ID - stops the copy/mirror task with specified ID which is currently running

- copy - optional parameter that can be used only if you want to stop all created copy tasks
- mirror - optional parameter that can be used only if you want to stop all created mirror tasks

EXAMPLES:

 If you want to stop all running copy and mirror tasks:

   $SCRIPT_NAME stop all

 If you want to stop all mirror type tasks:

   $SCRIPT_NAME stop all mirror

 If you want to stop task with given ID (in this example, ID = 2):

   $SCRIPT_NAME stop 2
"

USAGE_DEL="
USAGE:

  $SCRIPT_NAME del <all|task_ID> [<copy|mirror>]

DESCRIPTION:

  Deletes all or specified copy/mirror tasks

- all - deletes all copy and/or mirror tasks that are in the program and are NOT CURRENTLY RUNNING
- task_ID - deletes the copy/mirror task with specified ID (CAN NOT BE CURRENTLY RUNNING)

- copy - optional parameter that can be used only if you want to delete all created copy tasks that are NOT CURRENTLY RUNNING
- mirror - optional parameter that can be used only if you want to delete all created mirror tasks that are NOT CURRENTLY RUNNING

EXAMPLES:

 If you want to delete all copy and mirror tasks that are NOT CURRENTLY RUNNING:

   $SCRIPT_NAME del all

 If you want to delete all mirror type tasks that are NOT CURRENTLY RUNNING:

   $SCRIPT_NAME del all mirror

 If you want to delete task with given ID (in this example, ID = 2) that is NOT CURRENTLY RUNNING:

   $SCRIPT_NAME del 2
"

help_function ()
{
  echo "
This is HELP page of program CopyDirFile.

CopyDirFile is used to create copy or mirror tasks for copying or replicating files or folders to a given location every specified time period.

Copy task type allows you to copy elements from destination path to source.
Mirror task type allows you to replicates the contents of the source to the destination path.

The program can be operated using commands whose syntax is as follows:

  add <type> <source> <destination> <refresh_time> [<two_directions>]  - creates a new copy/mirror task
  show <all|running|task_ID> [<type>]  - displays a list of created copy/mirror tasks
  start <all|task_ID> [<type>]  - runs copy/mirror tasks
  del <all|task_ID> [<type>]  - deletes all or specified copy/mirror tasks
  stop <all|task_ID> [<type>]  - stops all or specified running copy/mirror tasks
  help  - display this help page
  about  - display information about this program
"
}

about_function ()
{
  echo "========================================"
  echo ""
  echo "         CopyDirFile for Linux"
  echo ""
  echo "             Version: $VERSION"
  echo ""
  echo "       Copyright by Gracjan Mika"
  echo "          ( https://gmika.pl )"
  echo ""
  echo "========================================"
}

add_function ()
{
  local ERROR=true
  local TWO_DIRECTIONS=false

  if [ "$#" -eq "5" ] || [ "$#" -eq "6" ] || [ "$#" -eq "2" ]; then
    if [ "$#" -eq "2" ]; then
      if [[ "$2" == "--help" ]] || [[ "$2" == "-help" ]] || [[ "$2" == "help" ]]; then
        echo "$USAGE_ADD"
        exit 0
      fi
    else
      if [[ "$2" =~ ^mirror$ && "$#" -eq "5" ]] || [[ "$2" =~ ^copy$ ]]; then
        if [[ "$2" =~ ^mirror$ && -d "$( realpath "$3" )" && -d "$( realpath "$4" )" ]] || [[ "$2" =~ ^mirror$ && -d "$( realpath "$3" )" && "$CHECK_IF_DESTINATION_EXISTS" == "false" ]] || [[ "$2" =~ ^copy$ ]]; then
          if [[ -f "$( realpath "$3" )" || -d "$( realpath "$3" )" ]] && [[ -f "$( realpath "$4" )" || -d "$( realpath "$4" )" || "$CHECK_IF_DESTINATION_EXISTS" == "false" ]]; then
            if [[ "$5" =~ ^([0-9]{1,3}[smh])$ ]]; then
              if [[ -d "$( realpath "$3" )" && -f "$( realpath "$4" )" ]]; then
                echo "[ERROR] Can not copy DIR to FILE!"
                exit 3
              else
                if [[ "$( realpath "$3" )" != "$( realpath "$4" )" ]]; then
                  if [ "$#" -eq "6" ]; then
                    if [[ -d "$( realpath "$3" )" && -d "$( realpath "$4" )" ]] || [[ -f "$( realpath "$3" )" && -f "$( realpath "$4" )" ]]; then
                      if [[ "$6" =~ ^true$ ]] || [[ "$6" =~ ^false$ ]]; then
                        TWO_DIRECTIONS="$6"
                        ERROR=false
                      fi
                    else
                      echo "[ERROR] two_directions (optional) parameter can only be used if paths exists and the source and destination paths are the same type (DIR <--> DIR, File <--> File)!"
                    fi
                  else
                    ERROR=false
                  fi
                else
                  echo "[ERROR] Source and destination can not be the same!"
                fi
              fi
            fi
          else
            echo "[ERROR] One of the paths is invalid!"
          fi
        else
          echo "[ERROR] In mirror task the destination and/or source CAN NOT BE FILE!"
          exit 4
        fi
      fi
    fi
  fi

  if [[ "$ERROR" == true ]]; then
    echo "$USAGE_ADD"
    exit 4
  fi

  local TASK_TYPE=$2
  local NUMBER="$((${#TASKS[@]}/6))"

  local SOURCE_PATH="$( realpath "$3" )"
  if [[ "$3" =~ \/\.$ ]] && [[ -d "$SOURCE_PATH" ]]; then
    SOURCE_PATH="$( realpath "$3" )/."
  fi

  local DESTINATION_PATH="$4"
  if [ "$CHECK_IF_DESTINATION_EXISTS" != "false" ]; then
    DESTINATION_PATH="$( realpath "$4" )"
    if [[ "$4" =~ \/\.$ ]] && [[ -d "$DESTINATION_PATH" ]]; then
      DESTINATION_PATH="$( realpath "$4" )/."
    fi
  fi

  local MAXIMUM=0
  for (( i=0; i<$NUMBER; i++ ))
  do
    if [[ "$SOURCE_PATH" == "${TASKS[$(($i*6+2))]}" ]] && [[ "$DESTINATION_PATH" == "${TASKS[$(($i*6+3))]}" ]]; then
      echo "[ERROR] Task with the given paths already exists!"
      exit 5
    fi

    if [ "${TASKS[$((i*6))]}" -gt "$MAXIMUM" ]; then
      MAXIMUM="${TASKS[$((i*6))]}"
    fi
  done

  if [[ "$TASK_TYPE" =~ ^mirror$ ]]; then
    TWO_DIRECTIONS="-"
  fi

  let MAXIMUM++

  TASKS+=( "$MAXIMUM" )

  TASKS+=( "$TASK_TYPE" )
  TASKS+=( "$SOURCE_PATH" )
  TASKS+=( "$DESTINATION_PATH" )
  TASKS+=( "$5" )
  TASKS+=( "$TWO_DIRECTIONS" )

  echo "${TASKS[$(($NUMBER*6))]} ${TASKS[$(($NUMBER*6+1))]} \"${TASKS[$(($NUMBER*6+2))]}\" \"${TASKS[$(($NUMBER*6+3))]}\" ${TASKS[$(($NUMBER*6+4))]} ${TASKS[$(($NUMBER*6+5))]}" >> "$FILE_TASKS"

  if [ $? ]; then 
    echo "[INFO] New $TASK_TYPE task created with ID: $MAXIMUM"
  else
    echo "[ERROR] An error occurred while adding $TASK_TYPE task to file!"
    exit 6
  fi
}

show_function ()
{
  local ERROR=true

  if [ "$#" -eq "2" ] || [ "$#" -eq "3" ]; then
    if [[ "$2" == "--help" || "$2" == "-help" || "$2" == "help" ]] && [ "$#" -eq "2" ]; then
      echo "$USAGE_SHOW"
      exit 0
    fi
    if [[ "$2" =~ ^all$ ]] || [[ "$2" =~ ^running$ ]] || [[ "$2" =~ ^[0-9]+$ ]]; then
      if [[ "$2" =~ ^all$ ]] || [[ "$2" =~ ^running$ ]]; then
        if [ "$#" -eq "2" ] || ([ "$#" -eq "3" ] && [[ "$3" =~ ^copy$ || "$3" =~ ^mirror$ ]]); then
          ERROR=false
        fi
      else
        if [ "$#" -eq "2" ]; then
          local FOUND=false
          for (( i=0; i<$((${#TASKS[@]}/6)); i++ ))
          do
            if [[ "$2" == "${TASKS[$(($i*6))]}" ]]; then
              FOUND=true
            fi
          done

          if [[ "$FOUND" == "true" ]]; then
            ERROR=false
          else
            echo "[ERROR] Task with given ID does not exist!"
            exit 7
          fi
        fi
      fi
    fi
  fi

  if [[ "$ERROR" == true ]]; then
    echo "$USAGE_SHOW"
    exit 8
  fi

  DIVIDER="=============================="
  DIVIDER=$DIVIDER$DIVIDER$DIVIDER$DIVIDER$DIVIDER
  if [[ "$2" =~ ^running$ ]]; then
    printf "\n%3s  %10s  %6s  %-40s  %-40s  %7s  %13s\n" "ID" "PROCESS ID" "TYPE" "SOURCE" "DESTINATION" "REFRESH" "TWO DIRECTION"
    printf "%-131.131s\n" "$DIVIDER"

    for (( i=0; i<$((${#TASKS[@]}/6)); i++ ))
    do
      if [ "${#RUNNING_TASKS[@]}" -gt "0" ]; then
        for (( j=0; j<$((${#RUNNING_TASKS[@]}/2)); j++ ))
        do
          if [ "${TASKS[$((i*6))]}" -eq "${RUNNING_TASKS[$(($j*2+1))]}" ]; then
            if ([ "$#" -eq "3" ] && [[ "$3" == "${TASKS[$(($i*6+1))]}" ]]) || [ "$#" -eq "2" ]; then
              printf "%3s  %10s  %6s  %-40s  %-40s  %7s  %13s\n" "${TASKS[$(($i*6))]}" "${RUNNING_TASKS[$(($j*2))]}" "${TASKS[$(($i*6+1))]}" "${TASKS[$(($i*6+2))]}" "${TASKS[$(($i*6+3))]}" "${TASKS[$(($i*6+4))]}" "${TASKS[$(($i*6+5))]}"
            fi
            break
          fi
        done
      fi
    done
  else
    printf "\n%3s  %6s  %-40s  %-40s  %7s  %13s\n" "ID" "TYPE" "SOURCE" "DESTINATION" "REFRESH" "TWO DIRECTION"
    printf "%-119.119s\n" "$DIVIDER"

    for (( i=0; i<$((${#TASKS[@]}/6)); i++ ))
    do
      if [[ "$2" =~ ^all$ || "$2" == "${TASKS[$(($i*6))]}" ]]; then
        if ([ "$#" -eq "3" ] && [[ "$3" == "${TASKS[$(($i*6+1))]}" ]]) || [ "$#" -eq "2" ]; then
          printf "%3s  %6s  %-40s  %-40s  %7s  %13s\n" "${TASKS[$(($i*6))]}" "${TASKS[$(($i*6+1))]}" "${TASKS[$(($i*6+2))]}" "${TASKS[$(($i*6+3))]}" "${TASKS[$(($i*6+4))]}" "${TASKS[$(($i*6+5))]}"
        fi
      fi
    done
  fi
  echo ""
}

del_function ()
{
  local ERROR=true
  local TASK_TYPE=""

  if [ "$#" -eq "2" ] || [ "$#" -eq "3" ]; then
    if [[ "$2" == "--help" || "$2" == "-help" || "$2" == "help" ]] && [ "$#" -eq "2" ]; then
      echo "$USAGE_DEL"
      exit 0
    fi
    if [[ "$2" =~ ^all$ ]] || [[ "$2" =~ ^[0-9]+$ ]]; then
      if [[ "$2" =~ ^all$ ]]; then
        if [ "$#" -eq "2" ] || ([ "$#" -eq "3" ] && [[ "$3" =~ ^copy$ || "$3" =~ ^mirror$ ]]); then
          local SURE="n"
          if [ "$#" -eq "3" ]; then
            TASK_TYPE=" $3"
          fi
          read -p "Are you sure you want to delete all$TASK_TYPE tasks? [y/n] " SURE
          if [[ "$SURE" =~ ^y$ ]]; then
            ERROR=false
          else
            echo "[ERROR] Operation canceled"
            exit 9
          fi
        fi
      else
        if [ "$#" -eq "2" ]; then
          local FOUND=false
          for (( i=0; i<$((${#TASKS[@]}/6)); i++ ))
          do
            if [ "$2" -eq "${TASKS[$(($i*6))]}" ]; then
              FOUND=true
            fi
          done

          if [[ "$FOUND" == "true" ]]; then
            ERROR=false
          else
            echo "[ERROR] Task with given ID does not exist!"
            exit 10
          fi
        fi
      fi
    fi
  fi

  if [[ "$ERROR" == true ]]; then
    echo "$USAGE_DEL"
    exit 11
  fi

  > "$FILE_TASKS"
  local REMOVED=false
  local PROBLEM=false

  for (( i=0; i<$((${#TASKS[@]}/6)); i++ ))
  do
    local TASK_ID=${TASKS[$(($i*6))]}
    local FOUND=false
    TASK_TYPE="${TASKS[$(($i*6+1))]}"

    for (( j=0; j<$((${#RUNNING_TASKS[@]}/2)); j++ ))
    do
      if [ "$TASK_ID" -eq "${RUNNING_TASKS[$(($j*2+1))]}" ]; then
        FOUND=true
        break
      fi
    done
    if [[ "$FOUND" == true ]]; then
      echo "[ERROR] Task with ID $TASK_ID can not be deleted because is already running!"
      PROBLEM=true
    else
      if [[ "$2" == "$TASK_ID" ]]; then
        REMOVED=true
      fi
    fi

    if ([[ "$2" == "$TASK_ID" ]] || ([ "$#" -eq "2" ] && [[ "$2" =~ ^all$ ]]) || [[ "$3" == "${TASKS[$((i*6+1))]}" ]]) && [[ "$FOUND" == false ]]; then
      if [ "$i" -eq "0" ]; then
        TASKS=( "${TASKS[@]:$(($i*6+6))}" )
      else
        TASKS=( "${TASKS[@]:0:$(($i*6))}" "${TASKS[@]:$(($i*6+6))}" )
      fi
      let i--
      echo "[INFO] Deleted $TASK_TYPE task with ID: $TASK_ID"
    else
      echo "${TASKS[$(($i*6))]} ${TASKS[$(($i*6+1))]} \"${TASKS[$(($i*6+2))]}\" \"${TASKS[$(($i*6+3))]}\" ${TASKS[$(($i*6+4))]} ${TASKS[$(($i*6+5))]}" >> "$FILE_TASKS"
    fi
  done
  if [[ "$PROBLEM" == true ]]; then
    exit 12
  fi
  if [[ "$2" =~ ^[0-9]+$ ]] && [[ "$REMOVED" == false ]]; then
    exit 13
  fi
}

create_new_task ()
{
  local TASK_PROCESS_ID=""
  local FILE_TASKS_LOGS="$FILE_TASKS_LOGS_DIR/Task_$1.log"
  local TASK_TYPE="${TASKS[$(($2*6+1))]}"
  local SOURCE="${TASKS[$(($2*6+2))]}"
  local DESTINATION="${TASKS[$(($2*6+3))]}"
  local REFRESH="${TASKS[$(($2*6+4))]}"
  local TWO_DIRECTIONS="${TASKS[$(($2*6+5))]}"
  local SUCCESS=false

  while true; \
  do \
    SUCCESS=false; \
    if [[ -f "$SOURCE" || -d "$SOURCE" ]] && [[ -f "$DESTINATION" || -d "$DESTINATION" || "$CHECK_IF_DESTINATION_EXISTS" == "false" ]]; then \
      cp -au "$SOURCE" "$DESTINATION" >> "$FILE_TASKS_LOGS" 2>&1 && SUCCESS=true || echo "[$(date +'%d/%m/%Y %R:%S')] ERROR: An error occurred while copying! The copy has not been made" >> "$FILE_TASKS_LOGS"; \
      if [[ "$TWO_DIRECTIONS" =~ ^true$ && "$TASK_TYPE" =~ ^copy$ ]]; then \
        cp -au "$DESTINATION" "$SOURCE" >> "$FILE_TASKS_LOGS" 2>&1 || echo "[$(date +'%d/%m/%Y %R:%S')] ERROR: An error occurred while copying into second direction! The copy has not been made" >> "$FILE_TASKS_LOGS"; \
      fi; \
      if [[ "$TASK_TYPE" =~ ^mirror$ && "$SUCCESS" =~ ^true$ ]]; then \
        diff -rq "$SOURCE" "$DESTINATION" | grep "$DESTINATION" | awk -F': ' '{print $1"/"$2}' | awk -F'/+|/./' '{printf "'"'"'"; for (i=2; i<=NF; i++) printf "/"$i; done; printf "'"'"'\n"}' | xargs rm -rf 
      fi; \
    else \
      echo "[$(date +'%d/%m/%Y %R:%S')] ERROR: One of the paths is invalid! The copy has not been made" >> "$FILE_TASKS_LOGS"; \
    fi; \
    sleep $REFRESH; \
  done &

  TASK_PROCESS_ID=$!
  RUNNING_TASKS+=( "$TASK_PROCESS_ID" "$1" )
  echo "$TASK_PROCESS_ID $1" >> "$FILE_TASKS_RUNNING"

  if [ $? ]; then 
    echo "[INFO] Task with ID $1 started with process ID: $TASK_PROCESS_ID"
  else
    kill $TASK_PROCESS_ID
    echo "[ERROR] An error occurred while adding a running $TASK_TYPE task ID $1 with process ID $TASK_PROCESS_ID to a file containing a list of running copy tasks! The process has been stopped!"
    exit 14
  fi
}

start_function ()
{
  local ERROR=true

  if [ "$#" -eq "2" ] || [ "$#" -eq "3" ]; then
    if [[ "$2" == "--help" || "$2" == "-help" || "$2" == "help" ]] && [ "$#" -eq "2" ]; then
      echo "$USAGE_START"
      exit 0
    fi
    if [[ "$2" =~ ^all$ ]] || [[ "$2" =~ ^[0-9]+$ ]]; then
      if [[ "$2" =~ ^all$ ]]; then
        if [ "$#" -eq "2" ] || ([ "$#" -eq "3" ] && [[ "$3" =~ ^copy$ || "$3" =~ ^mirror$ ]]); then
          ERROR=false
        fi
      else
        if [ "$#" -eq "2" ]; then
          local FOUND=false
          for (( i=0; i<$((${#TASKS[@]}/6)); i++ ))
          do
            if [[ "$2" == "${TASKS[$(($i*6))]}" ]]; then
              FOUND=true
            fi
          done

          if [[ "$FOUND" == "true" ]]; then
            ERROR=false
          else
            echo "[ERROR] Task with given ID does not exist!"
            exit 15
          fi
        fi
      fi
    fi
  fi

  if [[ "$ERROR" == true ]]; then
    echo "$USAGE_START"
    exit 16
  fi

  for (( i=0; i<$((${#TASKS[@]}/6)); i++ ))
  do
    local TASK_ID=${TASKS[$((i*6))]}
    local FOUND=false
    if [[ "$2" =~ ^all$ ]] || [[ "$2" == "$TASK_ID" ]]; then
      if ([ "$#" -eq "3" ] && [[ "$3" == "${TASKS[$(($i*6+1))]}" ]]) || [ "$#" -eq "2" ]; then
        if [ "${#RUNNING_TASKS[@]}" -gt "0" ]; then
          for (( j=0; j<$((${#RUNNING_TASKS[@]}/2)); j++ ))
          do
            if [ "$TASK_ID" -eq "${RUNNING_TASKS[$(($j*2+1))]}" ]; then
              FOUND=true
              break
            fi
          done
        fi

        if [[ "$FOUND" == true ]]; then
          echo "[ERROR] Task with ID $TASK_ID is already running!"
          if [[ "$2" == "$TASK_ID" ]]; then
            exit 17
          fi
        else
          create_new_task "$TASK_ID" "$i"
          if [[ "$2" == "$TASK_ID" ]]; then
            exit 0
          fi
        fi
      fi
    fi
  done
}

stop_function ()
{
  local ERROR=true

  if [ "$#" -eq "2" ] || [ "$#" -eq "3" ]; then
    if [[ "$2" == "--help" || "$2" == "-help" || "$2" == "help" ]] && [ "$#" -eq "2" ]; then
      echo "$USAGE_STOP"
      exit 0
    fi
    if [[ "$2" =~ ^all$ ]] || [[ "$2" =~ ^[0-9]+$ ]]; then
      if [[ "$2" =~ ^all$ ]]; then
        if [ "$#" -eq "2" ] || ([ "$#" -eq "3" ] && [[ "$3" =~ ^copy$ || "$3" =~ ^mirror$ ]]); then
          ERROR=false
        fi
      else
        if [ "$#" -eq "2" ]; then
          local FOUND=false
          for (( i=0; i<$((${#RUNNING_TASKS[@]}/2)); i++ ))
          do
            if [ "$2" -eq "${RUNNING_TASKS[$(($i*2+1))]}" ]; then
              FOUND=true
            fi
          done

          if [[ "$FOUND" == "true" ]]; then
            ERROR=false
          else
            echo "[ERROR] The entered task ID is not currently running or does not exist!"
            exit 18
          fi
        fi
      fi
    fi
  fi

  if [[ "$ERROR" == true ]]; then
    echo "$USAGE_STOP"
    exit 19
  fi

  > "$FILE_TASKS_RUNNING"
  local TASK_ID=0
  local PROCESS_ID=0
  local PROBLEM=false
  for (( i=0; i<$((${#RUNNING_TASKS[@]}/2)); i++ ))
  do
    PROCESS_ID=${RUNNING_TASKS[$(($i*2))]}
    TASK_ID=${RUNNING_TASKS[$(($i*2+1))]}
    local TASK_TYPE=""

    if [[ "$2" == "$TASK_ID" ]] || [[ "$2" =~ ^all$ ]]; then
      for (( j=0; j<$((${#TASKS[@]}/6)); j++ ))
      do
        if [[ "${RUNNING_TASKS[$(($i*2+1))]}" == "${TASKS[$(($j*6))]}" ]]; then
          if ([ "$#" -eq "3" ] && [[ "$3" == "${TASKS[$(($j*6+1))]}" ]]) || [ "$#" -eq "2" ]; then
            TASK_TYPE=" ${TASKS[$(($2*6+1))]}"

            kill $PROCESS_ID

            if [ $? ]; then
              echo "[INFO] Running$TASK_TYPE task ID $TASK_ID with process ID $PROCESS_ID has been stopped"
              if [ "$i" -eq "0" ]; then
                RUNNING_TASKS=( "${RUNNING_TASKS[@]:$(($i*2+2))}" )
              else
                RUNNING_TASKS=( "${RUNNING_TASKS[@]:0:$(($i*2))}" "${RUNNING_TASKS[@]:$(($i*2+2))}" )
              fi
              let i--
            else
              echo "[ERROR] An error occurred closing the$TASK_TYPE task ID $TASK_ID with the given process ID $PROCESS_ID!"
              echo "$PROCESS_ID $TASK_ID" >> "$FILE_TASKS_RUNNING"
              PROBLEM=true
            fi
          else
            echo "$PROCESS_ID $TASK_ID" >> "$FILE_TASKS_RUNNING"
          fi
          break
        fi
      done
    else
      echo "$PROCESS_ID $TASK_ID" >> "$FILE_TASKS_RUNNING"
    fi
  done

  if [[ "$PROBLEM" == true ]]; then
    exit 20
  fi
}

if [ "$#" -eq "0" ]; then
  help_function
  exit 1
else
  case $1 in
    add )
      add_function "$@"
      ;;
    show )
      show_function "$@"
      ;;
    start )
      start_function "$@"
      ;;
    stop )
      stop_function "$@"
      ;;
    help | -h | --help )
      help_function
      exit 0
      ;;
    about | version )
      about_function
      ;;
    del | delete )
      del_function "$@"
      ;;
    * )
      echo "[ERROR] Command not found!"
      help_function
      exit 2
  esac
fi
exit 0