#!/usr/bin/env python3
"""
Wrapper for the CakeML compiler
"""

# CHANGE THESE
__author__ = "TJ Barclay"
__version__ = "0.1.0"
__license__ = "MIT"

import argparse
import subprocess
import shutil

def main(args):
    output_file = open("./" + args.output_name, "w")
    input_files = []
    for i in args.input:
        input_files.append(open(i, "r"))

    total_code = ""
    for f in input_files:
        total_code = total_code + "(*" + args.output_name + "*)\n"
        total_code = total_code + f.read()
        total_code = total_code + "\n(*----------------------------------------------------------------------------------*)\n"

    output_file.write(total_code)
    output_file.close()
    for f in input_files:
        f.close()

if __name__ == "__main__":
    """ This is executed when run from the command line """
    parser = argparse.ArgumentParser(description="Appends CakeML files together into one large file")
    parser.add_argument("input", nargs="+", help="CakeML file")
    parser.add_argument("-o", "--output_file", dest="output_name", default="cake_output.sml", help="name for output file")

    args = parser.parse_args()
    main(args)
