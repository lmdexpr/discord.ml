type type_ =
  | CHAT_INPUT
  | USER
  | MESSAGE

val yojson_of_type_ : type_ -> Yojson.Safe.t

type opt_type =
  | SUB_COMMAND
  | SUB_COMMAND_GROUP
  | STRING
  | INTEGER
  | BOOLEAN
  | USER
  | CHANNEL
  | ROLE
  | MENTIONABLE
  | NUMBER
  | ATTACHMENT

val yojson_of_opt_type : opt_type -> Yojson.Safe.t
val opt_type_of_yojson : Yojson.Safe.t -> opt_type

type choice = {
  name: string;
  value: string;
}

type opt = {
  name: string;
  description: string;
  type_: opt_type;
  required: bool;
  choices: choice list option;
}

val make_opt :
  ?choices: choice list ->
  name: string ->
  description: string ->
  type_:opt_type ->
  required:bool ->
  unit -> opt

type t = {
  name : string;
  type_ : type_;
  description : string;
  options: opt list option;
  handler : Interaction.t -> Interaction_response.t;
}

val yojson_of_t : t -> Yojson.Safe.t

val make :
  ?options: opt list ->
  name: string ->
  type_: type_ ->
  description: string ->
  (Interaction.t -> Interaction_response.t) -> t

val global_uri : string -> string
val guild_uri  : string -> string -> string

val register : application_id:string -> ?guild_id:string -> discord_token:string -> t -> unit

val verify_key : public_key:string -> (string * string) list -> string -> unit option

val dispatch :
  public_key:string ->
  t list -> (string * string) list -> string -> 
  [> `Ok of Interaction_response.t | `Unauthorized | `Bad_request | `Service_unavailable ]
