(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 *)

val check_users_saved_shows : ids:string -> bool list Lwt.t
val get_a_show : id:string -> ?market:string -> unit -> Show_object.t Lwt.t
val get_a_shows_episodes : id:string -> ?market:string -> ?limit:int32 -> ?offset:int32 -> unit -> Episodes_paging_object.t Lwt.t
val get_multiple_shows : ids:string -> ?market:string -> unit -> Get_multiple_shows_200_response.t Lwt.t
val get_users_saved_shows : ?limit:int32 -> ?offset:int32 -> unit -> Get_users_saved_shows_200_response.t Lwt.t
val remove_shows_user : ids:string -> ?market:string -> save_shows_user_request_t:Save_shows_user_request.t -> unit -> unit Lwt.t
val save_shows_user : ids:string -> save_shows_user_request_t:Save_shows_user_request.t -> unit -> unit Lwt.t
