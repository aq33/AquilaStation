/datum/test_chamber_kit/pr_478
	name = "PR 478: nowa botanika z Bee"
	pr = "aq33/AquilaStation#478"
	description = "Wsyp podłoże z worka do tacy, posadź nasiona prawym klikiem, podlej z wiadra (woda w zlewce). Po dojrzeniu zbierz ręką, zeskanuj skanerem roślin. \
	Włóż roślinę do analizatora i zapisz cechę na dysk, w edytorze nasion dodaj ją do nasion, w piecu (butla z plazmą) zmutuj cechę - wszystko z terminala Yamato obok. \
	Seeder: włóż owoc, ma dać nasiona. Replica pod: wstrzyknij strzykawką krew martwego gracza do nasion, posadź - po dojrzeniu ma wyjść człowiek-strąk. \
	Kwiat trupi (z nasion w zestawie) po dojrzeniu ma wydzielać miazmę. Turtle bot ma sam podlewać tace. Glowshroom ma rosnąć i świecić bez runtime'ów."
	items = list(
		/obj/machinery/computer/plant_machine_controller = 1,
		/obj/machinery/plant_machine/plant_analyser = 1,
		/obj/machinery/plant_machine/seed_editor = 1,
		/obj/machinery/plant_machine/plant_mutator/tutorial = 1,
		/obj/machinery/refraction_catalogue = 1,
		/obj/machinery/seeder = 1,
		/obj/item/plant_tray = 3,
		/obj/item/substrate_bag/dirt = 1,
		/obj/item/substrate_bag/sand = 1,
		/obj/item/substrate_bag/clay = 1,
		/obj/item/plant_scanner = 1,
		/obj/item/disk/plant_disk = 2,
		/obj/item/reagent_containers/glass/bucket = 1,
		/obj/item/reagent_containers/syringe = 1,
		/obj/item/tank/internals/plasma/full = 1,
		/obj/item/shovel/spade = 1,
		/obj/item/plant_seeds/preset/tomato = 1,
		/obj/item/plant_seeds/preset/apple = 1,
		/obj/item/plant_seeds/preset/diona_pod = 1,
		/obj/item/plant_seeds/preset/corpse_flower = 1,
		/obj/item/plant_seeds/preset/butt = 1,
		/obj/item/plant_seeds/preset/glowshroom = 1,
		/obj/item/book/manual/wiki/hydroponics/tutorial = 1,
		/mob/living/simple_animal/bot/turtle = 1,
	)
