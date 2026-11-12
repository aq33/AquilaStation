/datum/test_chamber_kit/pr_627
	name = "Pasy TGMC, czapka na hardsuicie, barykady"
	pr = "aq33/AquilaStation#627"
	description = "1) Pasy: załóż każdy z pasów (sprite na postaci we wszystkich kierunkach). Do M276 wchodzą magazynki, naboje, nóż bojowy, flara i granat, a nie wchodzi np. apteczka. \
	Pasem na naboje kliknij pudełko z nabojami (albo pudełkiem pas): po 1,5 s naboje przechodzą do pasa, aż się zapełni. Pas na granaty mieści tylko granaty, sakwa G8 trzy dowolne rzeczy. \
	2) Czapka: załóż hardsuit, rozłóż hełm i kliknij go czapką (albo kliknij czapką kombinezon, gdy hełm jest schowany). Czapkę ma być widać na hełmie; Alt-klik na hełm ją zdejmuje. Schowaj hełm i rozłóż ponownie: czapka zostaje. \
	3) Barykady: zestaw dopisuje cię do drużyny Alpha (jeśli nie masz drużyny); w automacie drużyny pobierz zestaw; w skrzyni są dwa granaty barierowe. Oddaj skrzynię bez nich: brak grzywny. \
	4) Seks na przycisk: przeczytaj książkę i użyj zaklęcia na obiekcie testowym z kluczem w zasięgu kamery z zestawu (kamera stoi na środku areny i widzi do 7 pól, więc stańcie przy niej, nie w narożniku; obie postacie muszą mieć akta w konsoli ochrony): oboje dostają w aktach zbrodnię „Publiczne obcowanie płciowe” i status do aresztowania. Poza kamerą: brak wpisu. \
	5) Odchody: *poop albo wypróżnienie na podłogę: zamiast plamy leżą brązowe grudki (7 wariantów)."
	items = list(
		/obj/machinery/camera = 1,
		/obj/machinery/squad_vendor = 1,
		/obj/item/storage/belt/aq_tgmc/ammo = 1,
		/obj/item/storage/belt/aq_tgmc/ammo/upp = 1,
		/obj/item/storage/belt/aq_tgmc/ammo/som = 1,
		/obj/item/storage/belt/aq_tgmc/ammo/icc = 1,
		/obj/item/storage/belt/aq_tgmc/shotgun = 1,
		/obj/item/storage/belt/aq_tgmc/shotgun/icc = 1,
		/obj/item/storage/belt/aq_tgmc/grenade = 1,
		/obj/item/storage/belt/aq_tgmc/sparepouch = 1,
		/obj/item/storage/box/lethalshot = 2,
		/obj/item/ammo_box/magazine/m556 = 2,
		/obj/item/kitchen/knife/combat = 1,
		/obj/item/grenade/barrier = 2,
		/obj/item/clothing/suit/space/hardsuit/engine = 1,
		/obj/item/clothing/head/beret = 1,
		/obj/item/clothing/head/that = 1,
		/obj/item/book/granter/spell/sexonbutton = 1,
	)

/datum/test_chamber_kit/pr_627/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/mob/living/carbon/human/H = user
	var/datum/squad/alpha = GLOB.squad_manager?.get_squad("Alpha")
	if(!istype(H) || !alpha)
		to_chat(user, "<span class='warning'>Musisz być człowiekiem w komorze, żeby dołączyć do drużyny. Sprzęt i tak leży na arenie.</span>")
		return
	if(!H.squad)
		alpha.add_member(H)
