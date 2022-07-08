(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 * Schema Saved_episode_object_episode.t : Information about the episode.
 *)

type t = {
    (* A URL to a 30 second preview (MP3 format) of the episode. `null` if not available.  *)
    audio_preview_url: string;
    (* A description of the episode. HTML tags are stripped away from this field, use `html_description` field in case HTML tags are needed.  *)
    description: string;
    (* A description of the episode. This field may contain HTML tags.  *)
    html_description: string;
    (* The episode length in milliseconds.  *)
    duration_ms: int32;
    (* Whether or not the episode has explicit content (true = yes it does; false = no it does not OR unknown).  *)
    explicit: bool;
    external_urls: Episode_base_external_urls.t;
    (* A link to the Web API endpoint providing full details of the episode.  *)
    href: string;
    (* The [Spotify ID](/documentation/web-api/#spotify-uris-and-ids) for the episode.  *)
    id: string;
    (* The cover art for the episode in various sizes, widest first.  *)
    images: Image_object.t list;
    (* True if the episode is hosted outside of Spotify's CDN.  *)
    is_externally_hosted: bool;
    (* True if the episode is playable in the given market. Otherwise false.  *)
    is_playable: bool;
    (* The language used in the episode, identified by a [ISO 639](https://en.wikipedia.org/wiki/ISO_639) code. This field is deprecated and might be removed in the future. Please use the `languages` field instead.  *)
    language: string option [@default None];
    (* A list of the languages used in the episode, identified by their [ISO 639-1](https://en.wikipedia.org/wiki/ISO_639) code.  *)
    languages: string list;
    (* The name of the episode.  *)
    name: string;
    (* The date the episode was first released, for example `\''1981-12-15\''`. Depending on the precision, it might be shown as `\''1981\''` or `\''1981-12\''`.  *)
    release_date: string;
    (* The precision with which `release_date` value is known.  *)
    release_date_precision: Enums.release_date_precision;
    resume_point: Episode_base_resume_point.t;
    (* The object type.  *)
    _type: Enums.episodebase_type[@default `Episode];
    (* The [Spotify URI](/documentation/web-api/#spotify-uris-and-ids) for the episode.  *)
    uri: string;
    restrictions: Episode_base_restrictions.t option [@default None];
    (* The show on which the episode belongs.  *)
    show: Simplified_show_object.t;
} [@@deriving yojson { strict = false }, show ];;

(** Information about the episode. *)
let create (audio_preview_url : string) (description : string) (html_description : string) (duration_ms : int32) (explicit : bool) (external_urls : Episode_base_external_urls.t) (href : string) (id : string) (images : Image_object.t list) (is_externally_hosted : bool) (is_playable : bool) (languages : string list) (name : string) (release_date : string) (release_date_precision : Enums.release_date_precision) (resume_point : Episode_base_resume_point.t) (_type : Enums.episodebase_type) (uri : string) (show : Simplified_show_object.t) : t = {
    audio_preview_url = audio_preview_url;
    description = description;
    html_description = html_description;
    duration_ms = duration_ms;
    explicit = explicit;
    external_urls = external_urls;
    href = href;
    id = id;
    images = images;
    is_externally_hosted = is_externally_hosted;
    is_playable = is_playable;
    language = None;
    languages = languages;
    name = name;
    release_date = release_date;
    release_date_precision = release_date_precision;
    resume_point = resume_point;
    _type = _type;
    uri = uri;
    restrictions = None;
    show = show;
}

