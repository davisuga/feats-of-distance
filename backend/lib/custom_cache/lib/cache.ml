

module type S = sig
  type 'a container
  type data

  val cache_location : data -> data
  val get : data -> data container
  val set : data -> data -> unit container
  val get_or_update : data -> (data -> data) -> data
  val map_cases : data -> (data -> 'a) -> (data -> 'a) -> 'a
  val clear : data -> unit container
end


module FsCache : S with type 'a container := 'a option and type data := string =
struct
  let cache_location k = Printf.sprintf "./stuff/%s" k

  let get k =
    if Sys.file_exists k then Some (Core.In_channel.read_all (cache_location k))
    else None

  let set k v =
    try Some (Core.Out_channel.write_all ~data:v (cache_location k))
    with _ -> None

  let get_or_update k run_expesive_task =
    match get k with
    | Some cached -> cached
    | None ->
        let value_to_cache = run_expesive_task k in
        set k value_to_cache |> ignore;
        value_to_cache

  let map_cases cache_key handle_some handle_none =
    match get cache_key with
    | Some cached_val -> cached_val |> handle_some
    | None -> handle_none cache_key

  let clear key =
    try Option.some @@ Sys.remove @@ cache_location key with _ -> None
end