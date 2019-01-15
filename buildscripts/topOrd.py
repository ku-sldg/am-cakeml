#!/usr/bin/env python3

import sys
import functools

def main(filename):
    file = open(filename, "r")
    text = file.read()
    file.close()

    graph = {}
    topOrd = []

    lineIter = iter(list(map(str.strip, str.splitlines(text))))
    prev = ""
    for line in lineIter:
        line = prev + line
        if line == "" or line[0] == "#":
            continue
        if line[-1] == "\\":
            prev += line[:-1]
            continue
        prev = ""
        (file, sep, deps) = line.partition(":")
        if sep == "":
            sys.stderr.write("No colon on this line.\n")
            sys.exit(1)
        graph[str.strip(file)] = str.strip(deps).split()

    for (node, deps) in graph.copy().items():
        for dep in deps:
            if not dep in graph:
                graph[dep] = []

    while True:
        progress = False
        for (node, deps) in graph.copy().items():
            if all(list(map(lambda x: x in topOrd, deps))):
                topOrd.append(node)
                graph.pop(node, None)
                progress = True
                break
        if not graph:
            break
        if not progress:
            sys.stderr.write("Circular dependency found.\n")
            sys.exit(1)

    print(functools.reduce((lambda x, y: x + " " + y), topOrd))

if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.stderr.write("This script requires a filename argument.\n")
        sys.exit(1)
    else:
        main(sys.argv[1])
