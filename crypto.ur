open Process

type hashed = {Hash : string, Salt : string}

val getHash = fn x => x.Hash

val getSalt = fn x => x.Salt

fun random (length : int) : transaction string =
		output <- Process.exec ("head -c " ^ show length ^ " /dev/urandom | base64") (textBlob "") (1000 * length);
		if
				status output = 0
		then
				return (Process.blobText (Process.blob output))
		else
				return (error <xml>ERROR: Function 'random' generated non-zero exit code.</xml>)

fun constructHash (password : string) (salt : string) : transaction hashed =
		hasherResult <- Process.exec ("sha256sum | awk '{print $2}'") (textBlob (password ^ salt)) 100;
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
