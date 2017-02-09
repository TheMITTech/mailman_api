type user
type token

(* Logging in, logging out, etc.. *)
val addEmailLink : user -> StringTypes.addr -> transaction unit
val newAccount : string -> string -> StringTypes.addr -> transaction bool (* user, pass *)
val blessEmailLink : string -> token -> transaction bool
val signIn : string -> string -> transaction (option user) (* user, pass *)
val newToken : user -> transaction token
val loadUser : token -> transaction (option user) (* user, token *)

(* Token stuff *)
val readToken : string -> option token
val token_show : show token
