; ModuleID = 'bloglang'
source_filename = "bloglang"

%stack = type opaque
%node_base = type { i32 }
%node_num = type { %node_base, i32 }
%node_data = type { %node_base, i8, %node_base** }

declare void @stack_init(%stack*)

declare void @stack_free(%stack*)

declare void @stack_push(%stack*, %node_base*)

declare %node_base* @stack_pop(%stack*)

declare %node_base* @stack_peek(%stack*, i64)

declare void @stack_popn(%stack*, i64)

declare void @stack_slide(%stack*, i64)

declare void @stack_update(%stack*, i64)

declare void @stack_alloc(%stack*, i64)

declare void @stack_pack(%stack*, i64, i8)

declare %node_base* @stack_split(%stack*, i64)

declare %node_base* @alloc_app(%node_base*, %node_base*)

declare %node_base* @alloc_num(i32)

declare %node_base* @alloc_global(void (%stack*), i32)

declare %node_base* @alloc_ind(%node_base*)

declare %node_base* @eval(%node_base*)

define void @f_plus(%stack* %0) {
entry:
  %1 = call %node_base* @stack_peek(%stack* %0, i64 1)
  call void @stack_push(%stack* %0, %node_base* %1)
  %2 = call %node_base* @stack_pop(%stack* %0)
  %3 = call %node_base* @eval(%node_base* %2)
  call void @stack_push(%stack* %0, %node_base* %3)
  %4 = call %node_base* @stack_peek(%stack* %0, i64 1)
  call void @stack_push(%stack* %0, %node_base* %4)
  %5 = call %node_base* @stack_pop(%stack* %0)
  %6 = call %node_base* @eval(%node_base* %5)
  call void @stack_push(%stack* %0, %node_base* %6)
  %7 = call %node_base* @stack_pop(%stack* %0)
  %8 = bitcast %node_base* %7 to %node_num*
  %9 = getelementptr %node_num, %node_num* %8, i32 0, i32 1
  %10 = load i32, i32* %9
  %11 = call %node_base* @stack_pop(%stack* %0)
  %12 = bitcast %node_base* %11 to %node_num*
  %13 = getelementptr %node_num, %node_num* %12, i32 0, i32 1
  %14 = load i32, i32* %13
  %15 = add i32 %10, %14
  %16 = call %node_base* @alloc_num(i32 %15)
  call void @stack_push(%stack* %0, %node_base* %16)
  ret void
}

define void @f_minus(%stack* %0) {
entry:
  %1 = call %node_base* @stack_peek(%stack* %0, i64 1)
  call void @stack_push(%stack* %0, %node_base* %1)
  %2 = call %node_base* @stack_pop(%stack* %0)
  %3 = call %node_base* @eval(%node_base* %2)
  call void @stack_push(%stack* %0, %node_base* %3)
  %4 = call %node_base* @stack_peek(%stack* %0, i64 1)
  call void @stack_push(%stack* %0, %node_base* %4)
  %5 = call %node_base* @stack_pop(%stack* %0)
  %6 = call %node_base* @eval(%node_base* %5)
  call void @stack_push(%stack* %0, %node_base* %6)
  %7 = call %node_base* @stack_pop(%stack* %0)
  %8 = bitcast %node_base* %7 to %node_num*
  %9 = getelementptr %node_num, %node_num* %8, i32 0, i32 1
  %10 = load i32, i32* %9
  %11 = call %node_base* @stack_pop(%stack* %0)
  %12 = bitcast %node_base* %11 to %node_num*
  %13 = getelementptr %node_num, %node_num* %12, i32 0, i32 1
  %14 = load i32, i32* %13
  %15 = sub i32 %10, %14
  %16 = call %node_base* @alloc_num(i32 %15)
  call void @stack_push(%stack* %0, %node_base* %16)
  ret void
}

define void @f_times(%stack* %0) {
entry:
  %1 = call %node_base* @stack_peek(%stack* %0, i64 1)
  call void @stack_push(%stack* %0, %node_base* %1)
  %2 = call %node_base* @stack_pop(%stack* %0)
  %3 = call %node_base* @eval(%node_base* %2)
  call void @stack_push(%stack* %0, %node_base* %3)
  %4 = call %node_base* @stack_peek(%stack* %0, i64 1)
  call void @stack_push(%stack* %0, %node_base* %4)
  %5 = call %node_base* @stack_pop(%stack* %0)
  %6 = call %node_base* @eval(%node_base* %5)
  call void @stack_push(%stack* %0, %node_base* %6)
  %7 = call %node_base* @stack_pop(%stack* %0)
  %8 = bitcast %node_base* %7 to %node_num*
  %9 = getelementptr %node_num, %node_num* %8, i32 0, i32 1
  %10 = load i32, i32* %9
  %11 = call %node_base* @stack_pop(%stack* %0)
  %12 = bitcast %node_base* %11 to %node_num*
  %13 = getelementptr %node_num, %node_num* %12, i32 0, i32 1
  %14 = load i32, i32* %13
  %15 = mul i32 %10, %14
  %16 = call %node_base* @alloc_num(i32 %15)
  call void @stack_push(%stack* %0, %node_base* %16)
  ret void
}

define void @f_divide(%stack* %0) {
entry:
  %1 = call %node_base* @stack_peek(%stack* %0, i64 1)
  call void @stack_push(%stack* %0, %node_base* %1)
  %2 = call %node_base* @stack_pop(%stack* %0)
  %3 = call %node_base* @eval(%node_base* %2)
  call void @stack_push(%stack* %0, %node_base* %3)
  %4 = call %node_base* @stack_peek(%stack* %0, i64 1)
  call void @stack_push(%stack* %0, %node_base* %4)
  %5 = call %node_base* @stack_pop(%stack* %0)
  %6 = call %node_base* @eval(%node_base* %5)
  call void @stack_push(%stack* %0, %node_base* %6)
  %7 = call %node_base* @stack_pop(%stack* %0)
  %8 = bitcast %node_base* %7 to %node_num*
  %9 = getelementptr %node_num, %node_num* %8, i32 0, i32 1
  %10 = load i32, i32* %9
  %11 = call %node_base* @stack_pop(%stack* %0)
  %12 = bitcast %node_base* %11 to %node_num*
  %13 = getelementptr %node_num, %node_num* %12, i32 0, i32 1
  %14 = load i32, i32* %13
  %15 = sdiv i32 %10, %14
  %16 = call %node_base* @alloc_num(i32 %15)
  call void @stack_push(%stack* %0, %node_base* %16)
  ret void
}

define void @f_Nil(%stack* %0) {
entry:
  call void @stack_pack(%stack* %0, i64 0, i8 0)
  ret void
}

define void @f_Cons(%stack* %0) {
entry:
  call void @stack_pack(%stack* %0, i64 2, i8 1)
  ret void
}

define void @f_length(%stack* %0) {
entry:
  %1 = call %node_base* @stack_peek(%stack* %0, i64 0)
  call void @stack_push(%stack* %0, %node_base* %1)
  %2 = call %node_base* @stack_pop(%stack* %0)
  %3 = call %node_base* @eval(%node_base* %2)
  call void @stack_push(%stack* %0, %node_base* %3)
  %4 = call %node_base* @stack_peek(%stack* %0, i64 0)
  %5 = bitcast %node_base* %4 to %node_data*
  %6 = getelementptr %node_data, %node_data* %5, i32 0, i32 1
  %7 = load i8, i8* %6
  switch i8 %7, label %safety [
    i8 0, label %branch
    i8 1, label %branch1
  ]

safety:                                           ; preds = %branch1, %branch, %entry
  call void @stack_update(%stack* %0, i64 1)
  call void @stack_popn(%stack* %0, i64 1)
  ret void

branch:                                           ; preds = %entry
  %8 = call %node_base* @stack_split(%stack* %0, i64 0)
  %9 = call %node_base* @alloc_num(i32 0)
  call void @stack_push(%stack* %0, %node_base* %9)
  call void @stack_slide(%stack* %0, i64 0)
  br label %safety

branch1:                                          ; preds = %entry
  %10 = call %node_base* @stack_split(%stack* %0, i64 2)
  %11 = call %node_base* @stack_peek(%stack* %0, i64 1)
  call void @stack_push(%stack* %0, %node_base* %11)
  %12 = call %node_base* @alloc_global(void (%stack*)* @f_length, i32 1)
  call void @stack_push(%stack* %0, %node_base* %12)
  %13 = call %node_base* @stack_pop(%stack* %0)
  %14 = call %node_base* @stack_pop(%stack* %0)
  %15 = call %node_base* @alloc_app(%node_base* %13, %node_base* %14)
  call void @stack_push(%stack* %0, %node_base* %15)
  %16 = call %node_base* @alloc_num(i32 1)
  call void @stack_push(%stack* %0, %node_base* %16)
  %17 = call %node_base* @alloc_global(void (%stack*)* @f_plus, i32 2)
  call void @stack_push(%stack* %0, %node_base* %17)
  %18 = call %node_base* @stack_pop(%stack* %0)
  %19 = call %node_base* @stack_pop(%stack* %0)
  %20 = call %node_base* @alloc_app(%node_base* %18, %node_base* %19)
  call void @stack_push(%stack* %0, %node_base* %20)
  %21 = call %node_base* @stack_pop(%stack* %0)
  %22 = call %node_base* @stack_pop(%stack* %0)
  %23 = call %node_base* @alloc_app(%node_base* %21, %node_base* %22)
  call void @stack_push(%stack* %0, %node_base* %23)
  call void @stack_slide(%stack* %0, i64 2)
  br label %safety
}

define void @f_main(%stack* %0) {
entry:
  %1 = call %node_base* @alloc_global(void (%stack*)* @f_Nil, i32 0)
  call void @stack_push(%stack* %0, %node_base* %1)
  %2 = call %node_base* @alloc_num(i32 3)
  call void @stack_push(%stack* %0, %node_base* %2)
  %3 = call %node_base* @alloc_global(void (%stack*)* @f_Cons, i32 2)
  call void @stack_push(%stack* %0, %node_base* %3)
  %4 = call %node_base* @stack_pop(%stack* %0)
  %5 = call %node_base* @stack_pop(%stack* %0)
  %6 = call %node_base* @alloc_app(%node_base* %4, %node_base* %5)
  call void @stack_push(%stack* %0, %node_base* %6)
  %7 = call %node_base* @stack_pop(%stack* %0)
  %8 = call %node_base* @stack_pop(%stack* %0)
  %9 = call %node_base* @alloc_app(%node_base* %7, %node_base* %8)
  call void @stack_push(%stack* %0, %node_base* %9)
  %10 = call %node_base* @alloc_num(i32 2)
  call void @stack_push(%stack* %0, %node_base* %10)
  %11 = call %node_base* @alloc_global(void (%stack*)* @f_Cons, i32 2)
  call void @stack_push(%stack* %0, %node_base* %11)
  %12 = call %node_base* @stack_pop(%stack* %0)
  %13 = call %node_base* @stack_pop(%stack* %0)
  %14 = call %node_base* @alloc_app(%node_base* %12, %node_base* %13)
  call void @stack_push(%stack* %0, %node_base* %14)
  %15 = call %node_base* @stack_pop(%stack* %0)
  %16 = call %node_base* @stack_pop(%stack* %0)
  %17 = call %node_base* @alloc_app(%node_base* %15, %node_base* %16)
  call void @stack_push(%stack* %0, %node_base* %17)
  %18 = call %node_base* @alloc_num(i32 1)
  call void @stack_push(%stack* %0, %node_base* %18)
  %19 = call %node_base* @alloc_global(void (%stack*)* @f_Cons, i32 2)
  call void @stack_push(%stack* %0, %node_base* %19)
  %20 = call %node_base* @stack_pop(%stack* %0)
  %21 = call %node_base* @stack_pop(%stack* %0)
  %22 = call %node_base* @alloc_app(%node_base* %20, %node_base* %21)
  call void @stack_push(%stack* %0, %node_base* %22)
  %23 = call %node_base* @stack_pop(%stack* %0)
  %24 = call %node_base* @stack_pop(%stack* %0)
  %25 = call %node_base* @alloc_app(%node_base* %23, %node_base* %24)
  call void @stack_push(%stack* %0, %node_base* %25)
  %26 = call %node_base* @alloc_global(void (%stack*)* @f_length, i32 1)
  call void @stack_push(%stack* %0, %node_base* %26)
  %27 = call %node_base* @stack_pop(%stack* %0)
  %28 = call %node_base* @stack_pop(%stack* %0)
  %29 = call %node_base* @alloc_app(%node_base* %27, %node_base* %28)
  call void @stack_push(%stack* %0, %node_base* %29)
  call void @stack_update(%stack* %0, i64 0)
  call void @stack_popn(%stack* %0, i64 0)
  ret void
}
