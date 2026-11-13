/datum/test_chamber_kit/pr_627
	name = "Pas TGMC, czapka na hardsuicie, barykady"
	pr = "aq33/AquilaStation#627"
	description = "1) Pas M276: załóż go (sprite na postaci we wszystkich kierunkach). Wchodzą magazynki, naboje, granaty, nóż bojowy i flara, a nie wchodzi np. apteczka. \
	Pasem kliknij pudełko z nabojami do strzelby (albo pudełkiem pas): po 1,5 s naboje przechodzą do pasa, aż się zapełni (9 miejsc). Magazynek kliknięty w pas trafia do środka zamiast się opróżniać. \
	2) Czapka: załóż hardsuit, rozłóż hełm i kliknij go czapką (albo kliknij czapką kombinezon, gdy hełm jest schowany). Czapkę ma być widać na hełmie; Alt-klik na hełm ją zdejmuje. Schowaj hełm i rozłóż ponownie: czapka zostaje. \
	3) Barykady: zestaw dopisuje cię do drużyny Alpha (jeśli nie masz drużyny); w automacie drużyny pobierz zestaw; w skrzyni są dwa granaty barierowe. Oddaj skrzynię bez nich: brak grzywny. \
	4) Seks na przycisk: przeczytaj książkę i użyj zaklęcia na obiekcie testowym z kluczem w zasięgu kamery z zestawu (kamera stoi na środku areny i widzi do 7 pól, więc stańcie przy niej, nie w narożniku; obie postacie muszą mieć akta w konsoli ochrony): oboje dostają w aktach zbrodnię „Publiczne obcowanie płciowe” i status do aresztowania. Poza kamerą: brak wpisu. \
	5) Odchody: *poop albo wypróżnienie na podłogę: zamiast plamy leżą brązowe grudki (7 wariantów). Felinid zostawia fioletowy kopczyk. \
	6) Barykady kierunkowe: postaw z arkuszy metalu składaną metalową barykadę, a z worków barykadę z worków (staje przodem tam, gdzie patrzysz). Strzelaj w barykadę z lasera z kilku pól: część strzałów przelatuje (metal i worki ok. 20%, plastal 10%), a stojąc tuż przy barykadzie strzelasz nad nią. \
	Rozłóż drut kolczasty: przez barykadę nie da się przeskoczyć, nożyce go zdejmują. Uszkodź barykadę poniżej 30%: spawarka odmawia, dwa arkusze metalu wzmacniają podstawę. Worki naprawiasz workiem, a rozbierasz łopatą. Składaną barykadę składasz i rozkładasz ręką."
	items = list(
		/obj/machinery/camera = 1,
		/obj/machinery/squad_vendor = 1,
		/obj/item/storage/belt/aq_tgmc = 1,
		/obj/item/storage/box/lethalshot = 2,
		/obj/item/ammo_box/magazine/m556 = 2,
		/obj/item/kitchen/knife/combat = 1,
		/obj/item/grenade/barrier = 2,
		/obj/item/clothing/suit/space/hardsuit/engine = 1,
		/obj/item/clothing/head/beret = 1,
		/obj/item/clothing/head/that = 1,
		/obj/item/book/granter/spell/sexonbutton = 1,
		/obj/structure/peacekeeper_barricade/metal = 1,
		/obj/structure/peacekeeper_barricade/metal/sandbags = 1,
		/obj/structure/peacekeeper_barricade/metal/plasteel/folding_metal = 1,
		/obj/item/stack/sheet/iron/twenty = 1,
		/obj/item/stack/sheet/mineral/sandbags = 5,
		/obj/item/stack/barbed_wire/five = 1,
		/obj/item/weldingtool = 1,
		/obj/item/wirecutters = 1,
		/obj/item/shovel = 1,
		/obj/item/gun/energy/laser = 1,
	)

/datum/test_chamber_kit/pr_627/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/mob/living/carbon/human/H = user
	var/datum/squad/alpha = GLOB.squad_manager?.get_squad("Alpha")
	if(!istype(H) || !alpha)
		to_chat(user, "<span class='warning'>Musisz być człowiekiem w komorze, żeby dołączyć do drużyny. Sprzęt i tak leży na arenie.</span>")
		return
	if(!H.squad)
		alpha.add_member(H)
