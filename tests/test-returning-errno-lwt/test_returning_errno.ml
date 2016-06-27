(*
 * Copyright (c) 2016 Jeremy Yallop.
 *
 * This file is distributed under the terms of the MIT License.
 * See the file LICENSE for details.
 *)

open OUnit2
open Ctypes


module Bindings = Functions.Stubs(Generated_bindings)
module Constants = Types.Struct_stubs(Generated_struct_bindings)


(*
  Test the binding to "stat".
 *)
let test_stat _ =
  let s = make Constants.stat in
  begin
    Lwt_unix.run
      Lwt.((Bindings.stat "." (addr s)).lwt >>= fun (x, errno) ->
           assert_equal 0 x;
           assert_equal Signed.SInt.zero errno;
           return ());
    Lwt_unix.run
      Lwt.((Bindings.stat "/does-not-exist" (addr s)).lwt >>= fun (x, errno) ->
           assert_equal (-1) x;
           assert_equal Constants._ENOENT errno;
           return ())
  end


(*
  Test calling functions with many arguments.
 *)
let test_six_args _ =
  let open Lwt.Infix in
  Lwt_unix.run
    ((Bindings.sixargs 1 2 3 4 5 6).Generated_bindings.lwt >>= fun (i, errno) ->
     assert_equal (1 + 2 + 3 + 4 + 5 + 6) i;
     Lwt.return ())


(*
  Test calling functions with no arguments.
 *)
let test_no_args _ =
  let open Lwt.Infix in
  Lwt_unix.run
    ((Bindings.return_10 ()).Generated_bindings.lwt >>= fun (i, errno) ->
     assert_equal 10 i;
     Lwt.return ())


let suite = "Errno tests" >:::
  ["calling stat"
    >:: test_stat;

   "functions with many arguments"
    >:: test_six_args;

   "functions with no arguments"
    >:: test_no_args;
  ]


let _ =
  run_test_tt_main suite
