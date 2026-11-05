// Poprawki tłumaczenia przez graczy: projekt Crowdin, z którego zatwierdzone poprawki
// wracają do kodu jako PR (tools/i18n/crowdin.py, .github/workflows/crowdin_*.yml).
#define AQUILA_CROWDIN_EDITOR_URL "https://crowdin.com/editor/aquila/all/en-pl"

/client/verb/zglos_tlumaczenie()
	set name = "Popraw tłumaczenie"
	set desc = "Otwórz w przeglądarce projekt Crowdin, w którym możesz poprawić polskie teksty gry."
	set category = "OOC"
	if(tgui_alert(src, "To otworzy w przeglądarce Crowdin, gdzie poprawisz źle przetłumaczony tekst. Potrzebne jest darmowe konto (można zalogować się przez GitHub albo Google). Otworzyć?", "Popraw tłumaczenie", list("Tak", "Nie")) != "Tak")
		return
	to_chat(src, span_notice("W Crowdinie wpisz fragment złego tekstu w polu wyszukiwania nad listą napisów, wybierz napis i zaproponuj lepsze tłumaczenie. Nie zmieniaj wstawek w nawiasach \[ \]. Poprawka trafi do gry po zatwierdzeniu przez korektora."))
	DIRECT_OUTPUT(src, link(AQUILA_CROWDIN_EDITOR_URL))

#undef AQUILA_CROWDIN_EDITOR_URL
