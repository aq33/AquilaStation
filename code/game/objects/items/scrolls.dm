/obj/item/teleportation_scroll
	name = "scroll of teleportation"
	desc = "A scroll for moving around."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll"
	var/uses = 4
	w_class = WEIGHT_CLASS_SMALL
	item_state = "paper"
	throw_speed = 3
	throw_range = 7
	resistance_flags = FLAMMABLE

/obj/item/teleportation_scroll/apprentice
	name = "lesser scroll of teleportation"
	uses = 1



// AQ EDIT - jak w tg: zwój teleportuje od razu po użyciu, bez okna HTML
/obj/item/teleportation_scroll/examine(mob/user)
	. = ..()
	if(uses)
		. += "<span class='notice'>Pozostało użyć: [uses].</span>"
		. += "<span class='notice'>Na dole dopisano: „Z wyrazami szacunku, Federacja Czarodziejów. PS Nie zapomnij zabrać ekwipunku, będzie ci potrzebny do rzucania większości zaklęć.”</span>"
	else
		. += "<span class='warning'>Zwój jest już zużyty.</span>"

/obj/item/teleportation_scroll/attack_self(mob/user)
	if(!ishuman(user) || user.incapacitated() || !user.is_holding(src))
		return
	if(!uses)
		to_chat(user, "<span class='warning'>[src] jest już zużyty.</span>")
		return
	teleportscroll(user)

/obj/item/teleportation_scroll/proc/teleportscroll(mob/user)

	var/A

	A = input(user, "Obszar docelowy", "BOOYEA", A) as null|anything in GLOB.teleportlocs
	if(!src || QDELETED(src) || !user || !user.is_holding(src) || user.incapacitated() || !A || !uses)
		return
	var/area/thearea = GLOB.teleportlocs[A]

	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(2, user.loc)
	smoke.attach(user)
	smoke.start()
	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		if(!is_blocked_turf(T))
			L += T

	if(!L.len)
		to_chat(user, "Matryca zaklęcia z nieznanego powodu nie zdołała znaleźć odpowiedniego celu teleportacji. Przepraszamy.")
		return

	if(do_teleport(user, pick(L), channel = TELEPORT_CHANNEL_MAGIC, forced = TRUE))
		smoke.start()
		uses--
	else
		to_chat(user, "Coś w pobliżu celu zakłóciło matrycę zaklęcia.")
