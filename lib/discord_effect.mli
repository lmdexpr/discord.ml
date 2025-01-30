type _ Effect.t += Get_string : string -> string Effect.t

type _ Effect.t += Post_request : {
  host : string;
  path : string;
  headers : (string * string) list;
  body : string;
} -> unit Effect.t
