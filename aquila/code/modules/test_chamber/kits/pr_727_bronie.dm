// Bronie z przeglądu 119 kodów (aquila/code/modules/projectiles/guns/bronie_wybrane.dm)

/datum/test_chamber_kit/pr_727
	name = "Bronie z przeglądu kodów"
	pr = "aq33/AquilaStation#727"
	description = "Dziesięć nowych broni z amunicją. Sprawdź wygląd w ręku, na plecach i w ekwipunku, dźwięk strzału i tryby ognia (przełącznik trybów). \
		1) M19C4: seria 3 i ogień ciągły, niebieskie impulsy. 2) Karabin antycząstkowy: w próżni strzela normalnie i urabia skałę, w powietrzu się zacina, przepala strzał, rozładowuje albo wybucha; sam się ładuje. \
		3) Disabler ma wygląd X-41. 4) AKMS, XL8 (luneta), karabin bojowy (tylko pojedynczo), P90 (seria 3), Atreides (ogień ciągły), M44A (strzela tylko z implantem mindshield: zestaw daje implanter), XM29 (prawy przycisk: bęben 5 granatów). \
		5) Źródła: cargo (M44A, XL8), uplink atomowców (karabin bojowy, XM29, P90 także zdrajca), DonkCo (AKMS, P90), sklep złomiarzy (AKMS), zrzut gangu z premią (Atreides), abordażyści Syndykatu i piraci, ERT ochrony (M19C4)."
	items = list(
		/obj/item/gun/energy/laser/m19c4 = 1,
		/obj/item/gun/energy/antyczastkowy = 1,
		/obj/item/gun/energy/disabler = 1,
		/obj/item/gun/ballistic/automatic/akms = 1,
		/obj/item/ammo_box/magazine/akms = 2,
		/obj/item/gun/ballistic/automatic/xl8 = 1,
		/obj/item/ammo_box/magazine/m556 = 2,
		/obj/item/gun/ballistic/automatic/karabin_bojowy/unrestricted = 1,
		/obj/item/ammo_box/magazine/karabin_bojowy = 2,
		/obj/item/gun/ballistic/automatic/p90/unrestricted = 1,
		/obj/item/ammo_box/magazine/p90 = 2,
		/obj/item/gun/ballistic/automatic/atreides = 1,
		/obj/item/ammo_box/magazine/atreides = 2,
		/obj/item/gun/ballistic/automatic/m44a = 1,
		/obj/item/ammo_box/magazine/m44a = 1,
		/obj/item/implanter/mindshield = 1,
		/obj/item/gun/ballistic/automatic/m90/xm29/unrestricted = 1,
		/obj/item/ammo_casing/a40mm = 5,
		/obj/item/pickaxe = 1,
	)
