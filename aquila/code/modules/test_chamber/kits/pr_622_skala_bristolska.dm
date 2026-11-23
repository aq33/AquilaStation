// aq33/AquilaStation#622 - skala bristolska: typ stolca od diety, ruchu, nawodnienia i nastroju

/datum/test_chamber_kit/pr_622
	name = "PR 622: skala bristolska"
	pr = "aq33/AquilaStation#622"
	description = "Działa tylko z SHITTING_ENABLED w configu. Zestaw ustawia ci pilną potrzebę (jeśli jesteś człowiekiem), daje sedes, sałatkę, steki, kawę i olej rycynowy. \
	1) Zjedz dwa steki, stój w miejscu, nawodnienie zostaw jak jest (VV: bowel_since = world.time - 6000, żeby nie czekać 5 minut na ocenę ruchu) → najedź na alert potrzeby: dopisek „zanosi się na zaparcie”. Kliknij alert → wypróżnienie trwa 5–8 s, w czacie typ 1 albo 2 z przyczynami (za mało warzyw, za mało ruchu), moodlet „Wypróżnienie było męczarnią”, examine kupy pokazuje typ. \
	2) Ustaw defecation = 150, zjedz sałatkę, pobiegaj chwilę po komorze (VV hydration = 600) → typ 3–4, moodlet „Wypróżnienie jak w zegarku”, czas 3 s. \
	3) Ustaw defecation = 150, wypij olej rycynowy → typ 7, przyczyna „olej rycynowy”, moodlet „Biegunka mnie wykańcza”, popuszczenie już przy defecation 180 zamiast 200. \
	4) Kawa: wypij 2–3 kubki, defecation = 150 → typ 5–6. \
	5) Sam mocz (pisuar albo *piss) nie daje komunikatu o typie. Z cenzurą funkcji fizjologicznych w preferencjach nie ma komunikatu w czacie ani typu przy examine."
	items = list(
		/obj/structure/toilet = 1,
		/obj/item/food/salad/aesirsalad = 1,
		/obj/item/food/meat/steak = 2,
		/obj/item/reagent_containers/food/drinks/coffee = 3,
		/obj/item/reagent_containers/glass/bottle = 1,
	)

/datum/test_chamber_kit/pr_622/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	if(!CONFIG_GET(flag/shitting_enabled) && user)
		to_chat(user, span_warning("SHITTING_ENABLED jest wyłączone w configu: wypróżnianie nie działa."))
	var/mob/living/carbon/human/H = user
	if(istype(H))
		H.set_defecation(DEFECATION_SHIT_YOURSELF)
	for(var/obj/item/reagent_containers/glass/bottle/bottle in spawned)
		bottle.name = "olej rycynowy"
		bottle.reagents.add_reagent(/datum/reagent/consumable/castor_oil, 15)
