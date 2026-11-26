// aq33/AquilaStation#660 - botanika po przeglądzie: odmiany kapsułowe roślin obcych i z planet, surowa krewetka w konsoli kuchni

/datum/test_chamber_kit/pr_660
	name = "Botanika: odmiany kapsułowe i krewetki"
	pr = "aq33/AquilaStation#660"
	description = "1) Odmiany kapsułowe (nasiona z dopiskiem „kapsuła ksenoflory”): spróbuj posadzić je w zwykłej tacce, nie wzejdą. W kapsule ustaw ich warunki: jurl'mah azot i mróz od −30 do −10 °C, vale plazma i 30–60 °C. Owoc ma w skanerze nazwę z dopiskiem „odmiana kapsułowa” i dwa razy większą objętość niż zwykła wersja, a siewnik robi z niego znów nasiona kapsułowe. 2) Konsola zamówień kuchni: w dziale mięsa jest surowa krewetka (10 kr). Ugotuj z niej krewetki albo szaszłyk z 4 krewetek."
	items = list(
		/obj/machinery/atmospherics/components/binary/xenoflora_pod = 1,
		/obj/machinery/portable_atmospherics/canister/nitrogen = 1,
		/obj/machinery/portable_atmospherics/canister/toxins = 1,
		/obj/item/plant_seeds/preset/alien/xenoflora/capsule/jurlmah = 1,
		/obj/item/plant_seeds/preset/alien/xenoflora/capsule/vale = 1,
		/obj/item/plant_seeds/preset/alien/jurlmah = 1,
		/obj/item/plant_tray = 1,
		/obj/item/substrate_bag/dirt = 1,
		/obj/item/plant_scanner = 1,
		/obj/machinery/seeder = 1,
		/obj/item/wrench = 1,
		/obj/machinery/computer/order_console/cook = 1,
		/obj/item/food/shellfish_meat/shrimp = 4,
	)
