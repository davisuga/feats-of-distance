(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 *)

type t = {
    external_urls: Public_user_object_external_urls.t option [@default None];
    followers: Public_user_object_followers.t option [@default None];
    (* A link to the Web API endpoint for this user.  *)
    href: string option [@default None];
    (* The [Spotify user ID](/documentation/web-api/#spotify-uris-and-ids) for this user.  *)
    id: string option [@default None];
    (* The object type.  *)
    _type: Enums.publicuserobject_type option [@default Some(`User)];
    (* The [Spotify URI](/documentation/web-api/#spotify-uris-and-ids) for this user.  *)
    uri: string option [@default None];
    (* The name displayed on the user's profile. `null` if not available.  *)
    display_name: string option [@default None];
} [@@deriving yojson { strict = false }, show ];;

let create () : t = {
    external_urls = None;
    followers = None;
    href = None;
    id = None;
    _type = None;
    uri = None;
    display_name = None;
}
