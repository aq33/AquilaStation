/datum/test_chamber_kit/pr_472
	name = "Wampir z BeeStation"
	pr = "aq33/AquilaStation#472"
	description = "Pierwszy człowiek jest wampirem (przejmij go albo daj wampira sobie przez Antag Panel). Kliknij przycisk Vampire Guide i liczniki HUD-u. \
		Wybierz klan (moc Select Clan), zamknij się w trumnie, żeby ją przejąć i wydać rangę. Feed: po cichu na drugim człowieku, potem w combat mode z agresywnym chwytem. \
		Napij się z worka krwi. Drugi człowiek trzyma srebrny kołek: wbij go w klatkę piersiową wampira w combat mode i sprawdź, że moce nie działają. \
		Archiwum Kindred ma kurator w plecaku (w komorze go nie ma, bo poza stacją wraca na stację). \
		Zbuduj stół do tortur (crafting, kategoria Vampire) i zrób wasala z drugiego człowieka, potem wszczep mu mindshield. Komendami admina Level Add i Break Masq sprawdź HUD."
	items = list(
		/mob/living/carbon/human = 2,
		/obj/structure/closet/crate/coffin/blackcoffin = 1,
		/obj/structure/closet/crate/coffin/securecoffin = 1,
		/obj/item/stake = 2,
		/obj/item/reagent_containers/blood/OPlus = 2,
		/obj/item/reagent_containers/food/drinks/bottle/garlic_extract = 1,
		/obj/item/implanter/mindshield = 1,
		/obj/item/stack/sheet/iron/fifty = 1,
		/obj/item/stack/rods/fifty = 1,
		/obj/item/candle = 2,
		/obj/item/stack/sheet/mineral/wood/fifty = 1,
		/obj/item/kitchen/knife = 1,
	)

/datum/test_chamber_kit/pr_472/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/list/humans = list()
	for(var/mob/living/carbon/human/spawned_human in spawned)
		humans += spawned_human
	if(!length(humans))
		return
	var/mob/living/carbon/human/vampire_mob = humans[1]
	// Srebrny kołek w ręce drugiego człowieka, bo test komory liczy też podtypy /obj/item/stake leżące na podłodze
	if(length(humans) > 1)
		var/mob/living/carbon/human/hunter = humans[2]
		hunter.put_in_hands(new /obj/item/stake/hardened/silver(hunter))
	vampire_mob.mind_initialize()
	vampire_mob.mind.add_antag_datum(/datum/antagonist/vampire)
	vampire_mob.name = "wampir testowy"
	vampire_mob.real_name = vampire_mob.name
