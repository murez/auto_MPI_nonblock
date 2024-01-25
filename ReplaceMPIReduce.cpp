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

using namespace llvm;

std::string name_id(const std::string& a, int b) {
    std::ostringstream oss;
    oss << a << "_" << b;
    return oss.str();
}

//-----------------------------------------------------------------------------
// HelloWorld implementation
//-----------------------------------------------------------------------------
// No need to expose the internals of the pass to the outside world - keep
// everything in an anonymous namespace.
namespace {

void visitor(Module &M) {
  for (auto &F: M){
    for (auto &BB: F){
      for (auto &I: BB){
        // if call MPI_Reduce then
        // replace with MPI_Ireduce create an MPI_Request
        // add MPI_Wait after MPI_Ireduce
        if (auto *CI = dyn_cast<CallInst>(&I)){
          if (CI->getCalledFunction()->getName() == "MPI_Reduce"){
            errs()<<"Found MPI_Reduce\n";
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
            Function *MPI_Ireduce_Func = M.getFunction("MPI_Ireduce");
            Function *MPI_Wait_Func = M.getFunction("MPI_Wait");

            CallInst *MPI_Ireduce_Call = CallInst::Create(MPI_Ireduce_Func, Args);
            MPI_Ireduce_Call->setName(name_id("MPI_Ireduce", rand_id));
            MPI_Ireduce_Call->insertAfter(CI);
            
            CallInst *MPI_Wait_Call = CallInst::Create(MPI_Wait_Func, {mpi_req, mpi_status});
            MPI_Wait_Call->setName(name_id("MPI_Wait", rand_id));
            MPI_Wait_Call->insertAfter(MPI_Ireduce_Call);
            // mark this CI to be deleted
            
            errs()<<"Created MPI_Ireduce and MPI_Wait for ID: [" << rand_id << "]\n";

            CI->setName("MPI_Reduce_To_Delete");
          }
        }
      }
      BasicBlock::reverse_iterator I = BB.rbegin(), E = BB.rend();
      while (I != E) {
        Instruction *Inst = &*I;
        ++I;
        if (Inst->getName() == "MPI_Reduce_To_Delete"){
          Inst->eraseFromParent();
        }
      }
    }
  }
}

// New PM implementation
struct ReplaceMPIReduce : PassInfoMixin<ReplaceMPIReduce> {
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
llvm::PassPluginLibraryInfo getReplaceMPIReducePluginInfo() {
  return {LLVM_PLUGIN_API_VERSION, "ReplaceMPIReduce", LLVM_VERSION_STRING,
          [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
                [](StringRef Name, ModulePassManager &MPM,
                   ArrayRef<PassBuilder::PipelineElement>) {
                  if (Name == "replace-mpi-reduce") {
                    MPM.addPass(ReplaceMPIReduce());
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
  return getReplaceMPIReducePluginInfo();
}
