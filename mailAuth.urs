type user

val newAccount : string -> string -> EmailAddr.addr -> transaction unit (* user, pass *)
val blessAccount : string -> string -> transaction bool
val signIn : string -> string -> transaction user (* user, pass *)
val newToken : user -> transaction string
val loadUser : string -> string -> transaction user (* user, token *)
val username : string -> username
val password : string -> password

val addressesOwned : user -> list EmailAddr.addr
