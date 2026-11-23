// AQ - wyróżnienia mowy (+pogrubienie+, _podkreślenie_, |kursywa|) tylko w tekście, nie w znacznikach HTML.
// compose_message() woła say_emphasis() na całej wiadomości razem ze spanami, więc podkreślnik w nazwie
// klasy (np. SPAN_COMMAND = "command_headset") parował się z _podkreśleniem_ gracza i psuł znacznik.
// Tu dzielimy wejście na znaczniki i tekst, a wyróżnienia nakładamy tylko na kawałki tekstu.

/atom/say_emphasis(input)
	if(!istext(input) || !findtext(input, "<"))
		return ..()
	var/static/regex/html_tag = regex("<\[^>\]*>", "g")
	var/output = ""
	var/position = 1
	while(html_tag.Find(input, position))
		output += ..(copytext(input, position, html_tag.index))
		output += html_tag.match
		position = html_tag.next
	output += ..(copytext(input, position))
	return output
