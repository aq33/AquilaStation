// AQUILA: nauka substancji z krwi nosiciela, port pomysłu z Monkestation (code/modules/antagonists/borers/abilities/learn_chemicals.dm,
// /datum/action/cooldown/borer/learn_bloodchemical, AGPL-3.0) i Paradise. Różnice: Monke płaci osobnymi punktami ewolucji,
// u nas horror płaci zwykłymi chemikaliami; Monke nie ma limitu znanych substancji, u nas jest HORROR_MAX_LEARNED_CHEMS;
// poza flagą „nie do syntezy” wykluczamy też jawną listę zbyt silnych odczynników (HORROR_LEARN_BLACKLIST).
// Nauczone substancje wstrzykuje się z tego samego okna co stałe leki (HorrorChemicals, bez zmian w TSX).

/// Ile substancji horror może nauczyć się z krwi
#define HORROR_MAX_LEARNED_CHEMS 5
/// Koszt nauki jednej substancji (chemikalia horroru)
#define HORROR_LEARN_CHEM_COST 75
/// Koszt wstrzyknięcia nauczonej substancji
#define HORROR_LEARNED_CHEM_USE 50
/// Ile jednostek nauczonej substancji trafia do krwi nosiciela
#define HORROR_LEARNED_CHEM_QUANTITY 10

/datum/action/innate/horror/learn_blood_chem
	name = "Nauka z krwi"
	desc = "Przeanalizuj substancję krążącą we krwi nosiciela i naucz się ją wytwarzać. Kosztuje 75 chemikaliów i lekko uszkadza mózg nosiciela. Możesz znać najwyżej 5 takich substancji."
	icon_icon = 'icons/obj/chemical.dmi'
	button_icon_state = "dropper0"
	blacklisted = TRUE
	category = list("infest")

/datum/action/innate/horror/learn_blood_chem/Activate()
	B.learn_blood_chemical()

/// Odczynniki, których horror nie nauczy się z krwi, choć da się je zsyntetyzować: adminowe, boskie, zmiennokształtnych i zapalające
/proc/horror_learn_blacklist()
	var/static/list/blacklist
	if(!blacklist)
		blacklist = typesof(/datum/reagent/medicine/adminordrazine) + typesof(/datum/reagent/medicine/omnizine/godblood) \
			+ typesof(/datum/reagent/medicine/changelingadrenaline) + typesof(/datum/reagent/medicine/changelinghaste) \
			+ typesof(/datum/reagent/medicine/syndicate_nanites) + typesof(/datum/reagent/blood) \
			+ typesof(/datum/reagent/clf3) + typesof(/datum/reagent/phlogiston) + typesof(/datum/reagent/napalm) \
			+ typesof(/datum/reagent/toxin/plasma)
	return blacklist

/// Czy horror może nauczyć się tego odczynnika (nie liczy kosztu ani limitu)
/mob/living/simple_animal/horror/proc/can_learn_reagent(reagent_type)
	if(!ispath(reagent_type, /datum/reagent))
		return FALSE
	var/datum/reagent/reagent_path = reagent_type
	if(initial(reagent_path.chem_flags) & CHEMICAL_NOT_SYNTH)
		return FALSE
	if(reagent_type in horror_learn_blacklist())
		return FALSE
	if(reagent_type in learned_reagents)
		return FALSE
	if(victim && reagent_type == victim.get_blood_id())
		return FALSE
	for(var/datum/horror_chem/chem as anything in horror_chems)
		if(initial(chem.R) == reagent_type)
			return FALSE
	return TRUE

/// Odczynniki z krwi nosiciela, których można się teraz nauczyć: nazwa = typ
/mob/living/simple_animal/horror/proc/learnable_blood_reagents()
	var/list/options = list()
	if(!victim?.reagents)
		return options
	for(var/datum/reagent/reagent as anything in victim.reagents.reagent_list)
		if(can_learn_reagent(reagent.type))
			options[reagent.name] = reagent.type
	return options

/mob/living/simple_animal/horror/proc/learn_blood_chemical()
	if(!can_use_ability())
		return
	if(!victim)
		to_chat(src, span_warning("Nie jesteś w ciele nosiciela."))
		return
	if(length(learned_reagents) >= HORROR_MAX_LEARNED_CHEMS)
		to_chat(src, span_warning("Twoje gruczoły nie pomieszczą już żadnej nowej substancji."))
		return
	if(!has_chemicals(HORROR_LEARN_CHEM_COST))
		to_chat(src, span_warning("Potrzebujesz [HORROR_LEARN_CHEM_COST] zgromadzonych chemikaliów, by przeanalizować krew."))
		return
	var/list/options = learnable_blood_reagents()
	if(!length(options))
		to_chat(src, span_warning("We krwi nosiciela nie krąży nic, czego mógłbyś się nauczyć."))
		return
	var/choice = tgui_input_list(src, "Której substancji z krwi nosiciela chcesz się nauczyć?", "Nauka z krwi", options)
	if(!choice || QDELETED(src) || !victim)
		return
	var/reagent_type = options[choice]
	// okno mogło wisieć: substancja mogła się już rozłożyć, a chemikalia zejść na co innego
	if(!victim.reagents.has_reagent(reagent_type) || !can_learn_reagent(reagent_type))
		to_chat(src, span_warning("Tej substancji nie ma już we krwi nosiciela."))
		return
	learn_reagent(reagent_type)

/// Uczy horrora substancji, pobiera koszt i uszkadza mózg nosiciela. Zwraca TRUE, jeśli się udało
/mob/living/simple_animal/horror/proc/learn_reagent(reagent_type)
	if(length(learned_reagents) >= HORROR_MAX_LEARNED_CHEMS || !can_learn_reagent(reagent_type))
		return FALSE
	if(!use_chemicals(HORROR_LEARN_CHEM_COST))
		return FALSE
	learned_reagents += reagent_type
	var/datum/reagent/reagent_path = reagent_type
	to_chat(src, span_notice("Twoje gruczoły uczą się wytwarzać: [initial(reagent_path.name)]."))
	if(victim)
		victim.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5, 120)
		if(!HAS_TRAIT(victim, TRAIT_AGEUSIA))
			to_chat(victim, span_notice("Czujesz w ustach dziwny posmak: [initial(reagent_path.taste_description)]."))
	log_game("[src]/([ckey]) learned [reagent_type] from the blood of their host [victim]/([victim?.ckey])")
	return TRUE

/mob/living/simple_animal/horror/proc/inject_learned_reagent(reagent_type)
	if(!victim || controlling || stat || !(reagent_type in learned_reagents))
		return
	var/datum/reagent/reagent_path = reagent_type
	if(chemicals < HORROR_LEARNED_CHEM_USE)
		to_chat(src, "<span class='boldnotice'>Potrzebujesz [HORROR_LEARNED_CHEM_USE] zgromadzonych chemikaliów, by użyć tej substancji!</span>")
		return
	to_chat(src, "<span class='danger'>Wstrzykujesz [HORROR_LEARNED_CHEM_QUANTITY] jednostek [initial(reagent_path.name)] ze swoich zbiorników do krwiobiegu [victim].</span>")
	victim.reagents.add_reagent(reagent_type, HORROR_LEARNED_CHEM_QUANTITY)
	use_chemicals(HORROR_LEARNED_CHEM_USE)
	log_game("[src]/([ckey]) has injected learned [reagent_type] into their host [victim]/([victim.ckey])")

/// Pozycje okna HorrorChemicals dla nauczonych substancji (ten sam format co stałe leki)
/mob/living/simple_animal/horror/proc/learned_reagents_ui_data()
	var/list/entries = list()
	for(var/datum/reagent/reagent_path as anything in learned_reagents)
		entries += list(list(
			"path" = "[reagent_path]",
			"name" = "[initial(reagent_path.name)] (z krwi)",
			"cost" = HORROR_LEARNED_CHEM_USE,
			"desc" = initial(reagent_path.description),
		))
	return entries

#undef HORROR_MAX_LEARNED_CHEMS
#undef HORROR_LEARN_CHEM_COST
#undef HORROR_LEARNED_CHEM_USE
#undef HORROR_LEARNED_CHEM_QUANTITY
