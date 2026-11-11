// aq33/AquilaStation#617 - kałuże zmywają plamy, kształt pojedynczej kałuży, alarmy bez spamu, radial celowania, Ctrl+Shift+klik, mysz z bronią

/datum/test_chamber_kit/pr_617
	name = "PR 617: kałuże, alarmy, celowanie"
	pr = "aq33/AquilaStation#617"
	description = "Wiadra mają po 70 j. wody. Zestaw stawia oczyszczacz powietrza, alarm przeciwpożarowy i manekina. \
	1) Kształt kałuży: potnij manekina nożem, aż krwawi, i zostaw go na środku podłogi → kałuża krwi ma nieregularny kształt, nie kwadrat. \
	2) Zmywanie: przeciągnij krwawiącego manekina kilka kafli (ślady krwi), wylej obok wiadro wody w combat mode, żeby woda wpłynęła na ślady → ślady i plamy pod wodą znikają, a examine kałuży pokazuje krew. \
	3) Alarm: włącz alarm ręką → woda z oczyszczacza. Od razu kliknij alarm drugi raz → komunikat, że alarm jeszcze się przełącza. Po 3 s skasuj go i włącz znowu → tym razem bez wody (odstęp 3 minuty na pomieszczenie). Zemaguj alarm i pociągnij → zalanie mimo odstępu zwykłego zraszania (zalanie ma własny odstęp 3 minuty). EMP zalewa jak dotąd, także w czasie odstępów. \
	4) Radial celowania: weź pistolet i wskaż nim manekina (Shift+środkowy przycisk) → nad opcjami polskie podpisy (Ręce do góry, Rzuć broń, Strzelaj, Anuluj). Przejmij manekina (admin: Possess) → u niego Poddaj się i Ignoruj. \
	5) Ctrl+Shift+klik z pistoletem w ręku na podłogę → nic, bez „Oferujesz”. Na manekina obok → oferta tylko dla niego (drugi człowiek obok nie dostaje alertu). Na stół → stół się przewraca jak dotąd. \
	6) Mysz: załóż celownik laserowy na pistolet i szybko machaj myszą, w combat mode i bez niego → brak przycięć, kursor rozrzutu i wiązka nadążają za myszą. Sprawdź też na starych intencjach."
	items = list(
		/obj/machinery/atmospherics/components/unary/vent_scrubber = 1,
		/obj/machinery/firealarm = 1,
		/obj/item/card/emag = 1,
		/obj/item/grenade/empgrenade = 1,
		/obj/item/reagent_containers/glass/bucket = 2,
		/obj/item/kitchen/knife = 1,
		/obj/item/gun/ballistic/automatic/pistol = 1,
		/obj/item/attachment/laser_sight = 1,
		/obj/structure/table = 1,
		/mob/living/carbon/human = 1,
	)

/datum/test_chamber_kit/pr_617/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	for(var/obj/item/reagent_containers/glass/bucket/bucket in spawned)
		bucket.reagents.add_reagent(/datum/reagent/water, 70)
