#!/bin/bash
set -e

echo "--- Test MPICH installation ---"

printf "Check mpicc... "
mpicc --version > /dev/null
echo OK

printf "Check mpic++... "
mpic++ --version > /dev/null
echo OK

printf "Check mpiexec... "
mpiexec --version > /dev/null
echo OK

shopt -s dotglob

find * -prune -type d | while IFS= read -r d; do 
    printf "Compile $d... "
    cd $d
    
    mpic++ *.cpp -o ./app > /dev/null

    echo OK
    cd ../
done
