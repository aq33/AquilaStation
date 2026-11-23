// AQUILA - klucz resetu syntetyka (CM-SS13 code/game/objects/items/devices/defibrillator.dm, /obj/item/device/defibrillator/synthetic).
// Odpowiednik defibrylatora dla syntetyków: wpięty w port restartuje IPC po krytycznej awarii, a na działającym syntetyku
// czyści błędy oprogramowania (lżejsze urazy pozytronowego mózgu, halucynacje, zawroty, cyfrowe używki). Po użyciu ładuje się 2 minuty.
// Od teraz IPC nie wstaje sam po naprawie obrażeń (bez REVIVESBYHEALING): trzeba go naprawić spawarką i kablem, a potem
// zrestartować kluczem albo operacją reaktywacji (synth_surgery.dm). Klucz jest w projektach od startu rundy (protolathe
// i fabrykator egzoszkieletów) i w apteczce syntetyka.
// Ikona i dźwięki: CM-SS13 (synth_reset_key.dmi, boot_on.ogg, shortbeep.ogg, CC BY-SA 3.0).

/obj/item/aq_synth_reset_key
	name = "klucz resetu syntetyka"
	desc = "Urządzenie wpinane w port serwisowy syntetyka. Naprawia błędy oprogramowania i restartuje syntetyka po krytycznej awarii, potem musi się naładować."
	icon = 'aquila/icons/obj/robotics/synth_reset_key.dmi'
	icon_state = "reset_key"
	w_class = WEIGHT_CLASS_SMALL
	force = 0
	throwforce = 0
	/// Kiedy znów będzie gotowy
	var/ready_at = 0
	/// Czas ładowania po użyciu
	var/recharge_time = 2 MINUTES
	/// Czas wpinania i restartu
	var/use_time = 4 SECONDS

/obj/item/aq_synth_reset_key/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/aq_synth_reset_key/update_icon_state()
	icon_state = is_ready() ? "reset_key_on" : "reset_key"
	return ..()

/obj/item/aq_synth_reset_key/proc/is_ready()
	return world.time >= ready_at

/obj/item/aq_synth_reset_key/examine(mob/user)
	. = ..()
	if(is_ready())
		. += "<span class='notice'>Dioda świeci: klucz jest gotowy.</span>"
	else
		. += "<span class='warning'>Ładuje się, gotowy za [DisplayTimeText(ready_at - world.time)].</span>"

/obj/item/aq_synth_reset_key/attack(mob/living/M, mob/living/user)
	if(!ishuman(M) || (isliving(user) && user.combat_mode))
		return ..()
	INVOKE_ASYNC(src, PROC_REF(try_reset), M, user)

/// Czy to syntetyk z portem serwisowym (pozytronowy mózg w ciele robota)
/obj/item/aq_synth_reset_key/proc/is_synthetic(mob/living/carbon/human/target)
	var/obj/item/organ/brain/brain = target.getorganslot(ORGAN_SLOT_BRAIN)
	return (MOB_ROBOTIC in target.mob_biotypes) && brain && (brain.organ_flags & ORGAN_SYNTHETIC)

/obj/item/aq_synth_reset_key/proc/try_reset(mob/living/carbon/human/target, mob/living/user)
	if(!is_synthetic(target))
		to_chat(user, "<span class='warning'>[target] nie ma portu serwisowego. Klucz działa tylko na syntetyki.</span>")
		return FALSE
	if(!is_ready())
		playsound(src, 'aquila/sound/robotics/reset_key_beep.ogg', 40, FALSE)
		to_chat(user, "<span class='warning'>[src] jeszcze się ładuje.</span>")
		return FALSE
	user.visible_message("<span class='notice'>[user] wpina [src] w port serwisowy [target].</span>", "<span class='notice'>Wpinasz [src] w port serwisowy [target].</span>")
	playsound(src, 'sound/machines/capacitor_charge.ogg', 40, FALSE)
	if(!do_mob(user, target, use_time))
		return FALSE
	if(!is_ready() || !is_synthetic(target))
		return FALSE
	. = target.stat == DEAD ? reboot(target, user) : repair_software(target, user)
	if(.)
		ready_at = world.time + recharge_time
		update_icon()
		addtimer(CALLBACK(src, PROC_REF(recharged)), recharge_time)

/obj/item/aq_synth_reset_key/proc/recharged()
	update_icon()
	playsound(src, 'sound/machines/ping.ogg', 20, FALSE)

/// Restart po krytycznej awarii
/obj/item/aq_synth_reset_key/proc/reboot(mob/living/carbon/human/target, mob/living/user)
	var/refusal = target.aq_synth_reboot_refusal()
	if(refusal)
		playsound(src, 'aquila/sound/robotics/reset_key_beep.ogg', 40, FALSE)
		switch(refusal)
			if(AQ_SYNTH_REBOOT_LOST)
				user.visible_message("<span class='warning'>[src] brzęczy: jednostka nie odpowiada, przywrócenie jest niemożliwe. Dalsze próby są bezcelowe.</span>")
			if(AQ_SYNTH_REBOOT_DNR)
				user.visible_message("<span class='warning'>[src] brzęczy: jednostka odmawia restartu (DNR). Dalsze próby są bezcelowe.</span>")
			if(AQ_SYNTH_REBOOT_BRAIN)
				user.visible_message("<span class='warning'>[src] brzęczy: pozytronowy mózg jest nieodwracalnie uszkodzony. Dalsze próby są bezcelowe.</span>")
			else
				user.visible_message("<span class='warning'>[src] brzęczy: stan jednostki nie pozwala na restart. Najpierw napraw uszkodzenia.</span>")
		return FALSE
	target.notify_ghost_cloning("Ktoś restartuje twoje ciało!", source = target)
	target.grab_ghost()
	target.revive() // ludzka wersja revive() nic nie zwraca, więc liczy się stat
	if(target.stat == DEAD)
		playsound(src, 'aquila/sound/robotics/reset_key_beep.ogg', 40, FALSE)
		user.visible_message("<span class='warning'>[src] brzęczy: restart nieudany.</span>")
		return FALSE
	playsound(src, 'aquila/sound/robotics/reset_key_boot.ogg', 50, FALSE)
	user.visible_message("<span class='notice'>[src] piszczy: restart zakończony. [target] uruchamia się ponownie.</span>")
	return TRUE

/// Dlaczego wyłączonego syntetyka nie da się zrestartować: te same warunki co defibrylator (defib.dm, defib_reasons.dm),
/// żeby IPC nie umierał od razu ponownie i nie wstawał bez gracza. Null = restart możliwy.
/mob/living/carbon/human/proc/aq_synth_reboot_refusal()
	if(suiciding || ishellbound())
		return AQ_SYNTH_REBOOT_LOST
	if(has_dnr())
		return AQ_SYNTH_REBOOT_DNR
	var/obj/item/organ/brain/brain = getorganslot(ORGAN_SLOT_BRAIN)
	if(QDELETED(brain) || brain.brain_death || (brain.organ_flags & ORGAN_FAILING) || brain.suicided || brain.brainmob?.suiciding)
		return AQ_SYNTH_REBOOT_BRAIN
	if(!can_be_revived())
		return AQ_SYNTH_REBOOT_DAMAGE
	return null

/// Naprawa błędów oprogramowania działającego syntetyka
/obj/item/aq_synth_reset_key/proc/repair_software(mob/living/carbon/human/target, mob/living/user)
	target.cure_trauma_type(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_BASIC)
	target.adjustOrganLoss(ORGAN_SLOT_BRAIN, -20)
	target.adjust_hallucinations(-120 SECONDS)
	target.dizziness = 0
	target.confused = 0
	target.jitteriness = 0
	target.aq_clear_overloaders()
	playsound(src, 'aquila/sound/robotics/reset_key_boot.ogg', 50, FALSE)
	to_chat(target, "<span class='notice'>Restart podprogramów: błędy wyczyszczone.</span>")
	user.visible_message("<span class='notice'>[src] piszczy: błędy oprogramowania [target] wyczyszczone.</span>")
	return TRUE

/datum/design/aq_synth_reset_key
	name = "Klucz resetu syntetyka"
	desc = "Restartuje syntetyki po krytycznej awarii."
	id = "aq_synth_reset_key"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1000, /datum/material/gold = 500)
	build_path = /obj/item/aq_synth_reset_key
	category = list("Cyborg", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/// IPC nie wstaje sam po naprawie obrażeń: potrzebny klucz resetu albo reaktywacja
/datum/species/ipc/New()
	. = ..()
	species_traits -= REVIVESBYHEALING
