// AQUILA - port z tgstation (code/game/machinery/dna_infuser/dna_infuser.dm)

/// ile trwa infuzja
#define INFUSING_TIME (4 SECONDS)

/obj/machinery/dna_infuser
	name = "\improper DNA infuser"
	desc = "Wycofana z użytku maszyna genetyczna do łączenia obcego DNA z DNA pacjenta."
	icon = 'aquila/icons/dna_infuser/infuser.dmi'
	icon_state = "infuser"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	active_power_usage = 500
	circuit = /obj/item/circuitboard/machine/dna_infuser
	occupant_typecache = list(/mob/living/carbon/human)

	/// najwyższy tier, który maszyna wszczepi
	var/max_tier_allowed = DNA_MUTANT_TIER_ONE
	/// czy trwa infuzja
	var/infusing = FALSE
	/// próbka, z której pobieramy DNA
	var/atom/movable/infusing_from
	/// wpis, który właśnie wszczepiamy
	var/datum/infuser_entry/infusing_into
	COOLDOWN_DECLARE(message_cooldown)

/obj/machinery/dna_infuser/Destroy()
	infusing_into = null
	infusing_from = null
	return ..()

/obj/machinery/dna_infuser/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == infusing_from)
		infusing_from = null

/obj/machinery/dna_infuser/examine(mob/user)
	. = ..()
	if(!occupant)
		. += "<span class='notice'>Wymaga <b>pacjenta</b>.</span>"
	else
		. += "<span class='notice'>W komorze infuzyjnej jest \"<b>[occupant.name]</b>\".</span>"
	if(!infusing_from)
		. += "<span class='notice'>Brakuje <b>próbki do infuzji</b>.</span>"
	else
		. += "<span class='notice'>W gnieździe próbki jest <b>[infusing_from.name]</b>.</span>"
	. += "<span class='notice'>Obsługa: zdobądź martwe stworzenie. Zależnie od rozmiaru przeciągnij je na maszynę albo włóż do gniazda.</span>"
	. += "<span class='notice'>Pacjent wchodzi do komory, ktoś inny uruchamia maszynę. Voilà! Jeden z twoich organów się... zmienił!</span>"
	. += "<span class='notice'>Alt+klik wyjmuje próbkę, jeśli jest w środku.</span>"
	if(max_tier_allowed < DNA_INFUSER_MAX_TIER)
		. += "<span class='boldnotice'>Obecnie DNA infuser może wszczepiać tylko wpisy tieru [max_tier_allowed].</span>"
		. += "<span class='notice'>Jeśli wszczepisz wpis tieru [max_tier_allowed] aż do odblokowania bonusu, maszyna podniesie maksymalny tier i pozwoli na bardziej złożone infuzje (do tieru [DNA_INFUSER_MAX_TIER]).</span>"
	else
		. += "<span class='boldnotice'>Odblokowano maksymalny tier. Możliwe są wszystkie wpisy DNA.</span>"

/obj/machinery/dna_infuser/interact(mob/user)
	if(user == occupant)
		toggle_open(user)
		return
	if(infusing)
		balloon_alert(user, "nie w trakcie pracy!")
		return
	if(occupant && infusing_from)
		if(!occupant.can_infuse(user))
			playsound(src, 'sound/machines/scanbuzz.ogg', 35, TRUE)
			return
		if(!is_operational)
			balloon_alert(user, "brak zasilania!")
			return
		balloon_alert(user, "rozpoczynam infuzję DNA...")
		start_infuse()
		return
	toggle_open(user)

/obj/machinery/dna_infuser/proc/start_infuse()
	var/mob/living/carbon/human/human_occupant = occupant
	infusing = TRUE
	set_active_power()
	visible_message("<span class='notice'>[src] budzi się do życia i rozpoczyna proces infuzji!</span>")

	infusing_into = infusing_from.get_infusion_entry()
	var/fail_title = ""
	var/fail_explanation = ""
	if(istype(infusing_into, /datum/infuser_entry/fly))
		fail_title = "Nieznane DNA"
		fail_explanation = "Nieznane DNA. Sprawdź w \"Księdze infuzji DNA\"."
	if(infusing_into.tier > max_tier_allowed)
		infusing_into = GLOB.infuser_entries[/datum/infuser_entry/fly]
		fail_title = "Nadmierna złożoność"
		fail_explanation = "DNA zbyt złożone do infuzji. Maszyna musi najpierw wszczepić prostsze DNA."
	playsound(src, 'sound/machines/blender.ogg', 50, TRUE)
	to_chat(human_occupant, "<span class='danger'>Małe igły raz po raz cię nakłuwają!</span>")
	human_occupant.take_overall_damage(10)
	Shake(1, 1, INFUSING_TIME)
	addtimer(CALLBACK(human_occupant, TYPE_PROC_REF(/mob, emote), "scream"), INFUSING_TIME - 1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(end_infuse), fail_explanation, fail_title), INFUSING_TIME)
	update_icon()

/obj/machinery/dna_infuser/proc/end_infuse(fail_explanation, fail_title)
	var/mob/living/carbon/human/human_occupant = occupant
	if(istype(human_occupant) && infusing_into && human_occupant.infuse_organ(infusing_into, infusing_from))
		check_tier_progression(human_occupant)
		to_chat(human_occupant, "<span class='danger'>Czujesz się coraz bardziej... [infusing_into.infusion_desc]?</span>")
	infusing = FALSE
	infusing_into = null
	QDEL_NULL(infusing_from)
	set_idle_power()
	playsound(src, 'sound/machines/microwave/microwave-end.ogg', 100, FALSE)
	if(fail_explanation)
		playsound(src, 'sound/machines/terminal_alert.ogg', 50, TRUE)
		visible_message("<span class='notice'>[src] drukuje raport o błędzie.</span>")
		var/obj/item/paper/printed_paper = new /obj/item/paper(drop_location())
		printed_paper.name = "raport o błędzie - '[fail_title]'"
		printed_paper.add_raw_text(fail_explanation)
		printed_paper.update_icon()
	toggle_open()
	update_icon()

/// czy maszyna powinna przejść na wyższy tier
/obj/machinery/dna_infuser/proc/check_tier_progression(mob/living/carbon/human/target)
	if(max_tier_allowed != DNA_INFUSER_MAX_TIER \
		&& infusing_into.tier == max_tier_allowed \
		&& infusing_into.status_effect_type)
		var/datum/status_effect/organ_set_bonus/bonus = target.has_status_effect(infusing_into.status_effect_type)
		if(!bonus?.bonus_active)
			return
		max_tier_allowed++
		playsound(src, 'sound/machines/ding.ogg', 50, TRUE)
		visible_message("<span class='notice'>[src] dzwoni, zapisując wyniki pełnej infuzji.</span>")

/obj/machinery/dna_infuser/update_icon()
	if(machine_stat & (NOPOWER|BROKEN))
		icon_state = "infuser"
	else if((machine_stat & MAINT) || panel_open)
		icon_state = "infuser_panel"
	else if(infusing)
		icon_state = "infuser_on"
	else
		icon_state = "infuser[state_open ? "_open" : ""]"
	return ..()

/obj/machinery/dna_infuser/power_change()
	. = ..()
	update_icon()

/obj/machinery/dna_infuser/proc/toggle_open(mob/user)
	if(panel_open)
		if(user)
			balloon_alert(user, "najpierw zamknij panel!")
		return
	if(state_open)
		close_machine()
		return
	if(infusing)
		if(user)
			balloon_alert(user, "nie w trakcie pracy!")
		return
	open_machine(drop = FALSE)
	if(occupant)
		dropContents(list(occupant))

/obj/machinery/dna_infuser/attackby(obj/item/I, mob/living/user, params)
	if(!infusing)
		if(default_deconstruction_screwdriver(user, "infuser_panel", "infuser", I))
			update_icon()
			return
		if(default_pry_open(I))
			return
		if(default_deconstruction_crowbar(I))
			return
	if(user.combat_mode || (I.item_flags & ABSTRACT))
		return ..()
	if(!HAS_TRAIT(I, TRAIT_VALID_DNA_INFUSION))
		return ..()
	if(!is_valid_infusion(I, user))
		return
	if(!user.transferItemToLoc(I, src))
		to_chat(user, "<span class='warning'>[I] przykleił się do twojej ręki!</span>")
		return
	infusing_from = I
	balloon_alert(user, "włożono próbkę")

/obj/machinery/dna_infuser/relaymove(mob/living/user, direction)
	try_leave(user)

/obj/machinery/dna_infuser/container_resist(mob/living/user)
	try_leave(user)

/// pacjent próbuje wyjść
/obj/machinery/dna_infuser/proc/try_leave(mob/living/user)
	if(user.stat != CONSCIOUS)
		if(COOLDOWN_FINISHED(src, message_cooldown))
			COOLDOWN_START(src, message_cooldown, 4 SECONDS)
			to_chat(user, "<span class='warning'>Drzwi [src] ani drgną!</span>")
		return
	if(infusing)
		if(COOLDOWN_FINISHED(src, message_cooldown))
			COOLDOWN_START(src, message_cooldown, 4 SECONDS)
			to_chat(user, "<span class='danger'>Drzwi [src] ani drgną, dopóki igły wszczepiają ci DNA!</span>")
		return
	if(state_open)
		return
	open_machine(drop = FALSE)
	if(occupant)
		dropContents(list(occupant))

/// przeciąganie: martwe stworzenie trafia do gniazda próbki, żywy człowiek do komory
/obj/machinery/dna_infuser/MouseDrop_T(atom/movable/target, mob/living/user)
	if(!istype(user) || user.incapacitated() || !Adjacent(user) || !user.Adjacent(target) || !ismovable(target) || target.anchored)
		return
	if(isliving(target))
		var/mob/living/living_target = target
		if(living_target.stat != DEAD && ishuman(living_target))
			if(!state_open || infusing || !user.IsAdvancedToolUser())
				return
			close_machine(living_target)
			return
	else if(!HAS_TRAIT(target, TRAIT_VALID_DNA_INFUSION))
		return
	if(infusing)
		balloon_alert(user, "nie w trakcie pracy!")
		return
	if(!is_valid_infusion(target, user))
		return
	if(target.pulledby)
		target.pulledby.stop_pulling()
	infusing_from = target
	target.forceMove(src)
	balloon_alert(user, "włożono próbkę")

/// próbka musi być martwym stworzeniem albo przedmiotem z DNA
/obj/machinery/dna_infuser/proc/is_valid_infusion(atom/movable/target, mob/user)
	if(infusing_from)
		balloon_alert(user, "najpierw opróżnij maszynę!")
		return FALSE
	if(isliving(target))
		var/mob/living/living_target = target
		if(living_target.stat != DEAD)
			balloon_alert(user, "tylko martwe stworzenia!")
			return FALSE
		if(living_target.client || living_target.mind)
			balloon_alert(user, "tylko bezduszne ciała!")
			return FALSE
	else if(!HAS_TRAIT(target, TRAIT_VALID_DNA_INFUSION))
		balloon_alert(user, "tylko stworzenia!")
		return FALSE
	return TRUE

/obj/machinery/dna_infuser/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	if(infusing)
		balloon_alert(user, "nie w trakcie pracy!")
		return
	if(!infusing_from)
		balloon_alert(user, "brak próbki do wyjęcia!")
		return
	balloon_alert(user, "wyjęto próbkę")
	infusing_from.forceMove(drop_location())
	infusing_from = null

/obj/machinery/dna_infuser/proc/set_active_power()
	use_power = ACTIVE_POWER_USE

/obj/machinery/dna_infuser/proc/set_idle_power()
	use_power = IDLE_POWER_USE

#undef INFUSING_TIME

/obj/item/circuitboard/machine/dna_infuser
	name = "DNA infuser (płytka maszyny)"
	icon_state = "science"
	build_path = /obj/machinery/dna_infuser
	req_components = list(
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/cable_coil = 2,
	)

/datum/design/board/dnainfuser
	name = "Projekt maszyny (DNA infuser)"
	desc = "Płytka do budowy DNA infusera, który miesza DNA zwierząt i ludzi, tworząc hybrydy."
	id = "dnainfuser"
	build_path = /obj/item/circuitboard/machine/dna_infuser
	category = list("Medical Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

// dopisane, żeby zmiany upstreamu w tym węźle nadal działały
/datum/techweb_node/cloning/New()
	. = ..()
	design_ids += "dnainfuser"
