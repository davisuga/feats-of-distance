let flip f x y = f y x
let ( <% ) = ( |> )
let ( %> ) = Fun.id

let yojson_concat (yo_list : Yojson.Safe.t) (yo_elem : Yojson.Safe.t) =
  match yo_list with
  | `List items -> `List (List.cons yo_elem items)
  | _ -> `List [ yo_list; yo_elem ]

let yojson_fold = List.fold_left yojson_concat (`List [])

let utf_decimal_table =
  [
    ("\\\\195\\\\163", "ã");
    ("\\\\195\\\\131", "Ã");
    ("\\\\195\\\\129", "Á");
    ("\\\\195\\\\161", "á");
    ("\\\\195\\\\128", "À");
    ("\\\\195\\\\160", "à");
    ("\\\\195\\\\130", "Â");
    ("\\\\195\\\\162", "â");
    ("\\\\195\\\\137", "É");
    ("\\\\195\\\\169", "é");
    ("\\\\195\\\\136", "È");
    ("\\\\195\\\\168", "è");
    ("\\\\195\\\\138", "Ê");
    ("\\\\195\\\\170", "ê");
    ("\\\\195\\\\154", "Ú");
    ("\\\\195\\\\186", "ú");
    ("\\\\195\\\\153", "Ù");
    ("\\\\195\\\\185", "ù");
    ("\\\\195\\\\167", "ç");
    ("\\\\195\\\\173", "í");
    ("\\\\195\\\\141", "Í");
    ("\\\\195\\\\179", "ó");
    ("\\\\195\\\\145", "Ó");
  ]

let utf_decimal_decode s =
  List.fold_right
    (fun (decimal_code, character) acc ->
      Re2.rewrite_exn ~template:character (Re2.create_exn decimal_code) acc)
    utf_decimal_table s

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

let yojson_flat = Core.Fn.compose yojson_fold (List.map Yojson.Safe.from_string)
let concat_json_strings strings = sprintf "[%s]" (String.concat "," strings)
let remove_hd_and_last result = String.sub result 1 (String.length result - 2)

let tap eff ret =
  eff ret |> ignore;
  ret

(* [run cmd] runs a shell command, waits until it terminates, and
   returns a list of strings that the process outputed *)
let run cmd =
  Lwt_process.shell cmd |> log ("running " ^ cmd) |> Lwt_process.pread

let run_with_args = Lwt_process.pread

module List = struct
  include List

  let tail = function _ :: tail -> tail | _ -> []
end

let replace input output = Str.global_replace (Str.regexp_string input) output

exception ParseError of string

let print_yojson_exn (a, yojson) =
  Printf.sprintf "%s:%d\n Failed to parse %s. \n Error: %s" __FILE__ __LINE__
    (Yojson.Safe.show yojson) (Printexc.to_string a)

let join_partitions (a, b) = List.append a b

module StringSet = Core.Set.Make (Core.String)

let uniq_string_list = Core.Fn.compose StringSet.to_list StringSet.of_list

let contains sub string_a =
  Core.String.substr_index string_a ~pattern:sub <> None

let run_if boolean fn stuff = if boolean then fn stuff else stuff

let try_parse_json_with ?(prefix = "") parse_yojson path =
  try parse_yojson (Yojson.Safe.from_file (prefix ^ path))
  with Ppx_yojson_conv_lib.Yojson_conv.Of_yojson_error (e, t) ->
    failwith
      (Printf.sprintf "Failed to parse  \n %s \n %s" (Yojson.Safe.to_string t)
         (Printexc.to_string e))