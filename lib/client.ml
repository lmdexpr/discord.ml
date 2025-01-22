let version = "v10"

let post_request ~discord_token ~body path =
  let (/) = Filename.concat in
  Effect.perform @@ Discord_effect.Post_request {
    host = "discord.com"; 
    path = "api" / version / path;
    headers = [
      "user-agent", "DiscordBot (https://github.com/lmdexpr/discord.ml, 0.1)";
      "Authorization", Printf.sprintf "Bot %s" discord_token;
      "accept", "*/*"; 
      "Content-type", "application/json"; 
    ]; 
    body; 
  }
