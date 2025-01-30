type type_ =
  | PONG
  | CHANNEL_MESSAGE_WITH_SOURCE
  | DEFERRED_CHANNEL_MESSAGE_WITH_SOURCE
  | DEFERRED_UPDATE_MESSAGE
  | UPDATE_MESSAGE
  | APPLICATION_COMMAND_AUTOCOMPLETE_RESULT
  | MODAL
  | PREMIUM_REQUIRED

val yojson_of_type_ : type_ -> Yojson.Safe.t
val type__of_yojson : Yojson.Safe.t -> type_

type data = {
  content: string option
}

type t = {
  type_: type_;
  data: data option
}

val pong : t
val channel_message_with_source : string -> t
val deferred_channel_message_with_source : t

val string_of_t : t -> string

val ok : t -> (string * string) list * string

val follow_up : 
  application_id:string ->
  discord_token:string  ->
  interaction:Interaction.t -> string -> unit
