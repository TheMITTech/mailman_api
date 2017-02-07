type user
type token
val addEmailLink : user -> EmailAddr.addr -> transaction unit
val newAccount : string -> string -> EmailAddr.addr -> transaction bool (* user, pass *)
val blessEmailLink : string -> token -> transaction bool
val signIn : string -> string -> transaction (option user) (* user, pass *)
val newToken : user -> transaction token
val loadUser : token -> transaction (option user) (* user, token *)
val readToken : string -> option token
val token_show : show token
(*val addressesOwned : user -> list EmailAddr.addr*)
