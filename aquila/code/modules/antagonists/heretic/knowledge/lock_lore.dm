/datum/heretic_knowledge_tree_column/lock
	route = PATH_LOCK
	ui_bgr = "node_lock"
	complexity = "Średnia"
	complexity_color = COLOR_YELLOW
	shop_cost_discount = 1
	icon = list(
		"icon" = 'aquila/icons/obj/weapons/khopesh.dmi',
		"state" = "key_blade",
		"frame" = 1,
		"dir" = SOUTH,
		"moving" = FALSE,
	)
	description = list(
		"Ścieżka Zamka to dostęp, blokowanie terenu, kradzieże i gadżety.",
		"Wybierz ją, jeśli wolisz mniej konfrontacyjny styl gry i chcesz być śliskim szczurem.",
	)
	pros = list(
		"Twój Mansus Grasp otwiera każdy zamek, odblokowuje każdy terminal i omija każde ograniczenie dostępu.",
		"Heretycy Zamka mają zniżkę w sklepie wiedzy, więc to idealna ścieżka do eksperymentowania z jego błyskotkami.",
	)
	cons = list(
		"Bezapelacyjnie najsłabsza ścieżka w bezpośredniej walce.",
		"Bardzo mało bezpośrednich korzyści bojowych.",
		"Brak zdolności obronnych i odporności.",
		"Brak mobilności i dodatkowej teleportacji.",
		"Mocno zależy od zasobów innych działów, graczy i świata gry.",
	)
	tips = list(
		"Twój Mansus Grasp daje dostęp do wszystkiego: śluz, konsol, a nawet mechów, ale nie ma dodatkowych efektów na graczy. Zostawia jednak znak, który po aktywacji nie pozwala ofierze opuścić pomieszczenia, w którym jesteś.",
		"Twoje ostrze działa też jak łom! Możesz je nosić w pasie na narzędzia, a w razie potrzeby wyważyć nim śluzę.",
		"Twoja Eldritch ID może stworzyć portal między dwiema śluzami. Przydaje się do założenia tajnej bazy.",
		"Używaj księgi labiryntu, by zgubić pościg. Tworzy ściany, przez które przejść możesz tylko ty.",
	)

	start = /datum/heretic_knowledge/limited_amount/starting/base_lock
	knowledge_tier1 = /datum/heretic_knowledge/key_ring
	guaranteed_side_tier1 = /datum/heretic_knowledge/painting
	knowledge_tier2 = /datum/heretic_knowledge/limited_amount/concierge_rite
	guaranteed_side_tier2 = /datum/heretic_knowledge/spell/opening_blast
	robes = /datum/heretic_knowledge/armor/lock
	knowledge_tier3 = /datum/heretic_knowledge/spell/burglar_finesse
	guaranteed_side_tier3 = /datum/heretic_knowledge/summon/fire_shark
	blade = /datum/heretic_knowledge/blade_upgrade/flesh/lock
	knowledge_tier4 = /datum/heretic_knowledge/spell/caretaker_refuge
	ascension = /datum/heretic_knowledge/ultimate/lock_final

/datum/heretic_knowledge/limited_amount/starting/base_lock
	name = "A Steward's Secret"
	desc = "Otwiera przed tobą Ścieżkę Zamka.<br>\
		Pozwala tworzyć Key Blade. \
		Naraz możesz mieć tylko dwa. Działają jak szybkie łomy \
		i mieszczą się w pasie na narzędzia."
	transmute_text = "Przemień nóż i łom."
	gain_text = "Zamknięty Labirynt prowadzi ku wolności. Ale tylko uwięzieni Zarządcy znają właściwą drogę."
	required_atoms = list(
		/obj/item/kitchen/knife = 1,
		/obj/item/crowbar = 1,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/lock)
	limit = 2
	research_tree_icon_path = 'aquila/icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "key_blade"
	mark_type = /datum/status_effect/eldritch/lock
	eldritch_passive = /datum/status_effect/heretic_passive/lock

/datum/heretic_knowledge/limited_amount/starting/base_lock/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY, PROC_REF(on_secondary_mansus_grasp))
	var/datum/action/cooldown/spell/touch/mansus_grasp/grasp_spell = locate() in user.actions
	grasp_spell?.invocation_type = INVOCATION_NONE
	grasp_spell?.sound = null

/datum/heretic_knowledge/limited_amount/starting/base_lock/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY)

/datum/heretic_knowledge/limited_amount/starting/base_lock/on_mansus_grasp(mob/living/source, mob/living/target)
	. = ..()

	// AQUILA - tg sprawdzał can_adjust przed sprawdzeniem typu
	var/obj/item/clothing/under/suit = target.get_item_by_slot(ITEM_SLOT_ICLOTHING)
	if(!istype(suit) || !suit.can_adjust)
		return
	if(suit.adjusted == NORMAL_STYLE)
		suit.toggle_jumpsuit_adjust()
		suit.update_appearance()
		if(ishuman(target))
			var/mob/living/carbon/human/human_target = target
			human_target.update_inv_w_uniform()
			human_target.update_body()

/datum/heretic_knowledge/limited_amount/starting/base_lock/proc/on_secondary_mansus_grasp(mob/living/source, atom/target)
	SIGNAL_HANDLER

	if(ismecha(target))
		// AQUILA - nasze mechy: jeden pilot, blokada DNA i dostępu
		var/obj/mecha/mecha = target
		mecha.dna_lock = null
		mecha.operation_req_access = list()
		var/mob/living/occupant = mecha.occupant
		if(occupant && !isAI(occupant))
			mecha.go_out(TRUE)
			occupant.Paralyze(5 SECONDS)
	else if(istype(target,/obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/door = target
		door.unbolt()
	else if(istype(target, /obj/machinery/computer))
		var/obj/machinery/computer/computer = target
		computer.authenticated = TRUE
		computer.balloon_alert(source, "odblokowano")
	else if(istype(target, /obj/machinery/turretid))
		var/obj/machinery/turretid/turretcontrol = target
		turretcontrol.locked = FALSE
		turretcontrol.balloon_alert(source, "odblokowano")

	var/turf/target_turf = get_turf(target)
	SEND_SIGNAL(target_turf, COMSIG_ATOM_MAGICALLY_UNLOCKED, src, source)
	SEND_SOUND(source, 'aquila/sound/effects/magic/hereticknock.ogg')

	if(HAS_TRAIT(source, TRAIT_LOCK_GRASP_UPGRADED))
		var/datum/action/cooldown/spell/touch/mansus_grasp/grasp = locate() in source.actions
		if(grasp)
			grasp.next_use_time -= round(grasp.cooldown_time*0.75)
			grasp.build_all_button_icons()
		return

	return COMPONENT_USE_HAND

/datum/heretic_knowledge/key_ring
	name = "Key Keeper's Burden"
	desc = "Zaklina kartę identyfikacyjną w Eldritch Card.<br>\
		Uderz nią w dwie śluzy, by stworzyć parę portali, \
		które przenoszą cię między nimi, a nie-heretyków teleportują losowo. \
		Ctrl-kliknięciem karty odwracasz to działanie dla tworzonych portali. \
		Każda karta podtrzymuje naraz tylko jedną parę portali.<br>\
		Działa i wygląda też jak zwykła karta ID. \
		Uderzenie jej zwykłą kartą ID pochłania tamtą i przejmuje jej dostęp, \
		a użycie w dłoni zmienia jej wygląd na jedną z pochłoniętych kart."
	transmute_text = "Przemień portfel, metalowy pręt i kartę ID."
	gain_text = "Strażnik Kluczy szydził: „Te plastikowe prostokąty to kpina z kluczy. Przeklinam każde drzwi, które ich pożądają”."
	required_atoms = list(
		/obj/item/storage/wallet = 1,
		/obj/item/stack/rods = 1,
		/obj/item/card/id = 1,
	)
	result_atoms = list(/obj/item/card/id/heretic)
	cost = 2
	research_tree_icon_path = 'icons/obj/card.dmi'
	research_tree_icon_state = "card_gold"

/datum/heretic_knowledge/key_ring/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/obj/item/card/id/id = locate(/obj/item/card/id) in selected_atoms
	if(isnull(id))
		return FALSE
	var/obj/item/card/id/heretic/result_item = new(loc)
	if(!istype(result_item))
		return FALSE
	selected_atoms -= id
	result_item.eat_card(id)
	result_item.shapeshift(id)
	return TRUE

/datum/heretic_knowledge/limited_amount/concierge_rite
	name = "Concierge's Rite"
	desc = "Spisz Labyrinth Handbook.<br>\
		Z dystansu tworzy barierę, przez którą przejść możesz tylko ty i osoby odporne na magię.<br>\
		Ma 5 ładunków, które z czasem się odnawiają."
	transmute_text = "Przemień kredkę, drewnianą deskę i multitool."
	gain_text = "Konsjerż wpisał moje imię do Księgi. „Witaj w nowym domu, Zarządco”."
	required_atoms = list(
		/obj/item/toy/crayon = 1,
		/obj/item/stack/sheet/mineral/wood = 1,
		/obj/item/multitool = 1,
	)
	result_atoms = list(/obj/item/heretic_labyrinth_handbook)
	cost = 2
	research_tree_icon_path = 'aquila/icons/obj/service/library.dmi'
	research_tree_icon_state = "heretichandbook"
	drafting_tier = 5

/datum/heretic_knowledge/armor/lock
	desc = "Stwórz Shifting Guise.<br>\
		Ukrywa cię przed kamerami, skrywa twoją tożsamość i głos oraz wycisza kroki."
	transmute_text = "Przemień stół (albo strój), maskę i łom."
	gain_text = "Choć Konsjerż zna Zarządców, \
		ci spotykają się ze sobą i z obcymi w cieniu płaszczy i naciągniętych kapturów. \
		Zażyłość to zdrada, nawet wobec samego siebie."
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch/lock)
	research_tree_icon_state = "lock_armor"
	required_atoms = list(
		list(/obj/structure/table, /obj/item/clothing/suit) = 1,
		/obj/item/clothing/mask = 1,
		/obj/item/crowbar = 1,
	)

/datum/heretic_knowledge/spell/burglar_finesse
	name = "Burglar's Finesse"
	desc = "Daje ci Burglar's Finesse, zaklęcie na jeden cel, \
		które przenosi do twojej dłoni losowy przedmiot z plecaka ofiary."
	gain_text = "Zadawanie się z duchami Włamywaczy jest źle widziane, ale Zarządca zawsze chce poznać nowe drzwi."
	required_atoms = list(/obj/item/clothing/gloves = 1)
	action_to_add = /datum/action/cooldown/spell/pointed/burglar_finesse
	cost = 2
	max_charges = 12
	focus_recharge_amount = 0.33
	holywater_drain_amount = 0.33
	transmute_text = "Możesz je doładować rytuałem z parą rękawic."

/datum/heretic_knowledge/blade_upgrade/flesh/lock
	name = "Opening Blade"
	desc = "Twoje ostrze może przy ataku otworzyć ofierze krwawiącą ranę."
	gain_text = "Pielgrzym-Chirurg nie był Zarządcą. Mimo to jego ostrza i szwy dorównywały ich kluczom."
	research_tree_icon_path = 'aquila/icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_lock"
	/// Szansa na ranę przy ataku
	var/chance = 35

/datum/heretic_knowledge/blade_upgrade/flesh/lock/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	// AQUILA - u nas nie ma ran (/datum/wound); krytyczna rana tnąca to krytyczne krwawienie
	if(!iscarbon(target) || source == target)
		return
	if(!prob(chance))
		return
	var/mob/living/carbon/carbon_target = target
	carbon_target.add_bleeding(BLEED_CRITICAL)
	carbon_target.visible_message(span_danger("Ostrze rozdziera ciało [carbon_target], otwierając krwawiącą ranę!"), span_userdanger("Ostrze rozdziera ci ciało, otwierając krwawiącą ranę!"))

/datum/heretic_knowledge/spell/caretaker_refuge
	name = "Caretaker's Last Refuge"
	desc = "Daje ci zaklęcie, które czyni cię przezroczystym i niematerialnym.<br>\
		Gdy działa, nie możesz używać rąk ani innych zaklęć, ale nic cię nie spowalnia. \
		Jesteś całkowicie nietykalny, ale nie możesz nikogo skrzywdzić."
	gain_text = "Zazdrośnie polowali na mnie Strażnik i Ogar. Lecz odryglowałem swoją postać i stałem się mgłą, nieuchwytną."
	action_to_add = /datum/action/cooldown/spell/caretaker
	cost = 2
	is_final_knowledge = TRUE
	max_charges = 3
	path_recharge_amount = 0.66
	holywater_drain_amount = 0.33
	notice = "&bull; Nie działa w pobliżu żywych, świadomych istot.<br>&bull; Przerywa je trafienie przedmiotem antymagicznym."

/datum/heretic_knowledge/spell/caretaker_refuge/has_charges(mob/living/user)
	return user.has_status_effect(/datum/status_effect/caretaker_refuge) || ..()

/datum/heretic_knowledge/spell/caretaker_refuge/should_deduct_charge(mob/living/user)
	return !user.has_status_effect(/datum/status_effect/caretaker_refuge)

/datum/heretic_knowledge/ultimate/lock_final
	name = "Unlock the Labyrinth"
	desc = "Rytuał wniebowstąpienia Ścieżki Zamka. \
		Po jego ukończeniu zyskasz zdolność przemiany w potężne istoty z innego świata, \
		a twoje ostrza-klucze staną się jeszcze groźniejsze. \
		Do tego w miejscu rytuału otworzysz rozdarcie do serca Labiryntu, \
		szczelinę w rzeczywistości, z której bez końca będą wylewać się \
		istoty posłuszne twoim rozkazom."
	transmute_text = "Przemień trzy zwłoki bez organów w klatce piersiowej."
	gain_text = "Zarządcy prowadzili mnie, a ja prowadziłem ich. \
		Moimi wrogami były Zamki, a moje ostrza były Kluczem! \
		Labirynt nie będzie już Zamknięty i wolność będzie nasza! BĄDŹCIE ŚWIADKAMI!"
	required_atoms = list(/mob/living/carbon/human = 3)
	ascension_achievement = /datum/award/achievement/misc/lock_ascension
	announcement_text = "Wykryto anomalię wymiarową klasy Delta%SPOOKY% Rzeczywistość rozdarta, porwana. Bramy otwarte, drzwi otwarte, %NAME% wstąpił! Lękajcie się fali! %SPOOKY%"
	announcement_sound = 'aquila/sound/music/antag/heretic/ascend_knock.ogg'

// AQUILA - warunek „bez organów w klatce” w is_valid_sacrifice, żeby runa liczyła tylko takie ciała
/datum/heretic_knowledge/ultimate/lock_final/is_valid_sacrifice(mob/living/carbon/human/sacrifice)
	. = ..()
	if(!.)
		return FALSE
	return !LAZYLEN(sacrifice.getorganszone(BODY_ZONE_CHEST))

/datum/heretic_knowledge/ultimate/lock_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	// buffs
	var/datum/action/cooldown/spell/shapeshift/eldritch/ascension/transform_spell = new(user.mind)
	transform_spell.Grant(user)

	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(user)
	var/datum/heretic_knowledge/blade_upgrade/flesh/lock/blade_upgrade = heretic_datum.get_knowledge(/datum/heretic_knowledge/blade_upgrade/flesh/lock)
	if(blade_upgrade)
		blade_upgrade.chance += 30
	new /obj/structure/lock_tear(loc, user.mind)
