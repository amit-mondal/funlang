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

declare %node_base* @alloc_str(i8*, i32)

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
  %node_num_mem_load = load i32, i32* %node_num_gep, align 4
  %gmachine_stack_ptr_gep6 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop7 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep6)
  %node_num_cast8 = bitcast %node_base* %call_pop7 to %node_num*
  %node_num_gep9 = getelementptr %node_num, %node_num* %node_num_cast8, i32 0, i32 1
  %node_num_mem_load10 = load i32, i32* %node_num_gep9, align 4
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
  %node_num_mem_load = load i32, i32* %node_num_gep, align 4
  %gmachine_stack_ptr_gep6 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop7 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep6)
  %node_num_cast8 = bitcast %node_base* %call_pop7 to %node_num*
  %node_num_gep9 = getelementptr %node_num, %node_num* %node_num_cast8, i32 0, i32 1
  %node_num_mem_load10 = load i32, i32* %node_num_gep9, align 4
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
  %node_num_mem_load = load i32, i32* %node_num_gep, align 4
  %gmachine_stack_ptr_gep6 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop7 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep6)
  %node_num_cast8 = bitcast %node_base* %call_pop7 to %node_num*
  %node_num_gep9 = getelementptr %node_num, %node_num* %node_num_cast8, i32 0, i32 1
  %node_num_mem_load10 = load i32, i32* %node_num_gep9, align 4
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
  %node_num_mem_load = load i32, i32* %node_num_gep, align 4
  %gmachine_stack_ptr_gep6 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop7 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep6)
  %node_num_cast8 = bitcast %node_base* %call_pop7 to %node_num*
  %node_num_gep9 = getelementptr %node_num, %node_num* %node_num_cast8, i32 0, i32 1
  %node_num_mem_load10 = load i32, i32* %node_num_gep9, align 4
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

define void @f_Nil(%gmachine* %0) {
entry:
  call void @gmachine_pack(%gmachine* %0, i64 0, i8 0)
  call void @gmachine_update(%gmachine* %0, i64 0)
  ret void
}

define void @f_Cons(%gmachine* %0) {
entry:
  call void @gmachine_pack(%gmachine* %0, i64 2, i8 1)
  call void @gmachine_update(%gmachine* %0, i64 0)
  ret void
}

define void @f_main(%gmachine* %0) {
entry:
  %call_alloc_global = call %node_base* @alloc_global(void (%gmachine*)* @f_Nil, i32 0)
  %call_track = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_global)
  %gmachine_stack_ptr_gep = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep, %node_base* %call_track)
  %call_alloc_num = call %node_base* @alloc_num(i32 4)
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
  %call_alloc_num18 = call %node_base* @alloc_num(i32 3)
  %call_track19 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_num18)
  %gmachine_stack_ptr_gep20 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep20, %node_base* %call_track19)
  %call_alloc_global21 = call %node_base* @alloc_global(void (%gmachine*)* @f_Cons, i32 2)
  %call_track22 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_global21)
  %gmachine_stack_ptr_gep23 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep23, %node_base* %call_track22)
  %gmachine_stack_ptr_gep24 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop25 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep24)
  %gmachine_stack_ptr_gep26 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop27 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep26)
  %call_alloc_app28 = call %node_base* @alloc_app(%node_base* %call_pop25, %node_base* %call_pop27)
  %call_track29 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app28)
  %gmachine_stack_ptr_gep30 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep30, %node_base* %call_track29)
  %gmachine_stack_ptr_gep31 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop32 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep31)
  %gmachine_stack_ptr_gep33 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop34 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep33)
  %call_alloc_app35 = call %node_base* @alloc_app(%node_base* %call_pop32, %node_base* %call_pop34)
  %call_track36 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app35)
  %gmachine_stack_ptr_gep37 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep37, %node_base* %call_track36)
  %call_alloc_num38 = call %node_base* @alloc_num(i32 2)
  %call_track39 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_num38)
  %gmachine_stack_ptr_gep40 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep40, %node_base* %call_track39)
  %call_alloc_global41 = call %node_base* @alloc_global(void (%gmachine*)* @f_Cons, i32 2)
  %call_track42 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_global41)
  %gmachine_stack_ptr_gep43 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep43, %node_base* %call_track42)
  %gmachine_stack_ptr_gep44 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop45 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep44)
  %gmachine_stack_ptr_gep46 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop47 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep46)
  %call_alloc_app48 = call %node_base* @alloc_app(%node_base* %call_pop45, %node_base* %call_pop47)
  %call_track49 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app48)
  %gmachine_stack_ptr_gep50 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep50, %node_base* %call_track49)
  %gmachine_stack_ptr_gep51 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop52 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep51)
  %gmachine_stack_ptr_gep53 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop54 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep53)
  %call_alloc_app55 = call %node_base* @alloc_app(%node_base* %call_pop52, %node_base* %call_pop54)
  %call_track56 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app55)
  %gmachine_stack_ptr_gep57 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep57, %node_base* %call_track56)
  %call_alloc_num58 = call %node_base* @alloc_num(i32 1)
  %call_track59 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_num58)
  %gmachine_stack_ptr_gep60 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep60, %node_base* %call_track59)
  %call_alloc_global61 = call %node_base* @alloc_global(void (%gmachine*)* @f_Cons, i32 2)
  %call_track62 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_global61)
  %gmachine_stack_ptr_gep63 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep63, %node_base* %call_track62)
  %gmachine_stack_ptr_gep64 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop65 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep64)
  %gmachine_stack_ptr_gep66 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop67 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep66)
  %call_alloc_app68 = call %node_base* @alloc_app(%node_base* %call_pop65, %node_base* %call_pop67)
  %call_track69 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app68)
  %gmachine_stack_ptr_gep70 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep70, %node_base* %call_track69)
  %gmachine_stack_ptr_gep71 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop72 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep71)
  %gmachine_stack_ptr_gep73 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop74 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep73)
  %call_alloc_app75 = call %node_base* @alloc_app(%node_base* %call_pop72, %node_base* %call_pop74)
  %call_track76 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app75)
  %gmachine_stack_ptr_gep77 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep77, %node_base* %call_track76)
  %call_alloc_num78 = call %node_base* @alloc_num(i32 1)
  %call_track79 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_num78)
  %gmachine_stack_ptr_gep80 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep80, %node_base* %call_track79)
  %call_alloc_global81 = call %node_base* @alloc_global(void (%gmachine*)* @f_mul, i32 2)
  %call_track82 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_global81)
  %gmachine_stack_ptr_gep83 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep83, %node_base* %call_track82)
  %call_alloc_global84 = call %node_base* @alloc_global(void (%gmachine*)* @f_foldr, i32 3)
  %call_track85 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_global84)
  %gmachine_stack_ptr_gep86 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep86, %node_base* %call_track85)
  %gmachine_stack_ptr_gep87 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop88 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep87)
  %gmachine_stack_ptr_gep89 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop90 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep89)
  %call_alloc_app91 = call %node_base* @alloc_app(%node_base* %call_pop88, %node_base* %call_pop90)
  %call_track92 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app91)
  %gmachine_stack_ptr_gep93 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep93, %node_base* %call_track92)
  %gmachine_stack_ptr_gep94 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop95 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep94)
  %gmachine_stack_ptr_gep96 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop97 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep96)
  %call_alloc_app98 = call %node_base* @alloc_app(%node_base* %call_pop95, %node_base* %call_pop97)
  %call_track99 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app98)
  %gmachine_stack_ptr_gep100 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep100, %node_base* %call_track99)
  %gmachine_stack_ptr_gep101 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop102 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep101)
  %gmachine_stack_ptr_gep103 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop104 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep103)
  %call_alloc_app105 = call %node_base* @alloc_app(%node_base* %call_pop102, %node_base* %call_pop104)
  %call_track106 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app105)
  %gmachine_stack_ptr_gep107 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep107, %node_base* %call_track106)
  %call_alloc_global108 = call %node_base* @alloc_global(void (%gmachine*)* @f_Nil, i32 0)
  %call_track109 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_global108)
  %gmachine_stack_ptr_gep110 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep110, %node_base* %call_track109)
  %call_alloc_num111 = call %node_base* @alloc_num(i32 4)
  %call_track112 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_num111)
  %gmachine_stack_ptr_gep113 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep113, %node_base* %call_track112)
  %call_alloc_global114 = call %node_base* @alloc_global(void (%gmachine*)* @f_Cons, i32 2)
  %call_track115 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_global114)
  %gmachine_stack_ptr_gep116 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep116, %node_base* %call_track115)
  %gmachine_stack_ptr_gep117 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop118 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep117)
  %gmachine_stack_ptr_gep119 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop120 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep119)
  %call_alloc_app121 = call %node_base* @alloc_app(%node_base* %call_pop118, %node_base* %call_pop120)
  %call_track122 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app121)
  %gmachine_stack_ptr_gep123 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep123, %node_base* %call_track122)
  %gmachine_stack_ptr_gep124 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop125 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep124)
  %gmachine_stack_ptr_gep126 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop127 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep126)
  %call_alloc_app128 = call %node_base* @alloc_app(%node_base* %call_pop125, %node_base* %call_pop127)
  %call_track129 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app128)
  %gmachine_stack_ptr_gep130 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep130, %node_base* %call_track129)
  %call_alloc_num131 = call %node_base* @alloc_num(i32 3)
  %call_track132 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_num131)
  %gmachine_stack_ptr_gep133 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep133, %node_base* %call_track132)
  %call_alloc_global134 = call %node_base* @alloc_global(void (%gmachine*)* @f_Cons, i32 2)
  %call_track135 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_global134)
  %gmachine_stack_ptr_gep136 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep136, %node_base* %call_track135)
  %gmachine_stack_ptr_gep137 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop138 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep137)
  %gmachine_stack_ptr_gep139 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop140 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep139)
  %call_alloc_app141 = call %node_base* @alloc_app(%node_base* %call_pop138, %node_base* %call_pop140)
  %call_track142 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app141)
  %gmachine_stack_ptr_gep143 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep143, %node_base* %call_track142)
  %gmachine_stack_ptr_gep144 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop145 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep144)
  %gmachine_stack_ptr_gep146 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop147 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep146)
  %call_alloc_app148 = call %node_base* @alloc_app(%node_base* %call_pop145, %node_base* %call_pop147)
  %call_track149 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app148)
  %gmachine_stack_ptr_gep150 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep150, %node_base* %call_track149)
  %call_alloc_num151 = call %node_base* @alloc_num(i32 2)
  %call_track152 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_num151)
  %gmachine_stack_ptr_gep153 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep153, %node_base* %call_track152)
  %call_alloc_global154 = call %node_base* @alloc_global(void (%gmachine*)* @f_Cons, i32 2)
  %call_track155 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_global154)
  %gmachine_stack_ptr_gep156 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep156, %node_base* %call_track155)
  %gmachine_stack_ptr_gep157 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop158 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep157)
  %gmachine_stack_ptr_gep159 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop160 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep159)
  %call_alloc_app161 = call %node_base* @alloc_app(%node_base* %call_pop158, %node_base* %call_pop160)
  %call_track162 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app161)
  %gmachine_stack_ptr_gep163 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep163, %node_base* %call_track162)
  %gmachine_stack_ptr_gep164 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop165 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep164)
  %gmachine_stack_ptr_gep166 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop167 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep166)
  %call_alloc_app168 = call %node_base* @alloc_app(%node_base* %call_pop165, %node_base* %call_pop167)
  %call_track169 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app168)
  %gmachine_stack_ptr_gep170 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep170, %node_base* %call_track169)
  %call_alloc_num171 = call %node_base* @alloc_num(i32 1)
  %call_track172 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_num171)
  %gmachine_stack_ptr_gep173 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep173, %node_base* %call_track172)
  %call_alloc_global174 = call %node_base* @alloc_global(void (%gmachine*)* @f_Cons, i32 2)
  %call_track175 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_global174)
  %gmachine_stack_ptr_gep176 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep176, %node_base* %call_track175)
  %gmachine_stack_ptr_gep177 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop178 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep177)
  %gmachine_stack_ptr_gep179 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop180 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep179)
  %call_alloc_app181 = call %node_base* @alloc_app(%node_base* %call_pop178, %node_base* %call_pop180)
  %call_track182 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app181)
  %gmachine_stack_ptr_gep183 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep183, %node_base* %call_track182)
  %gmachine_stack_ptr_gep184 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop185 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep184)
  %gmachine_stack_ptr_gep186 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop187 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep186)
  %call_alloc_app188 = call %node_base* @alloc_app(%node_base* %call_pop185, %node_base* %call_pop187)
  %call_track189 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app188)
  %gmachine_stack_ptr_gep190 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep190, %node_base* %call_track189)
  %call_alloc_num191 = call %node_base* @alloc_num(i32 0)
  %call_track192 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_num191)
  %gmachine_stack_ptr_gep193 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep193, %node_base* %call_track192)
  %call_alloc_global194 = call %node_base* @alloc_global(void (%gmachine*)* @f_add, i32 2)
  %call_track195 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_global194)
  %gmachine_stack_ptr_gep196 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep196, %node_base* %call_track195)
  %call_alloc_global197 = call %node_base* @alloc_global(void (%gmachine*)* @f_foldr, i32 3)
  %call_track198 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_global197)
  %gmachine_stack_ptr_gep199 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep199, %node_base* %call_track198)
  %gmachine_stack_ptr_gep200 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop201 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep200)
  %gmachine_stack_ptr_gep202 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop203 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep202)
  %call_alloc_app204 = call %node_base* @alloc_app(%node_base* %call_pop201, %node_base* %call_pop203)
  %call_track205 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app204)
  %gmachine_stack_ptr_gep206 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep206, %node_base* %call_track205)
  %gmachine_stack_ptr_gep207 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop208 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep207)
  %gmachine_stack_ptr_gep209 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop210 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep209)
  %call_alloc_app211 = call %node_base* @alloc_app(%node_base* %call_pop208, %node_base* %call_pop210)
  %call_track212 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app211)
  %gmachine_stack_ptr_gep213 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep213, %node_base* %call_track212)
  %gmachine_stack_ptr_gep214 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop215 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep214)
  %gmachine_stack_ptr_gep216 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop217 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep216)
  %call_alloc_app218 = call %node_base* @alloc_app(%node_base* %call_pop215, %node_base* %call_pop217)
  %call_track219 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app218)
  %gmachine_stack_ptr_gep220 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep220, %node_base* %call_track219)
  %call_alloc_global221 = call %node_base* @alloc_global(void (%gmachine*)* @f_plus, i32 2)
  %call_track222 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_global221)
  %gmachine_stack_ptr_gep223 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep223, %node_base* %call_track222)
  %gmachine_stack_ptr_gep224 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop225 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep224)
  %gmachine_stack_ptr_gep226 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop227 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep226)
  %call_alloc_app228 = call %node_base* @alloc_app(%node_base* %call_pop225, %node_base* %call_pop227)
  %call_track229 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app228)
  %gmachine_stack_ptr_gep230 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep230, %node_base* %call_track229)
  %gmachine_stack_ptr_gep231 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop232 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep231)
  %gmachine_stack_ptr_gep233 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop234 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep233)
  %call_alloc_app235 = call %node_base* @alloc_app(%node_base* %call_pop232, %node_base* %call_pop234)
  %call_track236 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app235)
  %gmachine_stack_ptr_gep237 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep237, %node_base* %call_track236)
  call void @gmachine_update(%gmachine* %0, i64 0)
  %gmachine_stack_ptr_gep238 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_popn(%stack* %gmachine_stack_ptr_gep238, i64 0)
  ret void
}

define void @f_foldr(%gmachine* %0) {
entry:
  %gmachine_stack_ptr_gep = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_peek = call %node_base* @stack_peek(%stack* %gmachine_stack_ptr_gep, i64 2)
  %gmachine_stack_ptr_gep1 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep1, %node_base* %call_peek)
  call void @unwind(%gmachine* %0)
  %gmachine_stack_ptr_gep2 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_peek3 = call %node_base* @stack_peek(%stack* %gmachine_stack_ptr_gep2, i64 0)
  %node_data_cast = bitcast %node_base* %call_peek3 to %node_data*
  %node_data_gep = getelementptr %node_data, %node_data* %node_data_cast, i32 0, i32 1
  %node_data_mem_load = load i8, i8* %node_data_gep, align 1
  switch i8 %node_data_mem_load, label %safety_block [
    i8 0, label %match_branch
    i8 1, label %match_branch7
  ]

safety_block:                                     ; preds = %entry, %match_branch7, %match_branch
  call void @gmachine_update(%gmachine* %0, i64 3)
  %gmachine_stack_ptr_gep57 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_popn(%stack* %gmachine_stack_ptr_gep57, i64 3)
  ret void

match_branch:                                     ; preds = %entry
  call void @gmachine_split(%gmachine* %0, i64 0)
  %gmachine_stack_ptr_gep4 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_peek5 = call %node_base* @stack_peek(%stack* %gmachine_stack_ptr_gep4, i64 1)
  %gmachine_stack_ptr_gep6 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep6, %node_base* %call_peek5)
  call void @gmachine_slide(%gmachine* %0, i64 0)
  br label %safety_block

match_branch7:                                    ; preds = %entry
  call void @gmachine_split(%gmachine* %0, i64 2)
  %gmachine_stack_ptr_gep8 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_peek9 = call %node_base* @stack_peek(%stack* %gmachine_stack_ptr_gep8, i64 1)
  %gmachine_stack_ptr_gep10 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep10, %node_base* %call_peek9)
  %gmachine_stack_ptr_gep11 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_peek12 = call %node_base* @stack_peek(%stack* %gmachine_stack_ptr_gep11, i64 4)
  %gmachine_stack_ptr_gep13 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep13, %node_base* %call_peek12)
  %gmachine_stack_ptr_gep14 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_peek15 = call %node_base* @stack_peek(%stack* %gmachine_stack_ptr_gep14, i64 4)
  %gmachine_stack_ptr_gep16 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep16, %node_base* %call_peek15)
  %call_alloc_global = call %node_base* @alloc_global(void (%gmachine*)* @f_foldr, i32 3)
  %call_track = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_global)
  %gmachine_stack_ptr_gep17 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep17, %node_base* %call_track)
  %gmachine_stack_ptr_gep18 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep18)
  %gmachine_stack_ptr_gep19 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop20 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep19)
  %call_alloc_app = call %node_base* @alloc_app(%node_base* %call_pop, %node_base* %call_pop20)
  %call_track21 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app)
  %gmachine_stack_ptr_gep22 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep22, %node_base* %call_track21)
  %gmachine_stack_ptr_gep23 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop24 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep23)
  %gmachine_stack_ptr_gep25 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop26 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep25)
  %call_alloc_app27 = call %node_base* @alloc_app(%node_base* %call_pop24, %node_base* %call_pop26)
  %call_track28 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app27)
  %gmachine_stack_ptr_gep29 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep29, %node_base* %call_track28)
  %gmachine_stack_ptr_gep30 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop31 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep30)
  %gmachine_stack_ptr_gep32 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop33 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep32)
  %call_alloc_app34 = call %node_base* @alloc_app(%node_base* %call_pop31, %node_base* %call_pop33)
  %call_track35 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app34)
  %gmachine_stack_ptr_gep36 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep36, %node_base* %call_track35)
  %gmachine_stack_ptr_gep37 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_peek38 = call %node_base* @stack_peek(%stack* %gmachine_stack_ptr_gep37, i64 1)
  %gmachine_stack_ptr_gep39 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep39, %node_base* %call_peek38)
  %gmachine_stack_ptr_gep40 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_peek41 = call %node_base* @stack_peek(%stack* %gmachine_stack_ptr_gep40, i64 4)
  %gmachine_stack_ptr_gep42 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep42, %node_base* %call_peek41)
  %gmachine_stack_ptr_gep43 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop44 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep43)
  %gmachine_stack_ptr_gep45 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop46 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep45)
  %call_alloc_app47 = call %node_base* @alloc_app(%node_base* %call_pop44, %node_base* %call_pop46)
  %call_track48 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app47)
  %gmachine_stack_ptr_gep49 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep49, %node_base* %call_track48)
  %gmachine_stack_ptr_gep50 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop51 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep50)
  %gmachine_stack_ptr_gep52 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop53 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep52)
  %call_alloc_app54 = call %node_base* @alloc_app(%node_base* %call_pop51, %node_base* %call_pop53)
  %call_track55 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app54)
  %gmachine_stack_ptr_gep56 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep56, %node_base* %call_track55)
  call void @gmachine_slide(%gmachine* %0, i64 2)
  br label %safety_block
}

define void @f_mul(%gmachine* %0) {
entry:
  %gmachine_stack_ptr_gep = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_peek = call %node_base* @stack_peek(%stack* %gmachine_stack_ptr_gep, i64 1)
  %gmachine_stack_ptr_gep1 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep1, %node_base* %call_peek)
  %gmachine_stack_ptr_gep2 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_peek3 = call %node_base* @stack_peek(%stack* %gmachine_stack_ptr_gep2, i64 1)
  %gmachine_stack_ptr_gep4 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep4, %node_base* %call_peek3)
  %call_alloc_global = call %node_base* @alloc_global(void (%gmachine*)* @f_times, i32 2)
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

define void @f_swap_args(%gmachine* %0) {
entry:
  %gmachine_stack_ptr_gep = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_peek = call %node_base* @stack_peek(%stack* %gmachine_stack_ptr_gep, i64 1)
  %gmachine_stack_ptr_gep1 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep1, %node_base* %call_peek)
  %gmachine_stack_ptr_gep2 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_peek3 = call %node_base* @stack_peek(%stack* %gmachine_stack_ptr_gep2, i64 1)
  %gmachine_stack_ptr_gep4 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep4, %node_base* %call_peek3)
  %gmachine_stack_ptr_gep5 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_peek6 = call %node_base* @stack_peek(%stack* %gmachine_stack_ptr_gep5, i64 4)
  %gmachine_stack_ptr_gep7 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep7, %node_base* %call_peek6)
  %call_alloc_global = call %node_base* @alloc_global(void (%gmachine*)* @f_foldr, i32 3)
  %call_track = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_global)
  %gmachine_stack_ptr_gep8 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep8, %node_base* %call_track)
  %gmachine_stack_ptr_gep9 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep9)
  %gmachine_stack_ptr_gep10 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop11 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep10)
  %call_alloc_app = call %node_base* @alloc_app(%node_base* %call_pop, %node_base* %call_pop11)
  %call_track12 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app)
  %gmachine_stack_ptr_gep13 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep13, %node_base* %call_track12)
  %gmachine_stack_ptr_gep14 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop15 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep14)
  %gmachine_stack_ptr_gep16 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop17 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep16)
  %call_alloc_app18 = call %node_base* @alloc_app(%node_base* %call_pop15, %node_base* %call_pop17)
  %call_track19 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app18)
  %gmachine_stack_ptr_gep20 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep20, %node_base* %call_track19)
  %gmachine_stack_ptr_gep21 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop22 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep21)
  %gmachine_stack_ptr_gep23 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop24 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep23)
  %call_alloc_app25 = call %node_base* @alloc_app(%node_base* %call_pop22, %node_base* %call_pop24)
  %call_track26 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app25)
  %gmachine_stack_ptr_gep27 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep27, %node_base* %call_track26)
  call void @gmachine_update(%gmachine* %0, i64 3)
  %gmachine_stack_ptr_gep28 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_popn(%stack* %gmachine_stack_ptr_gep28, i64 3)
  ret void
}

define void @f_curried(%gmachine* %0) {
entry:
  %call_alloc_global = call %node_base* @alloc_global(void (%gmachine*)* @f_add, i32 2)
  %call_track = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_global)
  %gmachine_stack_ptr_gep = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep, %node_base* %call_track)
  %call_alloc_global1 = call %node_base* @alloc_global(void (%gmachine*)* @f_swap_args, i32 3)
  %call_track2 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_global1)
  %gmachine_stack_ptr_gep3 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep3, %node_base* %call_track2)
  %gmachine_stack_ptr_gep4 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep4)
  %gmachine_stack_ptr_gep5 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  %call_pop6 = call %node_base* @stack_pop(%stack* %gmachine_stack_ptr_gep5)
  %call_alloc_app = call %node_base* @alloc_app(%node_base* %call_pop, %node_base* %call_pop6)
  %call_track7 = call %node_base* @gmachine_track(%gmachine* %0, %node_base* %call_alloc_app)
  %gmachine_stack_ptr_gep8 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_push(%stack* %gmachine_stack_ptr_gep8, %node_base* %call_track7)
  call void @gmachine_update(%gmachine* %0, i64 0)
  %gmachine_stack_ptr_gep9 = getelementptr %gmachine, %gmachine* %0, i32 0, i32 0
  call void @stack_popn(%stack* %gmachine_stack_ptr_gep9, i64 0)
  ret void
}
