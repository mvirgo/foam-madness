window.onload = function() {
	// Set to color style
	document.body.style.backgroundColor = "#17408B";
	document.body.style.color = "#fff";
	document.alinkColor = "#e37221";
	document.linkColor = "#e37221";
    document.vlinkColor = "#e37221";
	// Get URL with search parameters
	// Thanks https://stackoverflow.com/questions/901115/how-can-i-get-query-string-values-in-javascript
	let params = (new URL(window.location)).searchParams;
	let game = params.get("games");
	if (game) {
		// Fetch the JSON file and display game info
	    fetch("https://raw.githubusercontent.com/mvirgo/foam-madness/master/docs/simulation2020-export.json")
	        .then(response => response.json())
	        .then(json => getGame(json, game));
	} else {
		setGameElement("No game selected.");
		addNextGame("0")
	}
}

function setGameElement(text) {
	document.getElementById("game").innerHTML = text;
}

function getGame(json, game) {
	try {
		setGameElement("Game "+game);
		let round = getRoundString(json["games"][game]["Round"])
		if (round === "") {
			document.getElementById("roundAndRegion").innerHTML = json["games"][game]["Region"]
		} else {
			document.getElementById("roundAndRegion").innerHTML = round + ": " + json["games"][game]["Region"] + " Region"
		}
		setGameStats(json, game)
		// Note next game, if applicable
		addNextGame(json["games"][game]["NextGame"])
	} catch {
		setGameElement("Invalid game selected.");
		addNextGame("0")
	}
}

function getRoundString(round) {
	switch (round) {
        case "0":
            out = "First Four"
            break;
        case "1":
            out = "First Round"
            break;
        case "2":
            out = "Second Round"
            break;
        case "3":
            out = "Sweet Sixteen"
            break;
        case "4":
            out = "Elite Eight"
            break;
        default:
            out = ""
    }
    
    return out;
}

function setGameStats(json, game) {
	var table = document.createElement("TABLE");
	table.setAttribute("style", "border: 3px double;")
	document.body.appendChild(table)
	let fields = ["Name", "Score", "Seed", "Hand", "Ones", "Twos", "Threes", "Fours"]
	for (i = 0; i < fields.length; i++) {
		setTableRow(json, game, table, fields[i])
	}
	// Add overtime, if applicable
	if (json["games"][game]["Team1OTTaken"] != "0") {
		setTableRow(json, game, table, "OTMade")
		setTableRow(json, game, table, "OTTaken")
	}
}

function setTableRow(json, game, table, field) {
	// Thanks https://www.w3schools.com/jsref/met_table_insertrow.asp
	// Add a new row
	var row = table.insertRow(-1);
	// Add three cells to it
	var cell1 = row.insertCell(0);
	var cell2 = row.insertCell(1);
	var cell3 = row.insertCell(2);
	cell2.setAttribute("style", "text-align: center; border: 1px solid;")
	cell3.setAttribute("style", "text-align: center; border: 1px solid;")
	// Add related stats
	if (field === "Name") {
		cell2.innerHTML = json["games"][game]["Team1"];
		cell2.setAttribute("style", "font-weight: bold;");
		cell3.innerHTML = json["games"][game]["Team2"];
		cell3.setAttribute("style", "font-weight: bold;");
	} else {
		cell1.innerHTML = field;
		cell2.innerHTML = json["games"][game]["Team1"+field];
	    cell3.innerHTML = json["games"][game]["Team2"+field];
	}
}

function addNextGame(nextGame) {
	if (nextGame != "-1") {
		linebreak = document.createElement("br");
		document.body.appendChild(linebreak)
		var section = document.createElement("SECTION");
		document.body.appendChild(section)
		let nextURL = window.location.pathname + "?games=" + nextGame
		let nextText = "Next game is: " + nextGame
		section.innerHTML = `<a href=${nextURL}>${nextText}</a>`
	}
}