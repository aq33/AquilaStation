/*!
 * Tier 1 knowledge: Stealth and general utility
 */

/datum/heretic_knowledge/void_cloak
	name = "Void Cloak"
	desc = "Uszyj Płaszcz Pustki.<br>Z opuszczonym kapturem chroni przed próżnią. \
		Z naciągniętym kapturem płaszcz staje się zupełnie niewidzialny.<br>Daje też przyzwoity pancerz i \
		ma kieszenie, które pomieszczą jedno z twoich ostrzy, różne składniki rytuałów (np. organy) i drobne heretyckie błyskotki."
	transmute_text = "Transmutuj odłamek szkła, prześcieradło i dowolne ubranie wierzchnie (np. pancerz albo marynarkę)."
	gain_text = "Sowa strzeże rzeczy, których w praktyce do końca nie ma, ale w teorii są. Wiele rzeczy takich jest."
	required_atoms = list(
		/obj/item/shard = 1,
		/obj/item/clothing/suit = 1,
		/obj/item/bedsheet = 1,
	)
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/void)
	cost = 1
	research_tree_icon_path = 'aquila/icons/obj/clothing/suits/armor.dmi'
	research_tree_icon_state = "void_cloak"
	drafting_tier = 1

/datum/heretic_knowledge/medallion
	name = "Ashen Eyes"
	desc = "Wyrzeźbij Medalion Eldritch.<br>\
		Noszony Medalion Eldritch daje widzenie termiczne."
	transmute_text = "Transmutuj parę oczu, świecę i odłamek szkła."
	gain_text = "Przenikliwe oczy prowadziły ich przez codzienność. Ani ciemność, ani groza nie mogły ich zatrzymać."
	required_atoms = list(
		/obj/item/organ/eyes = 1,
		/obj/item/shard = 1,
		/obj/item/candle = 1,
	)
	result_atoms = list(/obj/item/clothing/neck/eldritch_amulet)
	cost = 1
	research_tree_icon_path = 'aquila/icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "eye_medalion"
	drafting_tier = 1

/datum/heretic_knowledge/essence // AKA Eldritch Flask
	name = "Priest's Ritual"
	desc = "Napełnij flaszkę Esencją Eldritch.<br>\
		Esencja Eldritch po wypiciu silnie leczy, a podana poganom ciężko ich zatruwa."
	transmute_text = "Transmutuj zbiornik z wodą i odłamek szkła."
	gain_text = "To stary przepis. Wyszeptała mi go Sowa. \
		Stworzony przez Kapłana - Płyn, który jednocześnie był i go nie ma."
	required_atoms = list(
		/obj/structure/reagent_dispensers/watertank = 1,
		/obj/item/shard = 1,
	)
	result_atoms = list(/obj/item/reagent_containers/glass/beaker/eldritch)
	cost = 1
	research_tree_icon_path = 'aquila/icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "eldritch_flask"
	drafting_tier = 1

/datum/heretic_knowledge/phylactery
	name = "Phylactery of Damnation"
	desc = "Stwórz Filakterium, które w mgnieniu oka pobiera krew, nawet z dużej odległości."
	transmute_text = "Transmutuj arkusz szkła i mak."
	gain_text = "Nalewka wykręcona w kształt krwiopijczego robactwa. \
		Czy sama wybrała ten kształt, czy to żart chorego umysłu, który wezwał to plugawe narzędzie, lepiej się nie zastanawiać."
	required_atoms = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/food/grown/poppy = 1,
	)
	result_atoms = list(/obj/item/reagent_containers/glass/phylactery)
	cost = 1
	research_tree_icon_path = 'aquila/icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "phylactery_2"
	drafting_tier = 1
	notice = "Cel Filakterium może poczuć ukłucie."

/datum/heretic_knowledge/crucible
	name = "Mawed Crucible"
	desc = "Stwórz Paszczowy Tygiel.<br>\
		Paszczowy Tygiel warzy potężne, ale krótkotrwałe mikstury do walki i nie tylko. Między użyciami trzeba go karmić częściami ciała i organami. \
		<br>&bull; Wywar Duszy Tygla: pozwala przechodzić przez ściany. Po wygaśnięciu wracasz tam, gdzie go wypiłeś. \
		<br>&bull; Wywar Zmierzchu i Świtu: pozwala widzieć przez ściany. \
		<br>&bull; Wywar Rannego Żołnierza: leczy z czasem. Im cięższe obrażenia i krwawienie, tym szybciej leczy."
	transmute_text = "Transmutuj przenośny zbiornik z wodą i stół."
	gain_text = "To czysta agonia. Nie zdołałem przywołać postaci Arystokraty, \
		ale dzięki uwadze Kapłana natknąłem się na inny przepis..."
	required_atoms = list(
		/obj/structure/reagent_dispensers/watertank = 1,
		/obj/structure/table = 1,
	)
	result_atoms = list(/obj/structure/destructible/eldritch_crucible)
	cost = 1
	research_tree_icon_path = 'aquila/icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "crucible"
	drafting_tier = 1

/datum/heretic_knowledge/eldritch_coin
	name = "Eldritch Coin"
	desc = "Stwórz Monetę Eldritch.<br>\
		Podrzuć monetę. Gdy wypadnie orzeł, pobliskie śluzy się otworzą albo zamkną. Gdy wypadnie reszka, pobliskie śluzy zostaną zaryglowane w obecnym stanie albo odryglowane.<br>\
		Jeśli wciśniesz monetę w śluzę, przepadnie, ale przepali jej elektronikę - śluza zostanie zaryglowana otwarta albo zamknięta, dopóki ktoś jej nie naprawi."
	transmute_text = "Transmutuj arkusz plazmy i diament."
	gain_text = "Mansus jest miejscem wszelkich grzechów. Ale chciwość miała w nim szczególną rolę."
	required_atoms = list(
		/obj/item/stack/sheet/mineral/diamond = 1,
		/obj/item/stack/sheet/mineral/plasma = 1,
	)
	result_atoms = list(/obj/item/coin/eldritch)
	cost = 1
	research_tree_icon_path = 'aquila/icons/obj/eldritch_coin.dmi'
	research_tree_icon_state = "coin_heretic"
	drafting_tier = 1

/**
 * This allows heretics to choose if they want to rush all the influences and take them stealthily, or
 * Construct a codex and take what's left with more points.
 * Another downside to having the book is strip searches, which means that it's not just a free nab, at least until you get exposed - and when you do, you'll probably need the faster drawing speed.
 * Overall, it's a tradeoff between speed and stealth or power.
 */
/datum/heretic_knowledge/codex_cicatrix
	name = "Codex Cicatrix"
	desc = "Spisz Codex Cicatrix.<br>\
		Codex Cicatrix użyty przy wysysaniu wpływów daje dodatkową wiedzę, ale łatwiej wtedy zostać zauważonym.<br>\
		Ułatwia też rysowanie i usuwanie run transmutacji, a otwarty przywraca ładunki Uchwytu Mansusa."
	transmute_text = "Transmutuj książkę, dowolny długopis i coś na oprawę: skórę albo zwłoki (zwierzęcia lub człowieka)."
	gain_text = "Okultyzm zostawia okruchy wiedzy i mocy wszędzie. Codex Cicatrix jest jednym z przykładów. \
		W skórzanych okładkach i wiekowych stronicach odsłania się ścieżka do Mansusa."
	required_atoms = list(
		list(/obj/item/toy/eldritch_book, /obj/item/book) = 1,
		/obj/item/pen = 1,
		list(/mob/living, /obj/item/stack/sheet/leather, /obj/item/stack/sheet/animalhide, /obj/item/food/deadmouse) = 1,
	)
	result_atoms = list(/obj/item/codex_cicatrix)
	cost = 1
	drafting_tier = 1
	is_shop_only = TRUE
	research_tree_icon_path = 'aquila/icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "book"

	var/static/list/non_mob_bindings = typecacheof(list(
		/obj/item/stack/sheet/leather,
		/obj/item/stack/sheet/animalhide,
		/obj/item/food/deadmouse,
	))

/datum/heretic_knowledge/codex_cicatrix/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	if(!.)
		return FALSE

	for(var/thingy in atoms)
		if(is_type_in_typecache(thingy, non_mob_bindings))
			selected_atoms += thingy
			return TRUE
		else if(isliving(thingy))
			var/mob/living/body = thingy
			if(body.stat != DEAD)
				continue
			selected_atoms += body
			return TRUE
	return FALSE

/datum/heretic_knowledge/codex_cicatrix/cleanup_atoms(list/selected_atoms)
	var/mob/living/body = locate() in selected_atoms
	if(!body)
		return ..()
	// A golem or an android doesn't have skin!
	var/exterior_text = "skórę"
	// If carbon, it's the limb. If not, it's the body.
	var/atom/movable/ripped_thing = body

	// We will check if it's a carbon's body.
	// If it is, we will damage a random bodypart, and check that bodypart for its body type, to select between 'skin' or 'exterior'.
	if(iscarbon(body))
		var/mob/living/carbon/carbody = body
		var/obj/item/bodypart/bodypart = pick(carbody.get_bodyparts())
		ripped_thing = bodypart

		carbody.apply_damage(25, BRUTE, bodypart)
		if(!(bodypart.bodytype & BODYTYPE_ORGANIC))
			exterior_text = "powłokę"
	else
		body.apply_damage(25, BRUTE)
		// If it is not a carbon mob, we will just check biotypes and damage it directly.
		if(body.mob_biotypes & MOB_ROBOTIC)
			exterior_text = "powłokę"

	// Procure book for flavor text. This is why we call parent at the end.
	var/obj/item/le_book = locate(/obj/item/book) in selected_atoms
	if(!le_book)
		le_book = locate(/obj/item/toy/eldritch_book) in selected_atoms
	if(!le_book)
		stack_trace("Somehow, no book in codex cicatrix selected atoms! [english_list(selected_atoms)]")
	playsound(body, 'sound/items/poster_ripped.ogg', 100, TRUE)
	body.do_jitter_animation()
	body.visible_message(span_danger("Rozlega się okropny dźwięk rozdzierania - [ripped_thing] traci [exterior_text], która owija się wokół [le_book || "książki"] i przybiera upiorny odcień błękitu!"))
	return ..()

/**
 * Warren King's Welcome
 * Offers an alternative way besides stealing an ID or visiting the HoP to gain access to maintenance
 * Additionally changes all nearby airlock's access's to ACCESS_HERETIC
 */
/datum/heretic_knowledge/bookworm
	name = "Warren King's Welcome"
	desc = "Napiętnuj wszystkie obecne karty identyfikacyjne i pobliskie śluzy.<br>\
		Napiętnowane karty dostają dostęp do tuneli technicznych, śluz zewnętrznych i napiętnowanych śluz.<br>\
		Napiętnowane śluzy przepuszczą tylko posiadaczy napiętnowanych kart."
	transmute_text = "Transmutuj 10 odcinków kabla, kartkę papieru i multitool."
	gain_text = "Wgryzione w poplamione kości palców, moje ponure zaproszenie ciągnie mój mdlący, zamglony umysł ku ciężkim drzwiom. \
		Światło powoli tańczy w pełzającej ciemności, okrywając cuchnący deptak nieskończonymi machinacjami. \
		Lecz Król wkrótce weźmie swój funt mięsa. Nawet tu poborca bierze swoją dolę. Bo tysiące ust czekają na strawę."
	required_atoms = list(
		/obj/item/stack/cable_coil = 10,
		/obj/item/paper = 1,
		/obj/item/multitool = 1,
	)
	cost = 1
	drafting_tier = 1
	research_tree_icon_path = 'icons/obj/card.dmi'
	research_tree_icon_state = "centcom"

/datum/heretic_knowledge/bookworm/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	for(var/obj/item/card/id/used_id in atoms)
		selected_atoms += used_id
	var/obj/item/card/id/user_card = user.get_idcard(TRUE)
	if(user_card)
		selected_atoms |= user_card

/datum/heretic_knowledge/bookworm/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	for(var/obj/item/card/id/improved_id in selected_atoms)
		improved_id.access |= list(ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_HERETIC)
		selected_atoms -= improved_id
	for(var/obj/machinery/door/airlock/door in view(7, loc))
		door.req_one_access = null
		door.req_access = list(ACCESS_HERETIC)
		door.wires?.cut(WIRE_AI)
		new /obj/effect/temp_visual/eldritch_sparks(door.loc)
		var/obj/effect/light_emitter/light = new(door.loc)
		light.set_light(1.75, 1.5, COLOR_PUCE)
		QDEL_IN(light, 1 SECONDS)
		playsound(door, 'sound/effects/magic.ogg', 20, TRUE, SILENCED_SOUND_EXTRARANGE, ignore_walls = FALSE)
		playsound(door, "sparks", 33, TRUE, SILENCED_SOUND_EXTRARANGE, ignore_walls = FALSE)

	return TRUE

/**
 * Allows the heretic to craft a spell focus, which passively regenerates some spell charges
 */
/datum/heretic_knowledge/amber_focus
	name = "Amber Focus"
	desc = "Wyrzeźbij Bursztynowe Skupienie.<br>\
		Noszone co kilka minut odnawia część ładunków zaklęć (poza kilkoma wyjątkowymi zaklęciami)."
	transmute_text = "Transmutuj arkusz szkła i parę oczu."
	gain_text = "Czułem się zagubiony i bez celu. Wszystko, czego próbowałem się uchwycić, przeciekało mi przez palce. \
		Potrzebowałem czegoś, czego mogę się trzymać, na czym mogę się skupić, co nie pozwoli mi za bardzo zboczyć ze ścieżki."
	required_atoms = list(
		/obj/item/organ/eyes = 1,
		/obj/item/stack/sheet/glass = 1,
	)
	result_atoms = list(/obj/item/clothing/neck/heretic_focus)
	cost = 1
	drafting_tier = 1
	research_tree_icon_path = 'icons/obj/clothing/neck.dmi'
	research_tree_icon_state = "eldritch_necklace"

/datum/heretic_knowledge/miraculous_mirror
	name = "Miraculous Mirror"
	desc = "Wykonaj Cudowne Lustro.<br>\
		Cudowne Lustro pozwala dowolnie zmieniać każdy aspekt twojego wyglądu. \
		Możesz też zmienić w nim gatunek, ale lustro wtedy pęknie. \
		Każdy inny, kto w nie spojrzy, wpadnie w trans, a lustro losowo coś w nim zmieni."
	transmute_text = "Transmutuj pięć sztabek srebra i parę organicznych oczu."
	gain_text = "Byłem niedoskonały, słaby. Jak mogłem osiągnąć wielkie rzeczy w tak żałosnym stanie? \
		W każdym mijanym oknie widziałem swoje odbicie i za każdym razem czułem palące pragnienie, by się zmienić, być lepszym, zacząć od nowa."
	required_atoms = list(
		/obj/item/organ/eyes = 1,
		/obj/item/stack/sheet/mineral/silver = 5,
	)
	result_atoms = list(/obj/item/wallframe/mirror/heretic)
	cost = 1
	drafting_tier = 1
	research_tree_icon_path = 'icons/obj/watercloset.dmi'
	research_tree_icon_state = "magic_mirror"
	is_shop_only = TRUE

/datum/heretic_knowledge/miraculous_mirror/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	for(var/obj/item/organ/eyes/eye in atoms)
		if(eye.organ_flags & ORGAN_SYNTHETIC)
			atoms -= eye

/datum/heretic_knowledge/spell/cloak_of_shadows
	name = "Cloak of Shadow"
	desc = "Daje zaklęcie Cloak of Shadow.<br>\
		Na trzy minuty całkowicie ukrywa twoją tożsamość w fioletowym dymie, pomagając zachować tajemnicę."
	notice = "Można je rzucić tylko, gdy masz Żywe Serce."
	action_to_add = /datum/action/cooldown/spell/shadow_cloak
	cost = 1
	drafting_tier = 1
	max_charges = INFINITY
	is_shop_only = TRUE // not actually but it's got special requirements

/datum/heretic_knowledge/spell/cloak_of_shadows/spell_check(datum/action/the_spell, feedback)
	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(the_spell.owner)
	if(heretic_datum?.has_living_heart())
		return ..()

	if(feedback)
		to_chat(the_spell.owner, span_mansus("Do rzucenia [the_spell] potrzebujesz Żywego Serca!"))
	return SPELL_CANCEL_CAST

/datum/heretic_knowledge/lodestone
	name = "Rhythmic Lodestone"
	desc = "Wszczep przedmiotowi Magnetyt.<br>\
		Magnetyt bije w rytm twojego Żywego Serca, dzięki czemu możesz go namierzyć z każdej odległości - dopóki nie zostanie zniszczony."
	transmute_text = "Transmutuj GPS i do trzech dowolnych przedmiotów."
	gain_text = "Zgubiłem się. Nikt nie twierdził, że poruszanie się po Mansusie jest proste. \
		Musiałem odnaleźć swój środek. Skupić się. Wsłuchać się w bicie serca."
	notice = "Naraz można nasycić do trzech przedmiotów. Pierwszeństwo mają kosztowności, ekwipunek i broń."
	required_atoms = list(
		/obj/item/gps = 1,
	)
	cost = 1
	drafting_tier = 1
	is_shop_only = TRUE
	research_tree_icon_path = 'icons/obj/telescience.dmi'
	research_tree_icon_state = "gps-c"

/datum/heretic_knowledge/lodestone/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	for(var/obj/whatever in atoms)
		if(istype(whatever, /obj/item/gps) || whatever.anchored)
			continue
		selected_atoms += whatever

	if(!length(selected_atoms))
		loc.balloon_alert(user, "brak przedmiotów do nasycenia!")
		return FALSE
	return TRUE

/datum/heretic_knowledge/lodestone/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/lodestones_created = 0

	var/list/valuable_pool = list()
	var/list/equipment_pool = list()
	var/list/weapon_pool = list()
	var/list/item_pool = list()
	var/list/leftover_pool = list()
	for(var/obj/new_trackable in selected_atoms)
		if(istype(new_trackable, /obj/item/gps))
			continue

		if(new_trackable.resistance_flags & INDESTRUCTIBLE)
			valuable_pool += new_trackable
		if(isitem(new_trackable))
			var/obj/item/trackable_item = new_trackable
			if(isclothing(trackable_item) || trackable_item.slot_flags)
				equipment_pool += new_trackable
			item_pool += new_trackable
		if(new_trackable.force >= 15 || isgun(new_trackable))
			weapon_pool += new_trackable
		leftover_pool += new_trackable

	// Valuable items first, then clothing items (so you can track people wearing them), then weapons (stuff you probably want), then random items
	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(user)
	for(var/obj/new_trackable as anything in valuable_pool | equipment_pool | weapon_pool | item_pool | leftover_pool)
		LAZYADD(heretic_datum.tracked_items, WEAKREF(new_trackable))
		to_chat(user, span_mansus("Czujesz, jak nowy magnetyt w [new_trackable] zaczyna bić w rytm twojego serca."))
		lodestones_created += 1
		if(lodestones_created >= 3)
			break

	return lodestones_created >= 1

/datum/heretic_knowledge/lodestone/cleanup_atoms(list/selected_atoms)
	qdel(locate(/obj/item/gps) in selected_atoms)
	selected_atoms.Cut() // ASSUMING DIRECT CONTROL
	return ..()

/datum/heretic_knowledge/blessed_poppy
	name = "Blessed Poppy"
	desc = "Wyhoduj Błogosławiony Mak.<br>\
		Błogosławiony Mak przyłożony do zranionej kończyny z czasem ją leczy i tamuje krwawienie. \
		Noszony na głowie stabilizuje też osoby w stanie krytycznym. \
		Każde użycie z czasem wysysa z maku moc, aż w końcu uschnie."
	transmute_text = "Transmutuj mak i co najmniej cztery bandaże."
	gain_text = "\"Na polach Flandrii kwitną maki \
		/ Wśród krzyży, rząd za rzędem stoją, \
		/ Znacząc nasz grób; a w niebie wzwyż \
		/ Skowronki wciąż odważnie śpiewają, \
		/ Ledwie słyszalne wśród huku dział.\"\
	"
	required_atoms = list(
		/obj/item/food/grown/poppy = 1,
		/obj/item/stack/medical/gauze = 4,
	)
	result_atoms = list(/obj/item/food/grown/poppy/blessed)
	cost = 1
	drafting_tier = 1
	is_shop_only = TRUE
	research_tree_icon_path = 'icons/obj/hydroponics/harvest.dmi'
	research_tree_icon_state = "poppy"
