# auto MPI nonblocking
a very naive idea

## Run

```bash
mkdir build && cd build
cmake ..
make
cd ..
mpicc -S main.cpp -emit-llvm
opt -f -load-pass-plugin=./build/libReplaceMPIColl.so -passes=replace-mpi-coll -S  main.ll -o m.ll
```

## TODO

1. [x] finish all the collective MPI calls
2. [ ] try get data flow and rearrange IR order
3. [ ] find stencil pattern and acheive inner & outer seperate computation.