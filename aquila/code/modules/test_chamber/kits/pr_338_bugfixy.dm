// aq33/AquilaStation#338 - bugfixy: pompa paliwa z myśliwców, android kapelana, custom vendory

/datum/test_chamber_kit/pr_338_fuel
	name = "PR 338: pompa paliwa wysysa z myśliwca"
	pr = "aq33/AquilaStation#338"
	description = "Myśliwiec ma 500-1000 jednostek paliwa. Kliknij pompę Tyrosene, w oknie włącz \"Fuel inlet\" (zawór wlotowy), weź wąż i podłącz do myśliwca przy wyłączonym silniku - \
	paliwo ma przepływać z myśliwca do pompy, na końcu komunikat o zakończeniu. Przy zamkniętym zaworze wąż tankuje myśliwiec jak dawniej. \
	Uderz pompę z otwartym zaworem zlewką z wodą - zawartość ma trafić do pompy, a nie wrócić do zlewki."
	items = list(
		/obj/structure/overmap/small_craft/combat/light = 1,
		/obj/structure/reagent_dispensers/fueltank/cryogenic_fuel = 1,
		/obj/item/reagent_containers/glass/beaker/large = 1,
	)

/datum/test_chamber_kit/pr_338_fuel/setup(list/spawned, list/turfs, turf/center, mob/user)
	for(var/obj/item/reagent_containers/glass/beaker/large/beaker in spawned)
		beaker.reagents.add_reagent(/datum/reagent/water, 50)

/datum/test_chamber_kit/pr_338_android
	name = "PR 338: android z robotycznymi kończynami"
	pr = "aq33/AquilaStation#338"
	description = "Człowiek testowy zostaje zamieniony w androida (to samo, co robi rytuał kapelana). Zbadaj go analizatorem albo obejrzyj: wszystkie kończyny mają być robotyczne \
	(metaliczny wygląd, naprawa spawarką i kablem, nie apteczką), a nie organiczne. Drugi człowiek zostaje zwykły do porównania."
	items = list(
		/mob/living/carbon/human = 2,
		/obj/item/healthanalyzer = 1,
		/obj/item/weldingtool/largetank = 1,
		/obj/item/stack/cable_coil = 1,
	)

/datum/test_chamber_kit/pr_338_android/setup(list/spawned, list/turfs, turf/center, mob/user)
	for(var/mob/living/carbon/human/H in spawned)
		H.set_species(/datum/species/android)
		H.real_name = "Android testowy"
		H.name = H.real_name
		H.adjustBruteLoss(20)
		break

/datum/test_chamber_kit/pr_338_vendor
	name = "PR 338: custom vendor"
	pr = "aq33/AquilaStation#338"
	description = "Zbuduj automat: przykręć ramę kluczem, dodaj 5 kabli, włóż płytkę custom vendor i wkład, śrubokręt. Uderz go swoją kartą ID z kontem bankowym (połączy się z nią). \
	Włóż sok pomarańczowy i prześcieradło CentCom (\\improper w nazwie - wcześniej nie dało się go kupić; cenę nadaj metkownicą). \
	Okno ma się odświeżyć od razu po włożeniu i pokazać cenę, ikonę i liczbę sztuk (nie \"undefined\"). Kup oba przedmioty kartą z kontem (choćby swoją). UWAGA: zniszczony custom vendor lekko wybucha."
	items = list(
		/obj/structure/frame/machine = 1,
		/obj/item/circuitboard/machine/vendor = 1,
		/obj/item/vending_refill/custom = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/wrench = 1,
		/obj/item/screwdriver = 1,
		/obj/item/price_tagger = 1,
		/obj/item/reagent_containers/food/drinks/bottle/orangejuice = 2,
		/obj/item/bedsheet/centcom = 1,
	)
