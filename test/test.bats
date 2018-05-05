#!/usr/bin/env bats --tap

# test cha' before using it in other tests
@test "varaq-kling cha'" {
    [ "$( echo "99 cha'" | ./varaq-kling | tail -n +3 )" -eq 99 ]
}

# test disp before using it in other tests
@test "varaq-engl disp" {
    [ "$( echo "99 disp" | ./varaq-engl | tail -n +3 )" -eq 99 ]
}

# test Hotlh before using it in other tests
@test "varaq-kling Hotlh" {
    result=$( echo "9 99 999 Hotlh" | ./varaq-kling | tail -n +4 )
    [ "$result" = "9 99 999" ]
}

# test dump before using it in other tests
@test "varaq-kling dump" {
    result=$( echo "3 2 1 dump" | ./varaq-engl | tail -n +4 )
    [ "$result" = "3 2 1" ]
}

compare_k() {
    [ "$( echo "$1 Hotlh" | ./varaq-kling | tail -n +4 )" = "$2" ]
}

compare_e() {
    [ "$( echo "$1 dump" | ./varaq-engl | tail -n +4 )" = "$2" ]
}

@test "compare using varaq-kling" {
  compare_k "2" 2
}

@test "compare using varaq-engl" {
  compare_e "2" 2
}


@test "2.5.1 strtie/tlheghrar" {
  compare_e '0 2 strtie' '02'
  compare_e '2 0 strtie' '20'
  compare_e '2 2 strtie' '22'
  compare_e '2 -2 strtie' '2-2'
  compare_e '-5 -7 strtie' '-5-7'
  compare_e '"foo" "bar" strtie' 'foobar'
  compare_e '1 "bar" strtie' '1bar'
  compare_e '0 "bar" strtie' '0bar'
  compare_e '"bar" 0 strtie' 'bar0'
  compare_e '"bar" 1 strtie' 'bar1'
  compare_e '"bar" 0 "bar" strtie' 'bar 0bar'

  compare_k '0 2 tlheghrar' '02'
  compare_k '2 0 tlheghrar' '20'
  compare_k '2 2 tlheghrar' '22'
  compare_k '2 -2 tlheghrar' '2-2'
  compare_k '-5 -7 tlheghrar' '-5-7'
  compare_k '"foo" "bar" tlheghrar' 'foobar'
  compare_k '1 "bar" tlheghrar' '1bar'
  compare_k '0 "bar" tlheghrar' '0bar'
  compare_k '"bar" 0 tlheghrar' 'bar0'
  compare_k '"bar" 1 tlheghrar' 'bar1'
  compare_k '"bar" 0 "bar" tlheghrar' 'bar 0bar'
}

@test "#2.5.3 streq?/tlheghrap'a'" {
  compare_e '0 0 streq?' 1
  compare_e '0 "0" streq?' 1
  compare_e '"a" "a" streq?' 1
  compare_e '"foo" "bar" streq?' 0

  compare_k "0 0 tlheghrap'a'" 1
  compare_k "0 0 tlheghrap\'a\'" 1
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
