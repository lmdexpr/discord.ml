module Config               = Config
module Client               = Client
module Interaction          = Interaction
module Interaction_response = Interaction_response
module Slash_command        = Slash_command
module Effect               = Discord_effect

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
