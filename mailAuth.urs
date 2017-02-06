type user
type token
val addEmailLink : user -> EmailAddr.addr -> transaction unit
val newAccount : string -> string -> EmailAddr.addr -> transaction bool (* user, pass *)
val blessEmailLink : token -> transaction bool
val signIn : string -> string -> transaction (option user) (* user, pass *)
val newToken : user -> transaction token
val loadUser : token -> transaction user (* user, token *)
(*val addressesOwned : user -> list EmailAddr.addr*)
