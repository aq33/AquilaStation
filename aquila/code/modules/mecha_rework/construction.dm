// AQUILA - wspólna budowa nowych podwozi: części i rama w aquila/icons/mecha/aq_mech_construct.dmi,
// kroki budowy w aq_mech_construction.dmi (stany "[base_icon][numer]", bez brakujących numerów bierze ostatni).

/obj/item/mecha_parts/chassis/aq
	icon = 'aquila/icons/mecha/aq_mech_construct.dmi'

/obj/item/mecha_parts/part/aq
	icon = 'aquila/icons/mecha/aq_mech_construct.dmi'

/datum/component/construction/unordered/mecha_chassis/aq

/datum/component/construction/mecha/aq
	/// Najwyższy numer stanu kroku w pliku ikon
	var/aq_max_state = 22

/datum/component/construction/mecha/aq/update_parent(step_index)
	..()
	var/atom/parent_atom = parent
	parent_atom.icon = 'aquila/icons/mecha/aq_mech_construction.dmi'
	if(base_icon)
		parent_atom.icon_state = "[base_icon][min(index - 1, aq_max_state)]"

/datum/component/construction/mecha/aq/custom_action(obj/item/I, mob/living/user, diff)
	. = ..()
	if(!.)
		return
	var/list/step = steps[index]
	if(diff == FORWARD)
		user.visible_message("[user] pracuje nad [parent].", "<span class='notice'>Wykonujesz krok budowy: [lowertext(step["desc"])]</span>")
	else
		user.visible_message("[user] cofa krok budowy [parent].", "<span class='notice'>Cofasz krok budowy.</span>")

/// Projekt części w fabrykatorze egzoszkieletów
/datum/design/aq_mech_part
	build_type = MECHFAB
	construction_time = 150
