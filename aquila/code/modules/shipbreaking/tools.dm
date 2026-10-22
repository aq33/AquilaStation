/// Młot burzący: w strefie złomowania rozbija struktury i maszyny z wraku (Monke: /obj/item/melee/sledgehammer)
/obj/item/melee/sledgehammer
	name = "młot burzący"
	desc = "Ciężkie narzędzie do rozbijania okien, maszyn i innych konstrukcji wraku. W strefie złomowania łamie je znacznie mocniej."
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
	desc = "Laserowa przecinarka i spawarka Rayne Corp. Wbudowana blokada bezpieczeństwa pozwala jej działać tylko w wyznaczonej strefie złomowania."
	icon = 'aquila/icons/obj/shipbreaking.dmi'
	icon_state = "raynewelder"
	item_state = "exwelder"
	toolspeed = 0.2

/obj/item/weldingtool/experimental/rayne/tool_use_check(mob/living/user, amount)
	if(!is_shipbreak_area(user || src))
		balloon_alert(user, "Blokada: działa tylko w strefie złomowania!")
		return FALSE
	return ..()

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
