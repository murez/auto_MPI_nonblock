; ModuleID = 'main.ll'
source_filename = "main.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@.str = private unnamed_addr constant [18 x i8] c"rand_nums != NULL\00", align 1
@.str.1 = private unnamed_addr constant [9 x i8] c"main.cpp\00", align 1
@__PRETTY_FUNCTION__._Z16create_rand_numsi = private unnamed_addr constant [29 x i8] c"float *create_rand_nums(int)\00", align 1
@stderr = external global ptr, align 8
@.str.2 = private unnamed_addr constant [34 x i8] c"Usage: avg num_elements_per_proc\0A\00", align 1
@.str.3 = private unnamed_addr constant [41 x i8] c"Local sum for process %d - %f, avg = %f\0A\00", align 1
@.str.4 = private unnamed_addr constant [26 x i8] c"Total sum = %f, avg = %f\0A\00", align 1

; Function Attrs: mustprogress noinline nounwind optnone uwtable
define dso_local noundef ptr @_Z16create_rand_numsi(i32 noundef %0) #0 {
  %2 = alloca i32, align 4
  %3 = alloca ptr, align 8
  %4 = alloca i32, align 4
  store i32 %0, ptr %2, align 4
  %5 = load i32, ptr %2, align 4
  %6 = sext i32 %5 to i64
  %7 = mul i64 4, %6
  %8 = call noalias ptr @malloc(i64 noundef %7) #7
  store ptr %8, ptr %3, align 8
  %9 = load ptr, ptr %3, align 8
  %10 = icmp ne ptr %9, null
  br i1 %10, label %11, label %12

11:                                               ; preds = %1
  br label %14

12:                                               ; preds = %1
  call void @__assert_fail(ptr noundef @.str, ptr noundef @.str.1, i32 noundef 10, ptr noundef @__PRETTY_FUNCTION__._Z16create_rand_numsi) #8
  unreachable

13:                                               ; No predecessors!
  br label %14

14:                                               ; preds = %13, %11
  store i32 0, ptr %4, align 4
  br label %15

15:                                               ; preds = %27, %14
  %16 = load i32, ptr %4, align 4
  %17 = load i32, ptr %2, align 4
  %18 = icmp slt i32 %16, %17
  br i1 %18, label %19, label %30

19:                                               ; preds = %15
  %20 = call i32 @rand() #9
  %21 = sitofp i32 %20 to float
  %22 = fdiv float %21, 0x41E0000000000000
  %23 = load ptr, ptr %3, align 8
  %24 = load i32, ptr %4, align 4
  %25 = sext i32 %24 to i64
  %26 = getelementptr inbounds float, ptr %23, i64 %25
  store float %22, ptr %26, align 4
  br label %27

27:                                               ; preds = %19
  %28 = load i32, ptr %4, align 4
  %29 = add nsw i32 %28, 1
  store i32 %29, ptr %4, align 4
  br label %15, !llvm.loop !6

30:                                               ; preds = %15
  %31 = load ptr, ptr %3, align 8
  ret ptr %31
}

; Function Attrs: nounwind allocsize(0)
declare noalias ptr @malloc(i64 noundef) #1

; Function Attrs: noreturn nounwind
declare void @__assert_fail(ptr noundef, ptr noundef, i32 noundef, ptr noundef) #2

; Function Attrs: nounwind
declare i32 @rand() #3

; Function Attrs: mustprogress noinline norecurse optnone uwtable
define dso_local noundef i32 @main(i32 noundef %0, ptr noundef %1) #4 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca ptr, align 8
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  %9 = alloca ptr, align 8
  %10 = alloca float, align 4
  %11 = alloca i32, align 4
  %12 = alloca float, align 4
  store i32 0, ptr %3, align 4
  store i32 %0, ptr %4, align 4
  store ptr %1, ptr %5, align 8
  %13 = load i32, ptr %4, align 4
  %14 = icmp ne i32 %13, 2
  br i1 %14, label %15, label %18

15:                                               ; preds = %2
  %16 = load ptr, ptr @stderr, align 8
  %17 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %16, ptr noundef @.str.2)
  call void @exit(i32 noundef 1) #8
  unreachable

18:                                               ; preds = %2
  %19 = load ptr, ptr %5, align 8
  %20 = getelementptr inbounds ptr, ptr %19, i64 1
  %21 = load ptr, ptr %20, align 8
  %22 = call i32 @atoi(ptr noundef %21) #10
  store i32 %22, ptr %6, align 4
  %23 = call i32 @MPI_Init(ptr noundef null, ptr noundef null)
  %24 = call i32 @MPI_Comm_rank(i32 noundef 1140850688, ptr noundef %7)
  %25 = call i32 @MPI_Comm_size(i32 noundef 1140850688, ptr noundef %8)
  %26 = call i64 @time(ptr noundef null) #9
  %27 = load i32, ptr %7, align 4
  %28 = sext i32 %27 to i64
  %29 = mul nsw i64 %26, %28
  %30 = trunc i64 %29 to i32
  call void @srand(i32 noundef %30) #9
  store ptr null, ptr %9, align 8
  %31 = load i32, ptr %6, align 4
  %32 = call noundef ptr @_Z16create_rand_numsi(i32 noundef %31)
  store ptr %32, ptr %9, align 8
  store float 0.000000e+00, ptr %10, align 4
  store i32 0, ptr %11, align 4
  br label %33

33:                                               ; preds = %45, %18
  %34 = load i32, ptr %11, align 4
  %35 = load i32, ptr %6, align 4
  %36 = icmp slt i32 %34, %35
  br i1 %36, label %37, label %48

37:                                               ; preds = %33
  %38 = load ptr, ptr %9, align 8
  %39 = load i32, ptr %11, align 4
  %40 = sext i32 %39 to i64
  %41 = getelementptr inbounds float, ptr %38, i64 %40
  %42 = load float, ptr %41, align 4
  %43 = load float, ptr %10, align 4
  %44 = fadd float %43, %42
  store float %44, ptr %10, align 4
  br label %45

45:                                               ; preds = %37
  %46 = load i32, ptr %11, align 4
  %47 = add nsw i32 %46, 1
  store i32 %47, ptr %11, align 4
  br label %33, !llvm.loop !8

48:                                               ; preds = %33
  %49 = load i32, ptr %7, align 4
  %50 = load float, ptr %10, align 4
  %51 = fpext float %50 to double
  %52 = load float, ptr %10, align 4
  %53 = load i32, ptr %6, align 4
  %54 = sitofp i32 %53 to float
  %55 = fdiv float %52, %54
  %56 = fpext float %55 to double
  %57 = call i32 (ptr, ...) @printf(ptr noundef @.str.3, i32 noundef %49, double noundef %51, double noundef %56)
  %mpi_req_1804289383 = alloca i32, align 4
  %mpi_status_1804289383 = alloca i32, align 4
  %MPI_Ireduce_1804289383 = call i32 @MPI_Ireduce(ptr %10, ptr %12, i32 1, i32 1275069450, i32 1476395011, i32 0, i32 1140850688, ptr %mpi_req_1804289383)
  %MPI_Wait_1804289383 = call i32 @MPI_Wait(ptr %mpi_req_1804289383, ptr %mpi_status_1804289383)
  %58 = load i32, ptr %7, align 4
  %59 = icmp eq i32 %58, 0
  br i1 %59, label %60, label %71

60:                                               ; preds = %48
  %61 = load float, ptr %12, align 4
  %62 = fpext float %61 to double
  %63 = load float, ptr %12, align 4
  %64 = load i32, ptr %8, align 4
  %65 = load i32, ptr %6, align 4
  %66 = mul nsw i32 %64, %65
  %67 = sitofp i32 %66 to float
  %68 = fdiv float %63, %67
  %69 = fpext float %68 to double
  %70 = call i32 (ptr, ...) @printf(ptr noundef @.str.4, double noundef %62, double noundef %69)
  br label %71

71:                                               ; preds = %60, %48
  %72 = load ptr, ptr %9, align 8
  call void @free(ptr noundef %72) #9
  %73 = call i32 @MPI_Barrier(i32 noundef 1140850688)
  %74 = call i32 @MPI_Finalize()
  %75 = load i32, ptr %3, align 4
  ret i32 %75
}

declare i32 @fprintf(ptr noundef, ptr noundef, ...) #5

; Function Attrs: noreturn nounwind
declare void @exit(i32 noundef) #2

; Function Attrs: nounwind willreturn memory(read)
declare i32 @atoi(ptr noundef) #6

declare i32 @MPI_Init(ptr noundef, ptr noundef) #5

declare i32 @MPI_Comm_rank(i32 noundef, ptr noundef) #5

declare i32 @MPI_Comm_size(i32 noundef, ptr noundef) #5

; Function Attrs: nounwind
declare void @srand(i32 noundef) #3

; Function Attrs: nounwind
declare i64 @time(ptr noundef) #3

declare i32 @printf(ptr noundef, ...) #5

declare i32 @MPI_Reduce(ptr noundef, ptr noundef, i32 noundef, i32 noundef, i32 noundef, i32 noundef, i32 noundef) #5

declare i32 @MPI_Ireduce(ptr noundef, ptr noundef, i32 noundef, i32 noundef, i32 noundef, i32 noundef, i32 noundef, ptr noundef) #5

declare i32 @MPI_Wait(ptr noundef, ptr noundef) #5

; Function Attrs: nounwind
declare void @free(ptr noundef) #3

declare i32 @MPI_Barrier(i32 noundef) #5

declare i32 @MPI_Finalize() #5

attributes #0 = { mustprogress noinline nounwind optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nounwind allocsize(0) "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { noreturn nounwind "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { nounwind "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #4 = { mustprogress noinline norecurse optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #5 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #6 = { nounwind willreturn memory(read) "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #7 = { nounwind allocsize(0) }
attributes #8 = { noreturn nounwind }
attributes #9 = { nounwind }
attributes #10 = { nounwind willreturn memory(read) }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"clang version 17.0.4"}
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.mustprogress"}
!8 = distinct !{!8, !7}
