/datum/test_chamber_kit/pr_479
	name = "PR 479: nowa botanika z Bee"
	pr = "aq33/AquilaStation#479"
	description = "Wiadro z wodą i zlewka z wodą są napełnione, obok stoją zwłoki człowieka bez gracza. Terminal Yamato, analizator, edytor nasion i piec są połączone. \
		1) Wsyp podłoże z worka do tacy, posadź nasiono prawym klikiem i podlej z wiadra → oczekiwane: roślina rośnie; po dojrzeniu zbierz ją ręką, zeskanuj skanerem roślin → oczekiwane: skaner pokazuje cechy i potrzeby. \
		2) Negatyw: posadź nasiono w pustej tacy bez podłoża → oczekiwane: nasiono się nie przyjmuje (korzenie wymagają podłoża). Drugi negatyw: nie podlewaj rośliny → oczekiwane: roślina nie rośnie normalnie; potrzebę wody sprawdź skanerem roślin. \
		3) Włóż dojrzałą roślinę do analizatora i zapisz cechę na dysk; w edytorze nasion dodaj ją do nasion; w piecu (butla z plazmą) zmutuj cechę - wszystko z terminala Yamato → oczekiwane: nasiona dostają nową cechę, budżet genetyczny się zmienia. \
		4) Seeder: włóż owoc → oczekiwane: wychodzą nasiona. \
		5) Replica pod: strzykawką pobierz krew ze zwłok i wstrzyknij ją do nasion strąka diony → oczekiwane: nasiona „odrzucają próbkę”, bo to nie krew gracza z umysłem. Człowieka-strąka da się zrobić tylko krwią martwego gracza (wymaga drugiego gracza albo ciebie martwego z krwią pobraną wcześniej): po dojrzeniu wychodzi człowiek-strąk. \
		6) Kwiat trupi po dojrzeniu → oczekiwane: wydziela miazmę. Turtle bot → oczekiwane: sam podlewa tace. Glowshroom → oczekiwane: rośnie i świeci bez runtime'ów."
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
		/obj/item/reagent_containers/glass/beaker/large = 1,
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

/datum/test_chamber_kit/pr_479/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	// Woda do podlewania: pełne wiadro i zlewka
	for(var/obj/item/reagent_containers/glass/container in spawned)
		if(istype(container, /obj/item/reagent_containers/glass/bucket) || istype(container, /obj/item/reagent_containers/glass/beaker/large))
			container.reagents.add_reagent(/datum/reagent/water, container.reagents.maximum_volume)
	// Zwłoki do próby krwi w replica pod (to nie krew gracza, więc ma zostać odrzucona)
	var/turf/body_turf = turfs[min(length(items) + 1, length(turfs))]
	var/mob/living/carbon/human/corpse = new(body_turf)
	corpse.name = "zwłoki do krwi"
	corpse.real_name = corpse.name
	corpse.death()
	spawned += corpse
