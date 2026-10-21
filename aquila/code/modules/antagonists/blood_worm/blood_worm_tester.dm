// AQUILA - tester hemopasożytów i jego skrzynka w cargo (port z tgstation#93787)

/obj/item/blood_worm_tester
	name = "tester hemopasożytów"
	desc = "Opatentowane przez DeForest Medical Corporation urządzenie do wykrywania hemopasożytów, takich jak osławiony kosmiczny krwawy robak. Badanie podobno bardzo boli."
	icon = 'aquila/icons/obj/blood_worm.dmi'
	icon_state = "tester"
	item_state = "blood_worm_tester"
	lefthand_file = 'aquila/icons/mob/blood_worm_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/blood_worm_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/spent = FALSE

/obj/item/blood_worm_tester/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/blood_worm_tester/update_icon_state()
	icon_state = spent ? "tester_spent" : "tester"
	item_state = spent ? "blood_worm_tester_spent" : "blood_worm_tester"
	return ..()

/obj/item/blood_worm_tester/examine(mob/user)
	. = ..()
	. += spent ? "<span class='notice'>Ten jest już zużyty.</span>" : "<span class='notice'>Jest naładowany na jedno badanie.</span>"

/obj/item/blood_worm_tester/attack(mob/living/target_mob, mob/living/user)
	if(spent)
		target_mob.balloon_alert(user, "już zużyty!")
		return
	if(!user.IsAdvancedToolUser())
		target_mob.balloon_alert(user, "za mało zręczności!")
		return
	if(!ishuman(target_mob))
		target_mob.balloon_alert(user, "tylko na ludziach!")
		return
	if(!target_mob.can_inject(user, TRUE, user.zone_selected))
		return

	if(target_mob != user)
		user.visible_message("<span class='danger'>[user] dźga [target_mob] [src]!</span>", \
			"<span class='danger'>Dźgasz [target_mob] [src]!</span>", ignored_mobs = list(target_mob))
		to_chat(target_mob, "<span class='userdanger'>[user] dźga cię [src]!</span>")
	else
		user.visible_message("<span class='notice'>[user] dźga się [src].</span>", "<span class='notice'>Dźgasz się [src].</span>")

	log_combat(user, target_mob, "tested", src)
	INVOKE_ASYNC(target_mob, TYPE_PROC_REF(/mob, emote), "scream")
	target_mob.apply_damage(rand(10, 15), BRUTE, check_zone(user.zone_selected))
	SEND_SIGNAL(target_mob, COMSIG_ADD_MOOD_EVENT, "blood_worm_tester", /datum/mood_event/jabbed_with_tester)
	playsound(src, 'sound/items/hypospray.ogg', 50, TRUE)
	say("Skanowanie...")

	// Timer zamiast do_after: ucieczka od badania nie zdradza nosiciela
	addtimer(CALLBACK(src, PROC_REF(report_results), HAS_TRAIT(target_mob, TRAIT_BLOOD_WORM_HOST)), 3 SECONDS)
	spent = TRUE
	update_appearance()
	user.update_inv_hands()

/obj/item/blood_worm_tester/proc/report_results(is_worm)
	if(is_worm)
		say("Wykryto aktywnego hemopasożyta!")
		playsound(src, 'sound/machines/twobeep.ogg', 50, TRUE)
	else
		say("Brak nieprawidłowych odczytów.")
		playsound(src, 'sound/machines/buzz-two.ogg', 40, TRUE)

/datum/mood_event/jabbed_with_tester
	description = "<span class='warning'>Dźgnięcie tym testerem naprawdę bolało.</span>\n"
	mood_change = -4
	timeout = 5 MINUTES

/datum/supply_pack/security/blood_worm_testers
	name = "Hemoparasite Testing Crate"
	desc = "Cztery jednorazowe testery hemopasożytów. Dokładnie wykrywają, czy w pacjencie siedzi hemopasożyt, np. osławiony kosmiczny krwawy robak. \
		DeForest Medical Corporation nie odpowiada za urazy psychiczne ani fizyczne pacjentów spowodowane niewłaściwym użyciem. Wymaga dostępu ochrony."
	cost = 5000
	contains = list(
		/obj/item/blood_worm_tester,
		/obj/item/blood_worm_tester,
		/obj/item/blood_worm_tester,
		/obj/item/blood_worm_tester,
	)
	crate_name = "hemoparasite testing crate"
