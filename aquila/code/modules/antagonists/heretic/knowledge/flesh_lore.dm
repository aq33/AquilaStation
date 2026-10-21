/datum/heretic_knowledge_tree_column/flesh
	route = PATH_FLESH
	ui_bgr = "node_flesh"
	complexity = "Różnie"
	complexity_color = COLOR_ORANGE
	icon = list(
		"icon" = 'aquila/icons/obj/weapons/khopesh.dmi',
		"state" = "flesh_blade",
		"frame" = 1,
		"dir" = SOUTH,
		"moving" = FALSE,
	)
	description = list(
		"Ścieżka Ciała polega na przywoływaniu ghuli i potworów, które wykonują twoje rozkazy.",
		"Wybierz ją, jeśli lubisz być nekromantą dowodzącym legionami sług.",
	)
	pros = list(
		"Może zamieniać martwych humanoidów w kruche, ale lojalne ghule.",
		"Dostęp do różnorodnych przywołanych sług.",
		"Twoje sługi są bardzo wszechstronne i przy dobrej koordynacji szybko przytłaczają załogę.",
		"Jedzenie organów albo bycie grubym daje różne korzyści (zależnie od poziomu pasywki).",
	)
	cons = list(
		"Duża część rozwoju to zdobywanie kolejnych przywołanych potworów.",
		"Poza przywołanymi potworami masz bardzo mało użyteczności.",
		"Nie dostajesz z góry żadnych zaklęć obronnych, ofensywnych ani ruchu.",
		"Skupiasz się głównie na wspieraniu swoich sług.",
	)
	tips = list(
		"Twój Mansus Grasp zamienia martwych humanoidów w ghule (nawet z implantem mindshield, jak ochrona czy kapitan). Nakłada też znak, który po aktywacji krwawym ostrzem powoduje silne krwawienie.",
		"Jako heretyk Ciała kochasz organy i zwłoki! Przydają się do rytuałów, leczenia i wzmocnień.",
		"Zaklęcie Knit Flesh leczy twoje przywołańce. Twoja szata daje aurę, która też leczy pobliskie przywołańce (ale nie ciebie).",
		"Knit Flesh pozwala też kraść organy humanoidom. Przyda się, gdy potrzebujesz zapasowej wątroby.",
		"Raw Prophet może połączyć ciebie i inne przywołańce w sieć telepatyczną do koordynacji na odległość.",
		"Flesh Stalker to niezły wojownik, który potrafi udawać małe stworzenia, np. beepsky'ego albo corgi. Ma też zaklęcie EMP, które może go zranić, jeśli zmienił się w robota!",
		"Twój sukces zależy od tego, jak doświadczone są twoje sługi. Liczebność zawsze jednak daje siłę - im więcej sług, tym większe szanse.",
		"Twoje sługi są bardziej zbędne niż ty. Nie bój się posyłać ich na śmierć. Najwyżej później je odzyskasz... może.",
	)

	start = /datum/heretic_knowledge/limited_amount/starting/base_flesh
	knowledge_tier1 = /datum/heretic_knowledge/limited_amount/flesh_ghoul
	guaranteed_side_tier1 = /datum/heretic_knowledge/limited_amount/risen_corpse
	knowledge_tier2 = /datum/heretic_knowledge/spell/flesh_surgery
	guaranteed_side_tier2 = /datum/heretic_knowledge/crucible
	robes = /datum/heretic_knowledge/armor/flesh
	knowledge_tier3 = /datum/heretic_knowledge/summon/raw_prophet
	guaranteed_side_tier3 = /datum/heretic_knowledge/crimson_cleave
	blade = /datum/heretic_knowledge/blade_upgrade/flesh
	knowledge_tier4 = /datum/heretic_knowledge/summon/stalker
	ascension = /datum/heretic_knowledge/ultimate/flesh_final

/datum/heretic_knowledge/limited_amount/starting/base_flesh
	name = "Principle of Hunger"
	desc = "Otwiera przed tobą Ścieżkę Ciała.<br>\
		Pozwala tworzyć Bloody Blade. \
		Naraz możesz mieć tylko trzy."
	transmute_text = "Przemień nóż i kałużę krwi."
	gain_text = "Setki z nas głodowały, ale nie ja... W chciwości znalazłem siłę."
	required_atoms = list(
		/obj/item/kitchen/knife = 1,
		/obj/effect/decal/cleanable/blood = 1,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/flesh)
	limit = 3 // Bumped up so they can arm up their ghouls too.
	research_tree_icon_path = 'aquila/icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "flesh_blade"
	mark_type = /datum/status_effect/eldritch/flesh
	eldritch_passive = /datum/status_effect/heretic_passive/flesh

/datum/heretic_knowledge/limited_amount/starting/base_flesh/on_research(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	var/datum/objective/heretic_summon/summon_objective = new()
	summon_objective.owner = our_heretic.owner
	our_heretic.objectives += summon_objective

	to_chat(user, span_mansus("Wkraczając na Ścieżkę Ciała, otrzymujesz kolejny cel."))
	our_heretic.owner.announce_objectives()

/datum/heretic_knowledge/limited_amount/starting/base_flesh/on_mansus_grasp(mob/living/source, mob/living/target)
	. = ..()

	if(target.stat != DEAD)
		return

	if(LAZYLEN(created_items) >= limit)
		target.balloon_alert(source, "limit ghuli!")
		return COMPONENT_BLOCK_HAND_USE

	if(HAS_TRAIT(target, TRAIT_HUSK))
		target.balloon_alert(source, "zwęglone!")
		return COMPONENT_BLOCK_HAND_USE

	if(!IS_VALID_GHOUL_MOB(target))
		target.balloon_alert(source, "nieprawidłowe ciało!")
		return COMPONENT_BLOCK_HAND_USE

	target.grab_ghost()

	// The grab failed, so they're mindless or playerless. We can't continue
	if(!target.mind || !target.client)
		target.balloon_alert(source, "brak duszy!")
		return COMPONENT_BLOCK_HAND_USE

	make_ghoul(source, target)

/// The max amount of health a ghoul has.
#define GHOUL_MAX_HEALTH 25

/// Makes [victim] into a ghoul.
/datum/heretic_knowledge/limited_amount/starting/base_flesh/proc/make_ghoul(mob/living/user, mob/living/carbon/human/victim)
	user.log_message("created a ghoul, controlled by [key_name(victim)].", LOG_GAME)
	message_admins("[ADMIN_LOOKUPFLW(user)] created a ghoul, [ADMIN_LOOKUPFLW(victim)].")

	victim.apply_status_effect(
		/datum/status_effect/ghoul,
		GHOUL_MAX_HEALTH,
		user.mind,
		CALLBACK(src, PROC_REF(apply_to_ghoul)),
		CALLBACK(src, PROC_REF(remove_from_ghoul)),
	)

/// Callback for the ghoul status effect - Tracking all of our ghouls
/datum/heretic_knowledge/limited_amount/starting/base_flesh/proc/apply_to_ghoul(mob/living/ghoul)
	LAZYADD(created_items, WEAKREF(ghoul))

/// Callback for the ghoul status effect - Tracking all of our ghouls
/datum/heretic_knowledge/limited_amount/starting/base_flesh/proc/remove_from_ghoul(mob/living/ghoul)
	LAZYREMOVE(created_items, WEAKREF(ghoul))

/datum/heretic_knowledge/limited_amount/flesh_ghoul
	name = "Imperfect Ritual"
	desc = "Zamień zwłoki w Voiceless Dead. \
		Zwłoki nie muszą mieć duszy.<br>\
		Voiceless Dead to nieme ghule z zaledwie 50 punktami zdrowia, ale potrafią skutecznie walczyć Bloody Blade. \
		Naraz możesz mieć tylko dwóch."
	transmute_text = "Przemień zwłoki i mak."
	gain_text = "Znalazłem zapiski mrocznego rytuału, niedokończone... a jednak parłem naprzód."
	// AQUILA - mak z tg (food/grown/flower/poppy) to u nas food/grown/poppy
	required_atoms = list(
		/mob/living/carbon/human = 1,
		/obj/item/food/grown/poppy = 1,
	)
	limit = 2
	cost = 2
	research_tree_icon_path = 'aquila/icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "ghoul_voiceless"

/datum/heretic_knowledge/limited_amount/flesh_ghoul/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	if(!.)
		return FALSE

	for(var/mob/living/carbon/human/body in atoms)
		if(body.stat != DEAD)
			continue
		if(!IS_VALID_GHOUL_MOB(body) || HAS_TRAIT(body, TRAIT_HUSK))
			to_chat(user, span_hierophant_warning("[body] nie nadaje się na ghula."))
			continue

		// We'll select any valid bodies here. If they're clientless, we'll give them a new one.
		selected_atoms += body
		return TRUE

	loc.balloon_alert(user, "rytuał nieudany, brak ciała!")
	return FALSE

/datum/heretic_knowledge/limited_amount/flesh_ghoul/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/mob/living/carbon/human/soon_to_be_ghoul = locate() in selected_atoms
	if(QDELETED(soon_to_be_ghoul)) // No body? No ritual
		stack_trace("[type] reached on_finished_recipe without a human in selected_atoms to make a ghoul out of.")
		loc.balloon_alert(user, "rytuał nieudany, brak ciała!")
		return FALSE

	soon_to_be_ghoul.grab_ghost()

	if(!soon_to_be_ghoul.mind || !soon_to_be_ghoul.client)
		message_admins("[ADMIN_LOOKUPFLW(user)] is creating a voiceless dead of a body with no player.")
		// AQUILA - u nas zamiast SSpolling stare pollCandidatesForMob
		var/list/mob/dead/observer/candidates = pollCandidatesForMob("Chcesz zagrać jako [soon_to_be_ghoul.real_name], niemy umarły (voiceless dead)?", ROLE_HERETIC, ROLE_HERETIC, 5 SECONDS, soon_to_be_ghoul)
		if(!LAZYLEN(candidates))
			loc.balloon_alert(user, "rytuał nieudany, brak duchów!")
			return FALSE
		var/mob/dead/observer/chosen_one = pick(candidates)
		message_admins("[key_name_admin(chosen_one)] has taken control of ([key_name_admin(soon_to_be_ghoul)]) to replace an AFK player.")
		soon_to_be_ghoul.ghostize(FALSE)
		soon_to_be_ghoul.key = chosen_one.key

	selected_atoms -= soon_to_be_ghoul
	make_ghoul(user, soon_to_be_ghoul)
	return TRUE

/// The max amount of health a voiceless dead has.
#define MUTE_MAX_HEALTH 50

/// Makes [victim] into a ghoul.
/datum/heretic_knowledge/limited_amount/flesh_ghoul/proc/make_ghoul(mob/living/user, mob/living/carbon/human/victim)
	user.log_message("created a voiceless dead, controlled by [key_name(victim)].", LOG_GAME)
	message_admins("[ADMIN_LOOKUPFLW(user)] created a voiceless dead, [ADMIN_LOOKUPFLW(victim)].")

	victim.apply_status_effect(
		/datum/status_effect/ghoul,
		MUTE_MAX_HEALTH,
		user.mind,
		CALLBACK(src, PROC_REF(apply_to_ghoul)),
		CALLBACK(src, PROC_REF(remove_from_ghoul)),
	)

/// Callback for the ghoul status effect - Tracks all of our ghouls and applies effects
/datum/heretic_knowledge/limited_amount/flesh_ghoul/proc/apply_to_ghoul(mob/living/ghoul)
	LAZYADD(created_items, WEAKREF(ghoul))
	ADD_TRAIT(ghoul, TRAIT_MUTE, MAGIC_TRAIT)

/// Callback for the ghoul status effect - Tracks all of our ghouls and applies effects
/datum/heretic_knowledge/limited_amount/flesh_ghoul/proc/remove_from_ghoul(mob/living/ghoul)
	LAZYREMOVE(created_items, WEAKREF(ghoul))
	REMOVE_TRAIT(ghoul, TRAIT_MUTE, MAGIC_TRAIT)

/datum/heretic_knowledge/spell/flesh_surgery
	name = "Knitting of Flesh"
	desc = "Daje ci zaklęcie Knit Flesh.<br>Pozwala wyjmować organy ofiarom \
		bez długiej operacji.<br>Trwa to znacznie dłużej, jeśli cel nie jest martwy.<br>\
		Zaklęcie leczy też twoje sługi i przywołańce oraz przywraca niewydolne organy do znośnego stanu."
	gain_text = "Ale nie pozostali długo poza moim zasięgiem. Z każdym krokiem krzyki narastały, aż w końcu \
		nauczyłem się je uciszać."
	action_to_add = /datum/action/cooldown/spell/touch/flesh_surgery
	cost = 2
	drafting_tier = 5
	max_charges = INFINITY

/datum/heretic_knowledge/armor/flesh
	desc = "Stwórz Writhing Embrace.<br>\
		Pozwala rozpoznać stan zdrowia innych żywych (i nieżywych) \
		i daje aurę, która powoli leczy twoje przywołańce."
	transmute_text = "Przemień stół (albo strój), maskę i kałużę krwi."
	gain_text = "Owinąłem się tymi nędznymi, pełzającymi rzeczami jak ciepłym kocem. \
		Oczami-nie-moimi będą patrzeć. Zębami-nie-moimi będą kąsać. Kończynami-nie-moimi będą łamać."
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch/flesh)
	research_tree_icon_state = "flesh_armor"
	required_atoms = list(
		list(/obj/structure/table, /obj/item/clothing/suit) = 1,
		/obj/item/clothing/mask = 1,
		/obj/effect/decal/cleanable/blood = 1,
	)

/datum/heretic_knowledge/summon/raw_prophet
	name = "Raw Ritual"
	desc = "Przywołaj Raw Prophet.<br>\
		Raw Prophet ma znacznie większy zasięg wzroku i widzi przez ściany, potrafi przenikać na duże odległości \
		i łączyć umysły, by łatwo się porozumiewać, ale jest bardzo kruchy i słaby w walce."
	transmute_text = "Przemień parę oczu, lewą rękę i kałużę krwi."
	gain_text = "Nie mogłem iść dalej sam. Zdołałem przywołać Niesamowitego Człowieka, by pomógł mi widzieć więcej. \
		Krzyki... niegdyś nieustanne, teraz uciszone ich nędznym wyglądem. Nic nie było poza zasięgiem."
	required_atoms = list(
		/obj/item/organ/eyes = 1,
		/obj/effect/decal/cleanable/blood = 1,
		/obj/item/bodypart/l_arm = 1,
	)
	mob_to_summon = /mob/living/simple_animal/hostile/heretic_summon/raw_prophet
	cost = 2
	poll_ignore_define = POLL_IGNORE_RAW_PROPHET


/datum/heretic_knowledge/blade_upgrade/flesh
	name = "Bleeding Steel"
	desc = "Twój Bloody Blade wywołuje u wrogów silne krwawienie przy każdym ciosie."
	gain_text = "Niesamowity Człowiek nie był sam. Zaprowadził mnie do Marszałka. \
		Wreszcie zacząłem rozumieć. A potem z nieba spadł deszcz krwi."
	research_tree_icon_path = 'aquila/icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_flesh"
	// AQUILA - ran z tg (/datum/wound) u nas nie ma; ciężka rana cięta to u nas silne krwawienie
	/// How heavy is the bleeding we apply on hit
	var/bleed_level = BLEED_DEEP_WOUND

/datum/heretic_knowledge/blade_upgrade/flesh/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(!iscarbon(target) || source == target)
		return

	var/mob/living/carbon/carbon_target = target
	carbon_target.add_bleeding(bleed_level)

/datum/heretic_knowledge/summon/stalker
	name = "Lonely Ritual"
	desc = "Przywołaj Stalkera.<br>\
		Stalker potrafi przenikać, wywoływać EMP, zmieniać się w zwierzęta albo automaty i jest silny w walce."
	transmute_text = "Przemień dowolny ogon, żołądek, język, długopis i kartkę papieru."
	gain_text = "Połączyłem chciwość i pragnienia, by przywołać pradawną bestię, jakiej nigdy wcześniej nie widziałem. \
		Wiecznie zmieniająca kształt masa ciała dobrze znała moje cele. Marszałek był zadowolony."

	required_atoms = list(
		/obj/item/organ/tail = 1,
		/obj/item/organ/stomach = 1,
		/obj/item/organ/tongue = 1,
		/obj/item/pen = 1,
		/obj/item/paper = 1,
	)
	mob_to_summon = /mob/living/simple_animal/hostile/heretic_summon/stalker
	cost = 2

	poll_ignore_define = POLL_IGNORE_STALKER
	is_final_knowledge = TRUE

/datum/heretic_knowledge/ultimate/flesh_final
	name = "Priest's Final Hymn"
	desc = "Rytuał wniebowstąpienia Ścieżki Ciała.<br>\
		Po jego ukończeniu możesz zrzucić ludzką postać \
		i stać się Panem Nocy, niezwykle potężną istotą. \
		Już sama przemiana wywołuje u pobliskich pogan ogromny strach i traumę.<br>\
		W postaci Pana Nocy możesz pożerać ręce, by się leczyć i odzyskiwać segmenty.<br>\
		Dodatkowo możesz mieć trzy razy więcej Ghuli i Voiceless Dead \
		i tworzyć nieograniczoną liczbę ostrzy, by ich wszystkich uzbroić."
	transmute_text = "Przemień cztery zwłoki."
	gain_text = "Dzięki wiedzy Marszałka moja moc osiągnęła szczyt. Tron czekał na zdobycie. \
		Ludzie tego świata, słuchajcie, bo czas nadszedł! Marszałek prowadzi moją armię! \
		Rzeczywistość ugnie się przed PANEM NOCY albo się rozpadnie! UJRZYJCIE MOJE WNIEBOWSTĄPIENIE!"
	required_atoms = list(/mob/living/carbon/human = 4)
	ascension_achievement = /datum/award/achievement/misc/flesh_ascension
	announcement_text = "%SPOOKY% Wiecznie skręcający się wir. Rzeczywistość rozwinięta. Z RAMIONAMI WYCIĄGNIĘTYMI PAN NOCY, %NAME%, dostąpił wniebowstąpienia! Lękajcie się wiecznie wijącej się dłoni! %SPOOKY%"
	announcement_sound = 'aquila/sound/music/antag/heretic/ascend_flesh.ogg'

/datum/heretic_knowledge/ultimate/flesh_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	var/datum/action/cooldown/spell/shapeshift/shed_human_form/worm_spell = new(user.mind)
	worm_spell.Grant(user)

	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(user)
	var/datum/heretic_knowledge/limited_amount/starting/base_flesh/grasp_ghoul = heretic_datum.get_knowledge(/datum/heretic_knowledge/limited_amount/starting/base_flesh)
	grasp_ghoul.limit *= 3
	var/datum/heretic_knowledge/limited_amount/flesh_ghoul/ritual_ghoul = heretic_datum.get_knowledge(/datum/heretic_knowledge/limited_amount/flesh_ghoul)
	if(ritual_ghoul)
		ritual_ghoul.limit *= 3
	var/datum/heretic_knowledge/limited_amount/starting/base_flesh/blade_ritual = heretic_datum.get_knowledge(/datum/heretic_knowledge/limited_amount/starting/base_flesh)
	blade_ritual.limit = 999

#undef GHOUL_MAX_HEALTH
#undef MUTE_MAX_HEALTH
