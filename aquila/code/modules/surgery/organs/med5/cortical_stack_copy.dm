// AQUILA - kopia stosu korowego (zgłoszenie 25.11). Stos wyjęty z ciała (operacją, przy rozerwaniu ciała) zapisuje
// rekord klonowania: umysł, DNA, gatunek, cechy i urazy z tej chwili. Stos z zapisem włożony do konsoli klonowania
// dodaje ten rekord, więc da się sklonować kogoś, z kogo został sam stos. Pusty stos włożony do konsoli dostaje kopię
// wybranego rekordu (kopia zapasowa z godziną zapisu). Ożywa jeden umysł: kapsuła odrzuca klon umysłu, którego ciało żyje,
// i zapis starszy niż ostatnia śmierć (growclone).

/obj/item/organ/cortical_stack
	/// Rekord klonowania zapisany w stosie (pola jak w /datum/data/record konsoli klonowania), null = pusty stos
	var/list/clone_fields
	/// Godzina okrętowa zapisu
	var/recorded_at
	/// Umysł nosiciela zapamiętany za życia: po wyjęciu mózgu ciało nie ma już umysłu (przechodzi do brainmoba)
	var/datum/weakref/owner_mind

/obj/item/organ/cortical_stack/Remove(mob/living/carbon/M, special = 0)
	if(!special && ishuman(M))
		record_clone_fields(M)
	return ..()

/// Stos w ciele zapisuje umysł na bieżąco: stary zapis znika, nowy powstanie przy wyjęciu
/obj/item/organ/cortical_stack/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	clone_fields = null
	recorded_at = null
	name = initial(name)
	owner_mind = M?.mind ? WEAKREF(M.mind) : null
	return ..()

/obj/item/organ/cortical_stack/on_life()
	. = ..()
	if(owner?.mind && owner_mind?.resolve() != owner.mind)
		owner_mind = WEAKREF(owner.mind)

/obj/item/organ/cortical_stack/examine(mob/user)
	. = ..()
	if(clone_fields)
		. += span_notice("Zapis z [recorded_at]. Włóż stos do konsoli klonowania, żeby dodać z niego rekord.")
	else
		. += span_notice("Stos jest pusty. W konsoli klonowania można na nim zapisać kopię wybranego rekordu.")

/// Zapisuje w stosie rekord klonowania nosiciela (umysł z ciała albo zapamiętany za życia, gdy mózg wyjęto wcześniej)
/obj/item/organ/cortical_stack/proc/record_clone_fields(mob/living/carbon/human/H)
	var/datum/mind/mind = H.mind || owner_mind?.resolve()
	var/datum/dna/dna = H.has_dna()
	if(!mind || !dna?.species || (NO_DNA_COPY in dna.species.species_traits) || HAS_TRAIT(H, TRAIT_BADDNA))
		return FALSE
	var/list/fields = list()
	dna.delete_species = FALSE // jak przy skanie: rekord trzyma instancję gatunku
	fields["mrace"] = dna.species
	fields["name"] = H.real_name
	fields["id"] = copytext_char(rustg_hash_string(RUSTG_HASH_MD5, H.real_name), 3, 7) + copytext_char(rustg_hash_string(RUSTG_HASH_MD5, mind), -4)
	fields["UE"] = dna.unique_enzymes
	fields["UI"] = dna.uni_identity
	fields["SE"] = dna.mutation_index
	fields["blood_type"] = dna.blood_type
	fields["features"] = dna.features.Copy()
	fields["factions"] = H.faction.Copy()
	fields["quirks"] = list()
	for(var/datum/quirk/quirk as anything in H.roundstart_quirks)
		fields["quirks"][quirk.type] = quirk.clone_data()
	fields["traumas"] = H.get_traumas()
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	fields["bank_account"] = id_card?.registered_account
	fields["mindref"] = "[REF(mind)]"
	fields["last_death"] = (H.stat == DEAD) ? mind.last_death : -1
	fields["body_only"] = FALSE
	clone_fields = fields
	recorded_name = H.real_name
	recorded_at = station_time_timestamp()
	name = "[initial(name)] ([recorded_name])"
	return TRUE

/// Kopiuje rekord konsoli na pusty stos
/obj/item/organ/cortical_stack/proc/write_record(datum/data/record/record)
	clone_fields = record.fields.Copy()
	recorded_name = record.fields["name"]
	recorded_at = station_time_timestamp()
	name = "[initial(name)] ([recorded_name])"

/obj/machinery/computer/cloning/attackby(obj/item/W, mob/user, params)
	if(!istype(W, /obj/item/organ/cortical_stack))
		return ..()
	var/obj/item/organ/cortical_stack/stack = W
	if(stack.clone_fields)
		load_cortical_stack(stack, user)
	else
		INVOKE_ASYNC(src, PROC_REF(copy_to_cortical_stack), stack, user)
	return TRUE

/// Dodaje rekord zapisany w stosie (jak wczytanie z dyskietki)
/obj/machinery/computer/cloning/proc/load_cortical_stack(obj/item/organ/cortical_stack/stack, mob/user)
	var/list/fields = stack.clone_fields
	if(!fields?["name"] || !fields["mindref"])
		scantemp = "Odczyt stosu nieudany: zapis jest uszkodzony."
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return FALSE
	var/datum/data/record/old_record = find_record("id", fields["id"], records)
	if(old_record)
		// Zapis ze stosu z wcześniejszej śmierci nie wypiera nowszego skanu (kapsuła odrzuciłaby go jako nieaktualny).
		// Kopia zrobiona za życia (-1) pasuje do każdej śmierci, więc też nie zastępuje rekordu ze śmierci
		var/stack_death = fields["last_death"]
		var/record_death = old_record.fields["last_death"]
		if(record_death > 0 && (stack_death <= 0 || stack_death < record_death))
			scantemp = "Odczyt stosu: w pamięci jest już nowszy rekord [fields["name"]]."
			to_chat(user, span_warning("[src] ma już nowszy rekord: [fields["name"]]. Zapis ze stosu zostaje na stosie."))
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
			return FALSE
		records -= old_record
	var/datum/data/record/record = new(src)
	for(var/key in fields)
		record.fields[key] = fields[key]
	records += record
	var/obj/item/circuitboard/computer/cloning/board = circuit
	board.records = records
	scantemp = "Odczytano stos korowy: [fields["name"]] (zapis z [stack.recorded_at])."
	to_chat(user, span_notice("[src] odczytuje stos korowy i dodaje rekord: [fields["name"]]."))
	log_cloning("[key_name(user)] loaded the cortical stack record of [fields["name"]] into [src] at [AREACOORD(src)].")
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
	ui_update()
	return TRUE

/// Zapisuje na pustym stosie kopię wybranego rekordu (bez samych skanów ciała, z których nie ma umysłu)
/obj/machinery/computer/cloning/proc/copy_to_cortical_stack(obj/item/organ/cortical_stack/stack, mob/user)
	var/list/choices = list()
	for(var/datum/data/record/record as anything in records)
		if(record.fields["body_only"] || !record.fields["mindref"])
			continue
		choices["[record.fields["name"]] ([record.fields["id"]])"] = record
	if(!length(choices))
		to_chat(user, span_warning("W [src] nie ma rekordu z umysłem, który dałoby się zapisać na stosie."))
		return FALSE
	var/choice = tgui_input_list(user, "Który rekord zapisać na pustym stosie?", "Kopia stosu korowego", choices)
	var/datum/data/record/record = choices[choice]
	if(!record || !(record in records) || stack.clone_fields || !user.is_holding(stack) || !user.canUseTopic(src, BE_CLOSE))
		return FALSE
	stack.write_record(record)
	to_chat(user, span_notice("Zapisujesz na stosie kopię rekordu: [record.fields["name"]]."))
	log_cloning("[key_name(user)] copied the clone record of [record.fields["name"]] onto a cortical stack at [src] at [AREACOORD(src)].")
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
	return TRUE
