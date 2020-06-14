; ModuleID = 'funlang'
source_filename = "funlang"

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

declare void @stack_split(%stack*, i64)

declare %node_base* @stack_pack(%stack*, i64, i8)

declare %node_base* @alloc_app(%node_base*, %node_base*)

declare %node_base* @alloc_num(i32)

declare %node_base* @alloc_global(void (%stack*)*, i32)

declare %node_base* @alloc_ind(%node_base*)

declare %node_base* @eval(%node_base*)

declare void @unwind(%stack*)

define void @f_plus(%stack* %0) {
entry:
  %call_peek = call %node_base* @stack_peek(%stack* %0, i64 1)
  call void @stack_push(%stack* %0, %node_base* %call_peek)
  call void @unwind(%stack* %0)
  %call_peek1 = call %node_base* @stack_peek(%stack* %0, i64 1)
  call void @stack_push(%stack* %0, %node_base* %call_peek1)
  call void @unwind(%stack* %0)
  %call_pop = call %node_base* @stack_pop(%stack* %0)
  %node_num_cast = bitcast %node_base* %call_pop to %node_num*
  %node_num_gep = getelementptr %node_num, %node_num* %node_num_cast, i32 0, i32 1
  %node_num_mem_load = load i32, i32* %node_num_gep
  %call_pop2 = call %node_base* @stack_pop(%stack* %0)
  %node_num_cast3 = bitcast %node_base* %call_pop2 to %node_num*
  %node_num_gep4 = getelementptr %node_num, %node_num* %node_num_cast3, i32 0, i32 1
  %node_num_mem_load5 = load i32, i32* %node_num_gep4
  %int_add = add i32 %node_num_mem_load, %node_num_mem_load5
  %call_alloc_num = call %node_base* @alloc_num(i32 %int_add)
  call void @stack_push(%stack* %0, %node_base* %call_alloc_num)
  call void @stack_update(%stack* %0, i64 2)
  call void @stack_popn(%stack* %0, i64 2)
  ret void
}

define void @f_minus(%stack* %0) {
entry:
  %call_peek = call %node_base* @stack_peek(%stack* %0, i64 1)
  call void @stack_push(%stack* %0, %node_base* %call_peek)
  call void @unwind(%stack* %0)
  %call_peek1 = call %node_base* @stack_peek(%stack* %0, i64 1)
  call void @stack_push(%stack* %0, %node_base* %call_peek1)
  call void @unwind(%stack* %0)
  %call_pop = call %node_base* @stack_pop(%stack* %0)
  %node_num_cast = bitcast %node_base* %call_pop to %node_num*
  %node_num_gep = getelementptr %node_num, %node_num* %node_num_cast, i32 0, i32 1
  %node_num_mem_load = load i32, i32* %node_num_gep
  %call_pop2 = call %node_base* @stack_pop(%stack* %0)
  %node_num_cast3 = bitcast %node_base* %call_pop2 to %node_num*
  %node_num_gep4 = getelementptr %node_num, %node_num* %node_num_cast3, i32 0, i32 1
  %node_num_mem_load5 = load i32, i32* %node_num_gep4
  %int_sub = sub i32 %node_num_mem_load, %node_num_mem_load5
  %call_alloc_num = call %node_base* @alloc_num(i32 %int_sub)
  call void @stack_push(%stack* %0, %node_base* %call_alloc_num)
  call void @stack_update(%stack* %0, i64 2)
  call void @stack_popn(%stack* %0, i64 2)
  ret void
}

define void @f_times(%stack* %0) {
entry:
  %call_peek = call %node_base* @stack_peek(%stack* %0, i64 1)
  call void @stack_push(%stack* %0, %node_base* %call_peek)
  call void @unwind(%stack* %0)
  %call_peek1 = call %node_base* @stack_peek(%stack* %0, i64 1)
  call void @stack_push(%stack* %0, %node_base* %call_peek1)
  call void @unwind(%stack* %0)
  %call_pop = call %node_base* @stack_pop(%stack* %0)
  %node_num_cast = bitcast %node_base* %call_pop to %node_num*
  %node_num_gep = getelementptr %node_num, %node_num* %node_num_cast, i32 0, i32 1
  %node_num_mem_load = load i32, i32* %node_num_gep
  %call_pop2 = call %node_base* @stack_pop(%stack* %0)
  %node_num_cast3 = bitcast %node_base* %call_pop2 to %node_num*
  %node_num_gep4 = getelementptr %node_num, %node_num* %node_num_cast3, i32 0, i32 1
  %node_num_mem_load5 = load i32, i32* %node_num_gep4
  %int_mul = mul i32 %node_num_mem_load, %node_num_mem_load5
  %call_alloc_num = call %node_base* @alloc_num(i32 %int_mul)
  call void @stack_push(%stack* %0, %node_base* %call_alloc_num)
  call void @stack_update(%stack* %0, i64 2)
  call void @stack_popn(%stack* %0, i64 2)
  ret void
}

define void @f_divide(%stack* %0) {
entry:
  %call_peek = call %node_base* @stack_peek(%stack* %0, i64 1)
  call void @stack_push(%stack* %0, %node_base* %call_peek)
  call void @unwind(%stack* %0)
  %call_peek1 = call %node_base* @stack_peek(%stack* %0, i64 1)
  call void @stack_push(%stack* %0, %node_base* %call_peek1)
  call void @unwind(%stack* %0)
  %call_pop = call %node_base* @stack_pop(%stack* %0)
  %node_num_cast = bitcast %node_base* %call_pop to %node_num*
  %node_num_gep = getelementptr %node_num, %node_num* %node_num_cast, i32 0, i32 1
  %node_num_mem_load = load i32, i32* %node_num_gep
  %call_pop2 = call %node_base* @stack_pop(%stack* %0)
  %node_num_cast3 = bitcast %node_base* %call_pop2 to %node_num*
  %node_num_gep4 = getelementptr %node_num, %node_num* %node_num_cast3, i32 0, i32 1
  %node_num_mem_load5 = load i32, i32* %node_num_gep4
  %int_sdiv = sdiv i32 %node_num_mem_load, %node_num_mem_load5
  %call_alloc_num = call %node_base* @alloc_num(i32 %int_sdiv)
  call void @stack_push(%stack* %0, %node_base* %call_alloc_num)
  call void @stack_update(%stack* %0, i64 2)
  call void @stack_popn(%stack* %0, i64 2)
  ret void
}

define void @f_Cons(%stack* %0) {
entry:
  %call_pack = call %node_base* @stack_pack(%stack* %0, i64 2, i8 0)
  call void @stack_update(%stack* %0, i64 0)
  ret void
}

define void @f_Nil(%stack* %0) {
entry:
  %call_pack = call %node_base* @stack_pack(%stack* %0, i64 0, i8 1)
  call void @stack_update(%stack* %0, i64 0)
  ret void
}

define void @f_applyToList(%stack* %0) {
entry:
  %call_peek = call %node_base* @stack_peek(%stack* %0, i64 1)
  call void @stack_push(%stack* %0, %node_base* %call_peek)
  call void @unwind(%stack* %0)
  %call_peek1 = call %node_base* @stack_peek(%stack* %0, i64 0)
  %node_data_cast = bitcast %node_base* %call_peek1 to %node_data*
  %node_data_gep = getelementptr %node_data, %node_data* %node_data_cast, i32 0, i32 1
  %node_data_mem_load = load i8, i8* %node_data_gep
  switch i8 %node_data_mem_load, label %safety_block [
    i8 1, label %match_branch16
    i8 0, label %match_branch
  ]

safety_block:                                     ; preds = %entry, %match_branch16, %match_branch
  call void @stack_update(%stack* %0, i64 3)
  call void @stack_popn(%stack* %0, i64 3)
  ret void

match_branch:                                     ; preds = %entry
  call void @stack_split(%stack* %0, i64 2)
  %call_peek2 = call %node_base* @stack_peek(%stack* %0, i64 1)
  call void @stack_push(%stack* %0, %node_base* %call_peek2)
  %call_peek3 = call %node_base* @stack_peek(%stack* %0, i64 5)
  call void @stack_push(%stack* %0, %node_base* %call_peek3)
  %call_peek4 = call %node_base* @stack_peek(%stack* %0, i64 2)
  call void @stack_push(%stack* %0, %node_base* %call_peek4)
  %call_peek5 = call %node_base* @stack_peek(%stack* %0, i64 5)
  call void @stack_push(%stack* %0, %node_base* %call_peek5)
  %call_pop = call %node_base* @stack_pop(%stack* %0)
  %call_pop6 = call %node_base* @stack_pop(%stack* %0)
  %call_alloc_app = call %node_base* @alloc_app(%node_base* %call_pop, %node_base* %call_pop6)
  call void @stack_push(%stack* %0, %node_base* %call_alloc_app)
  %call_pop7 = call %node_base* @stack_pop(%stack* %0)
  %call_pop8 = call %node_base* @stack_pop(%stack* %0)
  %call_alloc_app9 = call %node_base* @alloc_app(%node_base* %call_pop7, %node_base* %call_pop8)
  call void @stack_push(%stack* %0, %node_base* %call_alloc_app9)
  %call_alloc_global = call %node_base* @alloc_global(void (%stack*)* @f_Cons, i32 2)
  call void @stack_push(%stack* %0, %node_base* %call_alloc_global)
  %call_pop10 = call %node_base* @stack_pop(%stack* %0)
  %call_pop11 = call %node_base* @stack_pop(%stack* %0)
  %call_alloc_app12 = call %node_base* @alloc_app(%node_base* %call_pop10, %node_base* %call_pop11)
  call void @stack_push(%stack* %0, %node_base* %call_alloc_app12)
  %call_pop13 = call %node_base* @stack_pop(%stack* %0)
  %call_pop14 = call %node_base* @stack_pop(%stack* %0)
  %call_alloc_app15 = call %node_base* @alloc_app(%node_base* %call_pop13, %node_base* %call_pop14)
  call void @stack_push(%stack* %0, %node_base* %call_alloc_app15)
  call void @stack_slide(%stack* %0, i64 2)
  br label %safety_block

match_branch16:                                   ; preds = %entry
  call void @stack_split(%stack* %0, i64 0)
  %call_alloc_global17 = call %node_base* @alloc_global(void (%stack*)* @f_Nil, i32 0)
  call void @stack_push(%stack* %0, %node_base* %call_alloc_global17)
  call void @stack_slide(%stack* %0, i64 0)
  br label %safety_block
}

define void @f_add(%stack* %0) {
entry:
  %call_peek = call %node_base* @stack_peek(%stack* %0, i64 1)
  call void @stack_push(%stack* %0, %node_base* %call_peek)
  %call_peek1 = call %node_base* @stack_peek(%stack* %0, i64 1)
  call void @stack_push(%stack* %0, %node_base* %call_peek1)
  %call_alloc_global = call %node_base* @alloc_global(void (%stack*)* @f_plus, i32 2)
  call void @stack_push(%stack* %0, %node_base* %call_alloc_global)
  %call_pop = call %node_base* @stack_pop(%stack* %0)
  %call_pop2 = call %node_base* @stack_pop(%stack* %0)
  %call_alloc_app = call %node_base* @alloc_app(%node_base* %call_pop, %node_base* %call_pop2)
  call void @stack_push(%stack* %0, %node_base* %call_alloc_app)
  %call_pop3 = call %node_base* @stack_pop(%stack* %0)
  %call_pop4 = call %node_base* @stack_pop(%stack* %0)
  %call_alloc_app5 = call %node_base* @alloc_app(%node_base* %call_pop3, %node_base* %call_pop4)
  call void @stack_push(%stack* %0, %node_base* %call_alloc_app5)
  call void @stack_update(%stack* %0, i64 2)
  call void @stack_popn(%stack* %0, i64 2)
  ret void
}

define void @f_ones(%stack* %0) {
entry:
  %call_alloc_global = call %node_base* @alloc_global(void (%stack*)* @f_ones, i32 0)
  call void @stack_push(%stack* %0, %node_base* %call_alloc_global)
  %call_alloc_num = call %node_base* @alloc_num(i32 1)
  call void @stack_push(%stack* %0, %node_base* %call_alloc_num)
  %call_alloc_global1 = call %node_base* @alloc_global(void (%stack*)* @f_Cons, i32 2)
  call void @stack_push(%stack* %0, %node_base* %call_alloc_global1)
  %call_pop = call %node_base* @stack_pop(%stack* %0)
  %call_pop2 = call %node_base* @stack_pop(%stack* %0)
  %call_alloc_app = call %node_base* @alloc_app(%node_base* %call_pop, %node_base* %call_pop2)
  call void @stack_push(%stack* %0, %node_base* %call_alloc_app)
  %call_pop3 = call %node_base* @stack_pop(%stack* %0)
  %call_pop4 = call %node_base* @stack_pop(%stack* %0)
  %call_alloc_app5 = call %node_base* @alloc_app(%node_base* %call_pop3, %node_base* %call_pop4)
  call void @stack_push(%stack* %0, %node_base* %call_alloc_app5)
  call void @stack_update(%stack* %0, i64 0)
  call void @stack_popn(%stack* %0, i64 0)
  ret void
}

define void @f_fst(%stack* %0) {
entry:
  %call_peek = call %node_base* @stack_peek(%stack* %0, i64 0)
  call void @stack_push(%stack* %0, %node_base* %call_peek)
  call void @unwind(%stack* %0)
  %call_peek1 = call %node_base* @stack_peek(%stack* %0, i64 0)
  %node_data_cast = bitcast %node_base* %call_peek1 to %node_data*
  %node_data_gep = getelementptr %node_data, %node_data* %node_data_cast, i32 0, i32 1
  %node_data_mem_load = load i8, i8* %node_data_gep
  switch i8 %node_data_mem_load, label %safety_block [
    i8 0, label %match_branch
    i8 1, label %match_branch3
  ]

safety_block:                                     ; preds = %entry, %match_branch3, %match_branch
  call void @stack_update(%stack* %0, i64 1)
  call void @stack_popn(%stack* %0, i64 1)
  ret void

match_branch:                                     ; preds = %entry
  call void @stack_split(%stack* %0, i64 2)
  %call_peek2 = call %node_base* @stack_peek(%stack* %0, i64 0)
  call void @stack_push(%stack* %0, %node_base* %call_peek2)
  call void @stack_slide(%stack* %0, i64 2)
  br label %safety_block

match_branch3:                                    ; preds = %entry
  call void @stack_split(%stack* %0, i64 0)
  %call_alloc_num = call %node_base* @alloc_num(i32 0)
  call void @stack_push(%stack* %0, %node_base* %call_alloc_num)
  call void @stack_slide(%stack* %0, i64 0)
  br label %safety_block
}

define void @f_main(%stack* %0) {
entry:
  %call_alloc_num = call %node_base* @alloc_num(i32 2)
  call void @stack_push(%stack* %0, %node_base* %call_alloc_num)
  %call_alloc_global = call %node_base* @alloc_global(void (%stack*)* @f_ones, i32 0)
  call void @stack_push(%stack* %0, %node_base* %call_alloc_global)
  %call_alloc_global1 = call %node_base* @alloc_global(void (%stack*)* @f_add, i32 2)
  call void @stack_push(%stack* %0, %node_base* %call_alloc_global1)
  %call_alloc_global2 = call %node_base* @alloc_global(void (%stack*)* @f_applyToList, i32 3)
  call void @stack_push(%stack* %0, %node_base* %call_alloc_global2)
  %call_pop = call %node_base* @stack_pop(%stack* %0)
  %call_pop3 = call %node_base* @stack_pop(%stack* %0)
  %call_alloc_app = call %node_base* @alloc_app(%node_base* %call_pop, %node_base* %call_pop3)
  call void @stack_push(%stack* %0, %node_base* %call_alloc_app)
  %call_pop4 = call %node_base* @stack_pop(%stack* %0)
  %call_pop5 = call %node_base* @stack_pop(%stack* %0)
  %call_alloc_app6 = call %node_base* @alloc_app(%node_base* %call_pop4, %node_base* %call_pop5)
  call void @stack_push(%stack* %0, %node_base* %call_alloc_app6)
  %call_pop7 = call %node_base* @stack_pop(%stack* %0)
  %call_pop8 = call %node_base* @stack_pop(%stack* %0)
  %call_alloc_app9 = call %node_base* @alloc_app(%node_base* %call_pop7, %node_base* %call_pop8)
  call void @stack_push(%stack* %0, %node_base* %call_alloc_app9)
  %call_alloc_global10 = call %node_base* @alloc_global(void (%stack*)* @f_fst, i32 1)
  call void @stack_push(%stack* %0, %node_base* %call_alloc_global10)
  %call_pop11 = call %node_base* @stack_pop(%stack* %0)
  %call_pop12 = call %node_base* @stack_pop(%stack* %0)
  %call_alloc_app13 = call %node_base* @alloc_app(%node_base* %call_pop11, %node_base* %call_pop12)
  call void @stack_push(%stack* %0, %node_base* %call_alloc_app13)
  call void @stack_update(%stack* %0, i64 0)
  call void @stack_popn(%stack* %0, i64 0)
  ret void
}
