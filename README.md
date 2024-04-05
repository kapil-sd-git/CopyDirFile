# CopyDirFile
## Description and basic information
 [Bash] CopyDirFile is used to create copy or mirror tasks for copying or replicating files or folders to a given location every specified time period. 
 
  The script allows you to easily add copy/mirror tasks that run in the background.  
  Mirror task type allows you to replicates the contents of the source to the destination path, which means that when you delete an item from the source, it will also be deleted in the target directory.  
  When creating a task you specify the time after which it should be performed again until it is stopped.  
  You can easily display a list of created tasks and those that are currently running.  
  
  If you are copying files between two folders and you for example adding one file to source folder and another to destination folder and you want the copying to be done in two directions, you do not have to create two copy tasks. All you have to do is type the optional *two_directions* argument as `true` at the end of the `add` command. This works only with copy tasks.  
  
  Logs of running copy/mirror tasks are created in the folder intended for this (the name of the variable that stores the folder location is in the section below). Each file created corresponds to one copy/mirror task ID. The file name syntax is: `Task_<task_ID>.log`  
  
  To access the script from any location, you can copy it to `/usr/bin/` folder (example shown in Code Examples section).  
  
  If you want the given copy or mirror task to be started automatically after specific user logs in, you can do it by adding the start command to `~/.profile` file.  
  
  Script written and tested on Ubuntu 18.04  
  
## You use it at your own risk
  I am not responsible for any damage or loss of data suffered as a result of using this program.   
  By using this, you confirm that you agree with the above information.   
  If you disagree with the above, you must do not use this.   
  
  This script is created in spare time and may contain bugs or be underdeveloped.   
  If you found any bugs that I could miss or you would like to give advice, I would be grateful for this information.   
  
## Settings changes
  By default, the script checks if the directory or file typed as source/destination exist. If you don't want the script to check if the destination folder or file exists, you can change it in the file by changing the value of the `CHECK_IF_DESTINATION_EXISTS` variable from `true` to `false`.   
  
  When adding a new task, the script automatically checks if the destination path contains the source path. If so, it causes an error. If you want to disable this option, change value of the `CHECK_IF_DESTINATION_CONTAINS_SOURCE` variable from `true` to `false`.   
  
  When you create new mirror task then program automatically adds `/.` at the end of the source path, if not added. If you want to disable this option, change value of the `SLASH_WITH_DOT_ON_END_SOURCE_PATH` variable from `true` to `false`. It works only with mirror type tasks.   
  
  The default location of the folder containing logs of started copy/mirror tasks and created files containing the list of created copy/mirror tasks and the list of started all copy/mirror tasks is set to the user's home folder. If you want to change the location, just change the values of the following variables in script:
  - `FILE_TASKS` - stores the location of the file containing the list of copy and mirror tasks
  - `FILE_TASKS_RUNNING` - location of the file containing the list of currently running copy and mirror tasks
  - `FILE_TASKS_LOGS_DIR` - location and name of the folder in which logs of running copy and mirror tasks will be created   
  
## Command syntax
  - `add <copy|mirror> <source> <destination> <refresh_time> [<two_directions>]`  - creates a new copy/mirror task
  - `show <all|running|task_ID> [<copy|mirror>]`  - displays a list of created copy/mirror tasks
  - `start <all|task_ID> [<copy|mirror>]`  - runs copy/mirror tasks
  - `del <all|task_ID> [<copy|mirror>]`  - deletes all or specified copy/mirror tasks
  - `stop <all|task_ID> [<copy|mirror>]`  - stops all or specified running copy/mirror tasks
  - `help`  - display help page
  - `about`  - display information about this program
  
## Code Examples
  If you want to create a mirror task that will replicate the contents of the source folder in the destination folder. With type mirror when specifying the source path, you do not need to specify `/.` on the end of this path because the program will add it automatically (only in mirror task). You can do it this way:

  ```sh
  $ ./CopyDirFile.sh add mirror /source/folder "/path to/destination/folder" 5s
  [INFO] New mirror task created with ID: 1
  ```

  To create a new copy task of copying a file to the specified folder every 5 seconds, you can do it this way:
  
  ```sh
  $ ./CopyDirFile.sh add copy /source/file.txt /destination/folder/. 5s
  [INFO] New copy task created with ID: 2
  ```

  If you want to create new copy task to copy every 5 minutes in two directions (from source folder to destination folder and vice versa) you need to type the optional *two_directions* argument as `true` at the end of the `add` command:
  
  ```sh
  $ ./CopyDirFile.sh add copy "/type/source folder/." "/type/destination folder/." 5m true
  [INFO] New copy task created with ID: 3
  ```
  
  To display only a specific copy or mirror task, type its ID:
  
  ```sh
  $ ./CopyDirFile.sh show 2
  
   ID    TYPE  SOURCE                                    DESTINATION                               REFRESH  TWO DIRECTION
=======================================================================================================================
    2    copy  /source/file.txt                          /destination/folder/.                          5s          false

  ```
  
  If you want to run a copy or mirror task, type its ID:
  
  ```sh
  $ ./CopyDirFile.sh start 2
  [INFO] Task with ID 2 started with process ID: 2890
  ```
  
  To view a list of running copy and mirror tasks, type:
  
  ```sh
  $ ./CopyDirFile.sh show running

   ID  PROCESS ID    TYPE  SOURCE                                    DESTINATION                               REFRESH  TWO DIRECTION
===================================================================================================================================
    2        2890    copy  /source/file.txt                          /destination/folder/.                          5s          false

  ```
  
  If you want to stop a copy or mirror task, type its ID:
  
  ```sh
  $ ./CopyDirFile.sh stop 2
[INFO] Running copy task ID 2 with process ID 2890 has been stopped
  ```
  
  Copy tasks or mirror tasks that are not running can be deleted completely by typing its ID:
  
  ```sh
  $ ./CopyDirFile.sh del 2
[INFO] Deleted copy task with ID: 2
  ```
  
  If you want to access the script from any location, you can copy it to the folder provided in this example and name it as you want it to be called. In this example, the copied script will be named `cdf`:
  
  ```sh
  $ sudo cp ~/CopyDirFile.sh /usr/bin/cdf
  ```
