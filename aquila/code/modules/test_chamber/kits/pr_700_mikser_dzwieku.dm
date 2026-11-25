// aq33/AquilaStation#700 - mikser dźwięku: osobne suwaki głośności kategorii w ustawieniach gry

/datum/test_chamber_kit/pr_700
	name = "PR 700: mikser dźwięku"
	pr = "aq33/AquilaStation#700"
	description = "Ustawienia gry → Dźwięk → Mikser: każdy suwak ścisza swoją kategorię, 0 wycisza ją całkiem. \
	1) Broń ręczna: strzel z pistoletu przy suwaku 100, 30 i 0. \
	2) Głosy botów: medibot co chwilę mówi nagrane kwestie; suwak 0 ma je wyciszyć, a tekst w czacie zostaje. \
	3) Emotki i Mowa postaci: *scream, *laugh i zwykłe mówienie przy różnych ustawieniach; mowa ma też zależeć od wyboru „hmm” / Goon / wyłączone. \
	4) Alarmy okrętu: w panelu admina (albo konsolą) włącz stan bojowy i przesuń suwak w trakcie: pętla alarmu ma od razu zmienić głośność. \
	5) Otoczenie: szum statku w tle ma ścichnąć od razu po zmianie suwaka. \
	6) Przełącz język gry na angielski (Interfejs): mikser ma się nazywać Mixer, a suwaki mieć angielskie nazwy."
	items = list(
		/obj/item/gun/ballistic/automatic/pistol = 1,
		/obj/item/ammo_box/magazine/m10mm = 2,
		/mob/living/basic/bot/medbot = 1,
	)
