val textMime = blessMime "text/plain"

fun ok [t ::: Type] (message : string) : transaction t = returnBlob (textBlob ("OK\n" ^ message)) textMime

fun fail [t ::: Type] (message : string) : transaction t = returnBlob (textBlob ("FAIL\n" ^ message)) textMime

fun addAccount (r : {Email : string, Username : string, Password : string}) : transaction page =
		case EmailAddr.fromString r.Email of
				None => fail ("INVALID EMAIL: " ^ r.Email)
			| Some email => success <- MailAuth.newAccount r.Username r.Password email;
				if success then
						ok ""
				else
						fail ""

fun apiLogin r : transaction page =
		maybeUser <- MailAuth.signIn r.Username r.Password;
		case maybeUser of
			None => fail ""
		| Some u => tokenOut <- MailAuth.newToken u;
			ok (show tokenOut)

fun apiTestToken r : transaction page =
		case (MailAuth.readToken r.Token) of
				None => fail "Bad token!"
			| Some token => 
				maybeUser <- MailAuth.loadUser token;
				case maybeUser of
						None => fail ""
					| Some _ => ok "" 
