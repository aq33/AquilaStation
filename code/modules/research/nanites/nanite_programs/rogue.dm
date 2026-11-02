//Programs generated through degradation of other complex programs.
//They generally cause minor damage or annoyance.

//Last stop of the error train
/datum/nanite_program/glitch
	name = "Usterka"
	desc = "Poważne uszkodzenie oprogramowania, przez które nanity stopniowo się rozpadają."
	use_rate = 1.5
	unique = FALSE
	rogue_types = list()

//Generic body-affecting programs will decay into this
/datum/nanite_program/necrotic
	name = "Martwica"
	desc = "Nanity bez różnicy atakują tkanki wewnętrzne, wywołując rozległe uszkodzenia."
	use_rate = 0.75
	unique = FALSE
	rogue_types = list(/datum/nanite_program/glitch)

/datum/nanite_program/necrotic/active_effect()
	host_mob.adjustBruteLoss(0.75, TRUE)
	if(prob(1))
		to_chat(host_mob, "<span class='warning'>Czujesz łagodny ból gdzieś w środku.</span>")

//Programs that don't directly interact with the body will decay into this
/datum/nanite_program/toxic
	name = "Kumulacja toksyn"
	desc = "Nanity powodują powolne, ale stałe gromadzenie się toksyn w nosicielu."
	use_rate = 0.25
	unique = FALSE
	rogue_types = list(/datum/nanite_program/glitch)

/datum/nanite_program/toxic/active_effect()
	host_mob.adjustToxLoss(0.5)
	if(prob(1))
		to_chat(host_mob, "<span class='warning'>Czujesz się trochę chory.</span>")

//Generic blood-affecting programs will decay into this
/datum/nanite_program/suffocating
	name = "Hipoksemia"
	desc = "Nanity utrudniają krwi nosiciela skuteczne wchłanianie tlenu."
	use_rate = 0.75
	unique = FALSE
	rogue_types = list(/datum/nanite_program/glitch)

/datum/nanite_program/suffocating/active_effect()
	host_mob.adjustOxyLoss(3, 0)
	if(prob(1))
		to_chat(host_mob, "<span class='warning'>Brakuje ci tchu.</span>")

//Generic brain-affecting programs will decay into this
/datum/nanite_program/brain_decay
	name = "Neuromartwica"
	desc = "Nanity wyszukują i atakują komórki mózgowe, wywołując u nosiciela rozległe uszkodzenia nerwowe."
	use_rate = 0.75
	unique = FALSE
	rogue_types = list(/datum/nanite_program/necrotic)

/datum/nanite_program/brain_decay/active_effect()
	if(prob(4))
		host_mob.hallucination = min(15, host_mob.hallucination)
	host_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1)

//Generic brain-affecting programs can also decay into this
/datum/nanite_program/brain_misfire
	name = "Zakłócenia mózgowe"
	desc = "Nanity zakłócają szlaki nerwowe, wywołując drobne zaburzenia psychiczne."
	use_rate = 0.50
	unique = FALSE
	rogue_types = list(/datum/nanite_program/brain_decay)

/datum/nanite_program/brain_misfire/active_effect()
	if(prob(10))
		switch(rand(1,4))
			if(1)
				host_mob.hallucination += 15
			if(2)
				host_mob.confused  += 10
			if(3)
				host_mob.drowsyness += 10
			if(4)
				host_mob.slurring += 10

//Generic skin-affecting programs will decay into this
/datum/nanite_program/skin_decay
	name = "Dermaliza"
	desc = "Nanity atakują komórki skóry, wywołując podrażnienia, wysypki i drobne obrażenia."
	use_rate = 0.25
	unique = FALSE
	rogue_types = list(/datum/nanite_program/necrotic)

/datum/nanite_program/skin_decay/active_effect()
	host_mob.adjustBruteLoss(0.25)
	if(prob(5)) //itching
		var/picked_bodypart = pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)
		var/obj/item/bodypart/bodypart = host_mob.get_bodypart(picked_bodypart)
		var/can_scratch = !host_mob.incapacitated() && get_location_accessible(host_mob, picked_bodypart)

		host_mob.visible_message("[can_scratch ? "<span class='warning'>[host_mob] drapie się: [bodypart.name].</span>" : ""]",\
		"<span class='warning'>Swędzi cię [strefa_pl(bodypart.body_zone)].[can_scratch ? " Drapiesz się." : ""]</span>")

//Generic nerve-affecting programs will decay into this
/datum/nanite_program/nerve_decay
	name = "Rozpad nerwów"
	desc = "Nanity atakują nerwy nosiciela, wywołując brak koordynacji i krótkie napady paraliżu."
	use_rate = 1
	unique = FALSE
	rogue_types = list(/datum/nanite_program/necrotic)

/datum/nanite_program/nerve_decay/active_effect()
	if(prob(5))
		to_chat(host_mob, "<span class='warning'>Tracisz równowagę!</span>")
		host_mob.confused += 10
	else if(prob(4))
		to_chat(host_mob, "<span class='warning'>Nie czujesz rąk!</span>")
		host_mob.drop_all_held_items()
	else if(prob(4))
		to_chat(host_mob, "<span class='warning'>Nie czujesz nóg!</span>")
		host_mob.Paralyze(30)
