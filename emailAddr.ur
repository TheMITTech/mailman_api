open String

type addr = string

val _charList : string = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789._"

val _sanePiece (s : string) : bool =
		(String.length s > 0) &&
		(String.all 
				 (fn c => case (String.index _charList c) of
											None => False
										| Some _ => True
				 )
				 s
		)

val addr_show = mkShow (fn x => x)
val fromString (s : string) : option string =
		case (split s #"@") of
				None => None
			| Some (a, b) =>
				if
						(_sanePiece a) && (_sanePiece b)
				then
						Some s
				else
						None
		
