open Crypto
open EmailAddr

type user = string
type token = {Id : int, Secret : string}

sequence ids

table userCredentials : {UserName : string, Hash : string, Salt : string}
												PRIMARY KEY UserName,
												CONSTRAINT UserName UNIQUE UserName

table userLinks : {Id : int,
									 WhenRequested : time,
									 Approved : bool,
									 TokenHash : string,
									 TokenSalt : string,
									 UserName : string,
									 Email : string}
									PRIMARY KEY UserName,
			            CONSTRAINT Id UNIQUE Id

table userTokens : {Id : int,
										TokenHash : string,
										TokenSalt : string,
									 	WhenCreated : time,
									  UserName : string
									 }
											 PRIMARY KEY Id, CONSTRAINT Id UNIQUE Id 

fun _addEmailLink (u : string) (e : addr) : transaction unit =
		requestTime <- now;
		myToken <- token 40;
		newId <- nextval ids;
		dml (INSERT INTO
					 userLinks (Id, UserName, Email, WhenRequested, Approved, TokenHash, TokenSalt) 
				 VALUES 
					 (
						 {[newId]},
						 {[u]},
						 {[show e]}, 
						 {[requestTime]},
						 {[False]},
						 {[getHash myToken.Hash]},
						 {[getSalt myToken.Hash]}
					 )
				)

fun _alphanumeric (s : string) : bool =
		let
				fun alphanumericChar (c : char) : bool =
						case (String.index "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789" c) of
								None => False
							| Some _ => True
		in
				String.all alphanumericChar s
		end

fun readToken (s : string) : option token =
		case (String.split (String.trim s) #".") of
				None => None
			| Some (a : string, b : string) => (
				let
						val maybeId : option int = read a
						val saneSecret : bool = _alphanumeric b
				in
						case maybeId of
								None => None
							| Some id => (
								if
										saneSecret
								then
										Some {Secret = b, Id = id}
								else
										None
								)
				end
				)

val token_show = mkShow (fn (x : token) => (show x.Id) ^ x.Secret)

fun usernameExists (username : string) : transaction bool =
		rows <- queryL (SELECT * FROM userCredentials WHERE userCredentials.UserName = {[username]});
		return (List.length rows > 0)

fun addEmailLink (u : user) (e : addr) : transaction unit =
		_addEmailLink (show u) e

fun writeAccount (u : string) (p : string) : transaction bool =
		exists <- usernameExists u;
		hashedPass <- hash p;
		if
				exists
		then
				return False
		else
				dml (INSERT INTO userCredentials (UserName, Hash, Salt) VALUES ({[u]}, {[getHash hashedPass]}, {[getSalt hashedPass]}));
				return True

fun newAccount (u : string) (p : string) (e : addr) : transaction bool =
		exists <- writeAccount u p;
		if
				exists
		then
				return False
		else
				_addEmailLink u e;
				return True

fun blessEmailLink (u : string) (t : token) : transaction bool =
		timeNow <- now;
		rows <- queryL (SELECT * FROM userLinks WHERE userLinks.Id = {[t.Id]});
		case rows of
				[] => return False
			| row :: _ =>
				correctToken <- verify t.Secret row.UserLinks.TokenHash row.UserLinks.TokenSalt;
				 if
						  row.UserLinks.UserName = u
							&&
							ge (addSeconds row.UserLinks.WhenRequested (24 * 3600)) timeNow
							&&
							correctToken
				 then
						 dml (UPDATE userLinks SET Approved = TRUE WHERE Id = {[t.Id]});
						 return True
				 else
						 return False

fun _getEmails (username : string) : transaction (list (option addr)) =
		rows <- queryL (SELECT * FROM userLinks WHERE userLinks.Approved = {[True]} AND userLinks.UserName = {[show username]});
		return (List.mp (fn x => fromString x.UserLinks.Email) rows)

fun signIn (username : string) (password : string) : transaction (option user) =
		rows <- queryL (SELECT * FROM userCredentials WHERE userCredentials.UserName = {[username]});
		releventEmails <- _getEmails username;
		case rows of
				[] => return None
			| row :: _ => 
				correctPassword <- verify password row.UserCredentials.Hash row.UserCredentials.Salt;
				if correctPassword then
						return (Some username)(* (Some {UserName = username, Emails = releventEmails}) *)
				else
						return None

fun newToken (u : user) : transaction token =
		tokenOut <- Crypto.token 100;
		timeNow <- now;
		newId <- nextval ids;
		dml (INSERT INTO userTokens (TokenHash, TokenSalt, WhenCreated, UserName, Id) VALUES ({[Crypto.getHash (tokenOut.Hash)]}, {[Crypto.getSalt (tokenOut.Hash)]}, {[timeNow]}, {[u]}, {[newId]}));
		return {Id = newId, Secret = tokenOut.Token}

fun loadUser (t : token) : transaction (option user) =
		rows <- queryL (SELECT * FROM userTokens WHERE userTokens.Id = {[t.Id]});
		case rows of
				[] => return None
			| row :: _ => 
				timeNow <- now;
				verified <- verify t.Secret row.UserTokens.TokenHash row.UserTokens.TokenSalt;
				if ((addSeconds row.UserTokens.WhenCreated (2 * 3600)) > timeNow && verified) then
						return (Some row.UserTokens.UserName)
				else
						return None
