# CopyDirFile
## Description and basic information
 [Bash] CopyDirFile is used to create copy tasks in background for copying files or folders to a given location every specified time period.  
 
  The script allows you to easily add copy tasks that run in the background.  
  When creating a task you specify the time after which copying should be performed again until it is stopped.  
  You can easily display a list of created tasks and those that are currently running.  
  
  If you are copying files between two folders and you for example adding one file to source folder and another to destination folder and you want the copying to be done in two directions, you do not have to create two copy tasks. All you have to do is type the optional *two_directions* argument as `true` at the end of the `add` command.  
  
  Logs of running copy tasks are created in the folder intended for this (the name of the variable that stores the folder location is in the section below). Each file created corresponds to one copy task. The file name syntax is: `Task_<copy_task_number>.log`
  
## Settings changes
  By default, the script checks if the directory or file typed as source/destination exist. If you don't want the script to check if the destination folder or file exists, you can change it in the file by changing the value of the `CHECK_IF_DESTINATION_EXISTS` variable from `true` to `false`.  
  
  The default location of the folder containing logs of started copy tasks and created files containing the list of created copy tasks and the list of started copy tasks is set to the user's home folder. If you want to change the location, just change the values of the following variables in script:
  - `FILE_TASKS` - variable that stores the location of the file containing the list of copy tasks
  - `FILE_TASKS_RUNNING` - location of the file containing the list of currently running copy tasks
  - `FILE_TASKS_LOGS_DIR` - location and name of the folder in which logs of running copy tasks will be created
  
## Command syntax
  - `add <source> <destination> <refresh_time> [<two_directions>]`  - creates a new copy task
  - `show <all|running|task_ID>`  - displays a list of created copy tasks
  - `start <all|task_ID>`  - runs copy tasks
  - `del <all|task_ID>`  - deletes all or specified copy tasks
  - `stop <all|task_ID>`  - stops all or specified running copy tasks
  - `help`  - display this help page
  - `about`  - display information about this program
  
## Code Examples

  To create a new task of copying a file to the specified folder every 5 seconds, you can do it this way:
  
  ```sh
  $ ./CopyDirFile.sh add /source/file.txt /destination/folder/. 5s
  [INFO] New task created with ID: 1
  ```

  If you want to create new copy task to copy every 5 minutes in two directions (from source folder to destination folder and vice versa) you need to type the optional *two_directions* argument as `true` at the end of the `add` command:
  
  ```sh
  $ ./CopyDirFile.sh add "/type/source folder/." "/type/destination folder/." 5m true
  [INFO] New task created with ID: 2
  ```
  
  To display only a specific task, type its ID:
  
  ```sh
  $ ./CopyDirFile.sh show 1
  
 ID  SOURCE                                    DESTINATION                               REFRESH  TWO DIRECTION
===============================================================================================================
   1  /source/file.txt                          /destination/folder/.                          5s          false

  ```
  
  If you want to run a copy task, type its ID:
  
  ```sh
  $ ./CopyDirFile.sh start 1
  [INFO] Task with ID 1 started with process ID: 2890
  ```
  
  To view a list of running copy tasks, type:
  
  ```sh
  $ ./CopyDirFile.sh show running

PROCESS ID   ID  SOURCE                                    DESTINATION                               REFRESH  TWO DIRECTION
===========================================================================================================================
        2890    1  /source/file.txt                          /destination/folder/.                          5s          false

  ```
  
  If you want to stop a copy task, type its ID:
  
  ```sh
  $ ./CopyDirFile.sh stop 1
[INFO] Running task 1 with process ID 2890 has been stopped
  ```
  
  Copy jobs that are not running can be deleted completely by typing its ID:
  
  ```sh
  $ ./CopyDirFile.sh del 1
[INFO] Task with ID 1 deleted
  ```
