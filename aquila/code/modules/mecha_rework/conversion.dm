// AQUILA - zestawy konwersji frakcyjnych (port z Shiptestu: code/game/mecha/equipment/tools/work_tools.dm, ten sam /obj/mecha)
// i zestaw Paddy (tg). Zestaw zakłada się na pusty mech z włączonymi protokołami serwisowymi i ogniwem; powstaje nowy mech
// z tymi samymi częściami, wyposażeniem, blokadą DNA i uszkodzeniami. Zestawu nie da się zdjąć.

/obj/item/mecha_parts/mecha_equipment/aq_conversion_kit
	name = "zestaw konwersji egzoszkieletu"
	desc = "Ogólny zestaw konwersji."
	icon = 'aquila/icons/mecha/aq_mecha_equipment.dmi'
	icon_state = "paddyupgrade"
	aq_slot = AQ_MECHA_SLOT_NONE
	selectable = FALSE
	/// Z jakich podwozi (dokładne typy)
	var/list/source_mechs = list()
	var/result_mech

/obj/item/mecha_parts/mecha_equipment/aq_conversion_kit/can_attach(obj/mecha/M)
	if(!(M.type in source_mechs))
		to_chat(loc, "<span class='warning'>Tego zestawu nie da się zastosować w tym modelu.</span>")
		return FALSE
	if(istype(M, /obj/mecha/working/ripley))
		var/obj/mecha/working/ripley/R = M
		if(length(R.cargo))
			to_chat(loc, "<span class='warning'>Ładownia [R] musi być pusta, zanim zastosujesz ten zestaw konwersji.</span>")
			return FALSE
	if(!M.maint_access)
		to_chat(loc, "<span class='warning'>Aby zastosować ten zestaw konwersji, [M] musi mieć aktywne protokoły serwisowe.</span>")
		return FALSE
	if(M.occupant || M.aq_copilot)
		to_chat(loc, "<span class='warning'>[M] musi być pusty, zanim zastosujesz ten zestaw konwersji.</span>")
		return FALSE
	if(!M.cell)
		to_chat(loc, "<span class='warning'>Proces konwersji wymaga zamontowanego ogniwa.</span>")
		return FALSE
	return TRUE

/obj/item/mecha_parts/mecha_equipment/aq_conversion_kit/attach(obj/mecha/M)
	var/obj/mecha/N = aq_mecha_transfer(M, result_mech)
	if(N)
		qdel(src)

/// Przenosi części, wyposażenie i stan na nowe podwozie (jak ripleyupgrade z rdzenia), zwraca nowego mecha
/proc/aq_mecha_transfer(obj/mecha/M, new_type)
	var/obj/mecha/N = new new_type(get_turf(M))
	if(!N)
		return null
	QDEL_NULL(N.cell)
	if(M.cell)
		N.cell = M.cell
		M.cell.forceMove(N)
		M.cell = null
	QDEL_NULL(N.scanmod)
	if(M.scanmod)
		N.scanmod = M.scanmod
		M.scanmod.forceMove(N)
		M.scanmod = null
	QDEL_NULL(N.capacitor)
	if(M.capacitor)
		N.capacitor = M.capacitor
		M.capacitor.forceMove(N)
		M.capacitor = null
	N.update_part_values()
	for(var/obj/item/mecha_parts/E in M.contents)
		if(istype(E, /obj/item/mecha_parts/concealed_weapon_bay))
			E.forceMove(N)
	if(M.aq_plating)
		var/obj/item/mecha_parts/aq_armor_plating/plate = M.aq_plating
		M.aq_remove_plating()
		N.aq_install_plating(plate)
	for(var/obj/item/mecha_parts/mecha_equipment/E in M.equipment.Copy())
		E.detach(N)
		if(E.can_attach(N))
			E.attach(N)
		else
			E.forceMove(get_turf(N))
	N.dna_lock = M.dna_lock
	N.maint_access = M.maint_access
	N.strafe = M.strafe
	N.obj_integrity = min(M.obj_integrity, N.max_integrity)
	N.aq_fuses = M.aq_fuses
	N.setDir(M.dir)
	M.wreckage = null
	qdel(M)
	playsound(get_turf(N), 'sound/items/ratchet.ogg', 50, TRUE)
	return N

/obj/item/mecha_parts/mecha_equipment/aq_conversion_kit/paddy
	name = "zestaw konwersji APLU \"Paddy\""
	desc = "Zestaw (tg) przerabiający APLU MK-I \"Ripley\" na lekki mech ochrony Paddy: pancerz, syreny, cela na zatrzymanych i gniazdo chwytaka na ludzi. Po założeniu nie da się go zdjąć."
	icon_state = "paddyupgrade"
	source_mechs = list(/obj/mecha/working/ripley)
	result_mech = /obj/mecha/working/ripley/aq_paddy

/obj/item/mecha_parts/mecha_equipment/aq_conversion_kit/clip_ripley
	name = "zestaw konwersji CLIP Ripley MK-IV"
	desc = "Lekka kabina od CLIP (Shiptest) dla APLU MK-I: szybki, hermetyczny Ripley MK-IV zdolny do pracy w próżni. Po założeniu nie da się go zdjąć."
	icon_state = "aq_conversion_clip"
	source_mechs = list(/obj/mecha/working/ripley, /obj/mecha/working/ripley/mining)
	result_mech = /obj/mecha/working/ripley/aq_clip

/obj/item/mecha_parts/mecha_equipment/aq_conversion_kit/paladin
	name = "zestaw konwersji CLIP Paladin"
	desc = "Zestaw od CLIP (Shiptest) przerabiający Duranda na Paladina do walki z fauną: grubszy pancerz w zwarciu i siatka razząca atakujących wręcz, kosztem osłony przed pociskami."
	icon_state = "aq_conversion_clip"
	source_mechs = list(/obj/mecha/combat/durand)
	result_mech = /obj/mecha/combat/durand/aq_paladin

/obj/item/mecha_parts/mecha_equipment/aq_conversion_kit/basenji
	name = "zestaw konwersji IRMG Basenji"
	desc = "Zestaw najemników IRMG (Shiptest) dla Gygaxa: wymaksowane siłowniki nóg pozwalają na krótkie szarże burzące ściany i rozrzucające ludzi."
	icon_state = "aq_conversion_inteq"
	source_mechs = list(/obj/mecha/combat/gygax, /obj/mecha/combat/gygax/dark)
	result_mech = /obj/mecha/combat/gygax/aq_basenji

/obj/item/mecha_parts/mecha_equipment/aq_conversion_kit/mp
	name = "zestaw konwersji MW-501p-MP"
	desc = "Zestaw Makosso-Warra (Shiptest) dla Gygaxa: lżejszy pancerz z masowej produkcji i szybkie szarże na średni dystans, bez burzenia ścian."
	icon_state = "aq_conversion_mp"
	source_mechs = list(/obj/mecha/combat/gygax, /obj/mecha/combat/gygax/dark)
	result_mech = /obj/mecha/combat/gygax/aq_basenji/aq_mp

/obj/item/mecha_parts/mecha_equipment/aq_conversion_kit/dark_gygax
	name = "zestaw konwersji 515 EX"
	desc = "Oficjalny zestaw Cybersun (Shiptest) przerabiający Gygaxa na ulepszony Gygax 515 EX. Sprzęt Syndykatu."
	icon_state = "aq_conversion_dark"
	source_mechs = list(/obj/mecha/combat/gygax)
	result_mech = /obj/mecha/combat/gygax/dark

// ---------------------------------------------------------------- podwozia z zestawów
/obj/mecha/working/ripley/aq_clip
	name = "\improper CLIP Ripley MK-IV"
	desc = "Lekki, hermetyczny APLU od CLIP: szybszy od MK-II i zdolny do pracy w próżni, ale słabiej opancerzony."
	icon = 'aquila/icons/mecha/aq_mecha.dmi'
	icon_state = "clipripley"
	silicon_icon_state = null
	step_in = 2
	max_integrity = 160
	armor = list("melee" = 30, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 40, "bio" = 0, "rad" = 50, "fire" = 100, "acid" = 100, "stamina" = 0)
	wreckage = /obj/structure/mecha_wreckage/aq_clip_ripley
	enclosed = TRUE
	enter_delay = 30

/obj/structure/mecha_wreckage/aq_clip_ripley
	name = "wrak CLIP Ripley MK-IV"
	icon = 'aquila/icons/mecha/aq_mecha.dmi'
	icon_state = "clipripley-broken"
	welder_salvage = list(/obj/item/stack/sheet/plasteel, /obj/item/stack/sheet/iron, /obj/item/stack/rods)

/obj/mecha/combat/durand/aq_paladin
	name = "\improper Paladin"
	desc = "Starzejący się Durand przerobiony przez dział CLIP do walki z fauną: grubszy pancerz w zwarciu i siatka razząca atakujących wręcz, kosztem osłony przed pociskami."
	icon = 'aquila/icons/mecha/aq_mecha.dmi'
	icon_state = "clipdurand"
	armor = list("melee" = 75, "bullet" = 50, "laser" = 50, "energy" = 10, "bomb" = 20, "bio" = 0, "rad" = 50, "fire" = 100, "acid" = 100, "stamina" = 0)
	deflect_chance = 20
	wreckage = /obj/structure/mecha_wreckage/aq_paladin

/obj/mecha/combat/durand/aq_paladin/aq_shock_attacker(mob/living/attacker)
	. = ..()
	if(isliving(attacker) && Adjacent(attacker) && has_charge(100) && prob(50))
		use_power(100)
		attacker.electrocute_act(10, src, 1)
		spark_system.start()

/obj/structure/mecha_wreckage/aq_paladin
	name = "wrak Paladina"
	icon = 'aquila/icons/mecha/aq_mecha.dmi'
	icon_state = "clipdurand-broken"

/obj/mecha/combat/gygax/aq_basenji
	name = "\improper Basenji"
	desc = "Lekki mech ochrony Cybersun mocno przerobiony przez najemników IRMG. Wymaksowane siłowniki nóg pozwalają na krótkie szarże burzące ściany i przeszkody."
	icon = 'aquila/icons/mecha/aq_mecha.dmi'
	icon_state = "inteqgygax"
	wreckage = /obj/structure/mecha_wreckage/aq_basenji
	var/charge_distance = 5
	var/charge_break_walls = TRUE
	var/charge_toss = TRUE
	var/charge_cooldown = 10 SECONDS
	var/charge_power = 500
	var/datum/action/innate/mecha/aq_charge/charge_action = new
	COOLDOWN_DECLARE(charge_cd)

/obj/mecha/combat/gygax/aq_basenji/GrantActions(mob/living/user, human_occupant = 0)
	. = ..()
	overload_action.Remove(user)
	charge_action.Grant(user, src)

/obj/mecha/combat/gygax/aq_basenji/RemoveActions(mob/living/user, human_occupant = 0)
	. = ..()
	charge_action.Remove(user)

/obj/mecha/combat/gygax/aq_basenji/Destroy()
	. = ..()
	QDEL_NULL(charge_action)

/obj/mecha/combat/gygax/aq_basenji/proc/charge()
	if(!COOLDOWN_FINISHED(src, charge_cd))
		occupant_message("<span class='warning'>Siłowniki jeszcze się nie zregenerowały.</span>")
		return
	if(!has_charge(charge_power) || completely_disabled)
		return
	use_power(charge_power)
	COOLDOWN_START(src, charge_cd, charge_cooldown)
	aq_adjust_heat(15)
	visible_message("<span class='danger'>[src] rusza do szarży!</span>")
	playsound(src, 'sound/mecha/mechstep.ogg', 70, TRUE)
	for(var/i in 1 to charge_distance)
		var/turf/T = get_step(src, dir)
		if(!T)
			break
		if(T.density)
			if(charge_break_walls && iswallturf(T) && !istype(T, /turf/closed/wall/r_wall))
				var/turf/closed/wall/W = T
				W.dismantle_wall()
				playsound(T, 'sound/effects/meteorimpact.ogg', 60, TRUE)
			break
		var/stop = FALSE
		for(var/atom/movable/AM in T)
			if(isliving(AM) && charge_toss)
				var/mob/living/L = AM
				L.Knockdown(2 SECONDS)
				L.adjustBruteLoss(10)
				L.throw_at(get_edge_target_turf(L, turn(dir, pick(90, -90))), 3, 2, src)
			else if(AM.density && isobj(AM))
				var/obj/O = AM
				O.take_damage(60, BRUTE, "melee", TRUE)
				if(O.density)
					stop = TRUE
		if(stop)
			break
		forceMove(T)
		sleep(1)

/datum/action/innate/mecha/aq_charge
	name = "Szarża"
	button_icon_state = "mech_overload_on"

/datum/action/innate/mecha/aq_charge/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	var/obj/mecha/combat/gygax/aq_basenji/B = chassis
	if(istype(B))
		INVOKE_ASYNC(B, TYPE_PROC_REF(/obj/mecha/combat/gygax/aq_basenji, charge))

/obj/structure/mecha_wreckage/aq_basenji
	name = "wrak Basenji"
	icon = 'aquila/icons/mecha/aq_mecha.dmi'
	icon_state = "inteqgygax-broken"

/obj/mecha/combat/gygax/aq_basenji/aq_mp
	name = "\improper MW-501p-MP"
	desc = "Pochodna Gygaxa przerobiona do masowej produkcji: cieńszy pancerz, lżejsza rama i szybkie szarże na średni dystans bez dużego poboru prądu."
	icon_state = "mpgygax"
	armor = list("melee" = 25, "bullet" = 30, "laser" = 30, "energy" = 15, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100, "stamina" = 0)
	wreckage = /obj/structure/mecha_wreckage/aq_mp
	charge_break_walls = FALSE
	charge_toss = FALSE
	charge_distance = 6
	charge_cooldown = 1 SECONDS
	charge_power = 100

/obj/structure/mecha_wreckage/aq_mp
	name = "wrak MW-501p-MP"
	icon = 'aquila/icons/mecha/aq_mecha.dmi'
	icon_state = "mpgygax-broken"
