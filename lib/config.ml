type t = {
  public_key : string;
  discord_token : string;
  application_id : string;
  guild_ids : string list;
}

let load
  ?(prefix="")
  ?(public_key_key="PUBLIC_KEY")
  ?(discord_token_key="DISCORD_TOKEN")
  ?(application_id_key="APPLICATION_ID")
  ?(guild_ids_key="GUILD_IDS")
  () =
  let open Discord_effect in
  let (+) prefix key =
    (if prefix = "" then "" else prefix ^ "_") ^ key
  in
  {
    public_key     = Effect.perform @@ Get_string (prefix + public_key_key);
    discord_token  = Effect.perform @@ Get_string (prefix + discord_token_key);
    application_id = Effect.perform @@ Get_string (prefix + application_id_key);
    guild_ids      = Effect.perform @@ Get_string (prefix + guild_ids_key) |> String.split_on_char ',' |> List.filter (fun x -> x <> "");
  }
