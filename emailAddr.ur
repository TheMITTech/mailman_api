type addr = string

val addr_show = mkShow (fn x => x)
val fromString (s : string) : option string = Some s 
