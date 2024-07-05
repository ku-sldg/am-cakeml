# Tests

This folder contains some tests and demo scripts to run.

## [Demo.sh](./Demo.sh)

This script will run a demo script (where one of the flexible mechanisms can be chosen) to run.

### Prerequisities
- `tmux` 
- `nc` (netcat) 
- POSIX Shell

To close the tmux script, make sure you close all `tmux` panes using `PREFIX + x` where the prefix is typically (Ctrl + b)
(To kill all tmux panes at once, type 'tmux kill-server' in one of the open panes)

## [HeadlessDemo.sh](./HeadlessDemo.sh)

This script will run a demo script but it will not be interactive. Successful completion of this script with a 0 exit code implies that the test passed successfully.
