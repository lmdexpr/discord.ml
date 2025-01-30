type t = {
  public_key : string;
  discord_token : string;
  application_id : string;
  guild_ids : string list;
}

val load :
  ?prefix:string ->
  ?public_key_key:string ->
  ?discord_token_key:string ->
  ?application_id_key:string ->
  ?guild_ids_key:string ->
  unit -> t
