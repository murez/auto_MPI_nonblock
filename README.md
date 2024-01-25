# auto MPI nonblocking
a very naive idea

## Run

```bash
mkdir build && cd build
cmake ..
make
cd ..
mpicc -S main.cpp -emit-llvm
opt -f -load-pass-plugin=./build/libReplaceMPIReduce.so -passes=replace-mpi-reduce -S  main.ll -o main_non_block.ll
```

## TODO

1. finish all the collective MPI calls
2. try get data flow and rearrange IR order
3. find stencil pattern and acheive inner & outer seperate computation.