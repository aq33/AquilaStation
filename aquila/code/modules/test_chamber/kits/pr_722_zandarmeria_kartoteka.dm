// aq33/AquilaStation#722 - Żandarmeria, część 1: kartoteka, prawo i pamięć między rundami (aquila/code/modules/security/)

/datum/test_chamber_kit/pr_722_zandarmeria
	name = "PR 722: kartoteka, zegar celi, kaucja, nakazy"
	pr = "aq33/AquilaStation#722"
	description = "Okulary z HUD-em ochrony i karta kapitana (wszystkie dostępy). 1) Zmień status w konsoli rekordów albo z HUD-u: aresztowanie i przeszukanie pytają o powód, zmiana idzie na kanał Żandarmerii, historia trafia do komentarzy. 2) Citationinatorem wystaw mandat: na kwicie jest termin; nie płać, po 10 min status zmienia się na do aresztowania. 3) Planerem zarzutów wybierz zarzuty, kliknij nim osobę (skan twarzy) i zegar celi: zegar dostaje osadzonego, zarzuty i czas. Uruchom, sprawdź status, ostrzeżenie 30 s przed końcem, pauzę, ułaskawienie i zatrzymanie (zwolnienie warunkowe). 4) Kasa grzywien: sekcja Kaucje, zapłać kartą albo holożetonem (nie działa przy alarmie czerwonym). 5) Projektor nakazu: osoba ze statusem do przeszukania, wybierz obszar, autoryzuj kartą, drzwi tego obszaru otwierają się z projektorem przy sobie. 6) Implanter alarmu śmierci na kukle i jej śmierć: komunikat na kanałach Żandarmerii i Medycznym. 7) Ramę skrzynki skarg zawieś na ścianie, wrzuć kartkę, przeczytaj ją w oknie. 8) Kod Żandarmerii: Żandarm ma język ,w. 9) Stopień Żandarma w konsoli rekordów: awans i degradacja (wymaga Żandarma w rundzie). 10) Kserokopiarka: polskie formularze Żandarmerii."
	items = list(
		/obj/item/clothing/glasses/hud/security/sunglasses = 1,
		/obj/item/card/id/captains_spare = 1,
		/obj/item/citationinator = 1,
		/obj/item/law_planner = 1,
		/obj/item/holowarrant = 1,
		/obj/item/restraints/handcuffs = 2,
		/obj/item/implanter/security_down = 1,
		/obj/item/implantcase/security_down/crew = 1,
		/obj/item/implanter = 1,
		/obj/item/wallframe/complaint_box = 1,
		/obj/item/paper = 3,
		/obj/item/pen = 1,
		/obj/item/holochip = 1,
		/obj/machinery/door_timer = 1,
		/obj/machinery/computer/warrant = 1,
		/obj/machinery/computer/secure_data = 1,
		/obj/machinery/photocopier = 1,
	)

/datum/test_chamber_kit/pr_722_zandarmeria/setup(list/spawned, list/turfs, turf/center, mob/user)
	for(var/obj/item/holochip/chip in spawned)
		chip.credits = 2000
		chip.update_appearance()
