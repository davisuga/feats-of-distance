module Request = struct
  let api_key = ""
  let base_url = "https://api.spotify.com/v1"

  let default_headers =
    Cohttp.Header.init_with "Content-Type" "application/json"

  let option_fold f default o = match o with Some v -> f v | None -> default
  let build_uri operation_path = Uri.of_string (base_url ^ operation_path)
  let add_string_header headers key value = Cohttp.Header.add headers key value

  let add_token token headers =
    add_string_header headers "Authorization" ("Bearer " ^ token)

  let default_headers_with_token t = default_headers |> add_token t

  let add_string_header_multi headers key values =
    Cohttp.Header.add_multi headers key values

  let add_header headers key to_string value =
    Cohttp.Header.add headers key (to_string value)

  let add_header_multi headers key to_string value =
    Cohttp.Header.add_multi headers key (to_string value)

  let maybe_add_header headers key to_string value =
    option_fold (add_header headers key to_string) headers value

  let maybe_add_header_multi headers key to_string value =
    option_fold (add_header_multi headers key to_string) headers value

  let write_string_body s = Cohttp_lwt.Body.of_string s

  let write_json_body payload =
    Cohttp_lwt.Body.of_string (Yojson.Safe.to_string payload ~std:true)

  let write_as_json_body to_json payload = write_json_body (to_json payload)

  let handle_response resp on_success_handler =
    match Cohttp_lwt.Response.status resp with
    | #Cohttp.Code.success_status -> on_success_handler ()
    | s ->
        failwith
          ("Server responded with status "
          ^ Cohttp.Code.(reason_phrase_of_code (code_of_status s)))

  let handle_unit_response resp = handle_response resp (fun () -> Lwt.return ())

  let read_json_body resp body =
    handle_response resp (fun () ->
        Lwt.(Cohttp_lwt.Body.to_string body >|= Yojson.Safe.from_string))

  let read_json_body_as of_json resp body =
    Lwt.(read_json_body resp body >|= of_json)

  let read_json_body_as_list resp body =
    Lwt.(read_json_body resp body >|= Yojson.Safe.Util.to_list)

  let read_json_body_as_list_of of_json resp body =
    Lwt.(read_json_body_as_list resp body >|= List.map of_json)

  let read_json_body_as_map resp body =
    Lwt.(read_json_body resp body >|= Yojson.Safe.Util.to_assoc)

  let read_json_body_as_map_of of_json resp body =
    Lwt.(
      read_json_body_as_map resp body
      >|= List.map (fun (s, v) -> (s, of_json v)))

  let replace_string_path_param uri param_name param_value =
    let regexp = Str.regexp (Str.quote ("{" ^ param_name ^ "}")) in
    let path =
      Str.global_replace regexp param_value (Uri.pct_decode (Uri.path uri))
    in
    Uri.with_path uri path

  let replace_path_param uri param_name to_string param_value =
    replace_string_path_param uri param_name (to_string param_value)

  let maybe_replace_path_param uri param_name to_string param_value =
    option_fold (replace_path_param uri param_name to_string) uri param_value

  let add_query_param uri param_name to_string param_value =
    Uri.add_query_param' uri (param_name, to_string param_value)

  let add_query_param_list uri param_name to_string param_value =
    Uri.add_query_param uri (param_name, to_string param_value)

  let maybe_add_query_param uri param_name to_string param_value =
    option_fold (add_query_param uri param_name to_string) uri param_value

  let init_form_encoded_body () = ""

  let add_form_encoded_body_param params param_name to_string param_value =
    let new_param_enc =
      Printf.sprintf {|%s=%s|}
        (Uri.pct_encode param_name)
        (Uri.pct_encode (to_string param_value))
    in
    if params = "" then new_param_enc
    else Printf.sprintf {|%s&%s|} params new_param_enc

  let add_form_encoded_body_param_list params param_name to_string new_params =
    add_form_encoded_body_param params param_name (String.concat ",")
      (to_string new_params)

  let maybe_add_form_encoded_body_param params param_name to_string param_value
      =
    option_fold
      (add_form_encoded_body_param params param_name to_string)
      params param_value

  let finalize_form_encoded_body body = Cohttp_lwt.Body.of_string body
end

include Request

module type S = sig
  val api_key : string
  val base_url : string
  val default_headers : Cohttp.Header.t
  val option_fold : ('a -> 'b) -> 'b -> 'a option -> 'b
  val build_uri : string -> Uri.t
  val add_string_header : Cohttp.Header.t -> string -> string -> Cohttp.Header.t

  val add_string_header_multi :
    Cohttp.Header.t -> string -> string list -> Cohttp.Header.t

  val add_header :
    Cohttp.Header.t -> string -> ('a -> string) -> 'a -> Cohttp.Header.t

  val add_header_multi :
    Cohttp.Header.t -> string -> ('a -> string list) -> 'a -> Cohttp.Header.t

  val maybe_add_header :
    Cohttp.Header.t -> string -> ('a -> string) -> 'a option -> Cohttp.Header.t

  val maybe_add_header_multi :
    Cohttp.Header.t ->
    string ->
    ('a -> string list) ->
    'a option ->
    Cohttp.Header.t

  val write_string_body : string -> Cohttp_lwt.Body.t
  val write_json_body : Yojson.Safe.t -> Cohttp_lwt.Body.t
  val write_as_json_body : ('a -> Yojson.Safe.t) -> 'a -> Cohttp_lwt.Body.t
  val handle_response : Cohttp.Response.t -> (unit -> 'a) -> 'a
  val handle_unit_response : Cohttp.Response.t -> unit Lwt.t

  val read_json_body :
    Cohttp.Response.t -> Cohttp_lwt.Body.t -> Yojson.Safe.t Lwt.t

  val read_json_body_as :
    (Yojson.Safe.t -> 'a) -> Cohttp.Response.t -> Cohttp_lwt.Body.t -> 'a Lwt.t

  val read_json_body_as_list :
    Cohttp.Response.t -> Cohttp_lwt.Body.t -> Yojson.Safe.t list Lwt.t

  val read_json_body_as_list_of :
    (Yojson.Safe.t -> 'a) ->
    Cohttp.Response.t ->
    Cohttp_lwt.Body.t ->
    'a list Lwt.t

  val read_json_body_as_map :
    Cohttp.Response.t ->
    Cohttp_lwt.Body.t ->
    (string * Yojson.Safe.t) list Lwt.t

  val read_json_body_as_map_of :
    (Yojson.Safe.t -> 'a) ->
    Cohttp.Response.t ->
    Cohttp_lwt.Body.t ->
    (string * 'a) list Lwt.t

  val replace_string_path_param : Uri.t -> string -> string -> Uri.t
  val replace_path_param : Uri.t -> string -> ('a -> string) -> 'a -> Uri.t

  val maybe_replace_path_param :
    Uri.t -> string -> ('a -> string) -> 'a option -> Uri.t

  val add_query_param : Uri.t -> string -> ('a -> string) -> 'a -> Uri.t

  val add_query_param_list :
    Uri.t -> string -> ('a -> string list) -> 'a -> Uri.t

  val maybe_add_query_param :
    Uri.t -> string -> ('a -> string) -> 'a option -> Uri.t

  val init_form_encoded_body : unit -> string

  val add_form_encoded_body_param :
    string -> string -> ('a -> string) -> 'a -> string

  val add_form_encoded_body_param_list :
    string -> string -> ('a -> string list) -> 'a -> string

  val maybe_add_form_encoded_body_param :
    string -> string -> ('a -> string) -> 'a option -> string

  val finalize_form_encoded_body : string -> Cohttp_lwt.Body.t
end
