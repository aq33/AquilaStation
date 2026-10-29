/obj/item/reagent_containers/pill
	name = "pigułka"
	desc = "Tabletka albo kapsułka."
	icon = 'icons/obj/medicine_containers.dmi'
	icon_state = "pill_shape_capsule_purple_pink"
	item_state = "pill_shape_capsule_purple_pink"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	possible_transfer_amounts = list()
	volume = 50
	grind_results = list()
	var/apply_type = INGEST
	var/apply_method = "swallow"
	var/rename_with_volume = FALSE
	var/self_delay = 0 //pills are instant, this is because patches inheret their aplication from pills
	var/dissolvable = TRUE

/obj/item/reagent_containers/pill/Initialize(mapload)
	. = ..()
	if(!icon_state)
		icon_state = pick(PILL_SHAPE_LIST)
	if(reagents.total_volume && rename_with_volume)
		name += " ([reagents.total_volume] j.)"


/obj/item/reagent_containers/pill/attack_self(mob/user)
	return


/obj/item/reagent_containers/pill/attack(mob/M, mob/user, obj/item/bodypart/affecting)
	if(!canconsume(M, user))
		return FALSE
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(/datum/surgery/dental_implant in C.surgeries)
			return
	if(M == user)
		M.visible_message("<span class='notice'>[user] próbuje [apply_method == "apply" ? "nakleić sobie" : "połknąć"] [src].</span>")
		if(self_delay)
			if(!do_mob(user, M, self_delay))
				return FALSE
		to_chat(M, "<span class='notice'>[apply_method == "apply" ? "Naklejasz sobie" : "Połykasz"] [src].</span>")

	else
		M.visible_message("<span class='danger'>[user] próbuje [apply_method == "apply" ? "nakleić [M]" : "zmusić [M] do połknięcia"] [src]!</span>", \
							"<span class='userdanger'>[user] próbuje [apply_method == "apply" ? "nakleić ci" : "zmusić cię do połknięcia"] [src]!</span>")
		if(!do_mob(user, M, CHEM_INTERACT_DELAY(3 SECONDS, user)))
			return FALSE
		M.visible_message("<span class='danger'>[user] [apply_method == "apply" ? "nakleja [M]" : "zmusza [M] do połknięcia"] [src]!</span>", \
							"<span class='userdanger'>[user] [apply_method == "apply" ? "nakleja ci" : "zmusza cię do połknięcia"] [src]!</span>")

	var/makes_me_think = pick(strings(REDPILL_FILE, "redpill_questions"))
	if(icon_state == "pill_shape_capsule_bloodred" && prob(5)) //you take the red pill - you stay in Wonderland, and I show you how deep the rabbit hole goes
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), M, "<span class='notice'>[makes_me_think]</span>"), 5 SECONDS)

	if(reagents.total_volume)
		reagents.reaction(M, apply_type, affecting = affecting)
		reagents.trans_to(M, reagents.total_volume, transfered_by = user)
	qdel(src)
	return TRUE


/obj/item/reagent_containers/pill/afterattack(obj/target, mob/user , proximity)
	. = ..()
	if(!proximity)
		return
	if(!dissolvable || !target.is_refillable())
		return
	if(target.is_drainable() && !target.reagents.total_volume)
		balloon_alert(user, "[target] jest pusty!")
		return

	if(target.reagents.holder_full())
		balloon_alert(user, "[target] jest pełny!")
		return

	user.visible_message("<span class='warning'>[user] wrzuca coś do [target]!</span>", "<span class='notice'>Rozpuszczasz [src] w [target].</span>", null, 2)
	reagents.trans_to(target, reagents.total_volume, transfered_by = user)
	qdel(src)

/obj/item/reagent_containers/pill/tox
	name = "pigułka: toksyny"
	desc = "Wysoce toksyczna."
	icon_state = "pill_shape_capsule_red_whitelined"
	list_reagents = list(/datum/reagent/toxin = 50)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/cyanide
	name = "pigułka: cyjanek"
	desc = "Nie połykaj tego."
	icon_state = "pill_shape_capsule_red_whitelined"
	list_reagents = list(/datum/reagent/toxin/cyanide = 50)

/obj/item/reagent_containers/pill/adminordrazine
	name = "pigułka: adminordrazyna"
	desc = "To magia. Nie musimy tego tłumaczyć."
	icon_state = "pill_shape_tablet_blue_skyblue_lined"
	list_reagents = list(/datum/reagent/medicine/adminordrazine = 50)

/obj/item/reagent_containers/pill/morphine
	name = "pigułka: morfina"
	desc = "Powszechnie stosowana na bezsenność."
	icon_state = "pill_shape_tablet_skyblue_lined"
	list_reagents = list(/datum/reagent/medicine/morphine = 30)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/stimulant
	name = "pigułka: stymulant"
	desc = "Często biorą ją przepracowani pracownicy, sportowcy i pijani. Od razu stajesz na baczność!"
	icon_state = "pill_shape_capsule_white_redlined"
	list_reagents = list(/datum/reagent/medicine/ephedrine = 10, /datum/reagent/medicine/antihol = 10, /datum/reagent/consumable/coffee = 30)

/obj/item/reagent_containers/pill/salbutamol
	name = "pigułka: salbutamol"
	desc = "Stosowana przy niedotlenieniu."
	icon_state = "pill_shape_tablet_blue_skyblue_lined"
	list_reagents = list(/datum/reagent/medicine/salbutamol = 20)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/charcoal
	name = "pigułka: węgiel aktywowany"
	desc = "Neutralizuje wiele popularnych toksyn."
	icon_state = "pill_shape_tablet_green_lined"
	list_reagents = list(/datum/reagent/medicine/charcoal = 10)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/epinephrine
	name = "pigułka: epinefryna"
	desc = "Służy do stabilizowania pacjentów."
	icon_state = "pill_shape_capsule_red_whitelined"
	list_reagents = list(/datum/reagent/medicine/epinephrine = 15)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/mannitol
	name = "pigułka: mannitol"
	desc = "Stosowana przy uszkodzeniach mózgu."
	icon_state = "pill_shape_tablet_green_lined"
	list_reagents = list(/datum/reagent/medicine/mannitol = 50)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/mannitol/braintumor //For the brain tumor quirk
	list_reagents = list(/datum/reagent/medicine/mannitol = 30)

/obj/item/reagent_containers/pill/mutadone
	name = "pigułka: mutadon"
	desc = "Stosowana przy uszkodzeniach genetycznych."
	icon_state = "pill_shape_capsule_purple_yellow"
	list_reagents = list(/datum/reagent/medicine/mutadone = 50)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/bicaridine
	name = "pigułka: bikarydyna"
	desc = "Przyspiesza gojenie drobnych urazów fizycznych."
	icon_state = "pill_shape_tablet_white_lined"
	list_reagents = list(/datum/reagent/medicine/bicaridine = 15)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/kelotane
	name = "pigułka: kelotan"
	desc = "Przyspiesza gojenie drobnych oparzeń."
	icon_state = "pill_shape_tablet_lightgreen_flat"
	list_reagents = list(/datum/reagent/medicine/kelotane = 15)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/salicyclic
	name = "pigułka: kwas salicylowy"
	desc = "Łagodzi ból."
	icon_state = "pill_shape_tablet_white_lined"
	list_reagents = list(/datum/reagent/medicine/sal_acid = 15)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/oxandrolone
	name = "pigułka: oksandrolon"
	desc = "Przyspiesza gojenie oparzeń."
	icon_state = "pill_shape_tablet_lightgreen_flat"
	list_reagents = list(/datum/reagent/medicine/oxandrolone = 15)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/insulin
	name = "pigułka: insulina"
	desc = "Pomaga w śpiączce hiperglikemicznej."
	icon_state = "pill_shape_capsule_white"
	list_reagents = list(/datum/reagent/medicine/insulin = 50)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/psicodine
	name = "pigułka: psykodyna"
	desc = "Stosowana przy niestabilności psychicznej i fobiach."
	list_reagents = list(/datum/reagent/medicine/psicodine = 10)
	icon_state = "pill_shape_capsule_lightgreen_white"
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/penacid
	name = "pigułka: kwas pentetowy"
	desc = "Usuwa promieniowanie i toksyny."
	list_reagents = list(/datum/reagent/medicine/pen_acid = 10)
	icon_state = "pill_shape_capsule_lightgreen_white"
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/neurine
	name = "pigułka: neuryna"
	desc = "Stosowana przy lżejszych urazach psychicznych."
	list_reagents = list(/datum/reagent/medicine/neurine = 10)
	icon_state = "pill_shape_capsule_lightgreen_white"
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/mutarad
	name = "pigułka przeciwradiacyjna deluxe"
	desc = "Stosowana przy ciężkim zatruciu promieniowaniem i wadach genetycznych."
	icon_state = "pill_shape_capsule_black_white"
	list_reagents = list(/datum/reagent/medicine/pen_acid = 15, /datum/reagent/medicine/potass_iodide = 15, /datum/reagent/medicine/mutadone = 15)

/obj/item/reagent_containers/pill/antirad_plus
	name = "pigułka przeciwradiacyjna plus"
	desc = "Stosowana przy ciężkim zatruciu promieniowaniem."
	icon_state = "pill_shape_capsule_skyblue"
	list_reagents = list(/datum/reagent/medicine/potass_iodide = 50, /datum/reagent/medicine/charcoal = 20)

/obj/item/reagent_containers/pill/antirad
	name = "pigułka: jodek potasu"
	desc = "Stosowana przy zatruciu promieniowaniem."
	icon_state = "pill_shape_capsule_white"
	list_reagents = list(/datum/reagent/medicine/potass_iodide = 30)


///////////////////////////////////////// this pill is used only in a legion mob drop
/obj/item/reagent_containers/pill/shadowtoxin
	name = "czarna pigułka"
	desc = "Na twoim miejscu bym tego nie jadł."
	icon_state = "pill_shape_tablet_white_lined"
	color = "#454545"
	list_reagents = list(/datum/reagent/mutationtoxin/shadow = 5)

//////////////////////////////////////// drugs
/obj/item/reagent_containers/pill/zoom
	name = "żółta pigułka"
	desc = "Niedbale zrobiona kanarkowożółta pigułka. Trochę się kruszy."
	list_reagents = list(/datum/reagent/medicine/synaptizine = 10, /datum/reagent/drug/nicotine = 10, /datum/reagent/drug/methamphetamine = 1)
	icon_state = "pill_shape_tablet_yellow_lined"


/obj/item/reagent_containers/pill/happy
	name = "wesoła pigułka"
	desc = "Mają na sobie małe uśmiechnięte buźki i pachną flamastrem."
	list_reagents = list(/datum/reagent/consumable/sugar = 10, /datum/reagent/drug/space_drugs = 10)
	icon_state = "pill_shape_tablet_happy"


/obj/item/reagent_containers/pill/lsd
	name = "słoneczna pigułka"
	desc = "Na tej dwukolorowej pigułce wygrawerowano pół słońca i pół księżyca."
	list_reagents = list(/datum/reagent/drug/mushroomhallucinogen = 15, /datum/reagent/toxin/mindbreaker = 15)
	icon_state = "pill_shape_tablet_yellow_purple_lined"


/obj/item/reagent_containers/pill/aranesp
	name = "gładka pigułka"
	desc = "Ta niebieska pigułka jest lekko wilgotna."
	list_reagents = list(/datum/reagent/drug/aranesp = 10)
	icon_state = "pill_shape_capsule_skyblue"


/obj/item/reagent_containers/pill/happiness
	name = "pigułka szczęścia"
	desc = "Ma na sobie upiorną uśmiechniętą buźkę."
	icon_state = "pill_shape_tablet_happy"
	list_reagents = list(/datum/reagent/drug/happiness = 10)

/obj/item/reagent_containers/pill/floorpill
	name = "pigułka z podłogi"
	desc = "Dziwna pigułka znaleziona w czeluściach technicznych."// Somehow, it can't be dissolved or used in a grinder."
	icon_state = "pill_shape_capsule_black_white"
	var/static/list/names = list("pigułka z technicznych","pigułka z podłogi","tajemnicza pigułka","podejrzana pigułka","dziwna pigułka")
	var/static/list/descs = list("Przeczucie mówi ci, że nie, ale...","Leki są drogie, nie stać cię na to, by nie zjadać znalezionych pigułek."\
	, "Na pewno nic złego się nie stanie.")
	//prevent_grinding = TRUE // AQ EDIT - floor pills now grindable
	//dissolvable = FALSE // AQ EDIT - and dissolvable!

/obj/item/reagent_containers/pill/floorpill/Initialize(mapload)
	list_reagents = list(get_random_reagent_id(CHEMICAL_RNG_FUN) = rand(10,50))
	. = ..()
	name = pick(names)


/obj/item/reagent_containers/pill/floorpill/examine(mob/user)
	. = ..()
	if(prob(20))
		. += "[pick(descs)]"
