/datum/test_chamber_kit/pr_zapachy
	name = "Dym i zapachy (pollution z Monke)"
	pr = "aq33/AquilaStation#PR"
	description = "Na środku areny wisi gęsty dym (szara mgiełka) i zapach kawy. Użyj *sniff, potem postój chwilę bez maski: \
		samo wąchanie co minutę, kaszel w dymie, nastrój za zapachy. Zapal papierosa i świecę zapachową, spryskaj kogoś perfumami \
		(najpierw zdejmij nakrętkę, Alt-klik) i psiknij odświeżaczem. Oczyszczacz przykręć kluczem i włącz ręką, \
		sprawdź, czy mgiełka znika. Wymiociny same śmierdzą co 10 s, a przenośny scrubber też czyści dym."
	items = list(
		/obj/machinery/pollution_scrubber = 1,
		/obj/item/wrench = 1,
		/obj/item/air_refresher = 2,
		/obj/item/storage/fancy/cigarettes = 1,
		/obj/item/lighter = 1,
		/obj/item/storage/box/perfume = 1,
		/obj/item/storage/fancy/candle_box/scented = 1,
		/obj/item/reagent_containers/food/drinks/coffee = 1,
		/obj/effect/decal/cleanable/vomit = 1,
		/obj/machinery/portable_atmospherics/scrubber = 1,
		/mob/living/carbon/human = 1,
	)

/datum/test_chamber_kit/pr_zapachy/setup(list/spawned, list/turfs, turf/center, mob/user)
	center.pollute_turf_list(list(/datum/pollutant/smoke = 400, /datum/pollutant/food/coffee = 100))
