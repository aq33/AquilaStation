/obj/effect/proc_holder/spell/targeted/conjure_item/summon_pie
	name = "Przywołanie tortu z kremem"
	desc = "Ulubiona broń klauna. Użyj, by przywołać świeży tort, który tylko czeka, by zapoznać się z czyjąś twarzą."
	invocation_type = "none"
	include_user = 1
	range = -1
	clothes_req = 0
	item_type = /obj/item/food/pie/cream

	charge_max = 30
	cooldown_min = 30
	action_icon = 'icons/obj/food/piecake.dmi'
	action_icon_state = "pie"

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/effect/proc_holder/spell/aimed/banana_peel
	name = "Wyczarowanie skórki od banana"
	desc = "Sprawiasz, że skórka od banana pojawia się znikąd prosto pod czyimiś stopami!"
	charge_type = "recharge"
	charge_max	= 100
	cooldown_min = 100
	clothes_req = 0
	invocation_type = "none"
	range = 7
	selection_type = "view"
	projectile_type = null

	active_msg = "Skupiasz się, a twój umysł sięga do wymiaru klaunów, gotów zmaterializować skórkę banana, gdzie tylko zechcesz!"
	deactive_msg = "Rozluźniasz się, a skórka pozostaje w „rozrzedzonym powietrzu”, z którego miała się wyłonić."
	action_icon = 'icons/obj/hydroponics/harvest.dmi'
	base_icon_state = "banana_peel"
	action_icon_state = "banana"


/obj/effect/proc_holder/spell/aimed/banana_peel/cast(list/targets, mob/user = usr)
	var/target = get_turf(targets[1])

	if(get_dist(user,target)>range)
		to_chat(user, "<span class='notice'>[target] jest za daleko!</span>")
		return

	. = ..()
	new /obj/item/grown/bananapeel(target)

/obj/effect/proc_holder/spell/aimed/banana_peel/update_icon()
	if(!action)
		return
	if(active)
		action.button_icon_state = base_icon_state
	else
		action.button_icon_state = action_icon_state

	action.UpdateButtonIcon()
	return
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/effect/proc_holder/spell/targeted/touch/megahonk
	name = "Mega HoNk"
	desc = "To zaklęcie skupia twoje wewnętrzne klaunie moce w jeden potężny HONK."
	hand_path = /obj/item/melee/touch_attack/megahonk

	charge_max = 100
	clothes_req = 0
	cooldown_min = 100

	action_icon = 'icons/mecha/mecha_equipment.dmi'
	action_icon_state = "mecha_honker"

/////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/effect/proc_holder/spell/targeted/touch/bspie
	name = "Bananowy placek bluespace"
	desc = "Zmieściłoby się tu całe ciało!"
	hand_path = /obj/item/melee/touch_attack/bspie

	charge_max = 450
	clothes_req = 0
	cooldown_min = 450

	action_icon = 'icons/obj/food/piecake.dmi'
	action_icon_state = "frostypie"




