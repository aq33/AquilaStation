/datum/test_chamber_kit/pr_484
	name = "PR 484: genetyka (mutacje + DNA Infuser)"
	pr = "aq33/AquilaStation#484"
	description = "Skrzynia z injectorami wszystkich nowych mutacji (druga skrzynia: anty-injectory). Wstrzyknij, sprawdź działanie i zdolność na pasku, 	potem konsolą DNA zbadaj, połącz w przepisy (np. Cryokinesis + Fire Sweat = Pyrokinesis) i dodaj chromosomy. Infuser: wejdź do komory, 	włóż martwą mysz / karpia / mięso gondoli, kilka razy aż do bonusu zestawu; nieznana próbka (ruda) ma dać organ muchy. Rock Eater: zjedz rudę."
	items = list(
		/obj/machinery/dna_scannernew = 1,
		/obj/machinery/computer/scan_consolenew = 1,
		/obj/machinery/dna_infuser = 1,
		/obj/item/book/manual/infuser = 1,
		/obj/item/sequence_scanner = 1,
		/obj/item/chromosome/power = 2,
		/obj/item/chromosome/energy = 2,
		/obj/item/chromosome/synchronizer = 2,
		/obj/item/food/deadmouse = 4,
		/obj/item/food/meat/slab/gondola = 3,
		/obj/item/stack/ore/iron = 1,
		/obj/item/stack/ore/diamond = 1,
	)
	/// Mutacje z tego PR - ich injectory lądują w skrzyniach
	var/static/list/new_mutations = list(
		/datum/mutation/acidooze/unstable,
		/datum/mutation/acidspit,
		/datum/mutation/acidspit/unstable,
		/datum/mutation/acromegaly,
		/datum/mutation/adaptation/cold,
		/datum/mutation/adaptation/heat,
		/datum/mutation/adaptation/pressure,
		/datum/mutation/adaptation/thermal,
		/datum/mutation/adrenaline_rush,
		/datum/mutation/alcohol_generate,
		/datum/mutation/alcohol_tolerance,
		/datum/mutation/alien_voice,
		/datum/mutation/anemia,
		/datum/mutation/aoe_moodlet,
		/datum/mutation/aoe_moodlet/positive,
		/datum/mutation/bloodier,
		/datum/mutation/bloodyhell,
		/datum/mutation/cerebral,
		/datum/mutation/chameleon/changeling,
		/datum/mutation/chameleon/super,
		/datum/mutation/chemical_allergy,
		/datum/mutation/cindikinesis,
		/datum/mutation/clever,
		/datum/mutation/colorblindness,
		/datum/mutation/cryokinesis/pyrokinesis,
		/datum/mutation/darkcloak,
		/datum/mutation/densebones,
		/datum/mutation/dizzy,
		/datum/mutation/ear_cancer,
		/datum/mutation/elastic_arms,
		/datum/mutation/empath,
		/datum/mutation/extendoarm,
		/datum/mutation/farsight,
		/datum/mutation/fat,
		/datum/mutation/firebreath/unstable,
		/datum/mutation/flash_protection,
		/datum/mutation/hallucinate,
		/datum/mutation/headless,
		/datum/mutation/heckacious,
		/datum/mutation/horns,
		/datum/mutation/hulk/ork,
		/datum/mutation/hulk/superhuman,
		/datum/mutation/hulk/wizardly,
		/datum/mutation/hypermarrow,
		/datum/mutation/illiterate,
		/datum/mutation/immolate,
		/datum/mutation/inexorable,
		/datum/mutation/jumpy,
		/datum/mutation/laser_eyes/unstable,
		/datum/mutation/laser_eyes/unstable/syndicate,
		/datum/mutation/lay_on_hands,
		/datum/mutation/lay_on_hands/syndicate,
		/datum/mutation/limb_regeneration,
		/datum/mutation/lisp,
		/datum/mutation/loud,
		/datum/mutation/martyrdom,
		/datum/mutation/meson_vision,
		/datum/mutation/morph,
		/datum/mutation/night_vision,
		/datum/mutation/no_fingerprints,
		/datum/mutation/paraplegic,
		/datum/mutation/piglatin,
		/datum/mutation/polymorph,
		/datum/mutation/psy_resist,
		/datum/mutation/radiantburst,
		/datum/mutation/radproof,
		/datum/mutation/ravenous,
		/datum/mutation/regenerate,
		/datum/mutation/remote_view,
		/datum/mutation/rock_absorber,
		/datum/mutation/rock_eater,
		/datum/mutation/sapblood,
		/datum/mutation/shock/far,
		/datum/mutation/spores,
		/datum/mutation/thickskin,
		/datum/mutation/tongue_spike,
		/datum/mutation/tongue_spike/chem,
		/datum/mutation/uwuspeak,
		/datum/mutation/venomous_strikes,
		/datum/mutation/vore/syndicate,
		/datum/mutation/weaker_xray,
		/datum/mutation/weaker_xray/syndicate,
		/datum/mutation/webbing,
	)

/datum/test_chamber_kit/pr_484/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/obj/structure/closet/crate/plus = new(center)
	plus.name = "injectory nowych mutacji"
	var/obj/structure/closet/crate/minus = new(center)
	minus.name = "anty-injectory nowych mutacji"
	for(var/injector_type in subtypesof(/obj/item/dnainjector))
		var/obj/item/dnainjector/injector = new injector_type(plus)
		var/keep = FALSE
		for(var/mutation_type in injector.add_mutations)
			if(mutation_type in new_mutations)
				keep = TRUE
		for(var/mutation_type in injector.remove_mutations)
			if(mutation_type in new_mutations)
				keep = TRUE
				injector.forceMove(minus)
		if(!keep)
			qdel(injector)
	var/obj/item/reagent_containers/syringe/mutadone = new(center)
	mutadone.name = "strzykawka (mutadon)"
	mutadone.reagents.add_reagent(/datum/reagent/medicine/mutadone, 15)
	for(var/i in 1 to 2)
		var/mob/living/simple_animal/hostile/carp/carp = new(center)
		carp.del_on_death = FALSE
		carp.death()
