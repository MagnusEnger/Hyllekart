#!/bin/bash

dbicdump -o dump_directory=./lib Hyllekart::Schema dbi:mysql:hyllekart hyllekart pass
