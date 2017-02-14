type user
type userName
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

(* Type-safe stuff! *)
val blessUserName : string -> transaction (option userName)
val show_username : show userName
