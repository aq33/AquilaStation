/datum/heretic_knowledge_tree_column/blade
	route = PATH_BLADE
	ui_bgr = "node_blade"
	complexity = "Hard"
	complexity_color = COLOR_RED
	icon = list(
		"icon" = 'aquila/icons/obj/weapons/khopesh.dmi',
		"state" = "dark_blade",
		"frame" = 1,
		"dir" = SOUTH,
		"moving" = FALSE,
	)
	description = list(
		"Ścieżka Ostrza jest dokładnie tym, na co wskazuje nazwa.",
		"Świetnie radzisz sobie z siekaniem przeciwników na kawałki.",
		"Wybierz tę ścieżkę, jeśli chcesz walczyć - i być w walce najlepszy.",
	)
	pros = list(
		"Potrafisz blokować nadchodzące ataki i odpowiadać ripostą.",
		"Szybko zadajesz obrażenia dwoma ostrzami naraz i kanałowanymi ciosami.",
		"Duża odporność na ogłuszenia i powalenia.",
		"Bardzo groźny w bezpośredniej walce jeden na jednego.",
	)
	cons = list(
		"Wymaga sporej wprawy.",
		"Bez ostrzy ścieżka traci większość siły bojowej.",
		"Brak zdolności ruchowych.",
		"Brak ochrony przed otoczeniem.",
	)
	tips = list(
		"Twój Mansus Grasp powala przeciwnika, jeśli trafisz go od tyłu albo gdy leży. Zamyka go też w pomieszczeniu, w którym stoi, aż do zdetonowania znaku. Zdetonowany znak daje ci krążący nóż, który ochroni cię przed jednym atakiem wręcz lub z dystansu.",
		"Masz najwyższy limit ostrzy ze wszystkich ścieżek (aż 4). Wymagają jednak srebra albo tytanu, więc bez pracowitych górników może ci zabraknąć materiałów. Tytan znajdziesz w ścianach i siedzeniach promów, a srebro w stołach operacyjnych.",
		"Musisz dopaść przeciwnika wręcz. Poślizgnięcia, bolasy i sidła to twoi najgorsi wrogowie. Na poślizgnięcia pomogą Greaves Of The Prophet, a z więzów uwolnisz się Ashen Passage.",
		"Realignment wyrwie cię z ogłuszeń i powaleń, ale na ten czas nie możesz atakować.",
		"Z Empowered Blades twoja siła ataku mocno rośnie. Walczysz dwoma ostrzami naraz, a użycie Mansus Grasp z ostrzem w ręce nasyca je mocą. Ostrza zadają też dodatkowe obrażenia obiektom, syntetykom i mechom.",
		"Dobry atak to też dobra obrona. Krążące ostrza zablokują dodatkowe ataki.",
		"Furious Steel tworzy kilka noży do obrony, ale możesz je też ciskać, klikając pustą ręką. To przydatny atak z dystansu w trudnej sytuacji.",
		"Ostrożnie z Wolves Among Sheep. Ma długie odnowienie, a każdy uwięziony z tobą na arenie dostaje własne ostrze. Używaj go jako ostatniej deski ratunku albo gdy masz przewagę i chcesz ją przypieczętować. Tylko nie próbuj uciec z areny, zanim kogoś nie powalisz.",
	)

	start = /datum/heretic_knowledge/limited_amount/starting/base_blade
	knowledge_tier1 = /datum/heretic_knowledge/spell/realignment
	guaranteed_side_tier1 = /datum/heretic_knowledge/greaves_of_the_prophet
	knowledge_tier2 = /datum/heretic_knowledge/duel_stance
	guaranteed_side_tier2 = /datum/heretic_knowledge/essence
	robes = /datum/heretic_knowledge/armor/blade
	knowledge_tier3 = /datum/heretic_knowledge/spell/furious_steel
	guaranteed_side_tier3 = /datum/heretic_knowledge/rune_carver
	blade = /datum/heretic_knowledge/blade_upgrade/blade
	knowledge_tier4 = /datum/heretic_knowledge/spell/wolves_among_sheep
	ascension = /datum/heretic_knowledge/ultimate/blade_final

/datum/heretic_knowledge/limited_amount/starting/base_blade
	name = "The Cutting Edge"
	desc = "Otwiera przed tobą Ścieżkę Ostrza.<br>\
		Pozwala tworzyć Sundered Blades. \
		Możesz mieć ich jednocześnie aż cztery."
	transmute_text = "Przemień nóż i sztabkę srebra albo tytanu."
	gain_text = "Nasi wielcy przodkowie wykuwali miecze i ćwiczyli fechtunek w przededniu wielkich bitew."
	required_atoms = list(
		/obj/item/kitchen/knife = 1,
		list(/obj/item/stack/sheet/mineral/silver, /obj/item/stack/sheet/mineral/titanium) = 1,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/dark)
	limit = 4 // It's the blade path, it's a given
	research_tree_icon_path = 'aquila/icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "dark_blade"
	mark_type = /datum/status_effect/eldritch/blade
	eldritch_passive = /datum/status_effect/heretic_passive/blade

/datum/heretic_knowledge/limited_amount/starting/base_blade/on_mansus_grasp(mob/living/source, mob/living/target)
	. = ..()

	if(!check_behind(source, target))
		return

	// We're officially behind them, apply effects
	target.AdjustParalyzed(1.5 SECONDS)
	target.apply_damage(10, BRUTE)
	target.balloon_alert(source, "cios w plecy!")
	playsound(target, 'aquila/sound/items/weapons/guillotine.ogg', 100, TRUE)

/datum/heretic_knowledge/limited_amount/starting/base_blade/create_mark(mob/living/source, mob/living/target)
	var/datum/status_effect/eldritch/blade/blade_mark = ..()
	if(istype(blade_mark))
		var/area/to_lock_to = get_area(target)
		blade_mark.locked_to = to_lock_to
		to_chat(target, span_hypnophrase("Nieziemska siła zmusza cię do pozostania w [get_area_name(to_lock_to)]!"))
	return blade_mark

/datum/heretic_knowledge/limited_amount/starting/base_blade/trigger_mark(mob/living/source, mob/living/target)
	. = ..()
	if(!.)
		return
	source.apply_status_effect(/datum/status_effect/protective_blades, 60 SECONDS, 1, 20, 0 SECONDS)

/datum/heretic_knowledge/spell/realignment
	name = "Realignment"
	desc = "Daje ci Realignment, zaklęcie, które przez krótki czas gwałtownie porządkuje twoje ciało.<br>\
		W tym czasie szybko odzyskujesz wytrzymałość i otrząsasz się z ogłuszeń, ale nie możesz atakować.<br>\
		Można je rzucać raz za razem, ale każde rzucenie wydłuża odnowienie."
	gain_text = "W wirze śmierci odnalazł w sobie spokój. Mimo beznadziejnej przewagi wroga parł naprzód."
	action_to_add = /datum/action/cooldown/spell/realignment
	cost = 2
	max_charges = 3
	focus_recharge_amount = 0.33
	holywater_drain_amount = 0.16

/datum/heretic_knowledge/duel_stance
	name = "Stance of the Torn Champion"
	desc = "Daje odporność na utratę krwi z ran i chroni twoje kończyny przed odcięciem.<br>\
		Dodatkowo, gdy twoje zdrowie spadnie poniżej 50%, \
		rany jeszcze słabiej krwawią, a obrażenia cię nie spowalniają."
	gain_text = "Z czasem to on jeden stał wśród ciał swych dawnych towarzyszy, skąpany we krwi - ani kropli własnej. \
		Nie miał rywala, równego sobie ani celu."
	cost = 2
	research_tree_icon_path = 'icons/effects/blood.dmi'
	research_tree_icon_state = "suitblood"
	research_tree_icon_dir = SOUTH
	drafting_tier = 5
	/// Whether we're currently in duelist stance, gaining certain buffs (low health)
	var/in_duelist_stance = FALSE

/datum/heretic_knowledge/duel_stance/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	// AQUILA - u nas nie ma ran z tg, więc odporność działa na krwawienie (zob. add_bleeding w _compat/bladecosmic.dm)
	user.add_traits(list(TRAIT_NODISMEMBER, TRAIT_HERETIC_BLEED_RESISTANCE), type)
	RegisterSignal(user, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(user, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(on_health_update))

	on_health_update(user) // Run this once, so if the knowledge is learned while hurt it activates properly

/datum/heretic_knowledge/duel_stance/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	user.remove_traits(list(TRAIT_NODISMEMBER, TRAIT_HERETIC_BLEED_RESISTANCE), type)
	if(in_duelist_stance)
		in_duelist_stance = FALSE
		user.remove_traits(list(TRAIT_HARDLY_WOUNDED, TRAIT_IGNOREDAMAGESLOWDOWN), type)

	UnregisterSignal(user, list(COMSIG_PARENT_EXAMINE, COMSIG_LIVING_HEALTH_UPDATE))

/datum/heretic_knowledge/duel_stance/proc/on_examine(mob/living/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	var/obj/item/held_item = source.get_active_held_item()
	if(in_duelist_stance)
		examine_list += span_warning("[source] stoi w nienaturalnie pewnej pozie[held_item?.force >= 15 ? ", gotów do ciosu" : ""].")

/datum/heretic_knowledge/duel_stance/proc/on_health_update(mob/living/source)
	SIGNAL_HANDLER

	if(in_duelist_stance && source.health > source.maxHealth * 0.5)
		source.balloon_alert(source, "koniec postawy pojedynkowicza")
		in_duelist_stance = FALSE
		source.remove_traits(list(TRAIT_HARDLY_WOUNDED, TRAIT_IGNOREDAMAGESLOWDOWN), type)
		return

	if(!in_duelist_stance && source.health <= source.maxHealth * 0.5)
		source.balloon_alert(source, "postawa pojedynkowicza")
		in_duelist_stance = TRUE
		source.add_traits(list(TRAIT_HARDLY_WOUNDED, TRAIT_IGNOREDAMAGESLOWDOWN), type)
		return

/datum/heretic_knowledge/armor/blade
	desc = "Tworzy Shattered Panoply.<br>\
		Noszona daje odporność na pałki i izolację przed porażeniem."
	transmute_text = "Przemień stół (albo strój), maskę i arkusz tytanu lub srebra."
	gain_text = "Wokół mnie niesie się echo bezładnej kakofonii przemocy. \
		Choć stalowy rynsztunek Czempiona zdarto z jego ciała, każdy kawałek wciąż łaknie celu, szukając niewidzialnych lub wyimaginowanych napastników."
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch/blade)
	research_tree_icon_state = "blade_armor"
	required_atoms = list(
		list(/obj/structure/table, /obj/item/clothing/suit) = 1,
		/obj/item/clothing/mask = 1,
		list(/obj/item/stack/sheet/mineral/silver, /obj/item/stack/sheet/mineral/titanium) = 1,
	)

/datum/heretic_knowledge/spell/wolves_among_sheep
	name = "Wolves Among Sheep"
	desc = "Zmienia tkankę rzeczywistości, tworząc magiczną arenę, do której nie wejdzie nikt z zewnątrz. \
		Uwięzieni uczestnicy są odporni na wszelkie ogłuszenia i zagrożenia otoczenia; \
		każdy dostaje ostrze i nie może opuścić areny ani się teleportować, dopóki kogoś nie powali do stanu krytycznego. \
		Powalenie przeciwnika do stanu krytycznego częściowo leczy heretyka."
	gain_text = "Cienie pełzną po pokoju, zmieniając każde krzesło, stół \
		i konsolę w złowrogi kształt kolejnej zdradzieckiej ręki. \
		Uczyniłem sobie wroga ze wszystkich i nigdy już nie zaznam \
		spokoju. Zerwałem więzy i przeciąłem wszelkie sojusze. W tej prawdzie \
		poznałem kruchość braterstwa. Moimi wrogami będą wszyscy, podzieleni."
	cost = 2
	action_to_add = /datum/action/cooldown/spell/wolves_among_sheep
	is_final_knowledge = TRUE
	max_charges = 4
	path_recharge_amount = 0.0
	holywater_drain_amount = 0.25
	transmute_text = "Za każdą dokonaną ofiarę dostajesz jeden ładunek. \
		Ładunek dostajesz też, gdy podczas działania zaklęcia powalisz do stanu krytycznego co najmniej trzech walczących. \
		Możesz mieć najwyżej cztery ładunki."

/datum/heretic_knowledge/spell/wolves_among_sheep/New()
	. = ..()
	charges = 1 // start with one, can go up to four

/datum/heretic_knowledge/spell/wolves_among_sheep/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	RegisterSignal(our_heretic, COMSIG_HERETIC_SACRIFICE, PROC_REF(on_sacrifice))

/datum/heretic_knowledge/spell/wolves_among_sheep/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	UnregisterSignal(our_heretic, COMSIG_HERETIC_SACRIFICE)

/datum/heretic_knowledge/spell/wolves_among_sheep/proc/on_sacrifice(datum/source, mob/living/sacrifice, high_value)
	SIGNAL_HANDLER
	add_charges(1)

/datum/heretic_knowledge/blade_upgrade/blade
	name = "Empowered Blades"
	desc = "Atak Sundered Blade, gdy trzymasz je w obu rękach, \
		zada cios obydwoma naraz - dwa ataki tuż po sobie.<br>\
		Drugi cios jest nieco słabszy.<br>\
		Możesz nasycić ostrza mocą Mansus Grasp, a ostrza lepiej niszczą konstrukcje."
	gain_text = "Znalazłem go rozciętego na dwoje, a obie połowy toczyły pojedynek bez końca; \
		zamieć ostrzy, z których żadne nie trafiało, bo Czempion był niezwyciężony."
	research_tree_icon_path = 'aquila/icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_blade"
	/// How much force do we apply to the offhand?
	var/offand_force_decrement = 0
	/// How much force was the last weapon we offhanded with? If it's different, we need to re-calculate the decrement
	var/last_weapon_force = -1

/datum/heretic_knowledge/blade_upgrade/blade/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	RegisterSignal(user, COMSIG_TOUCH_HANDLESS_CAST, PROC_REF(on_grasp_cast))
	RegisterSignal(user, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(on_blade_equipped))
	// Ostrza, które już trzymamy, też dostają premię do niszczenia
	for(var/obj/item/melee/sickly_blade/dark/held_blade in user.held_items)
		on_blade_equipped(user, held_blade)

/datum/heretic_knowledge/blade_upgrade/blade/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	UnregisterSignal(user, list(COMSIG_TOUCH_HANDLESS_CAST, COMSIG_MOB_EQUIPPED_ITEM))

///Tries to infuse our held blade with our mansus grasp
/datum/heretic_knowledge/blade_upgrade/blade/proc/on_grasp_cast(mob/living/carbon/cast_on, datum/action/cooldown/spell/spell)
	SIGNAL_HANDLER

	// Tylko Mansus Grasp nasyca ostrza
	if(spell && !istype(spell, /datum/action/cooldown/spell/touch/mansus_grasp))
		return NONE
	var/held_item = cast_on.get_active_held_item()
	if(!istype(held_item, /obj/item/melee/sickly_blade/dark))
		return NONE
	var/obj/item/melee/sickly_blade/dark/held_blade = held_item
	if(held_blade.infused)
		return NONE
	held_blade.infused = TRUE
	held_blade.update_appearance(UPDATE_ICON)

	//Infuse our off-hand blade just so it's nicer visually
	var/obj/item/melee/sickly_blade/dark/off_hand_blade = cast_on.get_inactive_held_item()
	if(istype(off_hand_blade, /obj/item/melee/sickly_blade/dark))
		off_hand_blade.infused = TRUE
		off_hand_blade.update_appearance(UPDATE_ICON)
	cast_on.update_inv_hands()

	return COMPONENT_CAST_HANDLESS

/datum/heretic_knowledge/blade_upgrade/blade/do_melee_effects(mob/living/source, atom/target, obj/item/melee/sickly_blade/blade)
	if(target == source)
		return

	var/obj/item/off_hand = source.get_inactive_held_item()
	if(QDELETED(off_hand) || !istype(off_hand, /obj/item/melee/sickly_blade))
		return
	// If our off-hand is the blade that's attacking,
	// quit out now to avoid an infinite stab combo
	if(off_hand == blade)
		return

	// Give it a short delay (for style, also lets people dodge it I guess)
	addtimer(CALLBACK(src, PROC_REF(follow_up_attack), source, target, off_hand), 0.25 SECONDS)

/datum/heretic_knowledge/blade_upgrade/blade/proc/follow_up_attack(mob/living/source, atom/target, obj/item/melee/sickly_blade/blade)
	if(QDELETED(source) || QDELETED(target) || QDELETED(blade))
		return
	// Sanity to ensure that the blade we're delivering an offhand attack with is ACTUALLY our offhand
	if(blade != source.get_inactive_held_item())
		return
	// And we easily could've moved away
	if(!source.Adjacent(target))
		return

	// Check if we need to recaclulate our offhand force
	// This is just so we don't run this block every attack, that's wasteful
	if(last_weapon_force != blade.force)
		last_weapon_force = blade.force
		offand_force_decrement = 0
		// We want to make sure that the offhand blade increases their hits to crit by one, just about
		// So, let's do some quick math. Yes this'll be inaccurate if their mainhand blade is modified (whetstone), no I don't care
		// Find how much force we need to detract from the second blade
		var/hits_to_crit_on_average = ROUND_UP(100 / (blade.force * 2))
		while(hits_to_crit_on_average <= 3) // 3 hits and beyond is a bit too absurd
			if(offand_force_decrement + 2 > blade.force * 0.5) // But also cutting the force beyond half is absurd
				break

			offand_force_decrement += 2
			hits_to_crit_on_average = ROUND_UP(100 / (blade.force * 2 - offand_force_decrement))

	// Perform the offhand attack
	// AQUILA - u nas łańcuch ataku nie przyjmuje modyfikatorów siły, więc na czas ciosu obniżamy siłę ostrza
	var/original_force = blade.force
	blade.force = max(original_force - offand_force_decrement, 0)
	blade.melee_attack_chain(source, target)
	if(!QDELETED(blade))
		blade.force = original_force

///Modifies our blade demolition modifier so we can take down doors with it
/datum/heretic_knowledge/blade_upgrade/blade/proc/on_blade_equipped(mob/user, obj/item/equipped, slot)
	SIGNAL_HANDLER
	if(!istype(equipped, /obj/item/melee/sickly_blade/dark))
		return
	// AQUILA - u nas nie ma demolition_mod; dokładamy obrażenia przy ataku na obiekt albo syntetyka (razem x2.5 jak w tg)
	RegisterSignal(equipped, COMSIG_ITEM_ATTACK_OBJ, PROC_REF(on_blade_attack_obj), override = TRUE)
	RegisterSignal(equipped, COMSIG_ITEM_ATTACK, PROC_REF(on_blade_attack_mob), override = TRUE)

/datum/heretic_knowledge/blade_upgrade/blade/proc/on_blade_attack_obj(obj/item/source, obj/target, mob/living/user)
	SIGNAL_HANDLER
	if(!source.force || (target.resistance_flags & INDESTRUCTIBLE))
		return
	INVOKE_ASYNC(target, TYPE_PROC_REF(/obj, take_damage), source.force * 1.5, source.damtype, "melee", FALSE, get_dir(user, target))

/datum/heretic_knowledge/blade_upgrade/blade/proc/on_blade_attack_mob(obj/item/source, mob/living/target, mob/living/user)
	SIGNAL_HANDLER
	if(!source.force || !issilicon(target))
		return
	INVOKE_ASYNC(target, TYPE_PROC_REF(/mob/living, apply_damage), source.force * 1.5, source.damtype)

/datum/heretic_knowledge/spell/furious_steel
	name = "Furious Steel"
	desc = "Daje ci Furious Steel, zaklęcie celowane. Przywołuje trzy \
		ostrza krążące wokół ciebie.<br>Ostrza chronią cię przed wszystkimi atakami, \
		ale znikają po użyciu.<br>Kliknięciem możesz miotać ostrzami \
		w cel, zadając obrażenia i wywołując krwawienie."
	gain_text = "Bez namysłu chwyciłem nóż poległego żołnierza i cisnąłem nim z całych sił. Trafiłem! \
		Rozdarty Czempion uśmiechnął się, gdy po raz pierwszy zasmakował bólu, i skinieniem głowy oddał mi swe ostrza."
	required_atoms = list(/obj/item/kitchen/knife = 1)
	action_to_add = /datum/action/cooldown/spell/pointed/projectile/furious_steel
	cost = 2
	max_charges = 6
	recharge_amount = 0.5
	focus_recharge_amount = 0.33
	holywater_drain_amount = 0.16
	transmute_text = "Możesz je ręcznie naładować rytuałem z nożem - przywraca to połowę maksymalnych ładunków zaklęcia."

/datum/heretic_knowledge/spell/furious_steel/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	RegisterSignal(user, COMSIG_MOB_BLADE_BARRIER_TRIGGERED, PROC_REF(blade_barrier_triggered))

/datum/heretic_knowledge/spell/furious_steel/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	UnregisterSignal(user, COMSIG_MOB_BLADE_BARRIER_TRIGGERED)

/datum/heretic_knowledge/spell/furious_steel/proc/blade_barrier_triggered(mob/living/target, datum/status_effect/barrier)
	SIGNAL_HANDLER

	var/datum/action/cooldown/spell/pointed/projectile/furious_steel/spell = created_action_ref
	if(spell?.blade_effect == barrier)
		remove_charges(1)

/datum/heretic_knowledge/ultimate/blade_final
	name = "Maelstrom of Silver"
	desc = "Rytuał wzniesienia Ścieżki Ostrza.<br>\
		Po jego ukończeniu otacza cię nieustannie odnawiający się wir ostrzy. \
		Ostrza chronią cię przed wszystkimi atakami, ale znikają po użyciu.<br>\
		Twoje zaklęcie Furious Steel będzie miało krótsze odnowienie.<br>\
		Stajesz się też mistrzem walki: twoje rany nie krwawią, a krótkie ogłuszenia strząsasz z siebie.<br>\
		Twoje Sundered Blades zadają dodatkowe obrażenia i leczą cię o część zadanych obrażeń."
	transmute_text = "Przemień trzy zwłoki bez głowy albo z rozłupaną (całkiem zmasakrowaną) czaszką."
	gain_text = "Rozdarty Czempion jest wolny! Stanę się na powrót złączonym ostrzem, a z moją większą ambicją \
		NIKT MI NIE DORÓWNA! NADCIĄGA BURZA STALI I SREBRA! UJRZYJCIE MOJE WZNIESIENIE!"

	ascension_achievement = /datum/award/achievement/misc/blade_ascension
	announcement_text = "%SPOOKY% Mistrz ostrzy, uczeń Rozdartego Czempiona, %NAME% wzniósł się! Jego stal przetnie rzeczywistość w wirze srebra! %SPOOKY%"
	announcement_sound = 'aquila/sound/music/antag/heretic/ascend_blade.ogg'

/datum/heretic_knowledge/ultimate/blade_final/is_valid_sacrifice(mob/living/carbon/human/sacrifice)
	. = ..()
	if(!.)
		return FALSE

	var/obj/item/bodypart/head/head = sacrifice.get_bodypart(BODY_ZONE_HEAD)
	if(!head || HAS_TRAIT(sacrifice, TRAIT_HAS_CRANIAL_FISSURE))
		return TRUE
	// AQUILA - u nas nie ma pękniętej czaszki (rany z tg), więc wystarczy całkiem zmasakrowana głowa
	return head.brute_dam >= head.max_damage

/datum/heretic_knowledge/ultimate/blade_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	ADD_TRAIT(user, TRAIT_NEVER_WOUNDED, type)
	RegisterSignal(user, COMSIG_HERETIC_BLADE_ATTACK, PROC_REF(on_eldritch_blade))
	user.apply_status_effect(/datum/status_effect/protective_blades/recharging, STATUS_EFFECT_PERMANENT, 8, 30, 0.25 SECONDS, /obj/effect/floating_blade, 60 SECONDS)
	// flashbangs are like 5-10 seoncds,
	// a banana peel is ~5 seconds, depending on botany
	// body throws and tackles are less than 5 seconds,
	// stun baton / stamcrit detracts no time,
	// and worst case: beepsky / tasers are 10 seconds.
	user.apply_status_effect(/datum/status_effect/blade_stun_absorption, name)
	var/datum/action/cooldown/spell/pointed/projectile/furious_steel/steel_spell = locate() in user.actions
	steel_spell?.cooldown_time /= 2

	if(ishuman(user))
		var/mob/living/carbon/human/heretic = user
		heretic.physiology.stun_mod *= 0.75 // tg: PHYS_COEFF_KNOCKDOWN 0.75, u nas jeden mnożnik na ogłuszenia

/datum/heretic_knowledge/ultimate/blade_final/proc/on_eldritch_blade(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	SIGNAL_HANDLER

	if(target == source || !isliving(target))
		return

	// Turns your heretic blades into eswords, pretty much.
	var/bonus_damage = clamp(30 - blade.force, 0, 12)

	target.apply_damage(bonus_damage, BRUTE, source.zone_selected)

	if(target.stat != DEAD)
		// And! Get some free healing for a portion of the bonus damage dealt.
		source.heal_overall_damage(bonus_damage / 2, bonus_damage / 2)

/**
 * AQUILA - tg: add_stun_absorption(max_seconds_of_stuns_blocked = 45 s, recharge_time = 2 min).
 * Nasze stare pochłanianie ogłuszeń nie ma limitu, więc pilnujemy go tym statusem.
 */
/datum/status_effect/blade_stun_absorption
	id = "blade_stun_absorption"
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = 1 SECONDS
	alert_type = null
	status_type = STATUS_EFFECT_UNIQUE
	/// Klucz w stun_absorption właściciela
	var/absorption_key = "blade_ascension"
	/// Ile ogłuszeń (w decysekundach) możemy pochłonąć przed przeładowaniem
	var/max_stuns_blocked = 45 SECONDS
	/// Czas odnowienia po wyczerpaniu
	var/recharge_time = 2 MINUTES
	/// Kiedy znowu zaczniemy pochłaniać (0 = działa)
	var/recharge_at = 0

/datum/status_effect/blade_stun_absorption/on_creation(mob/living/new_owner, key)
	if(key)
		absorption_key = key
	return ..()

/datum/status_effect/blade_stun_absorption/on_apply()
	enable_absorption()
	return TRUE

/datum/status_effect/blade_stun_absorption/on_remove()
	if(islist(owner.stun_absorption))
		owner.stun_absorption -= absorption_key

/datum/status_effect/blade_stun_absorption/proc/enable_absorption()
	recharge_at = 0
	owner.add_stun_absorption(absorption_key, INFINITY, 3, " zrzuca z siebie ogłuszenie!", "Zrzucasz z siebie ogłuszenie!", span_hypnophrase("[owner.p_they(TRUE)] stoi niewzruszenie."))

/datum/status_effect/blade_stun_absorption/tick(seconds_between_ticks)
	if(recharge_at)
		if(world.time >= recharge_at)
			enable_absorption()
		return
	if(!islist(owner.stun_absorption) || !owner.stun_absorption[absorption_key])
		return
	var/list/absorption = owner.stun_absorption[absorption_key]
	if(absorption["stuns_absorbed"] < max_stuns_blocked)
		return
	// Wyczerpane - wyłączamy do przeładowania
	absorption["end_time"] = world.time
	recharge_at = world.time + recharge_time
