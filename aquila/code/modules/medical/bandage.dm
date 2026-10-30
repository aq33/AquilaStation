// AQUILA - first aid bandage from tgstation (code/game/objects/items/stacks/medical.dm, crafting/tools.dm).
// One use: heals some brute damage on the limb and slightly slows bleeding. The makeshift one is crafted from cloth.
// Sprites from tgstation, already in aquila/icons/obj/medical/stack_medical.dmi (CC-BY-SA 3.0).

/obj/item/stack/medical/bandage
	name = "bandaż"
	singular_name = "bandaż"
	desc = "Bandaż marki DeForest do podstawowej pierwszej pomocy przy obrażeniach od tępych urazów."
	icon = 'aquila/icons/obj/medical/stack_medical.dmi'
	icon_state = "bandage"
	item_state = "bandage"
	lefthand_file = 'aquila/icons/mob/inhands/equipment/medkit_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/equipment/medkit_righthand.dmi'
	novariants = TRUE
	amount = 1
	max_amount = 1
	heal_brute = 25
	self_delay = 3 SECONDS
	grind_results = list(/datum/reagent/medicine/bicaridine = 2)
	/// How much bleeding it holds back, a light dressing compared to gauze
	var/bleed_suppression = BLEED_SCRATCH
	var/other_delay = 1 SECONDS

/obj/item/stack/medical/bandage/makeshift
	name = "prowizoryczny bandaż"
	singular_name = "prowizoryczny bandaż"
	desc = "Naprędce zrobiony bandaż do podstawowej pierwszej pomocy przy obrażeniach od tępych urazów."
	icon_state = "bandage_makeshift"

/obj/item/stack/medical/bandage/attack(mob/living/M, mob/user)
	if(!iscarbon(M))
		return ..()
	INVOKE_ASYNC(src, PROC_REF(apply_bandage), M, user)

/obj/item/stack/medical/bandage/proc/apply_bandage(mob/living/carbon/patient, mob/user)
	if(patient in user.do_afters)
		return
	if(patient.stat == DEAD)
		to_chat(user, "<span class='danger'>[patient] nie żyje, nie możesz mu pomóc!</span>")
		return
	if(!patient.can_inject(user, TRUE))
		return
	var/obj/item/bodypart/affecting = patient.get_bodypart(check_zone(user.zone_selected))
	if(!affecting)
		to_chat(user, "<span class='warning'>[patient] nie ma tej części ciała: [strefa_pl(user.zone_selected)]!</span>")
		return
	if(!IS_ORGANIC_LIMB(affecting))
		to_chat(user, "<span class='warning'>Bandaż nie pomoże robotycznej kończynie!</span>")
		return
	if(!affecting.brute_dam && !patient.is_bleeding())
		affecting.balloon_alert(user, "nic do opatrzenia")
		return
	var/self = patient == user
	user.visible_message("<span class='notice'>[user] zaczyna owijać [affecting.name] [patient] bandażem.</span>", "<span class='notice'>Zaczynasz owijać [affecting.name][self ? "" : " [patient]"] bandażem.</span>")
	if(!do_mob(user, patient, self ? self_delay : other_delay))
		return
	if(QDELETED(affecting) || affecting.owner != patient || !get_amount())
		return
	if(patient.is_bleeding())
		patient.suppress_bloodloss(bleed_suppression)
	if(affecting.heal_damage(heal_brute, 0))
		patient.update_damage_overlays()
	user.visible_message("<span class='green'>[user] owija [affecting.name] [patient] bandażem.</span>", "<span class='green'>Owijasz [affecting.name][self ? "" : " [patient]"] bandażem.</span>")
	use(1)

/datum/crafting_recipe/makeshift_bandage
	name = "Prowizoryczny bandaż"
	reqs = list(
		/obj/item/stack/sheet/cotton/cloth = 3,
		/datum/reagent/medicine/bicaridine = 10,
	)
	result = /obj/item/stack/medical/bandage/makeshift
	category = CAT_TOOLS
