// aq33/AquilaStation#672 - mechy: system slotów, overclock, kierunkowy pancerz, nowe podwozia, skiny i wyposażenie

/datum/test_chamber_kit/pr_672_mechy
	name = "PR 672: mechy - podwozia"
	pr = "aq33/AquilaStation#672"
	description = "Nowe podwozia i zestawy konwersji. Sprawdź: sloty w oknie mecha (dwie bronie w ramionach, trzecia odmawia), overclock (działa 15 s, potem 45 s odnowienia, \
	stan i czas w oknie mecha), Savannah z dwoma osobami (drugi prowadzi i skacze Skyfall, pierwszy strzela i odpala Ivanov), \
	Paddy (syreny, cela, chwytak), Clarke (ruda z pola do ładowni, bez jazdy skosem przy strafe), Sentinel (burzy ściany), \
	Basenji (szarża), konwersja Ripleya na Paddy i CLIP MK-IV (protokoły serwisowe włączone, mech pusty). Kokpit zdalnego sterowania: odbiornik w Gygaxie, usiądź w kokpicie. \
	Zrzut: system zrzutu w Gygaxie, latarnia postawiona kilka kratek dalej."
	items = list(
		/obj/mecha/working/aq_clarke = 1,
		/obj/mecha/working/ripley/aq_paddy = 1,
		/obj/mecha/combat/aq_savannah = 1,
		/obj/mecha/combat/aq_savannah/red_sunday = 1,
		/obj/mecha/combat/aq_sentinel/loaded = 1,
		/obj/mecha/working/ripley = 2,
		/obj/mecha/combat/gygax = 1,
		/obj/mecha/combat/durand = 1,
		/obj/item/mecha_parts/mecha_equipment/aq_conversion_kit/paddy = 1,
		/obj/item/mecha_parts/mecha_equipment/aq_conversion_kit/clip_ripley = 1,
		/obj/item/mecha_parts/mecha_equipment/aq_conversion_kit/basenji = 1,
		/obj/item/mecha_parts/mecha_equipment/aq_conversion_kit/paladin = 1,
		/obj/item/mecha_parts/aq_armor_plating/composite = 1,
		/obj/item/mecha_parts/mecha_equipment/aq_remote_receiver = 1,
		/obj/machinery/aq_mecha_remote_pod = 1,
		/obj/item/mecha_parts/mecha_equipment/aq_drop_system = 1,
		/obj/item/aq_mech_drop_beacon = 1,
		/obj/item/mecha_parts/mecha_equipment/aq_tool/paddy_claw = 1,
		/obj/item/card/id/captains_spare = 1,
		/obj/item/storage/toolbox/mechanical = 1,
	)

/datum/test_chamber_kit/pr_672_mechy_budowa
	name = "PR 672: mechy - budowa i skiny"
	pr = "aq33/AquilaStation#672"
	description = "Fabrykator egzoszkieletów z materiałami: zakładki Clarke, Savannah-Ivanov, Red Sunday, Sentinel (projekty po odblokowaniu węzłów w R&D). \
	Zbuduj Clarke'a z części z zestawu: po ostatnim kroku ma się pokazać menu kołowe skinów (Carrion Crawler, mech eksploracyjny). \
	Durand, Gygax, Phazon, Odysseus, H.O.N.K i Ripley też mają skiny przy budowie."
	items = list(
		/obj/machinery/modular_fabricator/exosuit_fab = 1,
		/obj/item/mecha_parts/chassis/aq/clarke = 1,
		/obj/item/mecha_parts/part/aq/clarke_torso = 1,
		/obj/item/mecha_parts/part/aq/clarke_head = 1,
		/obj/item/mecha_parts/part/aq/clarke_left_arm = 1,
		/obj/item/mecha_parts/part/aq/clarke_right_arm = 1,
		/obj/item/mecha_parts/part/aq/clarke_treads = 1,
		/obj/item/circuitboard/mecha/aq_clarke/main = 1,
		/obj/item/circuitboard/mecha/aq_clarke/peripherals = 1,
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/cell/high = 1,
		/obj/item/stack/sheet/plasteel/fifty = 1,
		/obj/item/stack/sheet/mineral/gold/fifty = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/storage/toolbox/mechanical = 1,
		/obj/item/weldingtool/largetank = 1,
	)

/datum/test_chamber_kit/pr_672_mechy_wyposazenie
	name = "PR 672: mechy - wyposażenie"
	pr = "aq33/AquilaStation#672"
	description = "Wszystkie 61 pozycji wyposażenia z planu obok Gygaxa, Ripleya i Odyseusza. Sprawdź broń wręcz (cios w cel, zamach w combat mode), \
	amunicję (skrzynki i magazynki użyte na mechu), autolat (arkusze użyte na mechu, „drukuj” w oknie), wiele modułów z przyciskami akcji."
	items = list(
		/obj/mecha/combat/gygax = 2,
		/obj/mecha/working/ripley = 1,
		/obj/mecha/medical/odysseus = 1,
		/obj/item/mecha_ammo/umg2 = 2,
		/obj/item/mecha_ammo/executor = 1,
		/obj/item/mecha_ammo/fpw = 1,
		/obj/item/mecha_ammo/smilgas = 1,
		/obj/item/stack/sheet/iron/fifty = 1,
		/obj/item/stack/sheet/glass/fifty = 1,
	)

/datum/test_chamber_kit/pr_672_mechy_wyposazenie/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/index = length(items) + 1
	for(var/name in GLOB.aq_mecha_plan_equipment)
		var/turf/T = turfs[min(index++, length(turfs))]
		var/path = GLOB.aq_mecha_plan_equipment[name]
		spawned += new path(T)
