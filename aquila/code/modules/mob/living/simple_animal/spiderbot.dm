// AQUILA - pająk-robot z MMI (AquilaMed 5, etap 13). Port z Paradise (code/modules/mob/living/basic/friendly/spiderbot.dm,
// składanie w code/game/objects/items/robot/robot_parts.dm), sprite'y z Paradise icons/mob/robots.dmi (CC BY-SA 3.0).
// Głowa cyborga z dwoma flashami + manipulator = pusty pająk-robot. Włożone MMI albo pozytronowy mózg przejmuje go:
// mały robot, który chodzi po stołach i przez rury wentylacji, mówi i lekko razi prądem. Karta z dostępem do robotyki
// wyjmuje mózg, spawarka (bez trybu walki) naprawia. Po zniszczeniu mózg wypada. Emag: pająk słucha emagującego
// i wybucha przy zniszczeniu.
// Różnice od Paradise: prosty mob (simple_animal) zamiast basic moba, bez sprawdzania banów na cyborga.

/mob/living/simple_animal/aq_spiderbot
	name = "pająk-robot"
	desc = "Mały, przebierający nóżkami robot. Ktoś musi włożyć do niego mózg."
	icon = 'aquila/icons/mob/spiderbot.dmi'
	icon_state = "spiderbot-chassis"
	icon_living = "spiderbot-chassis"
	icon_dead = "spiderbot-smashed"
	health = 40
	maxHealth = 40
	pass_flags = PASSTABLE
	melee_damage = 2
	melee_damage_type = BURN
	attacktext = "razi prądem"
	attack_sound = "sparks"
	response_help = "głaszcze"
	response_disarm = "odgania"
	response_harm = "depcze"
	speed = 0
	mob_biotypes = list(MOB_ROBOTIC)
	mob_size = MOB_SIZE_SMALL
	speak_emote = list("pika", "klika", "ćwierka")
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 500
	ventcrawler = VENTCRAWLER_ALWAYS
	del_on_death = TRUE
	loot = list(/obj/effect/decal/cleanable/robot_debris)
	/// The brain inside
	var/obj/item/mmi/mmi
	var/emagged = FALSE

/mob/living/simple_animal/aq_spiderbot/Destroy()
	if(emagged)
		QDEL_NULL(mmi)
		explosion(get_turf(src), -1, -1, 3, 5)
	else
		eject_brain()
	return ..()

/mob/living/simple_animal/aq_spiderbot/attackby(obj/item/O, mob/living/user, params)
	if(istype(O, /obj/item/mmi))
		var/obj/item/mmi/B = O
		if(mmi)
			to_chat(user, "<span class='warning'>W [src] już jest mózg!</span>")
			return TRUE
		if(!B.brainmob?.mind || B.brainmob.stat == DEAD)
			to_chat(user, "<span class='warning'>[B] nie reaguje, nie ma sensu go wkładać.</span>")
			return TRUE
		if(!user.transferItemToLoc(B, src))
			return TRUE
		mmi = B
		to_chat(user, "<span class='notice'>Wkładasz [B] do [src].</span>")
		transfer_personality(B)
		update_icon()
		return TRUE
	var/obj/item/card/id/id_card = O.GetID()
	if(id_card)
		if(!mmi)
			to_chat(user, "<span class='warning'>[src] nie ma mózgu, który dałoby się wyjąć.</span>")
		else if(emagged)
			to_chat(user, "<span class='warning'>[src] nie reaguje na kartę.</span>")
		else if(ACCESS_ROBOTICS in id_card.access)
			to_chat(user, "<span class='notice'>Przeciągasz kartę i wyjmujesz mózg z [src].</span>")
			eject_brain()
		else
			to_chat(user, "<span class='warning'>Przeciągasz kartę, ale nic się nie dzieje.</span>")
		return TRUE
	return ..()

/mob/living/simple_animal/aq_spiderbot/welder_act(mob/living/user, obj/item/I)
	if(user.combat_mode || user == src)
		return FALSE
	. = TRUE
	if(health >= maxHealth)
		to_chat(user, "<span class='warning'>[src] nie potrzebuje naprawy.</span>")
		return
	if(!I.use_tool(src, user, 0, volume = 50, amount = 1))
		return
	adjustHealth(-5)
	user.visible_message("<span class='notice'>[user] naprawia [src].</span>", "<span class='notice'>Naprawiasz [src].</span>")

/mob/living/simple_animal/aq_spiderbot/emag_act(mob/user)
	if(emagged)
		to_chat(user, "<span class='warning'>[src] nie reaguje.</span>")
		return
	emagged = TRUE
	maxHealth = 60
	health = 60
	to_chat(user, "<span class='notice'>Zwierasz zabezpieczenia i nadpisujesz pamięć [src].</span>")
	to_chat(src, "<span class='userdanger'>Ktoś cię zemagował: jesteś teraz całkowicie lojalny wobec [user] i wykonujesz każdy rozkaz!</span>")
	log_combat(user, src, "emagged")

/mob/living/simple_animal/aq_spiderbot/proc/transfer_personality(obj/item/mmi/M)
	M.brainmob.mind.transfer_to(src)
	name = "pająk-robot ([M.brainmob.name])"
	real_name = name

/mob/living/simple_animal/aq_spiderbot/update_icon_state()
	if(mmi)
		icon_state = istype(mmi, /obj/item/mmi/posibrain) ? "spiderbot-chassis-posi" : "spiderbot-chassis-mmi"
	else
		icon_state = "spiderbot-chassis"
	icon_living = icon_state
	return ..()

/mob/living/simple_animal/aq_spiderbot/proc/eject_brain()
	if(!mmi)
		return
	var/obj/item/mmi/brain = mmi
	mmi = null
	brain.forceMove(drop_location())
	if(mind && brain.brainmob)
		mind.transfer_to(brain.brainmob)
	name = initial(name)
	real_name = name
	if(!QDELETED(src))
		update_icon()

/mob/living/simple_animal/aq_spiderbot/examine(mob/user)
	. = ..()
	if(mmi)
		. += "<span class='notice'>W środku pracuje [mmi].</span>"
	if(emagged)
		. += "<span class='warning'>Z gniazda karty sypią się iskry.</span>"

/// A cyborg head with two flashes and a manipulator becomes a spider-bot
/obj/item/bodypart/head/robot/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stock_parts/manipulator) && flash1 && flash2)
		if(!user.temporarilyRemoveItemFromInventory(W))
			return
		to_chat(user, "<span class='notice'>Montujesz manipulator i przerabiasz głowę na pająka-robota.</span>")
		new /mob/living/simple_animal/aq_spiderbot(get_turf(src))
		qdel(W)
		qdel(src)
		return
	return ..()
