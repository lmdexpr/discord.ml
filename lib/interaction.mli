open Common

type type_ =
  | PING
  | APPLICATION_COMMAND
  | MESSAGE_COMPONENT
  | APPLICATION_COMMAND_AUTOCOMPLETE
  | MODAL_SUBMIT

type snowflake_user = (snowflake * User.t)
type snowflake_guild_member = (snowflake * Guild.member)
type snowflake_role = (snowflake * Role.t)
type snowflake_channel = (snowflake * Channel.t)
type snowflake_message = (snowflake * Channel.Message.t)
type snowflake_attachment = (snowflake * Channel.attachment)

type resolved = {
  users: snowflake_user list;
  members: snowflake_guild_member list;
  roles: snowflake_role list;
  channels: snowflake_channel list;
  messages: snowflake_message list;
  attachments: snowflake_attachment list;
}

val yojson_of_type_ : type_ -> Yojson.Safe.t
val type__of_yojson : Yojson.Safe.t -> type_

module Opt : sig
  type type_ =
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

  val yojson_of_type_ : type_ -> Yojson.Safe.t
  val type__of_yojson : Yojson.Safe.t -> type_

  type t = {
    name: string;
    type_: type_;
    value: string_or_integer_or_double_or_boolean option;
    options: t list;
    focused: bool option;
  }
end

type context_type =
  | GUILD
  | BOT_DM
  | PRIVATE_CHANNEL
val context_type_of_yojson : Yojson.Safe.t -> context_type
val yojson_of_context_type : context_type -> Yojson.Safe.t

type data = {
  id: snowflake;
  name: string;
  type_: int;
  resolved: resolved option;
  options: Opt.t list;
  guild_id: snowflake option;
  target_id: snowflake option;
}

type t = {
  id: snowflake;
  application_id: snowflake;
  type_: type_;
  data: data option;
  token: string;
}

val of_string : string -> t
val pp : Format.formatter -> t -> unit
val find_option_string_exn : t -> string -> string
