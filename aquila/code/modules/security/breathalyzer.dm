// AQUILA - alkomat (Aurora code/game/objects/items/devices/scanners.dm, breath_analyzer). Żandarm albo medyk bada
// oddech: 2 s przy ustach, wynik w umownych promilach i opisowo. Tylko alkohol (resztę daje skaner medyczny).
// Progi według efektów upojenia w code/modules/mob/living/carbon/life.dm.

/obj/item/aq_breathalyzer
	name = "alkomat"
	desc = "Przyłóż do ust badanego: po 2 sekundach podaje stężenie alkoholu w wydychanym powietrzu."
	icon = 'icons/obj/device.dmi'
	icon_state = "health"
	color = "#8fb4ff"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	custom_materials = list(/datum/material/iron = 200, /datum/material/glass = 100)

/obj/item/aq_breathalyzer/attack(mob/living/M, mob/living/user, params)
	if(!ishuman(M))
		return ..()
	var/mob/living/carbon/human/subject = M
	if(subject.is_mouth_covered())
		to_chat(user, "<span class='warning'>Usta [subject] są zasłonięte.</span>")
		return TRUE
	if(HAS_TRAIT(subject, TRAIT_NOBREATH))
		to_chat(user, "<span class='warning'>[subject] nie oddycha, alkomat nic nie pokaże.</span>")
		return TRUE
	user.visible_message("<span class='notice'>[user] przykłada [src] do ust [subject].</span>", "<span class='notice'>Przykładasz [src] do ust [subject].</span>")
	if(!do_after(user, 2 SECONDS, subject))
		return TRUE
	log_combat(user, subject, "breathalyzed", src)
	to_chat(user, "<div class='examine_block'>[breath_report(subject)]</div>")
	return TRUE

/// Wynik badania jako tekst (test czyta go bez klienta)
/obj/item/aq_breathalyzer/proc/breath_report(mob/living/carbon/human/subject)
	var/drunk = subject.get_drunk_amount()
	var/band
	switch(drunk)
		if(-INFINITY to 5)
			band = "<span class='notice'>trzeźwy</span>"
		if(5 to 40)
			band = "<span class='notice'>lekko wstawiony</span>"
		if(40 to 60)
			band = "<span class='warning'>pijany</span>"
		if(60 to 90)
			band = "<span class='warning'>mocno pijany</span>"
		else
			band = "<span class='danger'>zatrucie alkoholowe</span>"
	var/list/drinks = list()
	for(var/datum/reagent/consumable/ethanol/drink in subject.reagents?.reagent_list)
		drinks += drink.name
	. = "<b>Alkomat:</b> [subject.name]<br>Stężenie: <b>[round(max(drunk, 0) / 40, 0.01)] ‰</b> ([band])"
	if(length(drinks))
		. += "<br>Wykryto: [english_list(drinks, and_text = " i ")]"

/// Żandarmeria i medycy: alkomat w protolatach obu działów
/datum/design/aq_breathalyzer
	name = "Alkomat"
	desc = "Mierzy stężenie alkoholu w wydychanym powietrzu."
	id = "aq_breathalyzer"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 200, /datum/material/glass = 100)
	build_path = /obj/item/aq_breathalyzer
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SECURITY
