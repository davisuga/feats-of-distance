(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 *)

type reason = [
| `Market [@printer fun fmt _ -> Format.pp_print_string fmt "market"] [@name "market"]
| `Product [@printer fun fmt _ -> Format.pp_print_string fmt "product"] [@name "product"]
| `Explicit [@printer fun fmt _ -> Format.pp_print_string fmt "explicit"] [@name "explicit"]
] [@@deriving yojson, show { with_path = false }];;

let reason_of_yojson json = reason_of_yojson (`List [json])
let reason_to_yojson e =
    match reason_to_yojson e with
    | `List [json] -> json
    | json -> json

type release_date_precision = [
| `Year [@printer fun fmt _ -> Format.pp_print_string fmt "year"] [@name "year"]
| `Month [@printer fun fmt _ -> Format.pp_print_string fmt "month"] [@name "month"]
| `Day [@printer fun fmt _ -> Format.pp_print_string fmt "day"] [@name "day"]
] [@@deriving yojson, show { with_path = false }];;

let release_date_precision_of_yojson json = release_date_precision_of_yojson (`List [json])
let release_date_precision_to_yojson e =
    match release_date_precision_to_yojson e with
    | `List [json] -> json
    | json -> json

type audiofeaturesobject_type = [
| `Audio_features [@printer fun fmt _ -> Format.pp_print_string fmt "audio_features"] [@name "audio_features"]
] [@@deriving yojson, show { with_path = false }];;

let audiofeaturesobject_type_of_yojson json = audiofeaturesobject_type_of_yojson (`List [json])
let audiofeaturesobject_type_to_yojson e =
    match audiofeaturesobject_type_to_yojson e with
    | `List [json] -> json
    | json -> json

type artistobject_type = [
| `Artist [@printer fun fmt _ -> Format.pp_print_string fmt "artist"] [@name "artist"]
] [@@deriving yojson, show { with_path = false }];;

let artistobject_type_of_yojson json = artistobject_type_of_yojson (`List [json])
let artistobject_type_to_yojson e =
    match artistobject_type_to_yojson e with
    | `List [json] -> json
    | json -> json

type albumbase_type = [
| `Album [@printer fun fmt _ -> Format.pp_print_string fmt "album"] [@name "album"]
] [@@deriving yojson, show { with_path = false }];;

let albumbase_type_of_yojson json = albumbase_type_of_yojson (`List [json])
let albumbase_type_to_yojson e =
    match albumbase_type_to_yojson e with
    | `List [json] -> json
    | json -> json

type album_type = [
| `Album [@printer fun fmt _ -> Format.pp_print_string fmt "album"] [@name "album"]
| `Single [@printer fun fmt _ -> Format.pp_print_string fmt "single"] [@name "single"]
| `Compilation [@printer fun fmt _ -> Format.pp_print_string fmt "compilation"] [@name "compilation"]
] [@@deriving yojson, show { with_path = false }];;

let album_type_of_yojson json = album_type_of_yojson (`List [json])
let album_type_to_yojson e =
    match album_type_to_yojson e with
    | `List [json] -> json
    | json -> json

type album_group = [
| `Album [@printer fun fmt _ -> Format.pp_print_string fmt "album"] [@name "album"]
| `Single [@printer fun fmt _ -> Format.pp_print_string fmt "single"] [@name "single"]
| `Compilation [@printer fun fmt _ -> Format.pp_print_string fmt "compilation"] [@name "compilation"]
| `Appears_on [@printer fun fmt _ -> Format.pp_print_string fmt "appears_on"] [@name "appears_on"]
] [@@deriving yojson, show { with_path = false }];;

let album_group_of_yojson json = album_group_of_yojson (`List [json])
let album_group_to_yojson e =
    match album_group_to_yojson e with
    | `List [json] -> json
    | json -> json

type showbase_type = [
| `Show [@printer fun fmt _ -> Format.pp_print_string fmt "show"] [@name "show"]
] [@@deriving yojson, show { with_path = false }];;

let showbase_type_of_yojson json = showbase_type_of_yojson (`List [json])
let showbase_type_to_yojson e =
    match showbase_type_to_yojson e with
    | `List [json] -> json
    | json -> json

type episodebase_type = [
| `Episode [@printer fun fmt _ -> Format.pp_print_string fmt "episode"] [@name "episode"]
] [@@deriving yojson, show { with_path = false }];;

let episodebase_type_of_yojson json = episodebase_type_of_yojson (`List [json])
let episodebase_type_to_yojson e =
    match episodebase_type_to_yojson e with
    | `List [json] -> json
    | json -> json

type type_0 = [
| `Artist [@printer fun fmt _ -> Format.pp_print_string fmt "artist"] [@name "artist"]
| `User [@printer fun fmt _ -> Format.pp_print_string fmt "user"] [@name "user"]
] [@@deriving yojson, show { with_path = false }];;

let type_0_of_yojson json = type_0_of_yojson (`List [json])
let type_0_to_yojson e =
    match type_0_to_yojson e with
    | `List [json] -> json
    | json -> json

type type_1 = [
| `Album [@printer fun fmt _ -> Format.pp_print_string fmt "album"] [@name "album"]
| `Artist [@printer fun fmt _ -> Format.pp_print_string fmt "artist"] [@name "artist"]
| `Playlist [@printer fun fmt _ -> Format.pp_print_string fmt "playlist"] [@name "playlist"]
| `Track [@printer fun fmt _ -> Format.pp_print_string fmt "track"] [@name "track"]
| `Show [@printer fun fmt _ -> Format.pp_print_string fmt "show"] [@name "show"]
| `Episode [@printer fun fmt _ -> Format.pp_print_string fmt "episode"] [@name "episode"]
] [@@deriving yojson, show { with_path = false }];;

let type_1_of_yojson json = type_1_of_yojson (`List [json])
let type_1_to_yojson e =
    match type_1_to_yojson e with
    | `List [json] -> json
    | json -> json

type include_external = [
| `Audio [@printer fun fmt _ -> Format.pp_print_string fmt "audio"] [@name "audio"]
] [@@deriving yojson, show { with_path = false }];;

let include_external_of_yojson json = include_external_of_yojson (`List [json])
let include_external_to_yojson e =
    match include_external_to_yojson e with
    | `List [json] -> json
    | json -> json

type mode = [
| `Minus1 [@printer fun fmt _ -> Format.pp_print_string fmt "-1"] [@name "-1"]
| `_0 [@printer fun fmt _ -> Format.pp_print_string fmt "0"] [@name "0"]
| `_1 [@printer fun fmt _ -> Format.pp_print_string fmt "1"] [@name "1"]
] [@@deriving yojson, show { with_path = false }];;

let mode_of_yojson json = mode_of_yojson (`List [json])
let mode_to_yojson e =
    match mode_to_yojson e with
    | `List [json] -> json
    | json -> json

type publicuserobject_type = [
| `User [@printer fun fmt _ -> Format.pp_print_string fmt "user"] [@name "user"]
] [@@deriving yojson, show { with_path = false }];;

let publicuserobject_type_of_yojson json = publicuserobject_type_of_yojson (`List [json])
let publicuserobject_type_to_yojson e =
    match publicuserobject_type_to_yojson e with
    | `List [json] -> json
    | json -> json

type playererrorreasons = [
| `NO_PREV_TRACK [@printer fun fmt _ -> Format.pp_print_string fmt "NO_PREV_TRACK"] [@name "NO_PREV_TRACK"]
| `NO_NEXT_TRACK [@printer fun fmt _ -> Format.pp_print_string fmt "NO_NEXT_TRACK"] [@name "NO_NEXT_TRACK"]
| `NO_SPECIFIC_TRACK [@printer fun fmt _ -> Format.pp_print_string fmt "NO_SPECIFIC_TRACK"] [@name "NO_SPECIFIC_TRACK"]
| `ALREADY_PAUSED [@printer fun fmt _ -> Format.pp_print_string fmt "ALREADY_PAUSED"] [@name "ALREADY_PAUSED"]
| `NOT_PAUSED [@printer fun fmt _ -> Format.pp_print_string fmt "NOT_PAUSED"] [@name "NOT_PAUSED"]
| `NOT_PLAYING_LOCALLY [@printer fun fmt _ -> Format.pp_print_string fmt "NOT_PLAYING_LOCALLY"] [@name "NOT_PLAYING_LOCALLY"]
| `NOT_PLAYING_TRACK [@printer fun fmt _ -> Format.pp_print_string fmt "NOT_PLAYING_TRACK"] [@name "NOT_PLAYING_TRACK"]
| `NOT_PLAYING_CONTEXT [@printer fun fmt _ -> Format.pp_print_string fmt "NOT_PLAYING_CONTEXT"] [@name "NOT_PLAYING_CONTEXT"]
| `ENDLESS_CONTEXT [@printer fun fmt _ -> Format.pp_print_string fmt "ENDLESS_CONTEXT"] [@name "ENDLESS_CONTEXT"]
| `CONTEXT_DISALLOW [@printer fun fmt _ -> Format.pp_print_string fmt "CONTEXT_DISALLOW"] [@name "CONTEXT_DISALLOW"]
| `ALREADY_PLAYING [@printer fun fmt _ -> Format.pp_print_string fmt "ALREADY_PLAYING"] [@name "ALREADY_PLAYING"]
| `RATE_LIMITED [@printer fun fmt _ -> Format.pp_print_string fmt "RATE_LIMITED"] [@name "RATE_LIMITED"]
| `REMOTE_CONTROL_DISALLOW [@printer fun fmt _ -> Format.pp_print_string fmt "REMOTE_CONTROL_DISALLOW"] [@name "REMOTE_CONTROL_DISALLOW"]
| `DEVICE_NOT_CONTROLLABLE [@printer fun fmt _ -> Format.pp_print_string fmt "DEVICE_NOT_CONTROLLABLE"] [@name "DEVICE_NOT_CONTROLLABLE"]
| `VOLUME_CONTROL_DISALLOW [@printer fun fmt _ -> Format.pp_print_string fmt "VOLUME_CONTROL_DISALLOW"] [@name "VOLUME_CONTROL_DISALLOW"]
| `NO_ACTIVE_DEVICE [@printer fun fmt _ -> Format.pp_print_string fmt "NO_ACTIVE_DEVICE"] [@name "NO_ACTIVE_DEVICE"]
| `PREMIUM_REQUIRED [@printer fun fmt _ -> Format.pp_print_string fmt "PREMIUM_REQUIRED"] [@name "PREMIUM_REQUIRED"]
| `UNKNOWN [@printer fun fmt _ -> Format.pp_print_string fmt "UNKNOWN"] [@name "UNKNOWN"]
] [@@deriving yojson, show { with_path = false }];;

let playererrorreasons_of_yojson json = playererrorreasons_of_yojson (`List [json])
let playererrorreasons_to_yojson e =
    match playererrorreasons_to_yojson e with
    | `List [json] -> json
    | json -> json
