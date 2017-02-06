type hashed = {Hash : string, Salt : string}

val getHash = fn x => x.Hash

val getSalt = fn x => x.Salt

fun hashWithSalt (password : string) (saltSize : int) : transaction hashed =
		salt <- random saltSize;
		constructHash password salt

fun hash (password : string) : transaction option hashed = hashWithSalt password 70

fun verify (password : string) (correctHash : string) (salt : string): transaction bool =
		guess <- constructHash password salt;
		return (correctHash = (getHash guess))

fun random (length : int) : transaction string =
		output <- Process.exec ("< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-" + show length + "};echo;") (string.textBlob "") (length + 5);
		if
				status output = 0
		then
				return blobText (blob output)
		else
				return (error <xml><head/><body>ERROR: Function 'random' generated non-zero exit code.</body></xml>)

fun constructHash (password : string) (salt : string) : transaction hashed =
		hasherResult <- Process.exec ("hashalot -x sha256") (String.textBlob (password + salt)) 100;
		if
				status hasherResult = 0
		then
				return {Hash = (blobText (blob hasherResult)), Salt = salt}
		else
				return (error <xml><head/><body>ERROR: Function 'constructHash' generated non-zero exit code.</body></xml>)

fun token (length : int) : transaction hashed =
		out <- random length;
		hashOut <- hash out;
		return {Token = out, Hash = hashOut}
