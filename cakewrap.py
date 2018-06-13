#!/usr/bin/env python3
"""
Wrapper for the CakeML compiler
"""

# CHANGE THESE
CAKE_LOCATION = "/home/barclata/Projects/stairCASE/examples/CakeML/cake-x64/cake"
BASIS_LOCATION = "/home/barclata/Projects/stairCASE/examples/CakeML/cake-x64/basis_ffi.c"


__author__ = "TJ Barclay"
__version__ = "0.1.0"
__license__ = "MIT"

import argparse
import subprocess
import shutil

def main(args):
    output_file = open("/tmp/result.S", "w")
    input_file = open(args.input, "r")
    binary_name = args.output_name
    subprocess.call([CAKE_LOCATION], stdout=output_file, stdin=input_file)
    output_file.close()
    input_file.close()
    subprocess.call(['gcc', '-o', binary_name, BASIS_LOCATION, '/tmp/result.S'])




if __name__ == "__main__":
    """ This is executed when run from the command line """
    parser = argparse.ArgumentParser()
    parser.add_argument("input")
    parser.add_argument("output_name")


    args = parser.parse_args()
    main(args)
