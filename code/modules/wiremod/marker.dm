/obj/item/multitool/circuit
	name = "multitool do układów"
	desc = "Multitool do układów. Służy do oznaczania obiektów, które potem można wgrać do komponentów przyciskiem wgrywania przy porcie. \
	Poza tym działa jak zwykły multitool. Użyj go w ręce, by wyczyścić oznaczony obiekt i móc oznaczyć kolejny."
	icon_state = "multitool_circuit"
	item_state = "multitool_circuit"
	/// The marked atom of this multitool
	var/atom/marked_atom

/obj/item/multitool/circuit/Destroy()
	marked_atom = null
	return ..()

/obj/item/multitool/circuit/on_examine(datum/source, mob/user, list/examine_list)
	. = ..()
	examine_list += "<span class='notice'>[marked_atom? "Ma zarejestrowany oznaczony obiekt" : "Nie ma zarejestrowanego oznaczonego obiektu"].</span>"

/obj/item/multitool/circuit/attack_self(mob/user, modifiers)
	. = ..()
	if(.)
		return
	if(!marked_atom)
		return

	say("Wyczyszczono oznaczone cele.")
	clear_marked_atom()
	return TRUE

/obj/item/multitool/circuit/melee_attack_chain(mob/user, atom/target, params)
	if(marked_atom || !user.Adjacent(target))
		return ..()

	say("Oznaczono: [target].")
	marked_atom = target
	RegisterSignal(marked_atom, COMSIG_PARENT_QDELETING, PROC_REF(cleanup_marked_atom))
	return TRUE

/// Clears the current marked atom
/obj/item/multitool/circuit/proc/clear_marked_atom()
	if(!marked_atom)
		return
	UnregisterSignal(marked_atom, COMSIG_PARENT_QDELETING)
	marked_atom = null

/obj/item/multitool/circuit/proc/cleanup_marked_atom(datum/source)
	SIGNAL_HANDLER
	if(source == marked_atom)
		clear_marked_atom()
