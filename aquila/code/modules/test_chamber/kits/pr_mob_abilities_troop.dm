/datum/test_chamber_kit/pr_mob_troop
	name = "Basic moby: żołnierze (wrodzy)"
	pr = "aq33/AquilaStation#XXX"
	description = "Zestaw: agent Syndykatu z nożem, z pistoletem, z pistoletem maszynowym i ze strzelbą, szturmowiec z mieczem energetycznym, ochroniarz Nanotrasen (wręcz i z pistoletem), Rosjanin z rewolwerem i rosyjski oficer, pirat zabijaka i pirat strzelec, wypruwacz, granat z wypruwaczami i karta ID z kontem (100 kr). Wszystkie są wrogie, nie zrzucaj ich z pokojowymi. Sprawdzaj w obu trybach sterowania (combat mode i stare intencje). \
	1) Podejdź → strzelcy strzelają z dystansu (pistolet co sekundę, pistolet maszynowy i strzelba seriami co 3 s), nie strzelają przez swoich; agenci z nożem i mieczem atakują wręcz, szturmowiec z mieczem świeci na czerwono i czasem blokuje pociski tarczą. \
	2) Ochroniarz Nanotrasen i rosyjski oficer po zauważeniu cię krzyczą „Trwa 411, potrzebne wsparcie!” / „V BOJ!!”, a pozostali z tej samej frakcji schodzą się do nich. \
	3) Załóż kartę ID i daj się uderzyć piratowi zabijace → z konta znika 50 kr (karta mówi o przelewie), po śmierci pirata zostaje holoczip z łupem. \
	4) Odbezpiecz granat → wylatują wypruwacze i tną; giną z komunikatem. \
	5) Po śmierci: agent z pistoletem i nożem znika w gibach, ochroniarz zostawia ciało (z pistoletem także broń), Rosjanin ciało i rewolwer, pirat ciało i broń. Bez runtime'ów. \
	Poza komorą: wnętrza abordażu okrętów Syndykatu (fregata desantowa, lotniskowiec, niszczyciel, Mako, Mako z hangarem, fregata atomowa, mały posterunek) mają teraz tylko KNPC, mniej niż dawnych mobów; burza portali, pożyczka promu (infiltratorzy, Rosjanie) i automat Oriona po emagu dają basic moby."
	items = list(
		/mob/living/basic/trooper/syndicate/melee = 1,
		/mob/living/basic/trooper/syndicate/ranged = 1,
		/mob/living/basic/trooper/syndicate/ranged/smg = 1,
		/mob/living/basic/trooper/syndicate/ranged/shotgun = 1,
		/mob/living/basic/trooper/syndicate/melee/sword/space/stormtrooper = 1,
		/mob/living/basic/trooper/nanotrasen = 1,
		/mob/living/basic/trooper/nanotrasen/ranged = 1,
		/mob/living/basic/trooper/russian/ranged = 1,
		/mob/living/basic/trooper/russian/ranged/officer = 1,
		/mob/living/basic/trooper/pirate/melee = 1,
		/mob/living/basic/trooper/pirate/ranged = 1,
		/mob/living/basic/viscerator = 1,
		/obj/item/grenade/spawnergrenade/manhacks = 1,
		/obj/item/card/id = 1,
	)

/datum/test_chamber_kit/pr_mob_troop/setup(list/spawned, list/turfs, turf/center, mob/user)
	for(var/obj/item/card/id/card in spawned)
		card.registered_name = "Tester"
		var/datum/bank_account/account = new /datum/bank_account("Tester", SSjob.GetJobType(/datum/job/assistant))
		account.account_balance = 100
		card.registered_account = account
		account.bank_cards += card

/datum/test_chamber_kit/pr_mob_troop_peaceful
	name = "Basic moby: żołnierze (pokojowi)"
	pr = "aq33/AquilaStation#XXX"
	description = "Zestaw: dwóch pokojowych ochroniarzy Nanotrasen (wręcz i z pistoletem maszynowym). Nie zrzucaj razem z wrogimi żołnierzami. \
	1) Podejdź i stań obok → nie atakują. \
	2) Uderz jednego (combat mode albo intencja harm) → oddaje, krzyczy „Trwa 411, potrzebne wsparcie!”, drugi też rusza na ciebie. \
	3) Gdy uciekniesz poza zasięg wzroku, przestają gonić; po śmierci zostaje ciało i broń, bez runtime'ów."
	items = list(
		/mob/living/basic/trooper/nanotrasen/peaceful = 1,
		/mob/living/basic/trooper/nanotrasen/ranged/smg/peaceful = 1,
	)
