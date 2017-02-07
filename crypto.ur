open Process

type hashed = {Hash : string, Salt : string}

val getHash = fn x => x.Hash

val getSalt = fn x => x.Salt

fun random (length : int) : transaction string =
		output <- Process.exec ("< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-" + show length + "};echo;") (textBlob "") (length + 5);
		if
				status output = 0
		then
				return (Process.blobText (Process.blob output))
		else
				return (error <xml>ERROR: Function 'random' generated non-zero exit code.</xml>)

fun constructHash (password : string) (salt : string) : transaction hashed =
		hasherResult <- Process.exec ("hashalot -x sha256") (textBlob (password + salt)) 100;
		if
				status hasherResult = 0
		then
				return {Hash = (blobText (blob hasherResult)), Salt = salt}
		else
				return (error <xml>ERROR: Function 'constructHash' generated non-zero exit code.</xml>)

fun hashWithSalt (password : string) (saltSize : int) : transaction hashed =
		salt <- random saltSize;
		constructHash password salt

fun hash (password : string) : transaction hashed = hashWithSalt password 70

fun verify (password : string) (correctHash : string) (salt : string): transaction bool =
		guess <- constructHash password salt;
		return (correctHash = (getHash guess))

fun token (length : int) =
		out <- random length;
		hashOut <- hash out;
		return {Token = out, Hash = hashOut}
