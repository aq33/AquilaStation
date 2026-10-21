// AQUILA - krwawy robak: nosiciel, jedzenie krwi i komunikaty (port z tgstation#93787)

/// Cechy, które nosiciel dostaje od robaka
#define BLOOD_WORM_HOST_TRAITS list(TRAIT_NOBREATH, TRAIT_STABLEHEART, TRAIT_STABLELIVER, TRAIT_NOCRITDAMAGE, TRAIT_NOHUNGER, TRAIT_NOTHIRST, TRAIT_BLOOD_HUD, TRAIT_BLOOD_WORM_HOST)

/mob/living/simple_animal/hostile/blood_worm/proc/enter_host(mob/living/carbon/human/new_host, silent = FALSE, gain_progress = TRUE)
	if(!silent)
		playsound(src, 'sound/magic/enter_blood.ogg', 60, TRUE)
		visible_message("<span class='danger'><b>[src] wnika w [new_host]!</b></span>", \
			"<span class='notice'>Wnikasz w [new_host].</span>", \
			"<span class='italics'>Słyszysz mlaśnięcie.</span>")
		new /obj/effect/temp_visual/blood_worm_invade_host(get_turf(new_host), effect_name)

	host = new_host

	RegisterSignal(host, COMSIG_PARENT_QDELETING, PROC_REF(on_host_qdel))
	RegisterSignal(host, COMSIG_MOB_STATCHANGE, PROC_REF(on_host_stat_changed))
	RegisterSignal(host, COMSIG_LIVING_LIFE, PROC_REF(on_host_life))
	RegisterSignal(host, COMSIG_MOB_EXAMINATE, PROC_REF(on_host_examinate))

	ADD_TRAIT(src, TRAIT_IMMOBILIZED, BLOOD_WORM_HOST_TRAIT)
	ADD_TRAIT(src, TRAIT_MUTE, BLOOD_WORM_HOST_TRAIT)
	ADD_TRAIT(src, TRAIT_EMOTEMUTE, BLOOD_WORM_HOST_TRAIT)
	for(var/host_trait in BLOOD_WORM_HOST_TRAITS)
		ADD_TRAIT(host, host_trait, BLOOD_WORM_HOST_TRAIT)
	host.setOxyLoss(0)
	host.physiology?.bleed_mod *= BLOOD_WORM_BLEED_MOD
	GLOB.blood_worm_team_hud.add_to_hud(host)

	remove_actions(src, innate_actions)
	grant_actions(src, host_actions)

	var/cached_blood_volume = host.blood_volume
	if(gain_progress)
		// Krew nosiciela liczy się do wzrostu
		consume_blood(cached_blood_volume, host.get_blood_synth_content(), should_heal = FALSE)

	// Zdrowie robaka dolewa się do krwi nosiciela
	host.blood_volume = cached_blood_volume + health * BLOOD_WORM_HEALTH_TO_BLOOD
	// Pełne zdrowie robaka wygląda na skanerze jak normalny poziom krwi
	host.shown_blood_multiplier = BLOOD_VOLUME_NORMAL / (maxHealth * BLOOD_WORM_HEALTH_TO_BLOOD)

	forceMove(host)
	START_PROCESSING(SSfastprocess, src)
	sync_health()
	if(!host)
		return

	log_game("[key_name(src)] (blood worm) entered their new host [key_name(host)]")

	if(host.stat != DEAD)
		possess_host()

/mob/living/simple_animal/hostile/blood_worm/proc/leave_host()
	if(!host)
		return
	var/mob/living/carbon/human/old_host = host
	visible_message("<span class='danger'><b>[src] wyłania się z [old_host]!</b></span>", \
		blind_message = "<span class='italics'>Słyszysz mlaśnięcie.</span>", ignored_mobs = list(old_host, src))
	to_chat_self("<span class='notice'>Wyłaniasz się z [old_host].</span>")
	log_game("[key_name(src)] (blood worm) left their host [key_name(old_host)]")

	forceMove(old_host.drop_location()) // To wywoła unregister_host() przez Moved()
	playsound(src, 'sound/magic/exit_blood.ogg', 60, TRUE)
	if(leave_host_duration)
		ADD_TRAIT(src, TRAIT_IMMOBILIZED, "leave_host")
		update_mobility()
		addtimer(CALLBACK(src, PROC_REF(finish_leaving)), leave_host_duration)
	flick("leave-[effect_name]", src)

/mob/living/simple_animal/hostile/blood_worm/proc/finish_leaving()
	REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, "leave_host")
	update_mobility()

/mob/living/simple_animal/hostile/blood_worm/proc/unregister_host()
	if(!host)
		return
	var/mob/living/carbon/human/old_host = host

	possess_worm()
	STOP_PROCESSING(SSfastprocess, src)

	UnregisterSignal(old_host, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_STATCHANGE, COMSIG_LIVING_LIFE, COMSIG_MOB_EXAMINATE))

	REMOVE_TRAITS_IN(src, BLOOD_WORM_HOST_TRAIT)
	REMOVE_TRAITS_IN(old_host, BLOOD_WORM_HOST_TRAIT)
	update_mobility()
	if(old_host.physiology)
		old_host.physiology.bleed_mod /= BLOOD_WORM_BLEED_MOD
	GLOB.blood_worm_team_hud.remove_from_hud(old_host)
	old_host.update_blood_worm_hud_sight()

	remove_actions(src, host_actions)
	grant_actions(src, innate_actions)

	// Robak zabiera ze sobą całą krew
	sync_health(already_ejecting = TRUE)
	old_host.shown_blood_multiplier = 1
	old_host.blood_volume = 0
	old_host.clear_alert(ALERT_BLOODWORM_INFO)
	host = null

	if(old_host.stat != DEAD)
		old_host.death()

	log_game("[key_name(src)] (blood worm) unregistered their host [key_name(old_host)]")

/// Robak przejmuje żywego nosiciela
/mob/living/simple_animal/hostile/blood_worm/proc/possess_host()
	if(!host || is_possessing_host)
		return
	is_possessing_host = TRUE

	if(host.mind)
		backseat = new(host)
		// Zmiennokształtny trafia do zaplecza ze swoim graczem, żeby mógł wypluć robaka
		host.mind.transfer_to(backseat, force_key_move = !!host.mind.has_antag_datum(/datum/antagonist/changeling))

	mind?.transfer_to(host)

	remove_actions(src, host_actions)
	grant_actions(host, host_actions)

	host.grant_language(/datum/language/wormspeak, TRUE, FALSE, LANGUAGE_BLOOD_WORM)
	host.update_blood_worm_hud_sight()
	var/atom/movable/screen/alert/bloodworm_info/info_alert = host.throw_alert(ALERT_BLOODWORM_INFO, /atom/movable/screen/alert/bloodworm_info)
	if(istype(info_alert)) // throw_alert zwraca 0, gdy alert już jest
		info_alert.worm_owner = src

	log_game("[key_name(host)] (blood worm) possessed their host")

/// Robak oddaje ciało nosiciela, a umysł wraca do robaka
/mob/living/simple_animal/hostile/blood_worm/proc/possess_worm()
	if(!host || !is_possessing_host)
		return
	is_possessing_host = FALSE

	host.mind?.transfer_to(src)

	if(backseat)
		backseat.mind?.transfer_to(host)
		QDEL_NULL(backseat)

	remove_actions(host, host_actions)
	grant_actions(src, host_actions)

	host.remove_language(/datum/language/wormspeak, TRUE, FALSE, LANGUAGE_BLOOD_WORM)
	host.clear_alert(ALERT_BLOODWORM_INFO)
	update_blood_worm_hud_sight()

	log_game("[key_name(src)] (blood worm) unpossessed their host [key_name(host)]")

/mob/living/simple_animal/hostile/blood_worm/proc/on_host_qdel(datum/source, force)
	SIGNAL_HANDLER
	host = null
	qdel(src)

/mob/living/simple_animal/hostile/blood_worm/proc/on_host_stat_changed(datum/source, new_stat)
	SIGNAL_HANDLER
	// Sygnał idzie przed zmianą statu, więc przejęcie sprawdzamy chwilę później
	addtimer(CALLBACK(src, PROC_REF(check_possession)), 1)

/mob/living/simple_animal/hostile/blood_worm/proc/check_possession()
	if(!host)
		return
	if(host.stat == DEAD)
		possess_worm()
	else
		possess_host()

/mob/living/simple_animal/hostile/blood_worm/proc/on_host_life(datum/source, seconds, times_fired)
	SIGNAL_HANDLER
	var/delta = seconds || 2
	// Poza nosicielem robak leczy się w swoim Life()
	adjust_worm_health(regen_rate * delta)
	host.setOxyLoss(0)

	if(!is_possessing_host && COOLDOWN_FINISHED(src, host_bleed_alert_cooldown) && host.is_bleeding())
		to_chat_self("<span class='userdanger'>Twój nosiciel krwawi!</span>")
		COOLDOWN_START(src, host_bleed_alert_cooldown, 15 SECONDS)

	if(host.bodytemperature > maxbodytemp)
		adjust_worm_health(-unsuitable_heat_damage * damage_coeff[BURN] * delta)
		if(COOLDOWN_FINISHED(src, host_heat_alert_cooldown))
			to_chat_self("<span class='userdanger'>Twoja krew się gotuje!</span>")
			COOLDOWN_START(src, host_heat_alert_cooldown, 15 SECONDS)

	sync_health()

// Zmiana krwi nosiciela od razu zmienia zdrowie robaka
/mob/living/simple_animal/hostile/blood_worm/process(delta_time)
	if(!host)
		return PROCESS_KILL
	sync_health()

/mob/living/simple_animal/hostile/blood_worm/proc/consume_blood(blood_amount, synth_content = 0, should_heal = TRUE)
	if(blood_amount <= 0)
		return
	synth_content = clamp(synth_content, 0, 1)

	var/was_synth_capped = consumed_synth_blood >= maximum_synth_blood
	var/was_ready_to_mature = cocoon_action && get_consumed_blood() >= cocoon_action.total_blood_required

	var/added_normal_blood = blood_amount * (1 - synth_content)
	var/added_synth_blood = blood_amount * synth_content * synth_blood_efficiency
	var/added_total_blood = added_normal_blood + added_synth_blood

	consumed_synth_blood = min(consumed_synth_blood + added_synth_blood, maximum_synth_blood)
	consumed_normal_blood += added_normal_blood

	if(!was_synth_capped && consumed_synth_blood >= maximum_synth_blood)
		balloon_alert_self("limit syntetycznej krwi!")
	if(cocoon_action && !was_ready_to_mature && get_consumed_blood() >= cocoon_action.total_blood_required)
		balloon_alert_self("gotowy do dojrzewania!")

	if(should_heal)
		// Syntetyczna krew leczy tak samo dobrze
		adjust_worm_health(blood_amount * BLOOD_WORM_BLOOD_TO_HEALTH)

	SEND_SIGNAL(src, COMSIG_BLOOD_WORM_CONSUMED_BLOOD, added_normal_blood, added_synth_blood, added_total_blood)
	cocoon_action?.UpdateButtonIcon()

/mob/living/simple_animal/hostile/blood_worm/proc/reset_consumed_blood()
	consumed_normal_blood = 0
	consumed_synth_blood = 0

/mob/living/simple_animal/hostile/blood_worm/proc/get_consumed_blood()
	return consumed_normal_blood + consumed_synth_blood

/mob/living/simple_animal/hostile/blood_worm/proc/on_examinate(datum/source, atom/target)
	SIGNAL_HANDLER
	add_special_examining_messages(target, src)

/mob/living/simple_animal/hostile/blood_worm/proc/on_host_examinate(datum/source, atom/target)
	SIGNAL_HANDLER
	if(is_possessing_host)
		add_special_examining_messages(target, host)

/// Robak przy oględzinach widzi, ile krwi ma cel i ile by mu dała
/mob/living/simple_animal/hostile/blood_worm/proc/add_special_examining_messages(atom/target, mob/viewer)
	if(!isliving(target) || target == host || target == src)
		return
	var/mob/living/bloodbag = target
	var/cached_blood_volume = bloodbag.get_shown_blood_volume()
	if(cached_blood_volume <= 0 || !bloodbag.get_blood_id())
		return
	cached_blood_volume = bloodbag.blood_volume

	var/synth_content = bloodbag.get_blood_synth_content()
	var/normal_content = 1 - synth_content
	var/normal_blood_after = consumed_normal_blood + cached_blood_volume * normal_content
	var/synth_blood_after = min(consumed_synth_blood + cached_blood_volume * synth_content * synth_blood_efficiency, maximum_synth_blood)
	var/total_blood_now = get_consumed_blood()
	var/potential_gain = (normal_blood_after + synth_blood_after) - total_blood_now
	var/rounded_volume = CEILING(cached_blood_volume, 1)

	var/growth_string = ""
	if(HAS_TRAIT(bloodbag, TRAIT_BLOOD_WORM_HOST))
		growth_string = ", ale to nosiciel, nie da się jej wypić"
	else if(cocoon_action && total_blood_now < cocoon_action.total_blood_required)
		var/rounded_growth = CEILING(potential_gain / cocoon_action.total_blood_required * 100, 1)
		if(rounded_growth > 0)
			growth_string = ", wypicie jej dałoby <b>[rounded_growth]%</b> twojego wzrostu"
		else
			growth_string = ", ale wypicie jej nic nie da twojemu wzrostowi"
	else if(cocoon_action && !istype(src, /mob/living/simple_animal/hostile/blood_worm/adult))
		growth_string = ". Już możesz dojrzeć"
	else
		growth_string = ". Już jesteś w pełni dorosły"

	var/synth_string
	if(synth_content <= 0)
		synth_string = "wcale nie jest"
	else if(synth_content >= 1)
		synth_string = "jest całkowicie"
	else
		synth_string = "w [CEILING(synth_content * 100, 1)]% jest"

	to_chat(viewer, "<span class='notice'>[target] ma [rounded_volume] j. krwi[growth_string]. Ta krew <b>[synth_string]</b> syntetyczna.</span>")

/mob/living/simple_animal/hostile/blood_worm/proc/get_info_title()
	return "Zdrowie robaka: [round((get_worm_health() / maxHealth) * 100)]%"

/mob/living/simple_animal/hostile/blood_worm/proc/get_info_desc()
	. = "Wypita krew<br>"
	. += "- zwykła: [CEILING(consumed_normal_blood, 1)] j.<br>"
	. += "- syntetyczna: [CEILING(consumed_synth_blood, 1)] j. (MAKS. [maximum_synth_blood] j.)<br>"
	. += "- razem: [CEILING(get_consumed_blood(), 1)] j."
	if(cocoon_action?.total_blood_required)
		. += "<br>Wzrost: [min(round(get_consumed_blood() / cocoon_action.total_blood_required * 100), 100)]%"

/// Wiadomość do gracza robaka, w nosicielu czy poza nim
/mob/living/simple_animal/hostile/blood_worm/proc/to_chat_self(text)
	to_chat(is_possessing_host ? host : src, text)

/mob/living/simple_animal/hostile/blood_worm/proc/balloon_alert_self(text)
	var/mob/living/self = is_possessing_host ? host : src
	self.balloon_alert(self, text)

/// Martwy mob w nosicielu, w którym czeka umysł pierwotnego właściciela ciała
/mob/living/blood_worm_host
	name = "Nosiciel"
	desc = "...jak ty to oglądasz? TO NAWET NIE MA CIAŁA."
	stat = DEAD
	status_flags = GODMODE
	var/datum/action/changeling_expel_worm/expel_worm_action

/mob/living/blood_worm_host/Destroy()
	QDEL_NULL(expel_worm_action)
	return ..()

/mob/living/blood_worm_host/Login()
	. = ..()
	if(!mind?.has_antag_datum(/datum/antagonist/changeling))
		return
	to_chat(src, "<span class='green'>Krwawy robak w twoim ciele jest bezbronny wobec twojej genetycznej potęgi!</span>")
	if(!expel_worm_action)
		expel_worm_action = new(src)
		expel_worm_action.Grant(src)

/// Zmiennokształtny wypluwa robaka ze swojego ciała
/datum/action/changeling_expel_worm
	name = "Wyplucie robaka"
	desc = "Siłą wyrzuć krwawego robaka ze swojego ciała."
	background_icon_state = "bg_changeling"
	icon_icon = 'aquila/icons/obj/blood_worm.dmi'
	button_icon_state = "expel_worm"

/datum/action/changeling_expel_worm/IsAvailable()
	if(!owner?.mind?.has_antag_datum(/datum/antagonist/changeling))
		return FALSE
	if(!istype(owner, /mob/living/blood_worm_host))
		return FALSE
	if(!HAS_TRAIT(owner.loc, TRAIT_BLOOD_WORM_HOST))
		return FALSE
	return !!(locate(/mob/living/simple_animal/hostile/blood_worm) in owner.loc)

/datum/action/changeling_expel_worm/Trigger()
	if(!..())
		return FALSE
	var/mob/living/simple_animal/hostile/blood_worm/invader = locate() in owner.loc
	var/atom/body = owner.loc
	to_chat(owner, "<span class='danger'>Wyrzucasz [invader] ze swojego ciała!</span>")
	invader.to_chat_self("<span class='userdanger'>Ciało [body] siłą cię wyrzuca!</span>")
	invader.leave_host()
	return TRUE

/// Alert z informacjami o robaku: zdrowie i wypita krew po najechaniu myszą (tgstation#97474)
/atom/movable/screen/alert/bloodworm_info
	name = "Krwawy robak"
	desc = "Najedź myszą, żeby zobaczyć stan robaka."
	icon = 'icons/mob/actions/backgrounds.dmi'
	icon_state = "bg_demon"
	var/mob/living/simple_animal/hostile/blood_worm/worm_owner

/atom/movable/screen/alert/bloodworm_info/Initialize(mapload)
	. = ..()
	add_overlay(mutable_appearance('aquila/icons/mob/actions/actions_blood_worm.dmi', "leech_blood"))

/atom/movable/screen/alert/bloodworm_info/Destroy()
	worm_owner = null
	return ..()

/atom/movable/screen/alert/bloodworm_info/MouseEntered(location, control, params)
	if(!QDELETED(worm_owner))
		name = worm_owner.get_info_title()
		desc = worm_owner.get_info_desc()
	return ..()

#undef BLOOD_WORM_HOST_TRAITS
