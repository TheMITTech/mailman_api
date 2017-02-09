modName = "Api"

def getName(function):
    return function.split(":")[0].split()[1].strip()

def getFields(function):
    recordType = function.split("{")[1].split("}")[0]
    argInfos = recordType.split(",")
    return map(lambda x: x.split(":")[0].strip(), argInfos)

def oneForm(function):
    oneBox = lambda field: "  <p>" + field + "<textbox{#" + field + "}/></p>"
    return "<h1>" + getName(function) + "</h1>\n<form>\n" + \
        "\n".join(oneBox(x) for x in getFields(function)) + \
        "  <submit action={" + modName + "." + getName(function) + "}/>" + \
        "\n</form> <br/>"

def legitLine(line):
    if len(line) == 0:
        return False
    if line[0] == "v":
        return True
    return False

def runScript(fileIn, fileOut):
    preamble = """
fun dummyForm () : transaction page =
return <xml>
<head/>
<body>
"""
    footer = """
</body>
</xml>    
"""
    fileOut.write(preamble)
    forms = [oneForm(x) for x in fileIn if legitLine(x)]
    fileOut.write("\n".join(forms))
    fileOut.write(footer)

with open("api.urs", "r") as fileIn:
    with open("dummy.ur", "w") as fileOut:
        runScript(fileIn, fileOut)
