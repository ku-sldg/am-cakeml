# Tests

This folder contains some tests and demo scripts to run.

## Build and Test the CI suite

To build the code to support a number of pre-configured test protocols, first clone and build the appropriate branch of the asp-libs repository:    
&nbsp;&nbsp;&nbsp;&nbsp;https://github.com/ku-sldg/asp-libs

Next:  Set the environment variable `ASP_BIN` to point to the newly-created top-level `bin/` directory of asp-libs.

&nbsp;&nbsp;&nbsp;&nbsp;i.e.:  `export ASP_BIN=<some_path>/asp-libs/bin`


Then, back in this directory, do:

&nbsp;&nbsp;&nbsp;&nbsp;`make ci_build`

To subsequently run these test protocols, do:

&nbsp;&nbsp;&nbsp;&nbsp;`make ci_test`

(If you do simply: `make`, this will do both of the above in sequence)

Successful output from `make ci_test` will show a handful of protocol output logs, likely followed by text like:  "Killing background processes..." if no errors came up during execution.  Note that `make ci_test` will run each example protocol in "headless" mode (-h) so that all nodes (attestation manager executables) in the protocol will execute in the same terminal.  For the non-headless version using tmux, see details about [Demo.sh](./Demo.sh) below.

## INSPECTA Micro-example

First, set the `DEMO_ROOT` environment variable to point to a common directory that contains cloned sources of both the am-cakeml repository (this repo) and the INSPECTA-models repo (https://github.com/loonwerks/INSPECTA-models).

Then run:  
&nbsp;&nbsp;&nbsp;&nbsp;`make ci_build`, 

And finally:  

&nbsp;&nbsp;&nbsp;&nbsp;`./Demo.sh -t micro`


Successful output should look like:  "Resolute Policy check:  SUCCESS".

To demonstrate a failed appraisal (with output "Resolute Policy check:  FAILED"), make a local modification to one or both of the target micro example files ([addl file](https://github.com/loonwerks/INSPECTA-models/blob/main/micro-examples/microkit/aadl_port_types/data/base_type/aadl/data_1_prod_2_cons.aadl) , [microkit file](https://github.com/loonwerks/INSPECTA-models/blob/main/micro-examples/microkit/aadl_port_types/data/base_type/hamr/microkit/microkit.system)), then re-run `./Demo.sh -t micro`.

### Prerequisities
- `tmux` 
- `nc` (netcat) 
- POSIX Shell

To close the tmux script, make sure you close all `tmux` panes using `PREFIX + x` where the prefix is typically (Ctrl + b)
(To kill all tmux panes at once, type 'tmux kill-server' in one of the open panes)

## [Demo.sh](./Demo.sh)

This script will run a demo script (where one of the example protocols can be chosen) to run via the `-t` option:

&nbsp;&nbsp;&nbsp;&nbsp;i.e. `./Demo.sh -t cert`

### Prerequisities
- `tmux` 
- `nc` (netcat) 
- POSIX Shell

To close the tmux script, make sure you close all `tmux` panes using `PREFIX + x` where the prefix is typically (Ctrl + b)
(To kill all tmux panes at once, type 'tmux kill-server' in one of the open panes)
