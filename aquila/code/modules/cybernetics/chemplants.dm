// Port cybernetyki z Monkestation: chemplanty w nodze (wstrzykują koktajl, gdy zdrowie spadnie) i efekt chempunk.
// Reagenty, których nie mamy, podmienione: determination -> efedryna, aiuri -> kelotan, libital -> bikaridyna.

/obj/item/organ/cyberimp/leg/chemplant
	name = "chemplant testowy"
	desc = "Tego nie powinno tu być!"
	icon = 'aquila/icons/obj/cybernetics/implants.dmi'
	icon_state = "chemplant"
	implant_overlay = "chemplant_overlay"
	/// Co wstrzykuje
	var/list/reagent_list = list()
	/// Poniżej tego zdrowia implant się odpala
	var/health_threshold = 40
	/// Czas uzupełniania zapasu po wstrzyknięciu
	var/refill_time = 60 SECONDS
	/// Do kiedy implant się uzupełnia (koszt: jedzenie, krew, drżenie)
	var/refill_until = 0

/obj/item/organ/cyberimp/leg/chemplant/on_life()
	. = ..()
	if(!owner || (organ_flags & ORGAN_FAILING))
		return
	if(world.time < refill_until)
		// Uzupełnianie kosztuje trochę jedzenia, krwi i nerwów
		if(owner.nutrition > NUTRITION_LEVEL_STARVING && owner.blood_volume > BLOOD_VOLUME_SURVIVE)
			owner.adjust_nutrition(-5)
			owner.blood_volume--
			owner.Jitter(1)
			owner.Dizzy(1)
		else
			refill_until += 2 SECONDS // głodny organizm nie nadąża
		return
	if(owner.health < health_threshold)
		on_effect()

/obj/item/organ/cyberimp/leg/chemplant/emp_act(severity)
	. = ..()
	if(!owner || (. & EMP_PROTECT_SELF))
		return
	health_threshold += rand(-10, 10)
	on_effect()

/obj/item/organ/cyberimp/leg/chemplant/proc/on_effect()
	refill_until = world.time + refill_time
	var/obj/effect/temp_visual/chempunk/punk = new(get_turf(owner))
	punk.color = implant_color
	owner.reagents.add_reagent_list(reagent_list)
	to_chat(owner, span_notice("Czujesz ostre ukłucie, gdy koktajl chemikaliów wpływa ci do krwi!"))

/obj/effect/temp_visual/chempunk
	icon = 'aquila/icons/obj/cybernetics/chempunk.dmi'
	icon_state = "chempunk"
	pixel_x = -32 // 96x96 wyśrodkowane na kafelku
	pixel_y = -32
	layer = BELOW_MOB_LAYER
	duration = 5

/obj/item/organ/cyberimp/leg/chemplant/drugs
	name = "głębokożylny awaryjny wzmacniacz morale"
	desc = "Niebezpieczny implant, którym Syndykat wzmacnia oddziały szturmowe wysyłane na misje samobójcze."
	implant_color = "#74942a"
	syndicate_implant = TRUE
	reagent_list = list(
		/datum/reagent/medicine/ephedrine = 5,
		/datum/reagent/drug/methamphetamine = 5,
		/datum/reagent/medicine/atropine = 5,
	)

/obj/item/organ/cyberimp/leg/chemplant/drugs/l
	zone = BODY_ZONE_L_LEG

/obj/item/organ/cyberimp/leg/chemplant/emergency
	name = "głęboki awaryjny dozownik chemikaliów"
	desc = "Implant ratunkowy, który przy ciężkich obrażeniach wstrzykuje mieszankę leków."
	implant_color = "#2a6194"
	reagent_list = list(
		/datum/reagent/medicine/atropine = 5,
		/datum/reagent/medicine/omnizine = 3,
		/datum/reagent/medicine/leporazine = 3,
		/datum/reagent/medicine/kelotane = 2,
		/datum/reagent/medicine/bicaridine = 2,
	)

/obj/item/organ/cyberimp/leg/chemplant/emergency/l
	zone = BODY_ZONE_L_LEG
