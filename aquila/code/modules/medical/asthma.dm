// AQUILA - astma i inhalator (AquilaMed 5), port z tgstation:
// code/datums/quirks/negative_quirks/asthma.dm, code/datums/diseases/asthma_attack.dm,
// code/modules/reagents/reagent_containers/inhaler.dm (sprite'y z icons/obj/medical/chemical.dmi, CC-BY-SA 3.0).
// Stan zapalny dróg oddechowych rośnie od dymu (także papierosa w ustach) i histaminy, a spada sam i od salbutamolu.
// Co 15-25 minut może przyjść atak (lekki, średni, ciężki, rzadko krytyczny), który podbija stan zapalny, aż zgasi go
// salbutamol z inhalatora albo atak sam przejdzie w remisję. (tg: albuterol, czyli ten sam lek pod nazwą z USA)
// Różnica: w tg stan zapalny zmniejsza ciśnienie gazu w płucach (received_pressure_mult, którego nie mamy).
// U nas zamiast tego daje duszność: wstrzymany oddech i obrażenia z niedotlenienia, tym większe, im większy stan zapalny.

/// Highest inflammation, and the part of it at which breathing stops completely
#define AQ_ASTHMA_MAX_INFLAMMATION 500
#define AQ_ASTHMA_FULL_BLOCK 450

/datum/quirk/asthma
	name = "Astma"
	desc = "Masz astmę: dym i alergeny zaciskają ci drogi oddechowe, a co jakiś czas przychodzi atak duszności. Zaczynasz z inhalatorem salbutamolu."
	value = -2
	gain_text = "<span class='danger'>Oddycha ci się trochę ciężej.</span>"
	lose_text = "<span class='notice'>Nagle oddycha ci się dużo swobodniej!</span>"
	medical_record_text = "Pacjent choruje na astmę."
	icon = "lungs-virus"
	process = TRUE
	/// Current inflammation of the airways, 0 to AQ_ASTHMA_MAX_INFLAMMATION
	var/inflammation = 0
	/// Inflammation lost per second on its own
	var/passive_reduction = 0.15
	/// Inflammation per second in smoke and with a lit cigarette in the mouth
	var/smoke_inflammation = 7.5
	var/cigarette_inflammation = 1
	/// Inflammation per second from histamine, and from a histamine overdose
	var/histamine_inflammation = 2
	var/histamine_od_inflammation = 10
	/// Inflammation per second taken off while salbutamol is in the blood
	var/salbutamol_reduction = 3
	/// The attack going on now
	var/datum/disease/asthma_attack/current_attack
	/// No attack before this time
	var/next_attack = 0
	var/min_time_between_attacks = 15 MINUTES
	var/max_time_between_attacks = 25 MINUTES
	/// Per second chance of an attack once the wait is over
	var/attack_chance = 0.05
	var/last_process = 0
	/// Weights of the attack kinds
	var/static/list/attack_weights = list(
		/datum/disease/asthma_attack/minor = 300,
		/datum/disease/asthma_attack/moderate = 400,
		/datum/disease/asthma_attack/severe = 100,
		/datum/disease/asthma_attack/critical = 1,
	)

/datum/quirk/asthma/add()
	next_attack = world.time + 10 MINUTES
	last_process = world.time

/datum/quirk/asthma/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/inhaler/salbutamol/inhaler = new(get_turf(H))
	var/list/slots = list("lewa kieszeń" = ITEM_SLOT_LPOCKET, "prawa kieszeń" = ITEM_SLOT_RPOCKET, "plecak" = ITEM_SLOT_BACKPACK)
	H.equip_in_one_of_slots(inhaler, slots, qdel_on_fail = FALSE)
	if(inhaler.loc == get_turf(H))
		H.put_in_hands(inhaler)

/datum/quirk/asthma/remove()
	current_attack?.cure(FALSE)
	current_attack = null

/datum/quirk/asthma/on_process()
	var/mob/living/carbon/human/H = quirk_holder
	var/delta = clamp((world.time - last_process) / (1 SECONDS), 0, 5)
	last_process = world.time
	if(!istype(H) || H.stat == DEAD || HAS_TRAIT(H, TRAIT_NOBREATH) || H.IsInStasis() || !H.getorganslot(ORGAN_SLOT_LUNGS))
		return
	adjust_inflammation(-passive_reduction * delta)
	if(!H.internal)
		if(locate(/obj/effect/particle_effect/smoke) in get_turf(H))
			adjust_inflammation(smoke_inflammation * delta)
		var/obj/item/clothing/mask/cigarette/cig = H.wear_mask
		if(istype(cig) && cig.lit)
			adjust_inflammation(cigarette_inflammation * delta)
	var/datum/reagent/toxin/histamine/histamine = H.reagents.has_reagent(/datum/reagent/toxin/histamine)
	if(histamine)
		adjust_inflammation((histamine.overdosed ? histamine_od_inflammation : histamine_inflammation) * delta)
	if(H.reagents.has_reagent(/datum/reagent/medicine/salbutamol))
		adjust_inflammation(-salbutamol_reduction * delta)
	else if(H.client && !current_attack && world.time >= next_attack && prob(attack_chance * delta))
		start_attack()
	apply_breathing_effects(delta)

/// Changes the inflammation; healthy lungs make it grow slower and fall faster
/datum/quirk/asthma/proc/adjust_inflammation(amount)
	var/health_mult = get_lung_health_mult()
	if(amount > 0)
		amount *= (2 - health_mult)
	else
		amount *= health_mult
	var/old_inflammation = inflammation
	inflammation = clamp(inflammation + amount, 0, AQ_ASTHMA_MAX_INFLAMMATION)
	if(inflammation > old_inflammation && prob(3))
		to_chat(quirk_holder, "<span class='warning'>Czujesz, jak zaciska ci się gardło...</span>")

/// 1 for healthy lungs, 0 for failing ones
/datum/quirk/asthma/proc/get_lung_health_mult()
	var/mob/living/carbon/C = quirk_holder
	var/obj/item/organ/lungs/lungs = C.getorganslot(ORGAN_SLOT_LUNGS)
	if(!lungs)
		return 1
	if(lungs.organ_flags & ORGAN_FAILING)
		return 0
	return 1 - (lungs.damage / lungs.maxHealth)

/// How open the airways are, 1 to 0 (tg: the lung pressure multiplier)
/datum/quirk/asthma/proc/get_airway_mult()
	return 1 - min(inflammation / AQ_ASTHMA_FULL_BLOCK, 1)

/// Narrow airways: wheezing, held breath and oxygen damage
/datum/quirk/asthma/proc/apply_breathing_effects(delta)
	var/mob/living/carbon/human/H = quirk_holder
	var/airway = get_airway_mult()
	if(airway >= 0.7)
		return
	if(prob((0.7 - airway) * 20 * delta))
		H.emote(pick("cough", "gasp"))
	if(airway < 0.5 && prob((0.5 - airway) * 40 * delta))
		H.losebreath = max(H.losebreath, 1)
	if(airway < 0.3)
		H.adjustOxyLoss((0.3 - airway) * 6 * delta)

/datum/quirk/asthma/proc/start_attack()
	var/attack_type = pickweight(attack_weights)
	current_attack = new attack_type()
	current_attack.asthma_quirk = src
	if(!quirk_holder.ForceContractDisease(current_attack, FALSE, TRUE))
		current_attack = null
		return
	if(current_attack.alert_ghosts)
		notify_ghosts("[quirk_holder] ma atak astmy: [current_attack.name]!", source = quirk_holder, action = NOTIFY_ORBIT, header = "Atak astmy!")

/// The attack is over: wait before the next one
/datum/quirk/asthma/proc/attack_ended()
	current_attack = null
	next_attack = world.time + rand(min_time_between_attacks, max_time_between_attacks)

// --- Atak astmy ---

/datum/disease/asthma_attack
	form = "Zapalenie oskrzeli"
	name = "Atak astmy"
	desc = "Drogi oddechowe się zaciskają i grożą zatrzymaniem oddechu. Lekkie ataki mogą przejść same, ale każdy jest groźny."
	cure_text = "Salbutamol (inhalator)"
	cures = list(/datum/reagent/medicine/salbutamol)
	agent = "Stan zapalny"
	viable_mobtypes = list(/mob/living/carbon/human)
	disease_flags = CURABLE
	spread_flags = DISEASE_SPREAD_NON_CONTAGIOUS
	spread_text = "Brak"
	visibility_flags = HIDDEN_PANDEMIC
	bypasses_immunity = TRUE
	required_organs = list(/obj/item/organ/lungs)
	infectable_biotypes = list(MOB_ORGANIC, MOB_ROBOTIC, MOB_MINERAL, MOB_UNDEAD)
	cure_chance = 20
	/// The asthma that started it
	var/datum/quirk/asthma/asthma_quirk
	/// Inflammation per second at each stage
	var/list/stage_inflammation = list()
	var/min_time_to_remission = 80 SECONDS
	var/max_time_to_remission = 120 SECONDS
	var/remission_at = 0
	var/in_remission = FALSE
	/// In remission the stage drops by one every this many processes
	var/remission_steps = 5
	var/remission_progress = 0
	var/alert_ghosts = FALSE
	var/last_act = 0

/datum/disease/asthma_attack/New()
	. = ..()
	remission_at = world.time + rand(min_time_to_remission, max_time_to_remission)
	last_act = world.time

/datum/disease/asthma_attack/Destroy()
	asthma_quirk?.attack_ended()
	asthma_quirk = null
	return ..()

// Copy() keeps no asthma_quirk on purpose: copies land in blood samples (get_blood_data) and must not hold the quirk

/datum/disease/asthma_attack/stage_act()
	..()
	if(QDELETED(src) || !affected_mob)
		return
	var/delta = clamp((world.time - last_act) / (1 SECONDS), 0, 5)
	last_act = world.time
	if(HAS_TRAIT(affected_mob, TRAIT_NOBREATH) || !asthma_quirk || QDELETED(asthma_quirk))
		cure(FALSE)
		return
	var/per_second = stage_inflammation["[stage]"]
	if(per_second)
		asthma_quirk.adjust_inflammation(per_second * delta)
	stage_effects()
	if(world.time < remission_at)
		return
	if(!in_remission)
		in_remission = TRUE
		stage_prob = 0
		to_chat(affected_mob, "<span class='notice'>Duszność powoli ustępuje.</span>")
	if(++remission_progress < remission_steps)
		return
	remission_progress = 0
	if(stage <= 1)
		cure(FALSE)
		return
	update_stage(stage - 1)

/// Messages and choking of the attack kind
/datum/disease/asthma_attack/proc/stage_effects()
	return

/datum/disease/asthma_attack/proc/choke()
	to_chat(affected_mob, "<span class='warning'>Na chwilę dławisz się zalegającym śluzem!</span>")
	affected_mob.losebreath++

/datum/disease/asthma_attack/minor
	name = "Atak astmy (lekki)"
	danger = DISEASE_MEDIUM
	stage_prob = 4
	max_stages = 3
	stage_inflammation = list("2" = 0.3, "3" = 0.6)

/datum/disease/asthma_attack/minor/stage_effects()
	if(prob(5))
		to_chat(affected_mob, "<span class='warning'>[pick("Śluz spływa ci po gardle.", "Przełykasz nadmiar śluzu.")]</span>")

/datum/disease/asthma_attack/moderate
	name = "Atak astmy (średni)"
	danger = DISEASE_HARMFUL
	stage_prob = 5
	max_stages = 4
	stage_inflammation = list("2" = 1, "3" = 2, "4" = 4)

/datum/disease/asthma_attack/moderate/stage_effects()
	if(prob(15))
		to_chat(affected_mob, "<span class='warning'>[pick("Śluz spływa ci po gardle.", "Przełykasz nadmiar śluzu.")]</span>")
	if(stage >= 4 && prob(10))
		choke()

/datum/disease/asthma_attack/severe
	name = "Atak astmy (ciężki)"
	danger = DISEASE_DANGEROUS
	stage_prob = 6
	max_stages = 5
	min_time_to_remission = 60 SECONDS
	max_time_to_remission = 80 SECONDS
	stage_inflammation = list("2" = 1, "3" = 3, "4" = 6, "5" = 8)
	alert_ghosts = TRUE

/datum/disease/asthma_attack/severe/stage_effects()
	if(prob(15))
		to_chat(affected_mob, "<span class='warning'>[pick("Śluz spływa ci po gardle.", "Przełykasz nadmiar śluzu.")]</span>")
	else if(prob(20))
		affected_mob.emote("cough")
	if(stage >= 4 && prob(15))
		choke()

/datum/disease/asthma_attack/critical
	name = "Atak astmy (krytyczny)"
	danger = DISEASE_BIOHAZARD
	stage_prob = 85
	max_stages = 6
	cure_chance = 30
	min_time_to_remission = 40 SECONDS
	max_time_to_remission = 60 SECONDS
	stage_inflammation = list("1" = 5, "2" = 6, "3" = 7, "4" = 10, "5" = 20, "6" = 500)
	alert_ghosts = TRUE
	var/warned = FALSE

/datum/disease/asthma_attack/critical/stage_effects()
	if(stage >= 5 && !in_remission)
		stage_prob = 10
	if(stage >= 5 && !warned)
		warned = TRUE
		to_chat(affected_mob, "<span class='userdanger'>Płuca wypełniają ci się płynem! Coraz trudniej złapać oddech!</span>")
	if(stage == 6)
		if(prob(10))
			affected_mob.emote("gasp")
		return
	if(prob(stage * 15))
		affected_mob.emote("cough")
	if(stage >= 4 && prob(15))
		choke()

// --- Salbutamol gasi astmę (w tg robi to albuterol) ---

/datum/reagent/medicine/salbutamol/on_mob_metabolize(mob/living/L)
	. = ..()
	var/datum/quirk/asthma/asthma = locate() in L.roundstart_quirks
	asthma?.adjust_inflammation(-12) // tg: natychmiastowa ulga po wdechu

// --- Inhalator ---

/obj/item/inhaler
	name = "inhalator"
	desc = "Mały inhalator do podawania leków w aerozolu. Potrzebuje kanistra. Użyj na sobie albo na kimś bez maski na twarzy."
	icon = 'aquila/icons/obj/medical/medycyna5.dmi'
	icon_state = "inhaler_generic"
	w_class = WEIGHT_CLASS_SMALL
	custom_materials = list(/datum/material/plastic = 200)
	/// The canister it uses, if any
	var/obj/item/reagent_containers/inhaler_canister/canister
	/// Canister it starts with
	var/initial_canister_path

/obj/item/inhaler/Initialize(mapload)
	. = ..()
	if(ispath(initial_canister_path, /obj/item/reagent_containers/inhaler_canister))
		set_canister(new initial_canister_path(src))

/obj/item/inhaler/Destroy()
	QDEL_NULL(canister)
	return ..()

/obj/item/inhaler/examine(mob/user)
	. = ..()
	if(!canister)
		. += "<span class='notice'>Nie ma w nim kanistra.</span>"
		return
	var/puffs = canister.get_puffs_left()
	. += "<span class='notice'>Jest w nim [canister.name]. Licznik pokazuje, że zostało [puffs] wdechów.</span>"

/obj/item/inhaler/update_overlays()
	. = ..()
	if(canister)
		var/mutable_appearance/under = mutable_appearance(canister.icon, canister.icon_state)
		under.pixel_y = -2
		. += under

/obj/item/inhaler/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == canister)
		canister = null
		update_appearance()

/obj/item/inhaler/proc/set_canister(obj/item/reagent_containers/inhaler_canister/new_canister)
	canister = new_canister
	if(canister && canister.loc != src)
		canister.forceMove(src)
	update_appearance()

/obj/item/inhaler/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/reagent_containers/inhaler_canister))
		return ..()
	if(canister)
		to_chat(user, "<span class='warning'>Najpierw wyjmij stary kanister.</span>")
		return
	if(!do_after(user, 2 SECONDS, target = src) || canister || !user.transferItemToLoc(I, src))
		return
	set_canister(I)
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	to_chat(user, "<span class='notice'>Wkładasz [I] do [src].</span>")

/obj/item/inhaler/attack_self(mob/user)
	if(!canister)
		to_chat(user, "<span class='warning'>W [src] nie ma kanistra.</span>")
		return
	var/obj/item/reagent_containers/inhaler_canister/old = canister
	old.forceMove(drop_location())
	user.put_in_hands(old)
	to_chat(user, "<span class='notice'>Wyjmujesz [old] z [src].</span>")

/obj/item/inhaler/attack(mob/living/M, mob/living/user)
	if(!can_puff(M, user))
		return
	var/self = M == user
	if(!self)
		user.visible_message("<span class='warning'>[user] próbuje wsunąć [src] w usta [M]...</span>", "<span class='notice'>Próbujesz wsunąć [src] w usta [M]...</span>")
	if(!do_mob(user, M, self ? 1 SECONDS : 3 SECONDS) || !can_puff(M, user))
		return
	if(self)
		user.visible_message("<span class='notice'>[user] robi wdech z [src].</span>", "<span class='notice'>Robisz wdech z [src].</span>")
	else
		user.visible_message("<span class='warning'>[user] wsuwa [src] w usta [M] i naciska kanister!</span>", "<span class='notice'>Wsuwasz [src] w usta [M] i naciskasz kanister.</span>")
	canister.puff(user, M)
	log_combat(user, M, "podał(a) inhalatorem", src, canister.reagents.log_list())

/obj/item/inhaler/proc/can_puff(mob/living/target, mob/living/user)
	if(!canister)
		to_chat(user, "<span class='warning'>W [src] nie ma kanistra!</span>")
		return FALSE
	if(!canister.reagents?.total_volume)
		to_chat(user, "<span class='warning'>Kanister jest pusty!</span>")
		return FALSE
	if(!iscarbon(target) || HAS_TRAIT(target, TRAIT_NOBREATH))
		to_chat(user, "<span class='warning'>[target] nie oddycha.</span>")
		return FALSE
	var/mob/living/carbon/C = target
	if(C.is_mouth_covered())
		to_chat(user, "<span class='warning'>Najpierw odsłoń usta.</span>")
		return FALSE
	if(!C.getorganslot(ORGAN_SLOT_LUNGS))
		to_chat(user, "<span class='warning'>[target] nie ma płuc.</span>")
		return FALSE
	return TRUE

/obj/item/inhaler/medical
	icon_state = "inhaler_medical"

/obj/item/inhaler/salbutamol
	name = "inhalator salbutamolu"
	icon_state = "inhaler_medical"
	initial_canister_path = /obj/item/reagent_containers/inhaler_canister/salbutamol

/obj/item/reagent_containers/inhaler_canister
	name = "kanister do inhalatora"
	desc = "Mały kanister z lekiem w aerozolu do inhalatora. Da się go napełnić jak zlewkę."
	icon = 'aquila/icons/obj/medical/medycyna5.dmi'
	icon_state = "canister_generic"
	w_class = WEIGHT_CLASS_TINY
	volume = 30
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(5)
	reagent_flags = OPENCONTAINER
	custom_materials = list(/datum/material/iron = 400)

/obj/item/reagent_containers/inhaler_canister/proc/puff(mob/living/user, mob/living/carbon/target)
	playsound(src, 'sound/effects/spray.ogg', 20, TRUE, -6)
	// Only the transfer: a VAPOR reaction would add the dose a second time through the skin
	reagents.trans_to(target, amount_per_transfer_from_this, transfered_by = user)

/obj/item/reagent_containers/inhaler_canister/proc/get_puffs_left()
	return CEILING(reagents.total_volume / amount_per_transfer_from_this, 1)

/obj/item/reagent_containers/inhaler_canister/salbutamol
	name = "kanister salbutamolu"
	desc = "Kanister z salbutamolem, lekiem rozszerzającym oskrzela. Gasi atak astmy i leczy niedotlenienie."
	icon_state = "canister_medical"
	list_reagents = list(/datum/reagent/medicine/salbutamol = 30)

#undef AQ_ASTHMA_MAX_INFLAMMATION
#undef AQ_ASTHMA_FULL_BLOCK
