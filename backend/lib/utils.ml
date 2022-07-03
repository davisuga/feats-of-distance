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

let logInfo m anything =
  if Option.is_some (Array.find_opt (fun arg -> arg = "--info") Sys.argv) then (
    printf "%s" m;
    print_newline ();
    anything)
  else anything

let yojson_flat = Core.Fn.compose yojson_fold (List.map Yojson.Safe.from_string)
let concat_json_strings strings = sprintf "[%s]" (String.concat "," strings)

let tap eff ret =
  eff ret |> ignore;
  ret