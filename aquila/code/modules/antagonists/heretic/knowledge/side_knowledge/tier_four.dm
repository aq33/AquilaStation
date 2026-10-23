/*!
 * Tier 4 knowledge: Combat related knowledge
 */

/datum/heretic_knowledge/spell/space_phase
	name = "Space Phase"
	desc = "Daje Space Phase - zaklęcie, które pozwala swobodnie poruszać się w kosmosie.<br>\
		Wejść i wyjść z przenikania możesz tylko w kosmosie albo na otwartym, rozrzedzonym terenie na zewnątrz."
	gain_text = "Czujesz, że twoje ciało może przemierzać kosmos, jakby było pyłem."

	action_to_add = /datum/action/cooldown/spell/jaunt/space_crawl
	cost = 2
	research_tree_icon_frame = 6
	drafting_tier = 4
	max_charges = 2
	path_recharge_amount = 0.0
	holywater_drain_amount = 0.5
	transmute_text = "By odnowić ładunek, zmiażdż kryształ bluespace, stojąc przy runie."
	/// Tracks tim ein EVA
	var/seconds_in_eva = 0

/datum/heretic_knowledge/spell/space_phase/has_charges(mob/living/user)
	return HAS_TRAIT(user, TRAIT_MAGICALLY_PHASED) || ..()

/datum/heretic_knowledge/spell/space_phase/should_deduct_charge(mob/living/user)
	return !HAS_TRAIT(user, TRAIT_MAGICALLY_PHASED)

/datum/heretic_knowledge/spell/space_phase/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	RegisterSignal(user, COMSIG_MOB_CRUSHED_BLUESPACE_CRYSTAL, PROC_REF(on_crystal_crushed))

/datum/heretic_knowledge/spell/space_phase/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	UnregisterSignal(user, COMSIG_MOB_CRUSHED_BLUESPACE_CRYSTAL)

/datum/heretic_knowledge/spell/space_phase/proc/on_crystal_crushed(mob/living/source, obj/item/crystal)
	SIGNAL_HANDLER

	var/obj/effect/heretic_rune/rune = locate() in view(1, source)
	if(isnull(rune))
		return

	rune.ritual_animation()
	add_charges(1)

/datum/heretic_knowledge/unfathomable_curio
	name = "Unfathomable Curio"
	desc = "Wykonaj Niezgłębioną Osobliwość - \
		pas, który pomieści ostrza i przedmioty do rytuałów.<br>Noszony okrywa cię zasłoną, \
		która raz zablokuje cios, po czym znika. Zasłona odnawia się poza walką."
	transmute_text = "Transmutuj 3 pręty, płuca i dowolny pas."
	gain_text = "Mansus kryje wiele osobliwości, niektóre nie są przeznaczone dla śmiertelnych oczu."

	required_atoms = list(
		/obj/item/organ/lungs = 1,
		/obj/item/stack/rods = 3,
		/obj/item/storage/belt = 1,
	)
	result_atoms = list(/obj/item/storage/belt/unfathomable_curio)
	cost = 2
	research_tree_icon_path = 'icons/obj/clothing/belts.dmi'
	research_tree_icon_state = "unfathomable_curio"
	drafting_tier = 4

/datum/heretic_knowledge/rust_sower
	name = "Rust Sower Grenade"
	desc = "Wyczaruj przeklęty granat wypełniony Rdzą Eldritch.<br>Po wybuchu uwalnia wielką chmurę, która \
		oślepia istoty organiczne, rdzewieje teren i niszczy cyborgi i mechy."
	transmute_text = "Transmutuj obudowę granatu chemicznego i spleśniałe jedzenie."
	gain_text = "Zadławione pnącza Rdzawych Wzgórz uginają się pod takimi przejrzałymi owocami. Cofają znaki postępu, zostawiając czystą kartę, którą można ukształtować na nowo."
	required_atoms = list(
		list(
			/obj/item/food/breadslice/moldy,
			/obj/item/food/badrecipe/moldy,
			/obj/item/food/deadmouse/moldy,
			/obj/item/food/pizzaslice/moldy,
			/obj/item/food/boiledegg/rotten,
			/obj/item/food/egg/rotten
		) = 1,
		/obj/item/grenade/chem_grenade = 1
	)
	result_atoms = list(/obj/item/grenade/chem_grenade/rust_sower)
	cost = 2
	research_tree_icon_path = 'aquila/icons/obj/weapons/grenade.dmi'
	research_tree_icon_state = "rustgrenade"
	drafting_tier = 4

/datum/heretic_knowledge/crimson_cleave
	name = "The Crimson Cleaver"
	desc = "Pozwala wykuć Szkarłatny Tasak - straszliwą broń spragnioną krwi.<br>\
		Jego ciosy leczą cię o zadane obrażenia, a jednym zamachem tnie kilku wrogów naraz. \
		Nieźle sprawdza się też jako broń rzucana i wraca do ręki po rzucie."
	gain_text = "Na początku nie rozumiałem tych narzędzi wojny, ale Kapłan \
		kazał mi mimo to ich używać. Wkrótce, jak mówił, poznam je dobrze."
	transmute_text = "Transmutuj tasak rzeźniczy i trochę krwi - \
		kałużę albo krople, zakrwawioną szmatę albo bandaż, zlewkę albo fiolkę, a nawet sam tasak umazany krwią."
	required_atoms = list(
		/obj/item/kitchen/knife/butcher = 1,
	)
	result_atoms = list(/obj/item/kitchen/knife/butcher/heretic)
	banned_atom_types = list(/obj/item/kitchen/knife/butcher/heretic)
	cost = 2
	drafting_tier = 4
	research_tree_icon_path = 'aquila/icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "butch"

/datum/heretic_knowledge/crimson_cleave/prepare_atom_for_ritual_test(atom/what)
	. = ..()
	what.add_blood_DNA(list("Test DNA" = "O-"))

/datum/heretic_knowledge/crimson_cleave/get_extra_requirements()
	return "trochę krwi - kałuża albo krople, zakrwawiona szmata albo bandaż, zlewka albo fiolka, a nawet sam tasak umazany krwią"

/datum/heretic_knowledge/crimson_cleave/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	for(var/obj/item/kitchen/knife/butcher/cleaver in atoms)
		selected_atoms += cleaver
		if(length(cleaver.return_blood_DNA()))
			return TRUE // two for one deal
		break

	for(var/obj/effect/decal/cleanable/blood/blood in atoms)
		selected_atoms += blood // blood is blood
		return TRUE

	for(var/obj/item/reagent_containers/glass/rag/rag in atoms)
		if(length(rag.return_blood_DNA()))
			selected_atoms += rag
			return TRUE

	for(var/obj/item/stack/medical/gauze/medwrap in atoms)
		if(length(medwrap.return_blood_DNA()))
			selected_atoms += medwrap
			return TRUE

	for(var/obj/item/reagent_containers/container in atoms)
		if(!container.reagents)
			continue
		for(var/datum/reagent/reagent_content as anything in container.reagents.reagent_list)
			if(LAZYACCESS(reagent_content.data, BLOOD_DATA_DNA))
				selected_atoms += container
				return TRUE

	loc.balloon_alert(user, "rytuał nieudany, brak krwi!")
	to_chat(user, span_mansus("Do ukończenia rytuału \"[name]\" brakuje ci krwi."))
	return FALSE

/datum/heretic_knowledge/crimson_cleave/cleanup_atoms(list/selected_atoms)
	for(var/obj/item/reagent_containers/container in selected_atoms)
		if(container.reagents)
			for(var/datum/reagent/reagent_content as anything in container.reagents.reagent_list)
				if(LAZYACCESS(reagent_content.data, BLOOD_DATA_DNA))
					container.reagents.del_reagent(reagent_content.type)
		selected_atoms -= container

	for(var/obj/item/stack/medical/gauze/medwrap in selected_atoms)
		medwrap.use(1)
		selected_atoms -= medwrap

	return ..()

/datum/heretic_knowledge/rifle
	name = "Lionhunter's Rifle"
	desc = "Uwolnij Karabin Łowcy Lwów.<br>\
		Karabin Łowcy Lwów to dalekosiężna broń balistyczna na trzy naboje. \
		Z bliska albo w przedmioty strzela jak zwykła, choć słaba broń dużego kalibru. \
		Możesz jednak wycelować w odległego wroga - pocisk naznaczy ofiarę twoim Uchwytem i przeniesie cię prosto do niej."
	transmute_text = "Transmutuj kawałek drewna, skórę dowolnego zwierzęcia i aparat fotograficzny."
	gain_text = "W sklepie z antykami spotkałem starca, który władał bardzo nietypową bronią. \
		Nie mogłem jej wtedy kupić, ale pokazał mi, jak ją przed laty zrobił."
	required_atoms = list(
		/obj/item/stack/sheet/mineral/wood = 1,
		/obj/item/stack/sheet/animalhide = 1,
		/obj/item/camera = 1,
	)
	result_atoms = list(/obj/item/gun/ballistic/rifle/lionhunter)
	cost = 2
	research_tree_icon_path = 'aquila/icons/obj/weapons/guns/lionhunter.dmi'
	research_tree_icon_state = "lionhunter"
	drafting_tier = 2

/datum/heretic_knowledge/rifle_ammo
	name = "Lionhunter Rifle Ammunition"
	desc = "Stwórz dodatkową łódkę z amunicją do Karabinu Łowcy Lwów."
	transmute_text = "Transmutuj 3 łuski balistyczne (zużyte albo nie) dowolnego kalibru, także łuski śrutowe."
	gain_text = "Do broni dołączono trzy surowe żelazne kule jako amunicję. \
		Były bardzo skuteczne jak na zwykłe żelazo, ale szybko się kończyły. Wkrótce zabrakło mi ich. \
		Żadna inna amunicja ich nie zastąpiła. Ta broń była wybredna."
	required_atoms = list(
		/obj/item/ammo_casing = 3,
	)
	result_atoms = list(/obj/item/ammo_box/strilka310/lionhunter)
	cost = 0
	research_tree_icon_path = 'aquila/icons/obj/weapons/guns/ammo.dmi'
	research_tree_icon_state = "310_strip"

	/// A list of calibers that the ritual will deny. Only ballistic calibers are allowed.
	var/static/list/caliber_blacklist = list(
		"laser",
		"energy",
		"foam_force",
		"arrow",
		"mime",
		"harpoon",
		"hook",
	)

/datum/heretic_knowledge/rifle_ammo/pre_research(mob/user, datum/antagonist/heretic/our_heretic)
	if(!our_heretic.get_knowledge(/datum/heretic_knowledge/rifle))
		tgui_alert(user, "Zanim poznasz amunicję do Karabinu Łowcy Lwów, musisz poznać sam karabin.")
		return FALSE

	return TRUE

/datum/heretic_knowledge/rifle_ammo/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	for(var/obj/item/ammo_casing/casing in atoms)
		if(!(casing.caliber in caliber_blacklist) && !istype(casing, /obj/item/ammo_casing/energy))
			continue

		// Remove any casings in the caliber_blacklist list from atoms
		atoms -= casing
	// We removed any invalid casings from the atoms list,
	// return to allow the ritual to fill out selected atoms with the new list
	return TRUE
