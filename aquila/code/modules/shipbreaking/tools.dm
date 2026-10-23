/// Młot burzący: w strefie złomowania rozbija struktury i maszyny z wraku (Monke: /obj/item/melee/sledgehammer)
/obj/item/melee/sledgehammer
	name = "młot burzący"
	desc = "Ciężkie narzędzie do rozbijania maszyn, mebli, okien i innych przedmiotów we wraku. W strefie złomowania łamie je znacznie mocniej. Ściany i podłogi tnie się spawarką."
	icon = 'aquila/icons/obj/shipbreaking.dmi'
	icon_state = "sledgehammer"
	item_state = "sledgehammer"
	lefthand_file = 'aquila/icons/mob/inhands/shipbreaking_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/shipbreaking_righthand.dmi'
	worn_icon = 'aquila/icons/mob/shipbreaking_back.dmi'
	force = 5
	throwforce = 12
	throw_range = 3
	armour_penetration = 10
	hitsound = 'sound/weapons/smash.ogg'
	attack_verb = list("wali", "miażdży", "rozbija", "spłaszcza", "tłucze")
	materials = list(/datum/material/iron = 6000)
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = ITEM_SLOT_BACK
	/// Mnożnik obrażeń dla struktur i maszyn w strefie złomowania
	var/demolition_mod = 3

/obj/item/melee/sledgehammer/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded = 5, force_wielded = 12)

/obj/item/melee/sledgehammer/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || QDELETED(target))
		return
	if(!ISWIELDED(src))
		to_chat(user, "<span class='danger'>[src] jest za ciężki, żeby skutecznie walić nim jedną ręką!</span>")
		return
	if(!isobj(target) || !is_shipbreak_area(target))
		return
	if(!isstructure(target) && !ismachinery(target))
		return
	var/obj/smashed = target
	smashed.take_damage(force * demolition_mod, BRUTE, "melee", FALSE, null, 80)
	playsound(src, 'sound/effects/bang.ogg', 40, TRUE)

/// Spawarka laserowa Rayne: bardzo szybka, ale blokada bezpieczeństwa wyłącza ją poza strefą złomowania
/obj/item/weldingtool/experimental/rayne
	name = "spawarka laserowa Rayne"
	desc = "Laserowa przecinarka i spawarka Rayne Corp. W strefie złomowania tnie wszystko: ściany, dźwigary, podłogi, poszycie, maszyny i silniki. Wbudowana blokada bezpieczeństwa wyłącza ją poza tą strefą."
	icon = 'aquila/icons/obj/shipbreaking.dmi'
	icon_state = "raynewelder"
	item_state = "exwelder"
	toolspeed = 0.2

/obj/item/weldingtool/experimental/rayne/tool_use_check(mob/living/user, amount)
	if(!is_shipbreak_area(user || src))
		balloon_alert(user, "Blokada: działa tylko w strefie złomowania!")
		return FALSE
	return ..()

// W strefie złomowania tnie wszystko do gołej próżni: ścianę na dźwigar, dźwigar na szkielet,
// podłogę na poszycie i poszycie na złom, a maszyny i konstrukcje (też silniki) rozbiera na części
/obj/item/weldingtool/experimental/rayne/tool_attack_chain(mob/user, atom/target, is_right_clicking)
	if(!is_shipbreak_area(target) || !get_cut_time(target))
		return ..()
	INVOKE_ASYNC(src, PROC_REF(cut_down), user, target)
	return TRUE

/// Czas cięcia przed toolspeed, 0 = tej rzeczy spawarka nie tnie (wtedy działa zwykła spawarka)
/obj/item/weldingtool/experimental/rayne/proc/get_cut_time(atom/target)
	if(isclosedturf(target))
		return istype(target, /turf/closed/wall) ? 10 SECONDS : 0
	if(isopenturf(target))
		return isgroundlessturf(target) ? 0 : 5 SECONDS
	if(istype(target, /obj/structure/girder))
		return 5 SECONDS
	if(isstructure(target) || ismachinery(target))
		var/obj/O = target
		if(O.resistance_flags & INDESTRUCTIBLE)
			return 0
		return 10 SECONDS
	return 0

/obj/item/weldingtool/experimental/rayne/proc/cut_down(mob/user, atom/target)
	if(!tool_start_check(user, 1))
		return
	user.visible_message("<span class='notice'>[user] tnie [target] spawarką laserową.</span>",
		"<span class='notice'>Zaczynasz ciąć [target]...</span>",
		"<span class='italics'>Słyszysz syk lasera.</span>")
	// do_after nie przerywa cięcia, gdy turf zostanie w tym czasie podmieniony (np. drugie cięcie tej samej podłogi)
	var/target_type = target.type
	if(!use_tool(target, user, get_cut_time(target), 1, 50) || QDELETED(target) || target.type != target_type || !is_shipbreak_area(target))
		return
	if(istype(target, /turf/closed/wall))
		var/turf/closed/wall/wall = target
		wall.dismantle_wall()
	else if(isopenturf(target))
		var/turf/open/floor_turf = target
		if(isplatingturf(floor_turf))
			new /obj/item/stack/scrap/plating(floor_turf)
		floor_turf.ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
	else
		var/obj/O = target
		O.deconstruct(TRUE)

/obj/structure/closet/secure_closet/shipbreaker
	name = "szafka złomiarza"
	desc = "Sprzęt do rozbierania wraków przyciągniętych magnesem."
	req_access = list(ACCESS_MINING)
	icon_state = "eng"
	icon_door = "eng_tool"

/obj/structure/closet/secure_closet/shipbreaker/PopulateContents()
	..()
	new /obj/item/melee/sledgehammer(src)
	new /obj/item/weldingtool/experimental/rayne(src)
	new /obj/item/storage/toolbox/mechanical(src)
	new /obj/item/storage/toolbox/electrical(src)
	new /obj/item/tank/jetpack/void(src)
	new /obj/item/extinguisher(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/pushbroom(src)
