// AQUILA - port z tgstation (code/datums/mutations/reach.dm + system zasięgu z code/_onclick/click.dm)
// Rdzeń podpięty nadpisaniami procedur zamiast edycji plików rdzenia.

// --- System zasięgu tg: reach_length ---

/mob/living
	/// tg: z jakiej odległości mob sięga rękami (1 = sąsiednie pola)
	var/reach_length = 1

/// tg IsReachableBy/CheckReachableAdjacency: zasięg moba liczony jak zasięg narzędzia
/mob/living/CanReach(atom/ultimate_target, obj/item/tool, view_only = FALSE)
	. = ..()
	if(. || reach_length <= 1 || !ultimate_target)
		return
	var/reach_range = max(reach_length, tool ? tool.reach : 0)
	var/list/direct_access = DirectAccess()
	var/depth = 1 + (view_only ? STORAGE_VIEW_DEPTH : INVENTORY_DEPTH)
	var/list/closed = list()
	var/list/checking = list(ultimate_target)
	while(length(checking) && depth > 0)
		var/list/next = list()
		--depth
		for(var/atom/target in checking)
			if(closed[target] || isarea(target))
				continue
			closed[target] = TRUE
			if(isturf(target) || isturf(target.loc) || (target in direct_access) || (ismovable(target) && target.flags_1 & IS_ONTOP_1))
				if(CheckToolReach(src, target, reach_range))
					return TRUE
			if(!target.loc)
				continue
			if(!(SEND_SIGNAL(target.loc, COMSIG_ATOM_CANREACH, next) & COMPONENT_BLOCK_REACH))
				next += target.loc
		checking = next
	return FALSE

// --- tg COMSIG_LIVING_TRY_PUT_IN_HAND ---

/mob/living/put_in_hand_check(obj/item/I)
	. = ..()
	if(. && (SEND_SIGNAL(src, COMSIG_LIVING_TRY_PUT_IN_HAND, I) & COMPONENT_LIVING_CANT_PUT_IN_HAND))
		return FALSE

// --- tg COMSIG_LIVING_TRY_PULL ---

/mob/living/start_pulling(atom/movable/AM, state, force = pull_force, supress_message = FALSE)
	if(AM && (SEND_SIGNAL(src, COMSIG_LIVING_TRY_PULL, AM, force) & COMSIG_LIVING_CANCEL_PULL))
		return FALSE
	return ..()

// --- tg TRAIT_NO_TWOHANDING ---

/datum/component/two_handed/wield(mob/living/carbon/user, swap_hands = FALSE)
	if(!wielded && HAS_TRAIT(user, TRAIT_NO_TWOHANDING))
		if(require_twohands)
			to_chat(user, "<span class='warning'>Nie dasz rady utrzymać [parent] oburącz!</span>")
			user.dropItemToGround(parent, force = TRUE)
		else
			to_chat(user, "<span class='warning'>Nie możesz chwycić [parent] oburącz!</span>")
		return
	return ..()

// --- tg TRAIT_CHUNKYFINGERS (kabłąk spustu) ---

/mob/living/carbon/human/can_use_guns(obj/item/G)
	. = ..()
	if(!.)
		return
	if(G.trigger_guard == TRIGGER_GUARD_NORMAL && HAS_TRAIT(src, TRAIT_CHUNKYFINGERS))
		to_chat(src, "<span class='warning'>Twoje palce są za grube na kabłąk spustu!</span>")
		return FALSE

/// tg: pałka z grubymi palcami nie ogłusza
/obj/item/melee/baton/baton_stun(mob/living/target, mob/living/user)
	if(ishuman(user) && HAS_TRAIT(user, TRAIT_CHUNKYFINGERS) && user.is_holding(src))
		balloon_alert(user, "palce za grube!")
		return FALSE
	return ..()

/obj/item/modular_computer
	/// tg allow_chunky: czy grube palce mogą obsługiwać to urządzenie
	var/allow_chunky = FALSE

/obj/item/modular_computer/tablet/pda
	allow_chunky = TRUE

/obj/item/modular_computer/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(!allow_chunky && ishuman(usr) && HAS_TRAIT(usr, TRAIT_CHUNKYFINGERS))
		balloon_alert(usr, "palce za grube!")
		return TRUE
	return ..()

// --- Mutacja ---

/datum/mutation/elastic_arms
	name = "Elastic Arms"
	desc = "The subject's arms become elastic, allowing them to stretch up to a meter away. \
		However, this elasticity makes it difficult to wear gloves, handle complex tasks, or grab large objects."
	quality = POSITIVE
	instability = 35
	text_gain_indication = "<span class='warning'>Czujesz się jak Armstrong!</span>"
	text_lose_indication = "<span class='warning'>Twoje ręce przestają być takie obwisłe.</span>"
	difficulty = 32
	mutation_traits = list(TRAIT_CHUNKYFINGERS, TRAIT_NO_TWOHANDING)

/datum/mutation/elastic_arms/on_acquiring(mob/living/carbon/owner)
	if(..())
		return TRUE
	RegisterSignal(owner, COMSIG_LIVING_TRY_PUT_IN_HAND, PROC_REF(on_owner_equipping_item))
	RegisterSignal(owner, COMSIG_LIVING_TRY_PULL, PROC_REF(on_owner_try_pull))
	owner.reach_length++

/datum/mutation/elastic_arms/on_losing(mob/living/carbon/owner)
	if(..())
		return TRUE
	UnregisterSignal(owner, list(COMSIG_LIVING_TRY_PUT_IN_HAND, COMSIG_LIVING_TRY_PULL))
	owner.reach_length = max(1, owner.reach_length - 1)

/// Za duże przedmioty wypadają z rozciągliwych rąk
/datum/mutation/elastic_arms/proc/on_owner_equipping_item(mob/living/carbon/source, obj/item/pick_item)
	SIGNAL_HANDLER
	if((pick_item.w_class > WEIGHT_CLASS_BULKY) && !(pick_item.item_flags & ABSTRACT))
		pick_item.balloon_alert(source, "ręce zbyt wiotkie!")
		return COMPONENT_LIVING_CANT_PUT_IN_HAND

/// Za duże rzeczy i moby nie dają się ciągnąć
/datum/mutation/elastic_arms/proc/on_owner_try_pull(mob/living/carbon/source, atom/movable/target, force)
	SIGNAL_HANDLER
	if(isliving(target))
		var/mob/living/living_target = target
		if(living_target.mob_size > MOB_SIZE_HUMAN)
			living_target.balloon_alert(source, "ręce zbyt wiotkie!")
			return COMSIG_LIVING_CANCEL_PULL
	if(isitem(target))
		var/obj/item/item_target = target
		if(item_target.w_class > WEIGHT_CLASS_BULKY)
			item_target.balloon_alert(source, "ręce zbyt wiotkie!")
			return COMSIG_LIVING_CANCEL_PULL
