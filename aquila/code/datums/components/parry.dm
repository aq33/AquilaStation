// Parowanie na czas z Paradise (ParadiseSS13/Paradise code/datums/components/parry.dm).
// Klawisz parowania otwiera na PARRY_DEFAULT_TIMEOUT okno, w którym przedmiot w ręce paruje każdy atak z wybranych typów,
// z każdego kierunku. W pierwszej połowie okna parowanie jest idealne (koszt staminy tylko stały).
// U nas działa przez COMSIG_HUMAN_CHECK_SHIELDS, czyli przed pasywnym blokiem z Bee i bez jego kosztu staminy.

/datum/component/parry
	/// world.time ostatniego wciśnięcia parowania
	var/time_parried = -INFINITY
	/// Jak długo po wciśnięciu parowanie działa
	var/parry_time_out_time
	/// Stały koszt staminy za parowanie (w skali Paradise, 100 = pełna stamina)
	var/stamina_constant
	/// Koszt zależny od obrażeń i spóźnienia: współczynnik * obrażenia * (spóźnienie + przebicie)
	var/stamina_coefficient
	/// Typy ataków, które przedmiot paruje
	var/list/parryable_attack_types
	/// Przerwa między kolejnymi parowaniami
	var/parry_cooldown
	/// Bez dźwięku parowania
	var/no_parry_sound
	/// Tylko trzymany oburącz
	var/requires_two_hands = FALSE
	/// Tylko włączony (miecz energetyczny, teleskopowa tarcza)
	var/requires_activation = FALSE
	/// Kto trzyma przedmiot w ręce (na nim wiszą sygnały)
	var/mob/living/carbon/human/holder

/datum/component/parry/Initialize(_stamina_constant = 0, _stamina_coefficient = 0, _parry_time_out_time = PARRY_DEFAULT_TIMEOUT, _parryable_attack_types = ALL_ATTACK_TYPES, _parry_cooldown = 2 SECONDS, _no_parry_sound = FALSE, _requires_two_hands = FALSE, _requires_activation = FALSE)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	parry_time_out_time = _parry_time_out_time
	stamina_constant = _stamina_constant
	stamina_coefficient = _stamina_coefficient
	parry_cooldown = _parry_cooldown
	no_parry_sound = _no_parry_sound
	requires_two_hands = _requires_two_hands
	requires_activation = _requires_activation
	parryable_attack_types = islist(_parryable_attack_types) ? _parryable_attack_types : list(_parryable_attack_types)

/datum/component/parry/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(equipped))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(dropped))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_parent_examined))
	var/obj/item/item_parent = parent
	if(ishuman(item_parent.loc))
		var/mob/living/carbon/human/wearer = item_parent.loc
		if(item_parent in wearer.held_items)
			set_holder(wearer)

/datum/component/parry/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED, COMSIG_PARENT_EXAMINE))
	set_holder(null)

/datum/component/parry/Destroy(force, silent)
	set_holder(null)
	return ..()

/datum/component/parry/proc/set_holder(mob/living/carbon/human/new_holder)
	if(holder == new_holder)
		return
	if(holder)
		UnregisterSignal(holder, list(COMSIG_HUMAN_PARRY, COMSIG_HUMAN_CHECK_SHIELDS, COMSIG_PARENT_QDELETING))
	holder = new_holder
	if(holder)
		RegisterSignal(holder, COMSIG_HUMAN_PARRY, PROC_REF(start_parry))
		RegisterSignal(holder, COMSIG_HUMAN_CHECK_SHIELDS, PROC_REF(attempt_parry))
		RegisterSignal(holder, COMSIG_PARENT_QDELETING, PROC_REF(holder_deleted))

/datum/component/parry/proc/holder_deleted(datum/source)
	SIGNAL_HANDLER
	set_holder(null)

/datum/component/parry/proc/equipped(datum/source, mob/user, slot)
	SIGNAL_HANDLER
	set_holder((slot == ITEM_SLOT_HANDS && ishuman(user)) ? user : null)

/datum/component/parry/proc/dropped(datum/source, mob/user)
	SIGNAL_HANDLER
	set_holder(null)

/// Czy przedmiot jest teraz gotowy do parowania (oburącz, włączony)
/datum/component/parry/proc/can_parry_now()
	var/obj/item/item_parent = parent
	if(requires_two_hands)
		var/datum/component/two_handed/two_handed = item_parent.GetComponent(/datum/component/two_handed)
		if(!two_handed?.wielded)
			return FALSE
	if(requires_activation && !item_parent.is_parry_active())
		return FALSE
	return TRUE

/datum/component/parry/proc/start_parry(mob/living/carbon/human/source)
	SIGNAL_HANDLER
	if(source.stat != CONSCIOUS || source.incapacitated())
		return
	if(!can_parry_now())
		return
	if(world.time - time_parried < parry_cooldown)
		return
	time_parried = world.time
	source.changeNext_move(CLICK_CD_PARRY)
	source.do_attack_animation(source, used_item = parent)

/datum/component/parry/proc/attempt_parry(mob/living/carbon/human/source, atom/movable/hitby, damage, attack_text, attack_type, armour_penetration)
	SIGNAL_HANDLER
	if(!(attack_type in parryable_attack_types))
		return NONE
	var/time_since_parry = world.time - time_parried
	if(time_since_parry > parry_time_out_time || !can_parry_now() || source.stat != CONSCIOUS)
		return NONE
	if(armour_penetration >= 100)
		return NONE
	// Wzór z Paradise jest w skali 100 punktów staminy, nasza pula ma inny rozmiar
	var/stamina_scale = source.stamina ? source.stamina.maximum / 100 : 1
	var/stamina_damage = (stamina_coefficient * ((time_since_parry / parry_time_out_time) + armour_penetration / 100) * damage + stamina_constant) * stamina_scale
	var/perfect = time_since_parry <= parry_time_out_time * 0.5
	if(!no_parry_sound)
		var/parry_sound = 'sound/weapons/parry.ogg'
		if(attack_type == PROJECTILE_ATTACK)
			parry_sound = pick('sound/weapons/effects/ric1.ogg', 'sound/weapons/effects/ric2.ogg', 'sound/weapons/effects/ric3.ogg', 'sound/weapons/effects/ric4.ogg', 'sound/weapons/effects/ric5.ogg')
		playsound(source, parry_sound, clamp(stamina_damage, 40, 120), TRUE)
	source.apply_damage(stamina_damage, STAMINA)
	if(source.stamina && source.stamina.loss_as_percent >= 100)
		return NONE
	if(perfect)
		source.visible_message("<span class='danger'>[source] idealnie paruje [attack_text] za pomocą [parent]!</span>", "<span class='userdanger'>Idealnie parujesz [attack_text]!</span>")
	else
		source.visible_message("<span class='danger'>[source] paruje [attack_text] za pomocą [parent]!</span>", "<span class='userdanger'>Parujesz [attack_text]!</span>")
	return SHIELD_BLOCK

/datum/component/parry/proc/on_parent_examined(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	var/static/list/attack_type_names = list(
		"[MELEE_ATTACK]" = "ciosy bronią",
		"[UNARMED_ATTACK]" = "ciosy gołymi rękami",
		"[PROJECTILE_ATTACK]" = "pociski",
		"[THROWN_PROJECTILE_ATTACK]" = "rzucone przedmioty",
		"[LEAP_ATTACK]" = "skoki",
	)
	var/list/names = list()
	for(var/attack_type in parryable_attack_types)
		names += attack_type_names["[attack_type]"]
	var/conditions = ""
	if(requires_two_hands)
		conditions = " (trzymany oburącz)"
	else if(requires_activation)
		conditions = " (włączony)"
	examine_list += "<span class='notice'>Potrafi <b>parować</b>[conditions]: [english_list(names, and_text = " i ")]. Klawisz parowania: domyślnie Ctrl+Spacja.</span>"

/// Czy przedmiot jest włączony na potrzeby parowania (requires_activation)
/obj/item/proc/is_parry_active()
	return TRUE

/obj/item/melee/transforming/is_parry_active()
	return active

/obj/item/shield/riot/tele/is_parry_active()
	return active

/datum/keybinding/human/parry
	key = "Ctrl-Space"
	name = "parry"
	full_name = "Paruj"
	description = "Paruj ciosy bronią, która to potrafi (okno ok. 1 s, idealnie w pierwszej połowie)"
	keybind_signal = COMSIG_KB_HUMAN_PARRY_DOWN

/datum/keybinding/human/parry/down(client/user)
	. = ..()
	if(.)
		return
	SEND_SIGNAL(user.mob, COMSIG_HUMAN_PARRY)
	return TRUE

// Bronie, które parują (wartości z Paradise dla przedmiotów, które mamy)
/obj/item/nullrod/staff/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.5, _parryable_attack_types = ALL_ATTACK_TYPES)

/obj/item/nullrod/claymore/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.7, _parryable_attack_types = ALL_ATTACK_TYPES, _parry_cooldown = (7 / 3) SECONDS)

/obj/item/melee/transforming/energy/sword/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.5, _parryable_attack_types = ALL_ATTACK_TYPES, _requires_activation = TRUE)

/obj/item/holo/esword/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.5, _parryable_attack_types = NON_PROJECTILE_ATTACKS, _requires_activation = TRUE)

/obj/item/holo/esword/is_parry_active()
	return active

/obj/item/melee/sabre/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.5, _parryable_attack_types = NON_PROJECTILE_ATTACKS)

/obj/item/katana/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.5, _parryable_attack_types = ALL_ATTACK_TYPES)

/obj/item/claymore/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.5, _parryable_attack_types = ALL_ATTACK_TYPES)

/obj/item/shield/Initialize(mapload)
	. = ..()
	add_parry_component()

/obj/item/shield/proc/add_parry_component()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.5, _parryable_attack_types = ALL_ATTACK_TYPES)

/obj/item/shield/riot/buckler/add_parry_component()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.7, _parryable_attack_types = ALL_ATTACK_TYPES, _parry_cooldown = (10 / 3) SECONDS)

/obj/item/shield/riot/tele/add_parry_component()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.7, _parryable_attack_types = ALL_ATTACK_TYPES, _parry_cooldown = (5 / 3) SECONDS, _requires_activation = TRUE)

/obj/item/fireaxe/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.7, _parryable_attack_types = MELEE_ATTACK, _parry_cooldown = (10 / 3) SECONDS, _requires_two_hands = TRUE)

/obj/item/singularityhammer/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.25, _parryable_attack_types = ALL_ATTACK_TYPES, _parry_cooldown = (4 / 3) SECONDS, _requires_two_hands = TRUE)

/obj/item/mjollnir/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.25, _parryable_attack_types = ALL_ATTACK_TYPES, _parry_cooldown = (4 / 3) SECONDS, _requires_two_hands = TRUE)

/obj/item/dualsaber/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.25, _parryable_attack_types = ALL_ATTACK_TYPES, _parry_cooldown = (4 / 3) SECONDS, _requires_two_hands = TRUE)

/obj/item/staff/bostaff/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.5, _parryable_attack_types = ALL_ATTACK_TYPES)

/obj/item/spear/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.7, _parryable_attack_types = MELEE_ATTACK, _parry_cooldown = (10 / 3) SECONDS, _requires_two_hands = TRUE)

/obj/item/pushbroom/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.75, _parryable_attack_types = MELEE_ATTACK, _parry_cooldown = (7 / 3) SECONDS, _requires_two_hands = TRUE)

/obj/item/chair/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 1.5, _parryable_attack_types = NON_PROJECTILE_ATTACKS)

/obj/item/kinetic_crusher/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.7, _parryable_attack_types = MELEE_ATTACK, _parry_cooldown = (10 / 3) SECONDS, _requires_two_hands = TRUE)
