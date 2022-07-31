open Printf
open Lwt.Infix
let flip f x y = f y x
let ( <% ) = ( |> )
let ( %> ) = Fun.id
let get_env_var var ~default = Sys.getenv_opt var |> Option.value ~default

open Printf

let log m anything =
  if Option.is_some (Array.find_opt (fun arg -> arg = "--verbose") Sys.argv)
  then (
    printf "%s" m;
    print_newline ();
    anything)
  else anything

let trace msg anything = log (Printf.sprintf msg anything) anything

let logInfo m anything =
  if Option.is_some (Array.find_opt (fun arg -> arg = "--info") Sys.argv) then (
    printf "%s" m;
    print_newline ();
    anything)
  else anything

let tap eff ret =
  eff ret |> ignore;
  ret
exception ShellError of exn
(** [run cmd] runs a shell command, waits until it terminates, and
   returns a list of strings that the process outputed *)
let run cmd =
  try%lwt Lwt_process.shell cmd |> Lwt_process.pread  |> Lwt_result.ok
  with e -> Lwt_result.fail (ShellError e)

let run_with_args = Lwt_process.pread

exception ParseError of string

let print_yojson_exn (a, yojson) =
  Printf.sprintf "%s:%d\n Failed to parse %s. \n Error: %s" __FILE__ __LINE__
    (Yojson.Safe.show yojson) (Printexc.to_string a)

module StringUtils = struct
  let replace expr output = Str.global_replace (Str.regexp_string expr) output
  let concat_json_strings strings = sprintf "[%s]" (String.concat "," strings)
  let remove_hd_and_last result = String.sub result 1 (String.length result - 2)

  module StringSet = Core.Set.Make (Core.String)

  let uniq_string_list = Core.Fn.compose StringSet.to_list StringSet.of_list

  let utf_decimal_table =
    [
      ({|(\\195\\163|\\\\195\\\\163)|}, "ã");
      ({|(\\195\\131|\\\\195\\\\131)|}, "Ã");
      ({|(\\195\\129|\\\\195\\\\129)|}, "Á");
      ({|(\\195\\161|\\\\195\\\\161)|}, "á");
      ({|(\\195\\128|\\\\195\\\\128)|}, "À");
      ({|(\\195\\160|\\\\195\\\\160)|}, "à");
      ({|(\\195\\130|\\\\195\\\\130)|}, "Â");
      ({|(\\195\\162|\\\\195\\\\162)|}, "â");
      ({|(\\195\\137|\\\\195\\\\137)|}, "É");
      ({|(\\195\\169|\\\\195\\\\169)|}, "é");
      ({|(\\195\\136|\\\\195\\\\136)|}, "È");
      ({|(\\195\\168|\\\\195\\\\168)|}, "è");
      ({|(\\195\\138|\\\\195\\\\138)|}, "Ê");
      ({|(\\195\\170|\\\\195\\\\170)|}, "ê");
      ({|(\\195\\154|\\\\195\\\\154)|}, "Ú");
      ({|(\\195\\186|\\\\195\\\\186)|}, "ú");
      ({|(\\195\\153|\\\\195\\\\153)|}, "Ù");
      ({|(\\195\\185|\\\\195\\\\185)|}, "ù");
      ({|(\\195\\167|\\\\195\\\\167)|}, "ç");
      ({|(\\195\\173|\\\\195\\\\173)|}, "í");
      ({|(\\195\\141|\\\\195\\\\141)|}, "Í");
      ({|(\\195\\179|\\\\195\\\\179)|}, "ó");
      ({|(\\195\\145|\\\\195\\\\145)|}, "Ó");
      ({|(\\195\\180|\\\\195\\\\180)|}, "ô");
    ]

  let utf_decimal_decode s =
    List.fold_right
      (fun (decimal_code, character) acc ->
        Re2.rewrite_exn ~template:character (Re2.create_exn decimal_code) acc)
      utf_decimal_table s

  let contains ~sub string_a =
    Core.String.substr_index string_a ~pattern:sub <> None
end

let run_if boolean fn stuff = if boolean then fn stuff else stuff

module JsonUtils = struct
  let yojson_concat (yo_list : Yojson.Safe.t) (yo_elem : Yojson.Safe.t) =
    match yo_list with
    | `List items -> `List (List.cons yo_elem items)
    | _ -> `List [ yo_list; yo_elem ]

  let yojson_fold = List.fold_left yojson_concat (`List [])

  let try_parse_json_with ?(prefix = "") parse_yojson path =
    try parse_yojson (Yojson.Safe.from_file (prefix ^ path))
    with Ppx_yojson_conv_lib.Yojson_conv.Of_yojson_error (e, t) ->
      failwith
        (Printf.sprintf "Failed to parse  \n %s \n %s" (Yojson.Safe.to_string t)
           (Printexc.to_string e))

  let yojson_flat =
    Core.Fn.compose yojson_fold (List.map Yojson.Safe.from_string)

  let print_string_list = List.iter (Printf.printf "%s\n\n")
end

let get_ok_or fn result =
  match result with Ok something -> something | Error e -> fn e

module ListUtils = struct
  let tail = function _ :: tail -> tail | _ -> []
  let join_partitions (a, b) = List.append a b

  let list_max is_greater list =
    List.fold_right
      (fun item acc -> if is_greater item acc then item else acc)
      list (List.hd list)
end

include ListUtils
include JsonUtils
include StringUtils