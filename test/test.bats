#!/usr/bin/env bats

eval_vqe() {
    echo "$1" | ./varaq-engl | tail -n +3
}

@test "echo using varaq-engl" {
  [ "$( eval_vqe '2 disp' )" -eq 2 ]
}

@test "varaq-engl add" {
  [ "$( eval_vqe '2 2 add disp' )" -eq 4 ]
  [ "$( eval_vqe '2 -2 add disp' )" -eq 0 ]
  [ "$( eval_vqe '-5 -7 add disp' )" -eq -12 ]
}

@test "varaq-engl sub" {
  [ "$( eval_vqe '3 3 sub disp' )" -eq 0 ]
  [ "$( eval_vqe '2 -2 sub disp' )" -eq 4 ]
  [ "$( eval_vqe '-5 -7 sub disp' )" -eq 2 ]
}

