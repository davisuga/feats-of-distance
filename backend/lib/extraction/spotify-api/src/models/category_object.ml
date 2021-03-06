(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 *)

type t = {
  (* A link to the Web API endpoint returning full details of the category.  *)
  href : string;
  (* The category icon, in various sizes.  *)
  icons : Image_object.t list;
  (* The [Spotify category ID](/documentation/web-api/#spotify-uris-and-ids) of the category.  *)
  id : string;
  (* The name of the category.  *)
  name : string;
}
[@@deriving yojson { strict = false }, show]

let create (href : string) (icons : Image_object.t list) (id : string)
    (name : string) : t =
  { href; icons; id; name }
