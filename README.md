# CopyDirFile
 [Bash] CopyDirFile is used to create tasks in background for copying files or folders to a given location every specified time period.  
 
  The script allows you to easily add copy tasks that run in the background.  
  When creating a task you specify the time after which copying should be performed again until it is stopped.  
  You can easily display a list of created tasks and those that are currently running.  
  
## Command syntax
  - `add <source> <destination> <refresh_time> [<two_directions>]`  - creates a new copy task
  - `show <all|running|task_ID>`  - displays a list of created copy tasks
  - `start <all|task_ID>`  - runs copy tasks
  - `del <all|task_ID>`  - deletes all or specified copy tasks
  - `stop <all|task_ID>`  - stops all or specified running copy tasks
  - `help`  - display this help page
  - `about`  - display information about this program
  
