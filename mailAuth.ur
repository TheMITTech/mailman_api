open Crypto

type user = string
type uname = string
type pass = string

table userCredentials = 

fun NewAccount (u : string) (p : string) (email : EmailAddr.addr) : transaction unit =
		hashedPass <- hash p;
		dml (INSERT INTO accounts ())

fun usernameExists (username : string) : transaction bool =
		
