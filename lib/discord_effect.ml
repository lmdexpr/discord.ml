include Effect

type _ t += Post_request : {
  host : string;
  path : string;
  headers : (string * string) list;
  body : string;
} -> string t
