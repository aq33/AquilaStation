// Czat głosowy dla gracza z angielską wersją gry: strona po angielsku i rozpoznawanie mowy po angielsku
// (jego postać mówi po angielsku, resztę załatwia tłumaczenie obcokrajowca).
/datum/controller/subsystem/voice_chat/player_language(client/player)
	if(player?.wants_english())
		return "en"
	return ..()
