// AQUILA - modele NIF i ich autochirurgi. Port z Monkestation (nif_implants.dm).

/// Wzorcowy, porządny model NIF
/obj/item/organ/cyberimp/brain/nif/standard
	name = "NIF typu Standard"
	desc = "„Standard” to klasa wysokiej jakości Nanitowych Platform Implantów: niezawodne wzorce, gładkie zespolenie z nosicielem i dość pamięci oraz mocy obliczeniowej, by uruchomić szeroki wybór programów."
	manufacturer_notes = "Choć niezliczeni producenci, otwarci i zamknięci, robią własne wersje NIF-ów, w całej galaktyce jest mniej niż tysiąc modeli klasy Standard. To owoc niemal pięciu lat ulepszania starszych platform. Są bardzo pożądane, bo niezwykle trudno zbudować je domowym sposobem."

/// Tani model: mniej energii, mniej miejsca, krótsza i bardziej szorstka kalibracja
/obj/item/organ/cyberimp/brain/nif/roleplay_model
	name = "NIF typu Econo-Deck"
	desc = "„Econo-Deck” to klasa tańszych Nanitowych Platform Implantów. Zwykle są to „ekonomiczne” podróbki lepszych platform ze słabszymi ogniwami, przestarzałymi i ryzykownymi wzorcami budowy oraz znacznie bardziej szorstką kalibracją z nosicielem."
	manufacturer_notes = "Większość forów hobbystów i zapalonych użytkowników, korporacyjni neurolodzy i twórcy softów, jak Altspace Coven, odradza ich zakup. Mimo przystępnej ceny w środowisku użytkowników platform panuje przekonanie, że na urządzeniu wpiętym prosto w układ nerwowy nie wolno oszczędzać. Dlatego Econo-Decki trafiają głównie do zdesperowanych, przestępców albo wychodzą z warsztatów jako „samoróbki”."
	max_power_level = 500
	max_nifsofts = 3
	calibration_time = 1 MINUTES
	max_durability = 50
	death_durability_loss = 10

/// Model próbny. Bez przenoszenia między rundami działa jak Econo-Deck
/obj/item/organ/cyberimp/brain/nif/roleplay_model/cheap
	name = "NIF typu Trial-Lite"
	desc = "„Trial-Lite” to klasa tymczasowych Nanitowych Platform Implantów. Zwykle rozdaje się je na imprezach promocyjnych, do jednorazowych NIFSoftów albo w korporacyjnych salonach, żeby przyszli użytkownicy mogli spróbować, jak to jest."
	manufacturer_notes = "Platformy Trial-Lite w zasadzie nie „wiążą się” z nosicielem. Tworzą bardzo luźne połączenie, a po kilku godzinach rozpadają się w rozproszone, martwe nanomaszyny, zwykle wydychane. Przez gorszą budowę i oprogramowanie nikomu nie udało się dotąd przedłużyć ich życia."

/obj/item/autosurgeon/nif/econo
	name = "autochirurg z NIF typu Econo-Deck"
	desc = "Jednorazowy autochirurg z tanią Nanitową Platformą Implantów typu Econo-Deck. Użyj go na sobie, żeby wszczepić NIF."
	starting_organ = list(/obj/item/organ/cyberimp/brain/nif/roleplay_model)

/obj/item/autosurgeon/nif/disposable
	name = "autochirurg z NIF typu Trial-Lite"
	desc = "Jednorazowy autochirurg z próbną Nanitową Platformą Implantów typu Trial-Lite. Użyj go na sobie, żeby wszczepić NIF."
	starting_organ = list(/obj/item/organ/cyberimp/brain/nif/roleplay_model/cheap)
