(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 *)

type t = {
  (* An array of recommendation seed objects.  *)
  seeds : Recommendation_seed_object.t list;
  (* An array of track objects ordered according to the parameters supplied.  *)
  tracks : Track_object.t list;
}
[@@deriving yojson { strict = false }, show]

let create (seeds : Recommendation_seed_object.t list)
    (tracks : Track_object.t list) : t =
  { seeds; tracks }
