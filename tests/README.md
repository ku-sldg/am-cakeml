# Tests

This folder contains some tests and demo scripts to run.

## Useful Make targets

* `make ci_build` (builds all executables to run the CI test suite)
* `make ci_test` (runs the CI test suite -- in headless mode)
* `make demo_<target>` (runs various pre-configured demo targets)  

    NOTE:  By convention, when `<target>` ends in `noclient`, the tmux session will NOT include an AM client pane -- it will only start the appropriate AM servers).

## [Demo.sh](./Demo.sh)

This script will run a demo script (where one of the flexible mechanisms can be chosen) to run.

### Prerequisities for Demo.sh

- `tmux` (for the non-headless version of ./Demo.sh -- without the -h option)
- POSIX Shell

NOTE:  To kill all tmux panes at once, type `tmux kill-server` in one of the open panes.


To close the tmux script, make sure you close all `tmux` panes using `PREFIX + x` where the prefix is typically (Ctrl + b).

