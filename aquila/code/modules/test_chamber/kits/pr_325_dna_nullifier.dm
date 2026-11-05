// aq33/AquilaStation#325 - DNA nullifier + QoL ręcznego skanera sekwencji (port Bee#9403)

/datum/test_chamber_kit/pr_325
	name = "PR 325: DNA nullifier i skaner sekwencji"
	pr = "aq33/AquilaStation#325"
	description = "Pierwszy człowiek ma już wstrzyknięte mutacje (x-ray, telekineza); drugi jest czysty (kontrola). Konsola stoi przy skanerze DNA (połączone). \
	1) Ręcznym skanerem sekwencji kliknij pierwszego człowieka → oczekiwane: widać jego mutacje i stabilność genetyczną; ten sam skaner na drugim → brak mutacji. \
	2) Wsadź pierwszego człowieka do skanera DNA (przeciągnij go na skaner, zamknij drzwi), w konsoli wybierz jego aktywną mutację i wydrukuj DNA nullifier → oczekiwane: powstaje iniektor z własnym sprite'em \"dnanullifier\". \
	3) Wydrukuj kolejny nullifier od razu → oczekiwane: odmowa, cooldown jest 3x dłuższy niż zwykłego injectora. \
	4) Wstrzyknij nullifier pierwszemu człowiekowi → oczekiwane: mutacja znika, iniektor zmienia sprite na pusty \"dnanullifier0\", w logu ataków jest wpis o usuniętych mutacjach. \
	5) Negatyw: drugi nullifier (na mutację, której nie ma drugi człowiek) wstrzyknij drugiemu człowiekowi → oczekiwane: nic się nie zmienia; użyty iniektor ponownie nie zadziała (\"zużyty\"). \
	6) Dodatkowo: iniektor clumsy wstrzyknij drugiemu człowiekowi i zeskanuj go skanerem sekwencji → oczekiwane: pojawia się nowa mutacja."
	items = list(
		/obj/machinery/dna_scannernew = 1,
		/obj/machinery/computer/scan_consolenew = 1,
		/obj/item/sequence_scanner = 1,
		/obj/item/dnainjector/clumsymut = 1,
		/mob/living/carbon/human = 2,
	)

/datum/test_chamber_kit/pr_325/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/obj/machinery/dna_scannernew/scanner = locate() in spawned
	var/obj/machinery/computer/scan_consolenew/console = locate() in spawned
	if(scanner && console)
		// Konsola łączy się ze skanerem tylko, gdy stoi z nim bezpośrednio obok (kierunki kardynalne)
		for(var/direction in GLOB.cardinals)
			var/turf/T = get_step(scanner, direction)
			if(T && !T.density && !locate(/obj/machinery, T))
				console.forceMove(T)
				break
		console.connect_to_scanner()
	var/mob/living/carbon/human/H = locate() in spawned
	if(H && H.dna)
		H.dna.add_mutation(XRAY, MUT_EXTRA)
		H.dna.add_mutation(TK, MUT_EXTRA)
