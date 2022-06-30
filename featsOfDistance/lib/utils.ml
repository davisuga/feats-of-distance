let flip f x y = f y x
let ( <% ) = ( |> )
let ( %> ) = Fun.id

let yojson_concat (yo_list : Yojson.Safe.t) (yo_elem : Yojson.Safe.t) =
  match yo_list with
  | `List items -> `List (List.cons yo_elem items)
  | _ -> `List [ yo_list; yo_elem ]

let yojson_fold = List.fold_left yojson_concat (`List [])
