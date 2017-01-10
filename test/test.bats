#!/usr/bin/env bats

@test "echo using varaq-engl" {
  result="$(echo 2 disp | varaq-engl | tail -n +3)"
  [ "$result" -eq 2 ]
}

