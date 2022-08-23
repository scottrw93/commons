#!/bin/bash
set -e

cd ../logs
cp access.log access_copy.log
tar vcfz archive.tar access_copy.log
