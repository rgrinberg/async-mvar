open Core.Std
open Async.Std

module Mvar = Async_mvar

exception Test_failure of string

let fail msg = raise (Test_failure msg)

let assert_equals v1 v2 =
  if v1 <> v2 then fail "Failure. Two values aren't equal"

let t1 =
  let t = Mvar.create_empty () in
  Mvar.put t "testing" >>= fun () ->
  Mvar.take t >>| fun v ->
  assert_equals v "testing"

let t2 =
  let t = Mvar.create 123 in
  Mvar.take t >>| fun v ->
  assert_equals v 123

let t3 =
  let t = Mvar.create_empty () in
  [1;2;3] |> Deferred.List.iter ~f:(fun x ->
    Mvar.put t x
  ) |> don't_wait_for;
  [1;2;3] |> Deferred.List.iter ~f:(fun x ->
    Mvar.take t >>| fun x' ->
    assert_equals x x')

let run_tests =
  [t1; t2; t3] |> Deferred.List.all_unit >>= fun () ->
  print_endline "Finished tests";
  Shutdown.exit 0

let () =
  never_returns (Scheduler.go ())
