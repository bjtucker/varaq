#!/usr/bin/env bats --tap

# test cha' before using it in other tests
@test "varaq-kling cha'" {
    [ "$( echo "99 cha'" | ./varaq-kling | tail -n +3 )" -eq 99 ]
}

# test disp before using it in other tests
@test "varaq-engl disp" {
    [ "$( echo "99 disp" | ./varaq-engl | tail -n +3 )" -eq 99 ]
}

# test dump before using it in other tests
@test "varaq-engl dump" {
    [ "$( echo "9 99 999 Hotlh" | ./varaq-kling | tail -n +3 )" = "9 99 999" ]
}


compare_k() {
    [ "$( echo "$1 cha'" | ./varaq-kling | tail -n +3 )" -eq $2 ]
}

compare_e() {
    [ "$( echo "$1 disp" | ./varaq-engl | tail -n +3 )" -eq $2 ]
}


@test "compare using varaq-kling" {
  compare_k "2" 2
}

@test "compare using varaq-engl" {
  compare_e "2" 2
}



@test "#3.1.1 add/boq" {
  compare_e "0 2 add" 2
  compare_e "2 0 add" 2
  compare_e "2 2 add" 4
  compare_e "2 -2 add" 0
  compare_e "-5 -7 add" -12

  compare_k "0 2 boq" 2
  compare_k "2 0 boq" 2
  compare_k "2 2 boq" 4
  compare_k "2 -2 boq" 0
  compare_k "-5 -7 boq" -12
}

@test "#3.1.2 sub/boqHa'" {
  compare_e "3 3 sub" 0 
  compare_e "2 -2 sub" 4 
  compare_e "-5 -7 sub" 2
  compare_e "10 -5 -7 sub sub" 8 

  compare_k "3 3 boqHa'" 0 
  compare_k "2 -2 boqHa'" 4 
  compare_k "-5 -7 boqHa'" 2
  compare_k "10 -5 -7 boqHa' boqHa'" 8 
}

@test "#3.1.3 mul/boq'egh" {
  compare_e "3 3 mul" 9 
  compare_e "2 -2 mul" -4 
  compare_e "-5 -7 mul" 35
  compare_e "10 -5 -7 mul mul" 350 

  compare_k "3 3 boq'egh" 9 
  compare_k "2 -2 boq'egh" -4 
  compare_k "-5 -7 boq'egh" 35
  compare_k "10 -5 -7 boq'egh boq'egh" 350 
}

