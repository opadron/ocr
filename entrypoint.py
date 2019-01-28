#! /usr/bin/env python

import argparse
import signal
import subprocess

parser = argparse.ArgumentParser(description="OCR Service")

def aa(*args, **kwargs):
    parser.add_argument(*args, required=True, **kwargs)

aa("-q", "--queue-dir" , help="Path from which to dequeue pending requests")
aa("-t", "--tmp-dir" , help="Directory for temporary files")
aa("-r", "--results-dir" , help="Path in which to store results data")

args = parser.parse_args()

subprocess.call(
        ["bash", "worker.bash", args.queue_dir, args.results_dir, args.tmp_dir])

