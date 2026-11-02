/datum/test_chamber_kit/pr_452
	name = "Bitrunning z tg"
	pr = "aq33/AquilaStation#452"
	description = "Pracownia w pigułce: serwer kwantowy z konsolą obok (100 punktów domen), netpod, byteforge i sklep NexaCache. Jeśli jesteś człowiekiem z kontem bankowym, dostajesz 3000 np (inaczej zestaw pisze, że ich nie dał). Dyski zdolności i dungeon, implant wygnania i łom są w zestawie. \
		1) W konsoli kwantowej załaduj domenę „Planeta Klaunów” (najtańsza, nagroda to klakson rowerowy) → oczekiwane: serwer zużywa punkty, w byteforge pojawia się kryjówka, a domena jest gotowa. \
		2) Wejdź do netpoda (przeciągnij się na niego) → oczekiwane: trafiasz do domeny jako awatar, ciało zostaje w netpodzie w stazie. \
		3) Zdobądź skrzynię i zanieś ją do miejsca wysyłki w kryjówce → oczekiwane: nagroda wylatuje z byteforge'a, np i klakson dla ciebie. \
		4) Negatyw: rozłącz netpod łomem, gdy jesteś w domenie → oczekiwane: awatar się rozłącza, a mózg ciała dostaje obrażenia. Drabina hololadder → oczekiwane: wychodzi z domeny. \
		5) Cyfrowe wygnanie: wszczep drugiemu człowiekowi implant wygnania i wsadź go do netpoda → oczekiwane: po 10 s trafia do Pętli, a przy netpodzie zostaje depozyt z jego rzeczami. \
		6) W Pętli: terminal ładuje domeny za darmo, brama wpuszcza, drabina odsyła z powrotem. Sklep NexaCache (karta ID z kontem) → oczekiwane: zakup za punkty, dostawa promem albo ekspresem."
	items = list(
		/obj/machinery/quantum_server = 1,
		/obj/machinery/computer/quantum_console = 1,
		/obj/machinery/netpod = 1,
		/obj/machinery/byteforge = 1,
		/obj/machinery/computer/order_console/bitrunning = 1,
		/mob/living/carbon/human = 2,
		/obj/item/implanter/exile = 1,
		/obj/item/disk/bitrunning/ability/tier2 = 1,
		/obj/item/disk/bitrunning/gimmick/dungeon = 1,
		/obj/item/bitrunning_debug = 1,
		/obj/item/crowbar = 1,
	)

/datum/test_chamber_kit/pr_452/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/obj/machinery/quantum_server/server = locate() in spawned
	var/obj/machinery/computer/quantum_console/console = locate() in spawned
	var/obj/machinery/netpod/pod = locate() in spawned
	var/obj/machinery/byteforge/forge = locate() in spawned
	if(!server)
		return
	server.points = 100
	// konsola musi stać obok serwera, netpod i byteforge najwyżej 4 pola dalej
	for(var/direction in GLOB.cardinals)
		var/turf/open/next = get_step(server, direction)
		if(istype(next) && !is_blocked_turf(next, TRUE))
			console?.forceMove(next)
			break
	for(var/obj/machinery/machine as anything in list(pod, forge))
		if(machine && get_dist(machine, server) > 4)
			machine.forceMove(get_step(get_step(server, SOUTH), SOUTH))
	pod?.find_server()
	console?.find_server()
	var/mob/living/carbon/human/admin_body = user
	var/datum/bank_account/account = istype(admin_body) ? admin_body.get_bank_account() : null
	if(!account)
		to_chat(user, "<span class='warning'>Nie przyznano 3000 np: musisz być człowiekiem z kontem bankowym (karta ID w ręku albo noszona). Zdobądź kartę i zrzuć zestaw jeszcze raz albo zmień punkty przez VV.</span>")
		return
	account.bitrunning_points += 3000
