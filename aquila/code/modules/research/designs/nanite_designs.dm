/datum/design/nanites/nutrition_synthesis
	name = "Synteza pożywienia"
	desc = "Nanity syntetyzują z siebie składniki odżywcze we krwi nosiciela i stopniowo się rozpadają, by go wykarmić."
	id = "nutrition_nanites"
	program_type = /datum/nanite_program/nutrition_synthesis
	category = list("Utility Nanites")

/datum/design/nanites/nanolink
	name = "Nanołącze"
	desc = "Nanity zyskują zdolność przesyłania wiadomości między skupiskami nanitów połączonymi z nanołączem, pod klawiszem \".z\"."
	id = "nanolink_nanites"
	program_type = /datum/nanite_program/nanolink
	category = list("Utility Nanites")

/datum/design/nanites/cloud_change
	name = "Zmiana chmury"
	desc = "Po aktywacji zmienia chmurę nanitów na wskazaną."
	id = "cloud_change_nanites"
	program_type = /datum/nanite_program/cloud_change
	category = list("Utility Nanites")

/datum/design/nanites/nanojutsu
	name = "Program nauki Nanojutsu"
	desc = "Nanity pobudzają mózg nosiciela, dając mu umiejętność posługiwania się sztuką walki Nanojutsu."
	id = "nanojutsu_nanites"
	program_type = /datum/nanite_program/nanojutsu
	category = list("Augmentation Nanites")

/datum/design/nanites/camo
	name = "Adaptacyjny kamuflaż"
	desc = "Nanity pokrywają nosiciela cienką, odblaskową warstwą, przez co staje się prawie niewidzialny."
	id = "camo_nanites"
	program_type = /datum/nanite_program/camo
	category = list("Augmentation Nanites")

/datum/design/nanites/kunai
	name = "Forma kunai"
	desc = "Po aktywacji nanity zbierają się w wolnej dłoni nosiciela i tworzą nóż kunai, który rozpada się kilka sekund po rzuceniu."
	id = "kunai_nanites"
	program_type = /datum/nanite_program/kunai
	category = list("Weaponized Nanites")

/datum/design/nanites/nanophage
	name = "Nanorój"
	desc = "Po aktywacji nanity zbierają się w żołądku nosiciela, tworząc nanofagi - małe, zaprogramowane drony - które zaraz zostają wykaszlane."
	id = "nanoswarm_nanites"
	program_type = /datum/nanite_program/nanophage
	category = list("Weaponized Nanites")

/datum/design/nanites/movement
	name = "Wymuszony ruch"
	desc = "Po aktywacji nanity zmuszają nosiciela do marszu w zaprogramowanym kierunku."
	id = "movement_nanites"
	program_type = /datum/nanite_program/movement
	category = list("Suppression Nanites")

/datum/design/nanites/sensor_impact
	name = "Czujnik uderzeń"
	desc = "Wysyła sygnał, gdy nanity wykryją wahania zdrowia nosiciela."
	id = "sensor_impact_nanites"
	program_type = /datum/nanite_program/sensor/impact
	category = list("Sensor Nanites")

/datum/design/nanites/kickstart
	name = "Protokół szybkiego startu"
	desc = "Protokół replikacji: nanity skupiają się na wczesnym wzroście, mocno przyspieszając replikację przez kilka minut po wszczepieniu."
	id = "kickstart_nanites"
	program_type = /datum/nanite_program/protocol/kickstart
	category = list("Protocols_Nanites")

/datum/design/nanites/factory
	name = "Protokół fabryczny"
	desc = "Protokół replikacji: nanity budują w nosicielu matrycę fabryczną, która z czasem stopniowo przyspiesza replikację. Fabryka niszczeje, gdy protokół nie jest aktywny."
	id = "factory_nanites"
	program_type = /datum/nanite_program/protocol/factory
	category = list("Protocols_Nanites")

/datum/design/nanites/tinker
	name = "Protokół majsterkowicza"
	desc = "Protokół replikacji: nanity uczą się wykorzystywać metale we krwi nosiciela, by przyspieszyć replikację."
	id = "tinker_nanites"
	program_type = /datum/nanite_program/protocol/tinker
	category = list("Protocols_Nanites")

/datum/design/nanites/offline
	name = "Protokół produkcji offline"
	desc = "Protokół replikacji: gdy nosiciel śpi albo jest nieprzytomny, nanity wykorzystują mniejsze zakłócenia, by szybciej się replikować."
	id = "offline_nanites"
	program_type = /datum/nanite_program/protocol/offline
	category = list("Protocols_Nanites")

/datum/design/nanites/free_range
	name = "Protokół wolnego wybiegu"
	desc = "Protokół replikacji: nanity porzucają domyślne protokoły przechowywania na rzecz tańszego i bardziej organicznego podejścia. Zmniejsza maksymalną objętość, ale przyspiesza replikację."
	id = "free_range_nanites"
	program_type = /datum/nanite_program/protocol/free_range
	category = list("Protocols_Nanites")

/datum/design/nanites/zip
	name = "Protokół kompresji"
	desc = "Protokół replikacji: nieużywane nanity są rozkładane i kompresowane, co mocno zwiększa ich maksymalną objętość w nosicielu. Proces ten nieco spowalnia jednak replikację."
	id = "zip_nanites"
	program_type = /datum/nanite_program/protocol/zip
	category = list("Protocols_Nanites")
