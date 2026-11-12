// aq33/AquilaStation#633 - zgłoszenia 12.11

/datum/test_chamber_kit/pr_633
	name = "Zgłoszenia 12.11 (Po sprzęt, mapa taktyczna, pager XO, bezpiecznik Alt+klik, augmentacja)"
	pr = "aq33/AquilaStation#633"
	description = "Zestaw robi cię dowódcą drużyny Alpha i dokłada jednego członka bez gracza. Obok stoją konsola drużyn XO, dwa automaty drużyny, szafka XO, pistolet z tłumikiem, rewolwer, proteza ręki i torba chirurgiczna. \
	1) Konsola XO: przy Alpha kliknij „Po sprzęt” → komunikat na ekranie, znacznik nad bliższym automatem i strzałka na krawędzi ekranu po odejściu; otwórz wskazany automat → znacznik znika. Drugi klik od razu → „Za szybko” (negatyw). \
	2) Konsola: „Rozkaz” dla Alpha, a zaraz potem dla Bravo → oba przechodzą; drugi rozkaz dla Alpha przed upływem 30 s → odmowa (negatyw). \
	3) Mapa w konsoli albo w pagerze: przybliż i przeciągnij myszą → mapa się przesuwa, znacznik się nie stawia; zwykły klik dalej stawia znacznik. \
	4) Otwórz szafkę XO (dostęp HoP/XO) → globalny pager drużyn. \
	5) Pistolet w ręce: Alt+klik → odbezpieczony, drugi Alt+klik → zabezpieczony (podpowiedź w opisie i screentipie). Zabezpieczony z tłumikiem: Alt+klik odkręca tłumik. Rewolwer: Alt+klik kręci bębenkiem, bezpiecznik bez zmian (negatyw). \
	6) Augmentacja na członku drużyny: połóż go, serwety na prawą rękę, skalpel, rozwieracz, proteza ręki → ręka robotyczna i strefa NIE krwawi; śrubokręt na protezie bez przygotowania kroków → podpowiedź zamiast ciosu."
	items = list(
		/obj/machinery/computer/squad_manager = 1,
		/obj/machinery/squad_vendor = 2,
		/obj/structure/closet/secure_closet/hop = 1,
		/obj/item/gun/ballistic/automatic/pistol = 1,
		/obj/item/suppressor = 1,
		/obj/item/gun/ballistic/revolver = 1,
		/obj/item/bodypart/r_arm/robot = 1,
		/obj/item/storage/backpack/duffelbag/med/surgery = 1,
		/obj/item/surgical_drapes = 1,
	)

/datum/test_chamber_kit/pr_633/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/mob/living/carbon/human/H = user
	var/datum/squad/alpha = GLOB.squad_manager.get_squad("Alpha")
	if(!istype(H) || !alpha)
		to_chat(user, "<span class='warning'>Musisz być człowiekiem w komorze, żeby dołączyć do drużyny. Sprzęt i tak leży na arenie.</span>")
		return
	if(H.squad != alpha)
		if(H.squad)
			H.squad.remove_member(H)
		alpha.add_member(H)
	alpha.set_leader(H)
	H.put_in_hands(new /obj/item/squad_pager(get_turf(H), alpha))
	var/mob/living/carbon/human/member = new(turfs[min(length(turfs), 5)])
	member.equipOutfit(/datum/outfit/job/assistant)
	alpha.add_member(member)
	spawned += member
