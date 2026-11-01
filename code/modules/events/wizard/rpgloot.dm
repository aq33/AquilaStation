/datum/round_event_control/wizard/rpgloot //its time to minmax your shit
	name = "RPG Loot"
	weight = 3
	typepath = /datum/round_event/wizard/rpgloot
	max_occurrences = 1
	earliest_start = 0 MINUTES

/datum/round_event/wizard/rpgloot/start()
	var/upgrade_scroll_chance = 0
	for(var/obj/item/I in world)
		CHECK_TICK

		if(!(I.flags_1 & INITIALIZED_1))
			continue

		if(!istype(I.rpg_loot))
			I.rpg_loot = new(I)

		if(istype(I, /obj/item/storage))
			var/obj/item/storage/S = I
			var/datum/component/storage/STR = S.GetComponent(/datum/component/storage)
			if(prob(upgrade_scroll_chance) && S.contents.len < STR.max_items && !S.invisibility)
				var/obj/item/upgradescroll/scroll = new(get_turf(S))
				SEND_SIGNAL(S, COMSIG_TRY_STORAGE_INSERT, scroll, null, TRUE, TRUE)
				upgrade_scroll_chance = max(0,upgrade_scroll_chance-100)
				if(isturf(scroll.loc))
					qdel(scroll)

			upgrade_scroll_chance += 25

	GLOB.rpg_loot_items = TRUE

/obj/item/upgradescroll
	name = "zwój wzmacniania przedmiotów"
	desc = "W jakiś sposób ten kawałek papieru można nałożyć na przedmiot, żeby był „lepszy”. Podobno jest ryzyko utraty przedmiotu, jeśli jest już „za dobry”. <i>Wszystko to wydaje się takie arbitralne...</i>"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll"
	w_class = WEIGHT_CLASS_TINY

	var/upgrade_amount = 1
	var/can_backfire = TRUE
	var/uses = 1

/obj/item/upgradescroll/afterattack(obj/item/target, mob/user , proximity)
	. = ..()
	if(!proximity || !istype(target))
		return

	var/datum/rpg_loot/rpg_loot_datum = target.rpg_loot
	var/turf/T = get_turf(target)

	if(!istype(rpg_loot_datum))
		var/original_name = "[target]"
		target.rpg_loot = rpg_loot_datum = new /datum/rpg_loot(target)

		var/span
		var/effect_description
		if(target.rpg_loot.quality >= 0)
			span = "<span class='notice'>"
			effect_description = "<span class='heavy_brass'>lśniącą złotą tarczą</span>"
		else
			span = "<span class='danger'>"
			effect_description = "<span class='umbra_emphasis'>plamistą czarną poświatą</span>"

		T.visible_message("[span][original_name] pokrywa się [effect_description], po czym zmienia się w [target]!</span>")

	else
		var/quality = rpg_loot_datum.quality

		if(can_backfire && quality > 9 && prob((quality - 9)*10))
			T.visible_message("<span class='danger'>[target] <span class='inathneq_large'>gwałtownie świeci na niebiesko</span> przez chwilę, po czym wyparowuje.</span>")
			target.burn()
		else
			T.visible_message("<span class='notice'>[target] <span class='inathneq_small'>świeci na niebiesko</span> i wydaje się jakby \"lepszy\"!</span>")
			rpg_loot_datum.modify(upgrade_amount)

	if(--uses <= 0)
		qdel(src)

/obj/item/upgradescroll/unlimited
	name = "niezawodny zwój nieograniczonego wzmacniania przedmiotów"
	desc = "W jakiś sposób ten kawałek papieru można nałożyć na przedmiot, żeby był „lepszy”. Zwój zrobiono z języków martwych papierowych czarodziejów i można go używać bez ograniczeń i bez żadnych wad."
	uses = INFINITY
	can_backfire = FALSE

/datum/rpg_loot
	var/positive_prefix = "przeciętność"
	var/negative_prefix = "słabość"
	var/suffix = "czegoś głębokiego"
	var/quality = 0

	var/obj/item/attached
	var/original_name

/datum/rpg_loot/New(attached_item=null)
	attached = attached_item

	randomise()

/datum/rpg_loot/Destroy()
	attached = null // AQ EDIT - the item deletes us in its own Destroy(), deleting it back was a qdel loop
	return ..()

/datum/rpg_loot/proc/randomise()
	var/static/list/prefixespositive = list("wielkość", "potęga", "błogosławieństwo", "wyższość", "wzmocnienie", "ostrość", "prawdziwość", "chwała", "krzepa")
	var/static/list/prefixesnegative = list("małość", "liche wykonanie", "plugawość", "podrzędność", "osłabienie", "rdza", "chwiejność", "tragedia", "kalectwo")
	var/static/list/suffixes = list("zabijania orków", "zabijania elfów", "zabijania corgi", "siły", "zręczności", "kondycji", "inteligencji", "mądrości", "charyzmy", "lasu", "wzgórz", "równin", "morza", "słońca", "księżyca", "pustki", "świata", "głupca", "wielu sekretów", "wielu opowieści", "wielu barw", "rozdzierania", "rozłupywania", "nocy", "dnia")

	var/new_quality = pick(1;15, 2;14, 2;13, 2;12, 3;11, 3;10, 3;9, 4;8, 4;7, 4;6, 5;5, 5;4, 5;3, 6;2, 6;1, 6;0)

	suffix = pick(suffixes)
	positive_prefix = pick(prefixespositive)
	negative_prefix = pick(prefixesnegative)

	if(prob(50))
		new_quality = -new_quality

	modify(new_quality)

/datum/rpg_loot/proc/rename()
	var/obj/item/I = attached
	if(!original_name)
		original_name = I.name
	if(quality < 0)
		I.name = "[original_name] [suffix] ([negative_prefix]) [quality]"
	else if(quality == 0)
		I.name = "[original_name] [suffix]"
	else if(quality > 0)
		I.name = "[original_name] [suffix] ([positive_prefix]) +[quality]"

/datum/rpg_loot/proc/modify(quality_mod)
	var/obj/item/I = attached
	quality += quality_mod

	I.force = max(0,I.force + quality_mod)
	I.throwforce = max(0,I.throwforce + quality_mod)

	I.armor = I.armor.modifyAllRatings(quality)

	rename()
