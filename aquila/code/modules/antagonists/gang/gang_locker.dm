// Szafka gangu wzorowana na Goonstation: baza, sklep sprzętu, skup kontrabandy (gotówka, broń, narkotyki),
// darmowy mundur co 5 minut, przelewy punktów i przejęcie dowodzenia. Szef stawia ją akcją „Szafka gangu”.
// Szafka zajmuje teren wokół siebie, a gang może ją schować pod podłogę.

/obj/structure/gang_locker
	name = "szafka gangu"
	desc = "Obdrapana metalowa szafka z grubą kłódką i wymalowanym znakiem gangu."
	icon = 'icons/obj/closet.dmi'
	icon_state = "syndicate"
	density = TRUE
	anchored = TRUE
	max_integrity = 300
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 50, "acid" = 50, "stamina" = 0, "bleed" = 0)
	var/datum/team/gang/gang
	/// Gotówka czekająca na wypranie
	var/cash = 0
	/// Wyprane kredyty, które nie złożyły się jeszcze na punkt
	var/launder_carry = 0
	/// Kto ostatnio wrzucił gotówkę (dostaje premię za pranie)
	var/datum/mind/last_depositor
	/// Szafka schowana pod podłogą
	var/hidden = FALSE
	/// Umysł -> world.time, kiedy może odebrać kolejny mundur
	var/list/uniform_cooldowns = list()
	var/next_attack_alert = 0
	/// Szafka jest przenoszona: znika bez komunikatu i bez sypania gotówką
	var/moving = FALSE

/obj/structure/gang_locker/Initialize(mapload, datum/team/gang/G)
	. = ..()
	gang = G
	if(gang)
		if(gang.locker && gang.locker != src)
			qdel(gang.locker)
		gang.locker = src
		aq_gang_claim(src, gang, GANG_LOCKER_RADIUS)
	START_PROCESSING(SSobj, src)
	update_icon()

/obj/structure/gang_locker/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(gang)
		aq_gang_unclaim(src, gang)
		if(gang.locker == src)
			gang.locker = null
			if(!QDELETED(gang) && !moving)
				gang.message_gang("Nasza szafka została zniszczona! Szef może postawić nową.")
		gang = null
	if(cash > 0 && isturf(loc) && !moving)
		new /obj/item/holochip(loc, cash)
	cash = 0
	last_depositor = null
	return ..()

/obj/structure/gang_locker/update_icon()
	. = ..()
	cut_overlays()
	if(hidden)
		return
	add_overlay("syndicate_door")
	if(gang?.tag_icon)
		var/mutable_appearance/tag = mutable_appearance('icons/effects/crayondecal.dmi', gang.tag_icon)
		tag.color = gang.color
		tag.transform = matrix() * 0.5
		tag.pixel_y = 4
		add_overlay(tag)

/obj/structure/gang_locker/examine(mob/user)
	. = ..()
	if(is_member(user))
		. += "<span class='notice'>Pranie gotówki: [cash]/[GANG_LOCKER_CASH_CAP] kr. Wrzuć do szafki gotówkę, broń palną albo narkotyki, żeby dostać punkty.</span>"

/obj/structure/gang_locker/proc/is_member(mob/user)
	var/datum/antagonist/gang/GA = user?.mind?.has_antag_datum(/datum/antagonist/gang)
	return GA && GA.gang == gang

/obj/structure/gang_locker/process(delta_time)
	if(cash <= 0 || !gang)
		return
	var/amount = min(cash, GANG_LAUNDER_PER_SECOND * delta_time)
	cash -= amount
	launder_carry += amount
	var/laundered_points = round(launder_carry / GANG_CREDITS_PER_POINT)
	if(laundered_points > 0)
		launder_carry -= laundered_points * GANG_CREDITS_PER_POINT
		gang.add_income(laundered_points, GANG_SCORE_CASH, last_depositor)

/obj/structure/gang_locker/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, armour_penetration = 0)
	. = ..()
	if(!. || QDELETED(src) || !gang)
		return
	if(cash > 0 && isturf(loc))
		var/spilled = min(cash, round(. * 100))
		cash -= spilled
		new /obj/item/holochip(loc, spilled)
		visible_message("<span class='warning'>Z [src] sypią się kredyty!</span>")
	if(world.time >= next_attack_alert)
		next_attack_alert = world.time + 30 SECONDS
		gang.message_gang("Nasza szafka jest atakowana ([get_area_name(src)])!")

/obj/structure/gang_locker/attackby(obj/item/I, mob/living/user, params)
	if(is_member(user) && !user.combat_mode)
		if(sell(I, user))
			return TRUE
	return ..()

/// Skup: gotówka do prania, broń palna, narkotyki. Zwraca TRUE, jeśli szafka coś przyjęła albo odmówiła z komunikatem.
/obj/structure/gang_locker/proc/sell(obj/item/I, mob/living/user)
	if(istype(I, /obj/item/stack/spacecash) || istype(I, /obj/item/holochip))
		if(cash >= GANG_LOCKER_CASH_CAP)
			to_chat(user, "<span class='warning'>[src] jest pełna gotówki. Poczekaj, aż się wypierze.</span>")
			return TRUE
		var/value = I.get_item_credit_value()
		if(value > GANG_LOCKER_CASH_CAP - cash)
			to_chat(user, "<span class='warning'>Tyle się nie zmieści. Do prania zmieści się jeszcze [GANG_LOCKER_CASH_CAP - cash] kr.</span>")
			return TRUE
		if(!value || !user.temporarilyRemoveItemFromInventory(I))
			return TRUE
		cash += value
		last_depositor = user.mind
		qdel(I)
		to_chat(user, "<span class='notice'>Wrzucasz [value] kr. do prania.</span>")
		return TRUE
	if(istype(I, /obj/item/gun))
		if(!user.temporarilyRemoveItemFromInventory(I))
			return TRUE
		qdel(I)
		gang.add_income(GANG_GUN_POINTS, GANG_SCORE_GUN, user.mind)
		to_chat(user, "<span class='notice'>Gang odsprzeda tę broń. Każdy z was dostaje [GANG_GUN_POINTS] pkt.</span>")
		return TRUE
	var/list/containers = list()
	if(istype(I, /obj/item/storage/pill_bottle))
		for(var/obj/item/reagent_containers/pill in I)
			containers += pill
	else if(istype(I, /obj/item/reagent_containers))
		containers += I
	if(!length(containers))
		return FALSE
	var/drug_points = 0
	for(var/obj/item/reagent_containers/container as anything in containers)
		drug_points += sell_drugs_from(container)
	if(!drug_points)
		to_chat(user, "<span class='warning'>Tu nie ma nic, co gang by skupił.</span>")
		return TRUE
	gang.add_income(drug_points, GANG_SCORE_DRUG, user.mind)
	to_chat(user, "<span class='notice'>Gang upłynni ten towar. Każdy z was dostaje [drug_points] pkt.</span>")
	return TRUE

/// Zabiera z pojemnika narkotyki, które gang skupuje; pigułki i plastry znikają w całości
/obj/structure/gang_locker/proc/sell_drugs_from(obj/item/reagent_containers/container)
	. = 0
	if(!container.reagents)
		return
	var/list/values = aq_gang_drug_values()
	var/sold_any = FALSE
	var/kept_any = FALSE
	for(var/datum/reagent/R as anything in container.reagents.reagent_list.Copy())
		if(!values[R.type])
			continue
		var/accepted = min(R.volume, gang.drug_units_left(R.type))
		if(accepted < R.volume)
			kept_any = TRUE
		// Tuż przed limitem jednostka bywa warta mniej niż punkt: wtedy towar zostaje w pojemniku
		if(accepted <= 0 || gang.sell_drug(R.type, accepted, dry_run = TRUE) <= 0)
			kept_any = TRUE
			continue
		. += gang.sell_drug(R.type, accepted)
		container.reagents.remove_reagent(R.type, accepted)
		sold_any = TRUE
	if(sold_any && !kept_any && istype(container, /obj/item/reagent_containers/pill))
		qdel(container)

/obj/structure/gang_locker/attack_hand(mob/living/user)
	if(is_member(user))
		ui_interact(user)
		return
	return ..()

/obj/structure/gang_locker/ui_interact(mob/user, datum/tgui/ui)
	if(!is_member(user) || hidden)
		return
	var/list/dat = list()
	dat += "<b>Gang [gang.name]</b> - wynik gangu: <b>[gang.total_score()]</b>, teren: <b>[gang.territory_percent()]%</b> stacji<br>"
	dat += "Twoje punkty: <b>[gang.get_points(user.mind)]</b><br>"
	dat += "Pranie gotówki: [cash]/[GANG_LOCKER_CASH_CAP] kr.<br><br>"
	dat += "<a href='byond://?src=[REF(src)];uniform=1'>Odbierz mundur gangu</a> "
	dat += "<a href='byond://?src=[REF(src)];transfer=1'>Przelej punkty</a> "
	dat += "<a href='byond://?src=[REF(src)];refresh=1'>Odśwież</a><br>"
	if(gang.takeover_available() && !gang.is_boss(user.mind))
		dat += "<a href='byond://?src=[REF(src)];takeover=1'><b>Przejmij dowodzenie gangiem</b></a><br>"
	dat += "<hr>"
	var/list/shop = aq_gang_locker_items()
	for(var/cat in shop)
		dat += "<b>[cat]</b><br>"
		for(var/id in shop[cat])
			var/datum/gang_item/G = shop[cat][id]
			if(!G.can_see(user, gang, null))
				continue
			var/entry = G.get_name_display(user, gang, null)
			if(G.can_buy(user, gang, null))
				entry = "<a href='byond://?src=[REF(src)];buy=[id];cat=[url_encode(cat)]'>[entry]</a>"
			dat += "[G.get_cost_display(user, gang, null)] [entry]<br>"
		dat += "<br>"
	var/datum/browser/popup = new(user, "gang_locker", "Szafka gangu", 400, 600)
	popup.set_content(dat.Join())
	popup.open()

/obj/structure/gang_locker/Topic(href, href_list)
	. = ..()
	var/mob/living/user = usr
	if(!istype(user) || !is_member(user) || hidden || !user.Adjacent(src) || user.incapacitated())
		return
	if(href_list["buy"])
		var/list/category = aq_gang_locker_items()[href_list["cat"]]
		var/datum/gang_item/G = category?[href_list["buy"]]
		if(G?.can_buy(user, gang, null))
			G.purchase(user, gang, null, FALSE)
	else if(href_list["uniform"])
		give_uniform(user)
	else if(href_list["transfer"])
		transfer_points(user)
	else if(href_list["takeover"])
		if(gang.takeover_available() && !gang.is_boss(user.mind))
			gang.take_over(user.mind)
	ui_interact(user)

/obj/structure/gang_locker/proc/give_uniform(mob/living/user)
	if(world.time < (uniform_cooldowns[user.mind] || 0))
		to_chat(user, "<span class='warning'>Kolejny mundur dostaniesz za [DisplayTimeText(uniform_cooldowns[user.mind] - world.time)].</span>")
		return
	uniform_cooldowns[user.mind] = world.time + GANG_UNIFORM_COOLDOWN
	var/obj/item/storage/box/uniform_box = new(get_turf(user))
	uniform_box.name = "pudło z mundurem gangu"
	new gang.outfit(uniform_box)
	new gang.hat(uniform_box)
	if(gang.suit)
		new gang.suit(uniform_box)
	user.put_in_hands(uniform_box)
	to_chat(user, "<span class='notice'>Pełny mundur (kombinezon i nakrycie głowy) na terenie gangu daje więcej zdrowia i staminy.</span>")

/obj/structure/gang_locker/proc/transfer_points(mob/living/user)
	var/list/targets = list()
	for(var/datum/mind/member as anything in gang.members)
		if(member != user.mind)
			targets[member.name] = member
	if(!length(targets))
		return
	var/target_name = tgui_input_list(user, "Komu przelać punkty?", "Przelew punktów", targets)
	var/datum/mind/target = targets[target_name]
	if(!target)
		return
	var/amount = tgui_input_number(user, "Ile punktów przelać ([target.name])?", "Przelew punktów", 0, gang.get_points(user.mind), 0)
	if(!amount || !is_member(user) || !user.Adjacent(src) || !(target in gang.members))
		return
	amount = min(round(amount), gang.get_points(user.mind))
	if(amount <= 0)
		return
	gang.adjust_points(user.mind, -amount)
	gang.adjust_points(target, amount)
	to_chat(user, "<span class='notice'>Przelewasz [amount] pkt: [target.name].</span>")
	if(target.current)
		to_chat(target.current, "<span class='notice'>[user.real_name] przelewa ci [amount] pkt gangu.</span>")

/obj/structure/gang_locker/proc/toggle_hidden(mob/living/user)
	hidden = !hidden
	density = !hidden
	invisibility = hidden ? INVISIBILITY_MAXIMUM : 0
	mouse_opacity = hidden ? MOUSE_OPACITY_TRANSPARENT : MOUSE_OPACITY_ICON
	update_icon()
	playsound(src, 'sound/items/crowbar.ogg', 40, TRUE)
	user.visible_message("<span class='notice'>[user] [hidden ? "chowa szafkę pod podłogą" : "wyciąga szafkę spod podłogi"].</span>")

///////////////////
// Akcja „Szafka gangu”
///////////////////

/datum/action/innate/gang_locker
	name = "Szafka gangu"
	desc = "Postaw, schowaj albo znajdź szafkę gangu. Przy szafce kupujesz sprzęt i sprzedajesz kontrabandę."
	icon_icon = 'icons/obj/closet.dmi'
	button_icon_state = "syndicate"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/innate/gang_locker/Activate()
	var/mob/living/carbon/human/user = owner
	var/datum/antagonist/gang/GA = user?.mind?.has_antag_datum(/datum/antagonist/gang)
	if(!istype(user) || !GA?.gang)
		return
	var/datum/team/gang/G = GA.gang
	var/obj/structure/gang_locker/L = G.locker
	var/boss = istype(GA, /datum/antagonist/gang/boss)
	var/list/options = list()
	if(!L && boss)
		options += "Postaw szafkę tutaj"
	if(L)
		if(get_dist(user, L) <= 1 && user.z == L.z)
			options += (L.hidden ? "Wyciągnij szafkę spod podłogi" : "Schowaj szafkę pod podłogę")
		else
			options += "Gdzie jest szafka?"
		if(boss && get_dist(user, L) > 1)
			options += "Przenieś szafkę tutaj"
	if(G.takeover_available() && !G.is_boss(user.mind) && (!L || get_dist(user, L) <= 1))
		options += "Przejmij dowodzenie gangiem"
	if(!length(options))
		to_chat(user, "<span class='warning'>Gang nie ma jeszcze szafki. Postawi ją szef.</span>")
		return
	var/choice = length(options) == 1 ? options[1] : tgui_input_list(user, "Co robisz?", "Szafka gangu", options)
	if(!choice || user.incapacitated())
		return
	L = G.locker
	switch(choice)
		if("Postaw szafkę tutaj", "Przenieś szafkę tutaj")
			place_locker(user, G)
		if("Schowaj szafkę pod podłogę", "Wyciągnij szafkę spod podłogi")
			if(L && get_dist(user, L) <= 1 && do_after(user, 2 SECONDS, target = L))
				L.toggle_hidden(user)
		if("Gdzie jest szafka?")
			if(L)
				to_chat(user, "<span class='notice'>Szafka gangu: [get_area_name(L)], [get_dist(user, L)] kroków, kierunek: [aq_gang_dir_text(get_dir(user, L))].</span>")
		if("Przejmij dowodzenie gangiem")
			if(G.takeover_available() && !G.is_boss(user.mind))
				G.take_over(user.mind)

/datum/action/innate/gang_locker/proc/place_locker(mob/living/carbon/human/user, datum/team/gang/G)
	var/turf/T = get_turf(user)
	if(!can_place_locker(user, G, T))
		return
	if(!do_after(user, 5 SECONDS, target = T))
		return
	// W trakcie stawiania rywal mógł zająć kafelek, ktoś mógł coś postawić albo gangster mógł stracić stanowisko
	if(get_turf(user) != T || !can_place_locker(user, G, T))
		return
	var/obj/structure/gang_locker/old = G.locker
	var/old_cash = 0
	var/old_carry = 0
	var/datum/mind/old_depositor
	var/old_hidden = FALSE
	if(old)
		old_cash = old.cash
		old_carry = old.launder_carry
		old_depositor = old.last_depositor
		old_hidden = old.hidden
		old.moving = TRUE
		G.locker = null
		qdel(old)
	var/obj/structure/gang_locker/L = new(T, G)
	L.cash = old_cash
	L.launder_carry = old_carry
	L.last_depositor = old_depositor
	if(old_hidden)
		L.toggle_hidden(user)
	G.message_gang("[user.real_name] stawia szafkę gangu w: [get_area_name(L)].")

/datum/antagonist/gang
	var/datum/action/innate/gang_locker/locker_action

/datum/antagonist/gang/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/M = mob_override || owner.current
	if(!M)
		return
	if(!locker_action)
		locker_action = new
	locker_action.Grant(M)

/datum/antagonist/gang/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/M = mob_override || owner.current
	if(M)
		locker_action?.Remove(M)

/datum/antagonist/gang/Destroy()
	QDEL_NULL(locker_action)
	return ..()

///////////////////
// Przywództwo: nazwa i mundur od szefa, przejęcie po śmierci szefa
///////////////////

/datum/team/gang
	/// Szef już wybrał nazwę i mundur
	var/identity_chosen = FALSE
	/// Od kiedy szef nie żyje (0 = żyje)
	var/boss_dead_since = 0
	/// Gang usłyszał już, że może przejąć dowodzenie
	var/takeover_announced = FALSE

/// Szef gangu (nie porucznik)
/datum/team/gang/proc/current_boss()
	for(var/datum/mind/leader as anything in leaders)
		var/datum/antagonist/gang/boss/B = leader.has_antag_datum(/datum/antagonist/gang/boss)
		if(B?.type == /datum/antagonist/gang/boss)
			return leader

/datum/team/gang/proc/is_boss(datum/mind/M)
	return M && M == current_boss()

/// Czy członkowie mogą przejąć dowodzenie: szefa nie ma, albo nie żyje (od razu bez szafki, po 5 minutach z szafką)
/datum/team/gang/proc/takeover_available()
	var/datum/mind/boss = current_boss()
	var/mob/living/M = boss?.current
	if(!boss || QDELETED(M))
		return TRUE
	if(M.stat != DEAD)
		boss_dead_since = 0
		takeover_announced = FALSE
		return FALSE
	if(!boss_dead_since)
		boss_dead_since = world.time
	if(!locker)
		return TRUE
	return world.time - boss_dead_since >= GANG_TAKEOVER_DELAY

/datum/team/gang/proc/check_takeover()
	if(takeover_announced || !length(members) || !takeover_available())
		return
	takeover_announced = TRUE
	message_gang("Szefa nie ma. Pierwszy, kto zgłosi się przez akcję „Szafka gangu” [locker ? "przy szafce" : ""], przejmie dowodzenie.")

/datum/team/gang/proc/take_over(datum/mind/claimant)
	var/datum/antagonist/gang/old_datum = claimant?.has_antag_datum(/datum/antagonist/gang)
	if(!old_datum || old_datum.gang != src)
		return FALSE
	var/datum/mind/old_boss = current_boss()
	if(old_boss)
		var/datum/antagonist/gang/boss/B = old_boss.has_antag_datum(/datum/antagonist/gang/boss)
		if(old_boss.current)
			B.demote()
		else
			old_boss.remove_antag_datum(B.type)
	old_datum.silent = TRUE
	claimant.remove_antag_datum(old_datum.type)
	var/datum/antagonist/gang/boss/new_boss = new
	new_boss.silent = TRUE
	claimant.add_antag_datum(new_boss, src)
	new_boss.silent = FALSE
	new_boss.equip_gang(TRUE, FALSE, FALSE, FALSE)
	takeover_announced = FALSE
	boss_dead_since = 0
	log_game("[key_name(claimant)] took over the leadership of the [name] gang")
	message_gang("[claimant.name] przejmuje dowodzenie gangiem!")
	return TRUE

/datum/antagonist/gang/boss/on_gain()
	. = ..()
	if(type == /datum/antagonist/gang/boss && gang && !gang.identity_chosen)
		gang.identity_chosen = TRUE
		INVOKE_ASYNC(gang, TYPE_PROC_REF(/datum/team/gang, choose_identity), owner)

/datum/team/gang/proc/uniform_taken(outfit_type)
	for(var/datum/team/gang/other as anything in GLOB.gangs)
		if(other != src && other.outfit == outfit_type)
			return TRUE
	return FALSE

/proc/aq_gang_dir_text(direction)
	var/static/list/directions = list("north" = "północ", "south" = "południe", "east" = "wschód", "west" = "zachód", "northeast" = "północny wschód", "southeast" = "południowy wschód", "northwest" = "północny zachód", "southwest" = "południowy zachód")
	return directions[dir2text(direction)] || "tutaj"

/// Czy `user` może postawić albo przenieść szafkę gangu `G` na `T` (szef, miejsce na stacji, nie teren wroga)
/datum/action/innate/gang_locker/proc/can_place_locker(mob/living/carbon/human/user, datum/team/gang/G, turf/T)
	var/datum/antagonist/gang/GA = user.mind?.has_antag_datum(/datum/antagonist/gang)
	if(!istype(GA, /datum/antagonist/gang/boss) || GA.gang != G || user.incapacitated())
		return FALSE
	var/area/A = get_area(T)
	if(!isopenturf(T) || isspaceturf(T) || !aq_gang_station_turf(T) || !(A.area_flags & VALID_TERRITORY))
		to_chat(user, "<span class='warning'>Tutaj nie postawisz szafki.</span>")
		return FALSE
	for(var/obj/O in T)
		if(O.density)
			to_chat(user, "<span class='warning'>Tu nie ma miejsca na szafkę.</span>")
			return FALSE
	for(var/datum/team/gang/owner as anything in aq_gang_turf_gangs(T))
		if(owner != G)
			to_chat(user, "<span class='warning'>To teren gangu [owner]. Szafkę stawiasz na neutralnym albo własnym terenie.</span>")
			return FALSE
	if(G.locker && !G.owns_turf(T))
		to_chat(user, "<span class='warning'>Szafkę przeniesiesz tylko w obrębie terenu gangu.</span>")
		return FALSE
	return TRUE
