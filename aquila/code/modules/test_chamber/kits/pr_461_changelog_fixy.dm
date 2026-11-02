/datum/test_chamber_kit/pr_461
	name = "PR 461: poprawki z changelogu 2024"
	pr = "aq33/AquilaStation#461"
	description = "Człowiek, goryl, skaner DNA z konsolą, konsola cargo ze skanerem eksportowym i pełna bateria eksportowa są w zestawie. \
		1) Laser Eyes: wstrzyknij sobie injector, włącz combat mode i kliknij odległego człowieka z zestawu → oczekiwane: strzela promień (bez runtime'u), każdy strzał lekko rani oczy. \
		2) Matter Eater: wstrzyknij injector pożeracza materii, połknij przedmiot, potem wstrzyknij anty-injector → oczekiwane: przedmiot wypada zamiast zniknąć. \
		3) Konsola DNA: wstrzyknij Thermal, Glow i Radioactive (injectory), wejdź do skanera i połącz w konsoli Thermal + Glow oraz Thermal + Radioactive → oczekiwane: wychodzą Laser Eyes i X-ray (wymaga żywego człowieka). Pozostałe injectory (Vore, Cat Claws, Fire Breath) sprawdź na tym samym człowieku → oczekiwane: wszczepiają się bez blokady rasy. \
		4) Implant ochrony: wszczep go sobie, użyj *deathgasp → oczekiwane: implant się nie odpala; zabij się naprawdę (VV: wywołaj death) → oczekiwane: odzywa się przy prawdziwej śmierci. \
		5) Załóż kombinezon HEV → oczekiwane: pojawia się powitanie. Multitool układów, analizator Hilberta i apteczka gangu → oczekiwane: mają widoczne ikony, nie puste. \
		6) Skaner eksportowy: kliknij nim konsolę cargo, potem baterię eksportową → oczekiwane: pełna bateria na T1 wyceniona na 2000 kr. \
		7) Energy gun (z zestawu i ze stojaka) kontra laser → oczekiwane: ten sam rytm strzelania. \
		8) Uderz człowieka z zestawu ostrym narzędziem → oczekiwane: krew bryzga, ale czat adminów milczy. Goryl wymaga ducha: przejmij go z menu spawnerów, jeśli się pojawi."
	items = list(
		/obj/item/dnainjector/lasereyesmut = 1,
		/obj/item/dnainjector/thermal = 1,
		/obj/item/dnainjector/glow = 1,
		/obj/item/dnainjector/radioactive = 1,
		/obj/item/dnainjector/vore = 1,
		/obj/item/dnainjector/antivore = 1,
		/obj/item/dnainjector/catclaws = 1,
		/obj/item/dnainjector/firebreath = 1,
		/obj/item/implanter/security_down = 1,
		/obj/item/clothing/suit/space/hardsuit/aquila/hazard_suit = 1,
		/obj/item/multitool/circuit = 1,
		/obj/item/analyzer/hilbertsanalyzer = 1,
		/obj/item/storage/firstaid/shifty = 1,
		/obj/item/hemostat/alien = 1,
		/obj/item/energy_harvester = 1,
		/obj/machinery/power/battery = 1,
		/obj/item/gun/energy/e_gun = 1,
		/mob/living/simple_animal/hostile/gorilla = 1,
		/mob/living/carbon/human = 1,
		/obj/machinery/dna_scannernew = 1,
		/obj/machinery/computer/scan_consolenew = 1,
		/obj/machinery/computer/cargo = 1,
		/obj/item/export_scanner = 1,
	)

/datum/test_chamber_kit/pr_461/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	// Konsola DNA łączy się ze skanerem tylko, gdy stoi bezpośrednio obok (kierunki kardynalne)
	var/obj/machinery/dna_scannernew/scanner = locate() in spawned
	var/obj/machinery/computer/scan_consolenew/console = locate() in spawned
	if(scanner && console)
		for(var/direction in GLOB.cardinals)
			var/turf/T = get_step(scanner, direction)
			if(T && !T.density && !locate(/obj/machinery, T))
				console.forceMove(T)
				break
		console.connect_to_scanner()
	// Bateria eksportowa z zestawu jest pełna, żeby skaner pokazał pełną cenę
	for(var/obj/machinery/power/battery/battery in spawned)
		if(battery.max_charge > 1)
			battery.charge = battery.max_charge
			battery.update_icon()
