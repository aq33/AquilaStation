// AQUILA - bojowe cyberserce zasilane rdzeniem anomalii (tg code/modules/surgery/organs/internal/heart/heart_anomalock.dm, tgstation#82722).
// Cybernetyczne serce z gniazdem na rdzeń anomalii strumieniowej. Z rdzeniem chroni nosiciela przed porażeniem i samo jest
// odporne na EMP, a gdy nosiciel wpada w stan krytyczny, przez 30 s trzyma go na nogach (bez stanu krytycznego, bez bólu)
// i leczy po 5 urazów, oparzeń, toksyn i niedotlenienia na sekundę, póki jest w krytycznym. Potem 5 minut przerwy.
// Serce z rdzeniem da się wszczepić samemu (5 s, 100 obrażeń klatki); wyjęte z rdzeniem wyładowuje się i pada.
// Pominięte z tg: doładowywanie ogniw nosiciela (u nas nie ma get_all_cells), odporność na spowolnienie od obrażeń
// (nie mamy movespeed_mod_immunities), koagulant.
// Ikona: tg (organs.dmi, CC BY-SA 3.0).

/obj/item/organ/heart/cybernetic/aq_anomalock
	name = "woltaiczne serce bojowe"
	desc = "Najnowocześniejsze cyberserce, zaprojektowane dla oddziałów specjalnych Nanotrasen i odtajnione do badań. \
		Utrzymuje ciało na nogach w krytycznym stanie, a energia anomalii chroni nosiciela przed porażeniem, a serce przed EMP. \
		Wymaga rdzenia anomalii strumieniowej."
	icon = 'aquila/icons/obj/robotics/anomalock_heart.dmi'
	icon_state = "anomalock_heart"
	/// Rdzeń anomalii, który zasila serce
	var/obj/item/assembly/signaler/anomaly/core
	/// Jaki rdzeń pasuje
	var/required_anomaly = /obj/item/assembly/signaler/anomaly/flux
	/// Przerwa między ratunkami
	var/survival_cooldown_time = 5 MINUTES
	COOLDOWN_DECLARE(survival_cooldown)

/obj/item/organ/heart/cybernetic/aq_anomalock/prebuilt/Initialize(mapload)
	. = ..()
	core = new /obj/item/assembly/signaler/anomaly/flux(src)
	update_icon()

/obj/item/organ/heart/cybernetic/aq_anomalock/Destroy()
	QDEL_NULL(core)
	return ..()

/// Serce nie ma osobnych stanów bicia, tylko gniazdo z rdzeniem albo bez
/obj/item/organ/heart/cybernetic/aq_anomalock/update_icon()
	icon_state = initial(icon_state) + (core ? "-core" : "")

/obj/item/organ/heart/cybernetic/aq_anomalock/examine(mob/user)
	. = ..()
	. += core ? "<span class='notice'>W gnieździe tkwi rdzeń anomalii. Śrubokrętem da się go wyjąć, póki serce działa.</span>" : "<span class='warning'>Gniazdo na rdzeń anomalii strumieniowej jest puste.</span>"

/obj/item/organ/heart/cybernetic/aq_anomalock/attackby(obj/item/I, mob/user, params)
	if(!istype(I, required_anomaly))
		return ..()
	if(core)
		to_chat(user, "<span class='warning'>W sercu już jest rdzeń!</span>")
		return TRUE
	if(!user.transferItemToLoc(I, src))
		return TRUE
	core = I
	update_icon()
	playsound(src, 'sound/machines/click.ogg', 30, TRUE)
	to_chat(user, "<span class='notice'>Wkładasz rdzeń do gniazda serca.</span>")
	return TRUE

/obj/item/organ/heart/cybernetic/aq_anomalock/screwdriver_act(mob/living/user, obj/item/tool)
	if(!core)
		to_chat(user, "<span class='warning'>Gniazdo jest puste.</span>")
		return TRUE
	if(organ_flags & ORGAN_FAILING)
		to_chat(user, "<span class='warning'>Rdzeń jest wtopiony w martwe serce.</span>")
		return TRUE
	to_chat(user, "<span class='notice'>Wykręcasz rdzeń...</span>")
	if(!tool.use_tool(src, user, 3 SECONDS, volume = 50) || !core)
		return TRUE
	user.put_in_hands(core)
	core = null
	update_icon()
	return TRUE

/obj/item/organ/heart/cybernetic/aq_anomalock/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == core)
		core = null
		update_icon()

/obj/item/organ/heart/cybernetic/aq_anomalock/attack_self(mob/user)
	if(!core || !iscarbon(user))
		return ..()
	var/mob/living/carbon/C = user
	to_chat(C, "<span class='userdanger'>Czarne cyberżyły rozrywają skórę i wciągają serce w klatkę piersiową. To nie był dobry pomysł...</span>")
	if(!do_after(C, 5 SECONDS, target = C))
		return
	if(!C.temporarilyRemoveItemFromInventory(src))
		return
	Insert(C)
	playsound(C, 'sound/weapons/slice.ogg', 100, TRUE)
	C.apply_damage(100, BRUTE, BODY_ZONE_CHEST)
	C.emote("scream")

/obj/item/organ/heart/cybernetic/aq_anomalock/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	. = ..()
	if(!core || owner != M)
		return
	ADD_TRAIT(M, TRAIT_SHOCKIMMUNE, REF(src))
	RegisterSignal(M, COMSIG_MOB_STATCHANGE, PROC_REF(on_stat_change))
	playsound(M, 'sound/magic/charge.ogg', 40, TRUE)

/obj/item/organ/heart/cybernetic/aq_anomalock/Remove(mob/living/carbon/M, special = 0)
	if(M)
		REMOVE_TRAIT(M, TRAIT_SHOCKIMMUNE, REF(src))
		UnregisterSignal(M, COMSIG_MOB_STATCHANGE)
		M.remove_status_effect(/datum/status_effect/aq_voltaic_overdrive)
	. = ..()
	if(core && M && !special)
		do_sparks(5, TRUE, M)
		M.electrocute_act(15, src)
		setOrganDamage(maxHealth)

/obj/item/organ/heart/cybernetic/aq_anomalock/emp_act(severity)
	if(core)
		return EMP_PROTECT_SELF
	return ..()

/obj/item/organ/heart/cybernetic/aq_anomalock/on_life()
	. = ..()
	if(core && owner && owner.health <= owner.crit_threshold)
		activate_survival()

/obj/item/organ/heart/cybernetic/aq_anomalock/proc/on_stat_change(mob/living/source, new_stat)
	SIGNAL_HANDLER
	// tylko stan krytyczny: u nas UNCONSCIOUS to też sen i narkoza, więc liczy się zdrowie, nie sam stan
	if((new_stat == SOFT_CRIT || new_stat == UNCONSCIOUS) && source.health <= source.crit_threshold)
		INVOKE_ASYNC(src, PROC_REF(activate_survival))

/// Ratunek w krytycznym stanie. Zwraca TRUE, gdy się włączył.
/obj/item/organ/heart/cybernetic/aq_anomalock/proc/activate_survival()
	if(!owner || !core || !COOLDOWN_FINISHED(src, survival_cooldown))
		return FALSE
	owner.apply_status_effect(/datum/status_effect/aq_voltaic_overdrive)
	COOLDOWN_START(src, survival_cooldown, survival_cooldown_time)
	addtimer(CALLBACK(src, PROC_REF(notify_cooldown)), survival_cooldown_time)
	return TRUE

/obj/item/organ/heart/cybernetic/aq_anomalock/proc/notify_cooldown()
	if(owner)
		to_chat(owner, "<span class='notice'>Serce znów nabiera mocy.</span>")
		playsound(owner, 'sound/magic/charge.ogg', 30, TRUE)

/datum/status_effect/aq_voltaic_overdrive
	id = "aq_voltaic_overdrive"
	duration = 30 SECONDS
	tick_interval = 1 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/aq_voltaic_overdrive

/datum/status_effect/aq_voltaic_overdrive/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_NOSOFTCRIT, id)
	ADD_TRAIT(owner, TRAIT_NOHARDCRIT, id)
	ADD_TRAIT(owner, TRAIT_ANALGESIA, id)
	owner.add_filter("aq_voltaic", 2, outline_filter(1, "#639BFF"))
	to_chat(owner, "<span class='userdanger'>Czujesz wybuch energii! Teraz albo nigdy!</span>")
	owner.update_stat()

/datum/status_effect/aq_voltaic_overdrive/tick()
	if(owner.health > owner.crit_threshold)
		return
	owner.heal_overall_damage(5, 5)
	owner.adjustOxyLoss(-5)
	owner.adjustToxLoss(-5)

/datum/status_effect/aq_voltaic_overdrive/on_remove()
	REMOVE_TRAIT(owner, TRAIT_NOSOFTCRIT, id)
	REMOVE_TRAIT(owner, TRAIT_NOHARDCRIT, id)
	REMOVE_TRAIT(owner, TRAIT_ANALGESIA, id)
	owner.remove_filter("aq_voltaic")
	to_chat(owner, "<span class='warning'>Serce słabnie.</span>")
	owner.update_stat()
	return ..()

/atom/movable/screen/alert/status_effect/aq_voltaic_overdrive
	name = "Woltaiczne przeciążenie"
	desc = "Energia anomalii zalewa mięśnie i trzyma cię na nogach. Masz 30 sekund, zanim osłabnie!"
	icon_state = "default"

/datum/design/aq_anomalock_heart
	name = "Woltaiczne serce bojowe"
	desc = "Cyberserce zasilane rdzeniem anomalii strumieniowej (rdzeń osobno)."
	id = "aq_anomalock_heart"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 100
	materials = list(/datum/material/titanium = 10000, /datum/material/diamond = 2000, /datum/material/iron = 1000, /datum/material/glass = 1000)
	build_path = /obj/item/organ/heart/cybernetic/aq_anomalock
	category = list("Cyborg", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/techweb_node/anomaly_research/New()
	. = ..()
	design_ids += "aq_anomalock_heart"
