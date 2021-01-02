; ModuleID = 'funlang'
source_filename = "funlang"

%stack = type { i64, i64, %node_base** }
%node_base = type { i32, i8, %node_base* }
%gmachine = type { %stack, %node_base*, i64, i64 }
%node_num = type { %node_base, i32 }
%node_data = type { %node_base, i8, %node_base** }

declare void @stack_init(%stack*)

declare void @stack_free(%stack*)

declare void @stack_push(%stack*, %node_base*)

declare %node_base* @stack_pop(%stack*)

declare %node_base* @stack_peek(%stack*, i64)

declare void @stack_popn(%stack*, i64)

declare %node_base* @alloc_app(%node_base*, %node_base*)

declare %node_base* @alloc_num(i32)

declare %node_base* @alloc_global(void (%gmachine*)*, i32)

declare %node_base* @alloc_ind(%node_base*)

declare void @unwind(%gmachine*)

declare void @gmachine_init(%gmachine*)

declare void @gmachine_free(%gmachine*)

declare void @gmachine_slide(%gmachine*, i64)

declare void @gmachine_update(%gmachine*, i64)

declare void @gmachine_alloc(%gmachine*, i64)

declare void @gmachine_pack(%gmachine*, i64, i8)

declare void @gmachine_split(%gmachine*, i64)

declare %node_base* @gmachine_track(%gmachine*, %node_base*)

define void @f_plus(%gmachine* %0) {
entry:
  %gmachine_stack_ptr_gep = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_peek = call %node_base* @stack_peek(%stack* %gmachine_stack_ptr_gep, i64 1)
  %gmachine_stack_ptr_gep1 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep1, %node_base* %call_peek)
  call void @unwind(%gmachine* %0)
  %gmachine_stack_ptr_gep2 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_peek3 = call %node_base* @stack_peek(%stack* %gmachine_stack_ptr_gep2, i64 1)
  %gmachine_stack_ptr_gep4 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep4, %node_base* %call_peek3)
  call void @unwind(%gmachine* %0)
  %gmachine_stack_ptr_gep5 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep5)
  %node_num_cast = bitcast %node_base* %call_pop to %node_num*
  %node_num_gep = getelementptr %node_num, %node_num* %node_num_cast, i32 0, i32 1
  %node_num_mem_load = load i32, i32* %node_num_gep
  %gmachine_stack_ptr_gep6 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop7 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep6)
  %node_num_cast8 = bitcast %node_base* %call_pop7 to %node_num*
  %node_num_gep9 = getelementptr %node_num, %node_num* %node_num_cast8, i32 0, i32 1
  %node_num_mem_load10 = load i32, i32* %node_num_gep9
  %int_add = add i32 %node_num_mem_load, %node_num_mem_load10
  %call_alloc_num = call %node_base* @alloc_num(i32 %int_add)
  %call_track = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_num)
  %gmachine_stack_ptr_gep11 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep11, %node_base* %call_track)
  call void @gmachine_update(%gmachine* %0, i64 2)
  %gmachine_stack_ptr_gep12 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_popn(%stack* %gmachine_stack_ptr_gep12, i64 2)
  ret void
}

define void @f_minus(%gmachine* %0) {
entry:
  %gmachine_stack_ptr_gep = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_peek = call %node_base* @stack_peek(%stack* %gmachine_stack_ptr_gep, i64 1)
  %gmachine_stack_ptr_gep1 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep1, %node_base* %call_peek)
  call void @unwind(%gmachine* %0)
  %gmachine_stack_ptr_gep2 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_peek3 = call %node_base* @stack_peek(%stack* %gmachine_stack_ptr_gep2, i64 1)
  %gmachine_stack_ptr_gep4 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep4, %node_base* %call_peek3)
  call void @unwind(%gmachine* %0)
  %gmachine_stack_ptr_gep5 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep5)
  %node_num_cast = bitcast %node_base* %call_pop to %node_num*
  %node_num_gep = getelementptr %node_num, %node_num* %node_num_cast, i32 0, i32 1
  %node_num_mem_load = load i32, i32* %node_num_gep
  %gmachine_stack_ptr_gep6 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop7 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep6)
  %node_num_cast8 = bitcast %node_base* %call_pop7 to %node_num*
  %node_num_gep9 = getelementptr %node_num, %node_num* %node_num_cast8, i32 0, i32 1
  %node_num_mem_load10 = load i32, i32* %node_num_gep9
  %int_sub = sub i32 %node_num_mem_load, %node_num_mem_load10
  %call_alloc_num = call %node_base* @alloc_num(i32 %int_sub)
  %call_track = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_num)
  %gmachine_stack_ptr_gep11 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep11, %node_base* %call_track)
  call void @gmachine_update(%gmachine* %0, i64 2)
  %gmachine_stack_ptr_gep12 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_popn(%stack* %gmachine_stack_ptr_gep12, i64 2)
  ret void
}

define void @f_times(%gmachine* %0) {
entry:
  %gmachine_stack_ptr_gep = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_peek = call %node_base* @stack_peek(%stack* %gmachine_stack_ptr_gep, i64 1)
  %gmachine_stack_ptr_gep1 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep1, %node_base* %call_peek)
  call void @unwind(%gmachine* %0)
  %gmachine_stack_ptr_gep2 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_peek3 = call %node_base* @stack_peek(%stack* %gmachine_stack_ptr_gep2, i64 1)
  %gmachine_stack_ptr_gep4 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep4, %node_base* %call_peek3)
  call void @unwind(%gmachine* %0)
  %gmachine_stack_ptr_gep5 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep5)
  %node_num_cast = bitcast %node_base* %call_pop to %node_num*
  %node_num_gep = getelementptr %node_num, %node_num* %node_num_cast, i32 0, i32 1
  %node_num_mem_load = load i32, i32* %node_num_gep
  %gmachine_stack_ptr_gep6 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop7 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep6)
  %node_num_cast8 = bitcast %node_base* %call_pop7 to %node_num*
  %node_num_gep9 = getelementptr %node_num, %node_num* %node_num_cast8, i32 0, i32 1
  %node_num_mem_load10 = load i32, i32* %node_num_gep9
  %int_mul = mul i32 %node_num_mem_load, %node_num_mem_load10
  %call_alloc_num = call %node_base* @alloc_num(i32 %int_mul)
  %call_track = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_num)
  %gmachine_stack_ptr_gep11 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep11, %node_base* %call_track)
  call void @gmachine_update(%gmachine* %0, i64 2)
  %gmachine_stack_ptr_gep12 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_popn(%stack* %gmachine_stack_ptr_gep12, i64 2)
  ret void
}

define void @f_divide(%gmachine* %0) {
entry:
  %gmachine_stack_ptr_gep = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_peek = call %node_base* @stack_peek(%stack* %gmachine_stack_ptr_gep, i64 1)
  %gmachine_stack_ptr_gep1 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep1, %node_base* %call_peek)
  call void @unwind(%gmachine* %0)
  %gmachine_stack_ptr_gep2 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_peek3 = call %node_base* @stack_peek(%stack* %gmachine_stack_ptr_gep2, i64 1)
  %gmachine_stack_ptr_gep4 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep4, %node_base* %call_peek3)
  call void @unwind(%gmachine* %0)
  %gmachine_stack_ptr_gep5 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep5)
  %node_num_cast = bitcast %node_base* %call_pop to %node_num*
  %node_num_gep = getelementptr %node_num, %node_num* %node_num_cast, i32 0, i32 1
  %node_num_mem_load = load i32, i32* %node_num_gep
  %gmachine_stack_ptr_gep6 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop7 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep6)
  %node_num_cast8 = bitcast %node_base* %call_pop7 to %node_num*
  %node_num_gep9 = getelementptr %node_num, %node_num* %node_num_cast8, i32 0, i32 1
  %node_num_mem_load10 = load i32, i32* %node_num_gep9
  %int_sdiv = sdiv i32 %node_num_mem_load, %node_num_mem_load10
  %call_alloc_num = call %node_base* @alloc_num(i32 %int_sdiv)
  %call_track = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_num)
  %gmachine_stack_ptr_gep11 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep11, %node_base* %call_track)
  call void @gmachine_update(%gmachine* %0, i64 2)
  %gmachine_stack_ptr_gep12 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_popn(%stack* %gmachine_stack_ptr_gep12, i64 2)
  ret void
}

define void @f_Some(%gmachine* %0) {
entry:
  call void @gmachine_pack(%gmachine* %0, i64 1, i8 0)
  call void @gmachine_update(%gmachine* %0, i64 0)
  ret void
}

define void @f_None(%gmachine* %0) {
entry:
  call void @gmachine_pack(%gmachine* %0, i64 0, i8 1)
  call void @gmachine_update(%gmachine* %0, i64 0)
  ret void
}

define void @f_Cons(%gmachine* %0) {
entry:
  call void @gmachine_pack(%gmachine* %0, i64 2, i8 0)
  call void @gmachine_update(%gmachine* %0, i64 0)
  ret void
}

define void @f_Nil(%gmachine* %0) {
entry:
  call void @gmachine_pack(%gmachine* %0, i64 0, i8 1)
  call void @gmachine_update(%gmachine* %0, i64 0)
  ret void
}

define void @f_applyToList(%gmachine* %0) {
entry:
  %gmachine_stack_ptr_gep = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_peek = call %node_base* @stack_peek(%stack* %gmachine_stack_ptr_gep, i64 1)
  %gmachine_stack_ptr_gep1 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep1, %node_base* %call_peek)
  call void @unwind(%gmachine* %0)
  %gmachine_stack_ptr_gep2 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_peek3 = call %node_base* @stack_peek(%stack* %gmachine_stack_ptr_gep2, i64 0)
  %node_data_cast = bitcast %node_base* %call_peek3 to %node_data*
  %node_data_gep = getelementptr %node_data, %node_data* %node_data_cast, i32 0, i32 1
  %node_data_mem_load = load i8, i8* %node_data_gep
  switch i8 %node_data_mem_load, label %safety_block [
    i8 0, label %match_branch
    i8 1, label %match_branch43
  ]

safety_block:                                     ; preds = %entry, %match_branch43, %match_branch
  call void @gmachine_update(%gmachine* %0, i64 3)
  %gmachine_stack_ptr_gep47 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_popn(%stack* %gmachine_stack_ptr_gep47, i64 3)
  ret void

match_branch:                                     ; preds = %entry
  call void @gmachine_split(%gmachine* %0, i64 2)
  %gmachine_stack_ptr_gep4 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_peek5 = call %node_base* @stack_peek(%stack* %gmachine_stack_ptr_gep4, i64 1)
  %gmachine_stack_ptr_gep6 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep6, %node_base* %call_peek5)
  %gmachine_stack_ptr_gep7 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_peek8 = call %node_base* @stack_peek(%stack* %gmachine_stack_ptr_gep7, i64 5)
  %gmachine_stack_ptr_gep9 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep9, %node_base* %call_peek8)
  %gmachine_stack_ptr_gep10 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_peek11 = call %node_base* @stack_peek(%stack* %gmachine_stack_ptr_gep10, i64 2)
  %gmachine_stack_ptr_gep12 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep12, %node_base* %call_peek11)
  %gmachine_stack_ptr_gep13 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_peek14 = call %node_base* @stack_peek(%stack* %gmachine_stack_ptr_gep13, i64 5)
  %gmachine_stack_ptr_gep15 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep15, %node_base* %call_peek14)
  %gmachine_stack_ptr_gep16 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep16)
  %gmachine_stack_ptr_gep17 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop18 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep17)
  %call_alloc_app = call %node_base* @alloc_app(%node_base* %call_pop, %node_base* %call_pop18)
  %call_track = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app)
  %gmachine_stack_ptr_gep19 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep19, %node_base* %call_track)
  %gmachine_stack_ptr_gep20 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop21 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep20)
  %gmachine_stack_ptr_gep22 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop23 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep22)
  %call_alloc_app24 = call %node_base* @alloc_app(%node_base* %call_pop21, %node_base* %call_pop23)
  %call_track25 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app24)
  %gmachine_stack_ptr_gep26 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep26, %node_base* %call_track25)
  %call_alloc_global = call %node_base* @alloc_global(void (%gmachine*)* @f_Cons, i32 2)
  %call_track27 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_global)
  %gmachine_stack_ptr_gep28 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep28, %node_base* %call_track27)
  %gmachine_stack_ptr_gep29 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop30 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep29)
  %gmachine_stack_ptr_gep31 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop32 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep31)
  %call_alloc_app33 = call %node_base* @alloc_app(%node_base* %call_pop30, %node_base* %call_pop32)
  %call_track34 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app33)
  %gmachine_stack_ptr_gep35 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep35, %node_base* %call_track34)
  %gmachine_stack_ptr_gep36 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop37 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep36)
  %gmachine_stack_ptr_gep38 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop39 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep38)
  %call_alloc_app40 = call %node_base* @alloc_app(%node_base* %call_pop37, %node_base* %call_pop39)
  %call_track41 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app40)
  %gmachine_stack_ptr_gep42 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep42, %node_base* %call_track41)
  call void @gmachine_slide(%gmachine* %0, i64 2)
  br label %safety_block

match_branch43:                                   ; preds = %entry
  call void @gmachine_split(%gmachine* %0, i64 0)
  %call_alloc_global44 = call %node_base* @alloc_global(void (%gmachine*)* @f_Nil, i32 0)
  %call_track45 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_global44)
  %gmachine_stack_ptr_gep46 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep46, %node_base* %call_track45)
  call void @gmachine_slide(%gmachine* %0, i64 0)
  br label %safety_block
}

define void @f_add(%gmachine* %0) {
entry:
  %gmachine_stack_ptr_gep = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_peek = call %node_base* @stack_peek(%stack* %gmachine_stack_ptr_gep, i64 1)
  %gmachine_stack_ptr_gep1 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep1, %node_base* %call_peek)
  %gmachine_stack_ptr_gep2 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_peek3 = call %node_base* @stack_peek(%stack* %gmachine_stack_ptr_gep2, i64 1)
  %gmachine_stack_ptr_gep4 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep4, %node_base* %call_peek3)
  %call_alloc_global = call %node_base* @alloc_global(void (%gmachine*)* @f_plus, i32 2)
  %call_track = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_global)
  %gmachine_stack_ptr_gep5 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep5, %node_base* %call_track)
  %gmachine_stack_ptr_gep6 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep6)
  %gmachine_stack_ptr_gep7 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop8 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep7)
  %call_alloc_app = call %node_base* @alloc_app(%node_base* %call_pop, %node_base* %call_pop8)
  %call_track9 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app)
  %gmachine_stack_ptr_gep10 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep10, %node_base* %call_track9)
  %gmachine_stack_ptr_gep11 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop12 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep11)
  %gmachine_stack_ptr_gep13 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop14 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep13)
  %call_alloc_app15 = call %node_base* @alloc_app(%node_base* %call_pop12, %node_base* %call_pop14)
  %call_track16 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app15)
  %gmachine_stack_ptr_gep17 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep17, %node_base* %call_track16)
  call void @gmachine_update(%gmachine* %0, i64 2)
  %gmachine_stack_ptr_gep18 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_popn(%stack* %gmachine_stack_ptr_gep18, i64 2)
  ret void
}

define void @f_ones(%gmachine* %0) {
entry:
  %call_alloc_global = call %node_base* @alloc_global(void (%gmachine*)* @f_ones, i32 0)
  %call_track = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_global)
  %gmachine_stack_ptr_gep = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep, %node_base* %call_track)
  %call_alloc_num = call %node_base* @alloc_num(i32 1)
  %call_track1 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_num)
  %gmachine_stack_ptr_gep2 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep2, %node_base* %call_track1)
  %call_alloc_global3 = call %node_base* @alloc_global(void (%gmachine*)* @f_Cons, i32 2)
  %call_track4 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_global3)
  %gmachine_stack_ptr_gep5 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep5, %node_base* %call_track4)
  %gmachine_stack_ptr_gep6 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep6)
  %gmachine_stack_ptr_gep7 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop8 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep7)
  %call_alloc_app = call %node_base* @alloc_app(%node_base* %call_pop, %node_base* %call_pop8)
  %call_track9 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app)
  %gmachine_stack_ptr_gep10 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep10, %node_base* %call_track9)
  %gmachine_stack_ptr_gep11 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop12 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep11)
  %gmachine_stack_ptr_gep13 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop14 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep13)
  %call_alloc_app15 = call %node_base* @alloc_app(%node_base* %call_pop12, %node_base* %call_pop14)
  %call_track16 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app15)
  %gmachine_stack_ptr_gep17 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep17, %node_base* %call_track16)
  call void @gmachine_update(%gmachine* %0, i64 0)
  %gmachine_stack_ptr_gep18 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_popn(%stack* %gmachine_stack_ptr_gep18, i64 0)
  ret void
}

define void @f_fst(%gmachine* %0) {
entry:
  %gmachine_stack_ptr_gep = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_peek = call %node_base* @stack_peek(%stack* %gmachine_stack_ptr_gep, i64 0)
  %gmachine_stack_ptr_gep1 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep1, %node_base* %call_peek)
  call void @unwind(%gmachine* %0)
  %gmachine_stack_ptr_gep2 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_peek3 = call %node_base* @stack_peek(%stack* %gmachine_stack_ptr_gep2, i64 0)
  %node_data_cast = bitcast %node_base* %call_peek3 to %node_data*
  %node_data_gep = getelementptr %node_data, %node_data* %node_data_cast, i32 0, i32 1
  %node_data_mem_load = load i8, i8* %node_data_gep
  switch i8 %node_data_mem_load, label %safety_block [
    i8 1, label %match_branch13
    i8 0, label %match_branch
  ]

safety_block:                                     ; preds = %entry, %match_branch13, %match_branch
  call void @gmachine_update(%gmachine* %0, i64 1)
  %gmachine_stack_ptr_gep17 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_popn(%stack* %gmachine_stack_ptr_gep17, i64 1)
  ret void

match_branch:                                     ; preds = %entry
  call void @gmachine_split(%gmachine* %0, i64 2)
  %gmachine_stack_ptr_gep4 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_peek5 = call %node_base* @stack_peek(%stack* %gmachine_stack_ptr_gep4, i64 0)
  %gmachine_stack_ptr_gep6 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep6, %node_base* %call_peek5)
  %call_alloc_global = call %node_base* @alloc_global(void (%gmachine*)* @f_Some, i32 1)
  %call_track = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_global)
  %gmachine_stack_ptr_gep7 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep7, %node_base* %call_track)
  %gmachine_stack_ptr_gep8 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep8)
  %gmachine_stack_ptr_gep9 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop10 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep9)
  %call_alloc_app = call %node_base* @alloc_app(%node_base* %call_pop, %node_base* %call_pop10)
  %call_track11 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app)
  %gmachine_stack_ptr_gep12 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep12, %node_base* %call_track11)
  call void @gmachine_slide(%gmachine* %0, i64 2)
  br label %safety_block

match_branch13:                                   ; preds = %entry
  call void @gmachine_split(%gmachine* %0, i64 0)
  %call_alloc_global14 = call %node_base* @alloc_global(void (%gmachine*)* @f_None, i32 0)
  %call_track15 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_global14)
  %gmachine_stack_ptr_gep16 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep16, %node_base* %call_track15)
  call void @gmachine_slide(%gmachine* %0, i64 0)
  br label %safety_block
}

define void @f_blah(%gmachine* %0) {
entry:
  %call_alloc_global = call %node_base* @alloc_global(void (%gmachine*)* @f_ones, i32 0)
  %call_track = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_global)
  %gmachine_stack_ptr_gep = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep, %node_base* %call_track)
  %call_alloc_global1 = call %node_base* @alloc_global(void (%gmachine*)* @f_add, i32 2)
  %call_track2 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_global1)
  %gmachine_stack_ptr_gep3 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep3, %node_base* %call_track2)
  %call_alloc_global4 = call %node_base* @alloc_global(void (%gmachine*)* @f_applyToList, i32 3)
  %call_track5 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_global4)
  %gmachine_stack_ptr_gep6 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep6, %node_base* %call_track5)
  %gmachine_stack_ptr_gep7 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep7)
  %gmachine_stack_ptr_gep8 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop9 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep8)
  %call_alloc_app = call %node_base* @alloc_app(%node_base* %call_pop, %node_base* %call_pop9)
  %call_track10 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app)
  %gmachine_stack_ptr_gep11 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep11, %node_base* %call_track10)
  %gmachine_stack_ptr_gep12 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop13 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep12)
  %gmachine_stack_ptr_gep14 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop15 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep14)
  %call_alloc_app16 = call %node_base* @alloc_app(%node_base* %call_pop13, %node_base* %call_pop15)
  %call_track17 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app16)
  %gmachine_stack_ptr_gep18 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep18, %node_base* %call_track17)
  call void @gmachine_update(%gmachine* %0, i64 0)
  %gmachine_stack_ptr_gep19 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_popn(%stack* %gmachine_stack_ptr_gep19, i64 0)
  ret void
}

define void @f_main(%gmachine* %0) {
entry:
  %call_alloc_num = call %node_base* @alloc_num(i32 2)
  %call_track = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_num)
  %gmachine_stack_ptr_gep = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep, %node_base* %call_track)
  %call_alloc_global = call %node_base* @alloc_global(void (%gmachine*)* @f_blah, i32 0)
  %call_track1 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_global)
  %gmachine_stack_ptr_gep2 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep2, %node_base* %call_track1)
  %gmachine_stack_ptr_gep3 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep3)
  %gmachine_stack_ptr_gep4 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop5 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep4)
  %call_alloc_app = call %node_base* @alloc_app(%node_base* %call_pop, %node_base* %call_pop5)
  %call_track6 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app)
  %gmachine_stack_ptr_gep7 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep7, %node_base* %call_track6)
  %call_alloc_global8 = call %node_base* @alloc_global(void (%gmachine*)* @f_fst, i32 1)
  %call_track9 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_global8)
  %gmachine_stack_ptr_gep10 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep10, %node_base* %call_track9)
  %gmachine_stack_ptr_gep11 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop12 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep11)
  %gmachine_stack_ptr_gep13 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop14 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep13)
  %call_alloc_app15 = call %node_base* @alloc_app(%node_base* %call_pop12, %node_base* %call_pop14)
  %call_track16 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app15)
  %gmachine_stack_ptr_gep17 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep17, %node_base* %call_track16)
  call void @gmachine_update(%gmachine* %0, i64 0)
  %gmachine_stack_ptr_gep18 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_popn(%stack* %gmachine_stack_ptr_gep18, i64 0)
  ret void
}
