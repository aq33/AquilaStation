/datum/test_chamber_kit/pr_552
	name = "PR 552: hej!, Gauss partiami, przeszukiwanie"
	pr = "aq33/AquilaStation#552"
	description = "Emotka: wpisz *hey (albo „hej!” w Panelu emotek), mim i maska bez głosu nie powinny grać dźwięku. \
		Kuźnia: na stole montażowym leży gotowy korpus Gaussa i zapalnik, złóż je (klik stołu pustą ręką) i policz pociski (6). \
		Przeszukiwanie: przeciągnij manekina na siebie, Alt+klik na fartuch i plecak otwiera ich zawartość bez zdejmowania, \
		dymek slotu pokazuje „Alt+klik: przeszukaj”. Sprawdź w combat mode i w starych intencjach. \
		Samouczek i pule weighted sprawdzisz poza komorą: lekcja Przetrwanie z lobby (krok z bandażem), pule w logu admina przy ofercie midround."
	items = list(
		/obj/machinery/munitions_forge/assembly_bench = 1,
		/mob/living/carbon/human = 1,
	)

/datum/test_chamber_kit/pr_552/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/obj/machinery/munitions_forge/assembly_bench/bench = locate() in spawned
	var/turf/bench_turf = bench ? get_turf(bench) : center
	var/obj/item/munition_part/body/shell/gauss/body = new(bench_turf)
	body.set_material(get_munition_material(/datum/material/iron))
	body.hammer_time = 0
	body.update_part_name()
	var/obj/item/munition_part/fuze/impact/fuze = new(bench_turf)
	fuze.hammer_time = 0
	// manekin z kieszeniami do przeszukania
	var/mob/living/carbon/human/dummy = locate() in spawned
	if(!dummy)
		return
	dummy.name = "manekin do przeszukania"
	dummy.real_name = dummy.name
	dummy.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(dummy), ITEM_SLOT_ICLOTHING)
	var/obj/item/clothing/suit/apron/apron = new(dummy)
	dummy.equip_to_slot_or_del(apron, ITEM_SLOT_OCLOTHING)
	new /obj/item/pen(apron)
	var/obj/item/storage/backpack/backpack = new(dummy)
	dummy.equip_to_slot_or_del(backpack, ITEM_SLOT_BACK)
	new /obj/item/toy/crayon/red(backpack)
	new /obj/item/flashlight(backpack)
