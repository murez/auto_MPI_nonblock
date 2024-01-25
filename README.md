# auto MPI nonblocking
a very naive idea

```
mkdir build && cd build
cmake ..
make
cd ..
mpicc -S main.cpp -emit-llvm
opt -f -load-pass-plugin=./build/libReplaceMPIReduce.so -passes=replace-mpi-reduce -S  main.ll -o main_non_block.ll
```