//=============================================================================
// FILE:
//    HelloWorld.cpp
//
// DESCRIPTION:
//    Visits all functions in a module, prints their names and the number of
//    arguments via stderr. Strictly speaking, this is an analysis pass (i.e.
//    the functions are not modified). However, in order to keep things simple
//    there's no 'print' method here (every analysis pass should implement it).
//
// USAGE:
//    New PM
//      opt -load-pass-plugin=libHelloWorld.dylib -passes="hello-world" `\`
//        -disable-output <input-llvm-file>
//
//
// License: MIT
//=============================================================================
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/IR/Attributes.h"
#include <alloca.h>
#include <sstream>
#include <tuple>
#include <utility>
#include <vector>
#include <unordered_map>
using namespace llvm;

std::string name_id(const std::string& a, int b) {
    std::ostringstream oss;
    oss << a << "_" << b;
    return oss.str();
}


namespace {

std::tuple<bool, std::string, std::string> is_mpi_collective_call(CallInst *CI) {
  std::vector<std::string> mpi_collective_calls = {
    "MPI_Allgather",
    "MPI_Allgatherv",
    "MPI_Allreduce",
    "MPI_Alltoall",
    "MPI_Alltoallv",
    "MPI_Alltoallw",
    "MPI_Bcast",
    "MPI_Exscan",
    "MPI_Gather",
    "MPI_Gatherv",
    "MPI_Reduce",
    "MPI_Reduce_scatter",
    "MPI_Reduce_scatter_block",
    "MPI_Scan",
    "MPI_Scatter",
    "MPI_Scatterv"
  };
  std::unordered_map<std::string, std::string> mpi_coll_block2nonblock = {
    {"MPI_Allgather", "MPI_Iallgather"},
    {"MPI_Allgatherv", "MPI_Iallgatherv"},
    {"MPI_Allreduce", "MPI_Iallreduce"},
    {"MPI_Alltoall", "MPI_Ialltoall"},
    {"MPI_Alltoallv", "MPI_Ialltoallv"},
    {"MPI_Alltoallw", "MPI_Ialltoallw"},
    {"MPI_Bcast", "MPI_Ibcast"},
    {"MPI_Exscan", "MPI_Iexscan"},
    {"MPI_Gather", "MPI_Igather"},
    {"MPI_Gatherv", "MPI_Igatherv"},
    {"MPI_Reduce", "MPI_Ireduce"},
    {"MPI_Reduce_scatter", "MPI_Ireduce_scatter"},
    {"MPI_Reduce_scatter_block", "MPI_Ireduce_scatter_block"},
    {"MPI_Scan", "MPI_Iscan"},
    {"MPI_Scatter", "MPI_Iscatter"},
    {"MPI_Scatterv", "MPI_Iscatterv"}
  };
  for (auto mpi_call: mpi_collective_calls){
    if (CI->getCalledFunction()->getName() == mpi_call){
      return std::make_tuple(true, mpi_call, mpi_coll_block2nonblock[mpi_call]);
    }
  }
  return std::make_tuple(false, "", "");
}

void visitor(Module &M) {
  for (auto &F: M){
    for (auto &BB: F){
      for (auto &I: BB){
        if (auto *CI = dyn_cast<CallInst>(&I)){
          auto [is_mpi_coll, func_name, nonblock_func_name] = is_mpi_collective_call(CI);
          if(is_mpi_coll){
            errs()<<"Found " << func_name <<" \n";
            int rand_id = rand();
            std::vector<Value *> Args(CI->arg_begin(), CI->arg_end());
            // create new var
            Type *Int32Ty = Type::getInt32Ty(M.getContext());
            Value *mpi_req_size = ConstantInt::get(Int32Ty, 1);

            AllocaInst *mpi_req = new AllocaInst(Int32Ty, 0, mpi_req_size, name_id("mpi_req", rand_id), CI);
            AllocaInst *mpi_status = new AllocaInst(Int32Ty, 0, mpi_req_size, name_id("mpi_status", rand_id), CI);

            errs()<<"Created mpi_req and mpi_status for ID: [" << rand_id << "]\n"; 

            Args.push_back(mpi_req);
            // create new call
            Function *MPI_I_Func = M.getFunction(nonblock_func_name);
            Function *MPI_Wait_Func = M.getFunction("MPI_Wait");

            CallInst *MPI_I_Call = CallInst::Create(MPI_I_Func, Args);
            MPI_I_Call->setName(name_id(nonblock_func_name, rand_id));
            MPI_I_Call->insertAfter(CI);
            
            CallInst *MPI_Wait_Call = CallInst::Create(MPI_Wait_Func, {mpi_req, mpi_status});
            MPI_Wait_Call->setName(name_id("MPI_Wait", rand_id));
            MPI_Wait_Call->insertAfter(MPI_I_Call);
            // mark this CI to be deleted
            
            errs()<<"Created "<< nonblock_func_name <<" and MPI_Wait for ID: [" << rand_id << "]\n";

            CI->setName("MPI_Coll_To_Delete");
          }
        }
      }
      BasicBlock::reverse_iterator I = BB.rbegin(), E = BB.rend();
      while (I != E) {
        Instruction *Inst = &*I;
        ++I;
        if (Inst->getName() == "MPI_Coll_To_Delete"){
          Inst->eraseFromParent();
        }
      }
    }
  }
}

// New PM implementation
struct ReplaceMPIColl : PassInfoMixin<ReplaceMPIColl> {
  // Main entry point, takes IR unit to run the pass on (&F) and the
  // corresponding pass manager (to be queried if need be)
  PreservedAnalyses run(Module &M, ModuleAnalysisManager &) {
    visitor(M);
    return PreservedAnalyses::all();
  }

  // Without isRequired returning true, this pass will be skipped for functions
  // decorated with the optnone LLVM attribute. Note that clang -O0 decorates
  // all functions with optnone.
  static bool isRequired() { return true; }
};
} // namespace

//-----------------------------------------------------------------------------
// New PM Registration
//-----------------------------------------------------------------------------
llvm::PassPluginLibraryInfo getReplaceMPICollPluginInfo() {
  return {LLVM_PLUGIN_API_VERSION, "ReplaceMPIColl", LLVM_VERSION_STRING,
          [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
                [](StringRef Name, ModulePassManager &MPM,
                   ArrayRef<PassBuilder::PipelineElement>) {
                  if (Name == "replace-mpi-coll") {
                    MPM.addPass(ReplaceMPIColl());
                    return true;
                  }
                  return false;
                });
          }};
}

// This is the core interface for pass plugins. It guarantees that 'opt' will
// be able to recognize HelloWorld when added to the pass pipeline on the
// command line, i.e. via '-passes=hello-world'
extern "C" LLVM_ATTRIBUTE_WEAK ::llvm::PassPluginLibraryInfo
llvmGetPassPluginInfo() {
  return getReplaceMPICollPluginInfo();
}
