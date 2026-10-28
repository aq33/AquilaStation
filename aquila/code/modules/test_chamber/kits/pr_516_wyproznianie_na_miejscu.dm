// aq33/AquilaStation#516 - wypróżnienie na miejscu po kliknięciu w alert, nagrody w aquilosach

/datum/test_chamber_kit/pr_516
	name = "PR 516: wypróżnienie na miejscu"
	pr = "aq33/AquilaStation#516"
	description = "Działa tylko z SHITTING_ENABLED w configu. Zestaw ustawia ci pilną potrzebę, więc po chwili w prawym górnym rogu pojawia się alert z sedesem. \
	Kliknij go w ubraniu: po 3 s popuszczasz w spodnie i od tej pory śmierdzisz (badanie: okropny smród). \
	Umyj się, zdejmij kombinezon, ustaw sobie VV defecation = 150 i kliknij alert nago: kupa na podłodze, bez smrodu. \
	Na kafelku z sedesem kliknięcie w alert działa jak skorzystanie z ubikacji."
	items = list(
		/obj/item/soap = 1,
	)

/datum/test_chamber_kit/pr_516/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		return
	H.set_defecation(DEFECATION_SHIT_YOURSELF)
