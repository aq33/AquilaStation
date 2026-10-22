// AQUILA - port z tgstation (code/game/machinery/dna_infuser/infuser_entry.dm)

/// wszystkie wpisy infusera (typ = instancja)
GLOBAL_LIST_INIT(infuser_entries, prepare_infuser_entries())

/// tworzy po jednej instancji każdego podtypu /datum/infuser_entry
/proc/prepare_infuser_entries()
	var/list/entries = list()
	for(var/entry_type in subtypesof(/datum/infuser_entry))
		entries[entry_type] = new entry_type()
	return entries

/datum/infuser_entry
	//-- Książka infuzji --//
	/// nazwa mutanta
	var/name = "Mutant"
	/// czego trzeba użyć, żeby nim zostać
	var/infuse_mob_name = "jakiś mutant"
	/// ogólny opis
	var/desc = "Ignoranci nazywają cię mutantem. Ja wolę myśleć o mutantach jako o przyszłości ludzkości!"
	/// opis bonusu po przekroczeniu progu; pusty = wpis żartobliwy, bez bonusu
	var/threshold_desc = "bałagan w DNA bierze górę i zmieniasz się w mutanta!"
	/// lista cech
	var/list/qualities = list(
		"nadpisz to",
		"kładzie ananasa na pizzę",
		"po prostu dziwny gość",
	)
	/// typ efektu bonusu zestawu (tier 0 nigdy go nie ustawia)
	var/status_effect_type
	/// zestaw ma organy z bonusem, ale sam nie dobije do progu (u nas nieużywane - zostawione dla zgodności z tg)
	var/unreachable_effect = FALSE
	/// trudność / próg odblokowania, patrz DNA_MUTANT_TIER_*
	var/tier = DNA_MUTANT_UNOBTAINABLE

	//-- Maszyna --//
	/// typy mobów i przedmiotów, które dają ten wpis
	var/list/input_obj_or_mob
	/// typy, które mimo dziedziczenia nie dają tego wpisu
	var/list/excluded_input
	/// organy, które może wyprodukować maszyna
	var/list/output_organs
	/// co czuje osoba w trakcie infuzji
	var/infusion_desc = "mutantowato"

/// lista organów do wyboru dla danej osoby; wpisy mogą to nadpisać
/datum/infuser_entry/proc/get_output_organs(mob/living/carbon/human/target, atom/movable/infused_from)
	return output_organs.Copy()

/// czy ta próbka pasuje do wpisu
/datum/infuser_entry/proc/matches_input(atom/movable/source)
	if(!is_type_in_list(source, input_obj_or_mob))
		return FALSE
	if(length(excluded_input) && is_type_in_list(source, excluded_input))
		return FALSE
	return TRUE
