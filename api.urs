val addAccount : {Email : string, Username : string, Password : string} -> transaction page
val apiLogin : {Username : string, Password : string} -> transaction page
val apiTestToken : {Token : string} -> transaction page
