open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type type_ =
  | CHAT_INPUT
  | USER
  | MESSAGE

let yojson_of_type_ = function
  | CHAT_INPUT -> `Int 1
  | USER       -> `Int 2
  | MESSAGE    -> `Int 3

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

let yojson_of_opt_type = function
  | SUB_COMMAND       -> `Int 1
  | SUB_COMMAND_GROUP -> `Int 2
  | STRING            -> `Int 3
  | INTEGER           -> `Int 4
  | BOOLEAN           -> `Int 5
  | USER              -> `Int 6
  | CHANNEL           -> `Int 7
  | ROLE              -> `Int 8
  | MENTIONABLE       -> `Int 9
  | NUMBER            -> `Int 10
  | ATTACHMENT        -> `Int 11

(* for deriving. not implemented *)
let opt_type_of_yojson _ = raise (Yojson.Json_error "opt_type (not implemented)")

type choice = {
  name: string;
  value: string;
} [@@deriving yojson]

type opt = {
  name: string;
  description: string;
  type_: opt_type; [@key "type"]
  required: bool;
  choices: choice list option; [@yojson.option]
} [@@deriving yojson]

let make_opt ?choices ~name ~description ~type_ ~required () = { name; description; type_; required; choices }

type t = {
  name : string;
  type_ : type_;
  description : string;
  options: opt list option;
  handler : Interaction.t -> Interaction_response.t;
}

let yojson_of_t command = 
  let lst = [
    "name", `String command.name;
    "type", yojson_of_type_ command.type_;
    "description", `String command.description;
  ] in
  let lst = match command.options with
    | None         -> lst
    | Some options -> ("options", `List (List.map yojson_of_opt options)) :: lst
  in
  `Assoc lst

let make ?options ~name ~type_ ~description handler = { name; type_; description; options; handler }

open Printf

let global_uri a   = sprintf "applications/%s/commands" a
let guild_uri  a g = sprintf "applications/%s/guilds/%s/commands" a g

let register ~application_id ?guild_id ~discord_token command =
  let body = Yojson.Safe.to_string @@ yojson_of_t command in
  Logs.info (fun m -> m "Registering commands: %s" body);
  match guild_id with
  | None          -> Client.post_request ~discord_token ~body (global_uri application_id)
  | Some guild_id -> Client.post_request ~discord_token ~body (guild_uri  application_id guild_id)

let verify_key ~public_key headers body =
  try
    let signature = List.assoc "x-signature-ed25519" headers in
    let timestamp = List.assoc "x-signature-timestamp" headers in

    Logs.debug (fun m -> m "Verifying signature: %a" Hex.pp @@ `Hex signature);
    Logs.debug (fun m -> m "Timestamp: %a" Hex.pp @@ `Hex timestamp);
    Logs.debug (fun m -> m "Body: %s" (timestamp ^ body));

    Sodium.Sign.Bytes.(verify
      (`Hex public_key  |> Hex.to_bytes |> to_public_key)
      (`Hex signature   |> Hex.to_bytes |> to_signature)
      (timestamp ^ body |> String.to_bytes)
    );
    Some ()
  with e ->
    Logs.err (fun m -> m "Verification failed: %s" (Printexc.to_string e));
    None

let dispatch ~public_key all headers body =
  match verify_key ~public_key headers body with
  | Some _ -> (
    match Interaction.(of_string body) with
    | Interaction.{ type_ = APPLICATION_COMMAND; data = Some data; _ } as interaction ->
      List.find_opt (fun { name; _ } -> name = data.name) all
      |> Option.map (fun { handler; _ } -> handler)
      |> Option.fold
        ~none:`Bad_request
        ~some:(fun handler -> `Ok (handler interaction))
    | { type_ = APPLICATION_COMMAND; _ } -> `Bad_request
    | { type_ = PING; _ }                -> `Ok Interaction_response.pong
    | _                                  -> `Service_unavailable
  )
  | None   -> `Unauthorized
