// AQUILA - Alt+klik na przełączanym stroju (fartuchy, kitle, kurtki) rozpina i zapina guziki.
// W core AltClick tylko wysyłał sygnał, więc działał wyłącznie werb „Toggle Suit Style”, choć opis każe użyć Alt+kliku.

/obj/item/clothing/suit/toggle/AltClick(mob/user)
	..()
	if(!user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	usr = user // suit_toggle to werb i sprawdza usr
	suit_toggle()
