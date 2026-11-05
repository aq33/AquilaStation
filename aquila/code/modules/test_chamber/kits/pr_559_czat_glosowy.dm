/datum/test_chamber_kit/pr_559
	name = "PR 559: czat głosowy"
	pr = "aq33/AquilaStation#559"
	description = "Wymaga VOICE_CHAT_ENABLED w config/voice_chat.txt i uruchomionego tools/voice_chat/start.bat. \
		Zakładka OOC → Czat głosowy: otwiera się strona w przeglądarce, zezwól na mikrofon i wróć do gry. \
		Trzymaj N i powiedz zdanie: nad postacią ma być dymek, po puszczeniu postać mówi rozpoznany tekst. \
		Z założonymi słuchawkami trzymaj U: tekst ma pójść przez radio. Krótkie dotknięcie N nie może nic powiedzieć. \
		Zamknij kartę: w czacie ma pojawić się komunikat o rozłączeniu, a N ma otworzyć stronę ponownie."
	items = list(
		/obj/item/radio/headset = 1,
	)
