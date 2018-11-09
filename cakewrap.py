#!/usr/bin/env python3
"""
Wrapper for the CakeML compiler
"""

# CHANGE THESE
CAKE_LOCATION = "/home/barclata/cake-x64-64/cake"
DEFAULT_BASIS = "./mod_basis_ffi.c"

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
    BASIS = args.basis 
    subprocess.call([CAKE_LOCATION], stdout=output_file, stdin=input_file)
    output_file.close()
    input_file.close()
    subprocess.call(['gcc', '-o', binary_name, BASIS, '/tmp/result.S'] + args.other)

if __name__ == "__main__":
    """ This is executed when run from the command line """
    parser = argparse.ArgumentParser(description="Wrapper for the CakeML compiler")
    parser.add_argument("input", help="CakeML file")
    parser.add_argument("--basis", default=DEFAULT_BASIS, help="basis file")
    parser.add_argument("other", metavar="cFile", default=[], nargs="*", help="other files to compile with gcc")
    parser.add_argument("-o", "--output_file", dest="output_name", default="cake_output", help="name of the output binary")

    args = parser.parse_args()
    main(args)
