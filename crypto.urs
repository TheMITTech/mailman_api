type hashed

val getHash : hashed -> string
val getSalt : hashed -> string
val hash : string -> transaction hashed
val hashWithSalt : string -> int -> transaction hashed
val verify : string -> string -> string -> transaction bool (* pass -> hash -> salt *)
val random : int -> transaction string
