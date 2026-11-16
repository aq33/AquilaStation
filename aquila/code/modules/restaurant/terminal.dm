///Ścienny terminal lokalu: kucharz (albo barman) widzi tu gości i ich zamówienia. Lokal otwiera się sam na czas zlecenia gości ze stacji handlowej (station_contracts.dm)
/obj/machinery/restaurant_terminal
	name = "terminal restauracji"
	desc = "Panel z listą gości z portalu i ich zamówień. Lokal otwiera się sam na czas zlecenia gości ze stacji handlowej."
	icon = 'icons/obj/terminals.dmi'
	icon_state = "dorm_taken"
	density = FALSE
	anchored = TRUE
	layer = ABOVE_WINDOW_LAYER
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 50
	resistance_flags = FIRE_PROOF | ACID_PROOF
	max_integrity = 200
	///Lokal obsługiwany przez terminal. Typ zamieniany w Initialize na instancję
	var/datum/venue/linked_venue = /datum/venue/restaurant
	COOLDOWN_DECLARE(announce_cooldown)

/obj/machinery/restaurant_terminal/Initialize(mapload)
	. = ..()
	linked_venue = SSrestaurant.get_venue(linked_venue)
	linked_venue.terminals += src
	update_appearance()

/obj/machinery/restaurant_terminal/Destroy()
	if(istype(linked_venue))
		linked_venue.terminals -= src
	linked_venue = null
	return ..()

/obj/machinery/restaurant_terminal/update_icon_state()
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN))
		icon_state = "dorm_off"
	else
		icon_state = linked_venue?.open ? "dorm_available" : "dorm_taken"

/obj/machinery/restaurant_terminal/power_change()
	. = ..()
	update_appearance()

/obj/machinery/restaurant_terminal/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[linked_venue.display_name] jest teraz [linked_venue.open ? "<b>otwarta</b>" : "<b>zamknięta</b>"].</span>"

///Terminal mówi na głos nowe zamówienie
/obj/machinery/restaurant_terminal/proc/announce_order(mob/living/simple_animal/robot_customer/customer, order_name)
	if(machine_stat & (NOPOWER|BROKEN))
		return
	say("[customer.name] zamawia: [order_name].")
	if(COOLDOWN_FINISHED(src, announce_cooldown))
		playsound(src, 'sound/machines/ping.ogg', 40, FALSE)
		COOLDOWN_START(src, announce_cooldown, 3 SECONDS)

/obj/machinery/restaurant_terminal/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RestaurantTerminal", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/restaurant_terminal/ui_data(mob/user)
	var/list/data = list()
	data["venue_name"] = linked_venue.display_name
	data["open"] = linked_venue.open
	data["has_portal"] = !!linked_venue.restaurant_portal
	data["served"] = linked_venue.customers_served
	data["lost"] = linked_venue.customers_lost
	data["income"] = linked_venue.total_income
	data["seats_total"] = length(linked_venue.linked_seats)
	data["seats_free"] = linked_venue.free_seat_count()
	data["max_guests"] = linked_venue.max_guests
	data["contract"] = aq_venue_contract_entry(linked_venue)

	var/list/guests = list()
	for(var/mob/living/simple_animal/robot_customer/customer as anything in linked_venue.current_visitors)
		var/datum/ai_controller/controller = customer.ai_controller
		if(!controller)
			continue
		var/datum/customer_data/customer_data = controller.blackboard[BB_CUSTOMER_CUSTOMERINFO]
		var/order = controller.blackboard[BB_CUSTOMER_CURRENT_ORDER]
		var/status
		if(controller.blackboard[BB_CUSTOMER_LEAVING])
			status = controller.blackboard[BB_CUSTOMER_EATING] ? "Wychodzi zadowolony" : "Wychodzi"
		else if(controller.blackboard[BB_CUSTOMER_CURRENT_TARGET])
			status = "Bije się!"
		else if(controller.blackboard[BB_CUSTOMER_EATING])
			status = "Je"
		else if(order)
			status = "Czeka na zamówienie"
		else if(controller.blackboard[BB_CUSTOMER_MY_SEAT])
			status = "Idzie do stolika"
		else
			status = "Szuka miejsca"
		var/patience = 0
		if(customer_data?.total_patience)
			patience = clamp(round(100 * controller.blackboard[BB_CUSTOMER_PATIENCE] / customer_data.total_patience), 0, 100)
		guests += list(list(
			"name" = customer.name,
			"order" = order ? linked_venue.get_order_name(order) : null,
			"status" = status,
			"patience" = patience,
			"waiting" = !!order,
		))
	data["guests"] = guests
	return data

///Kierunek do sąsiedniego stołu (najpierw ten, w który patrzy krzesło), albo 0, gdy obok nie ma stołu
/proc/robot_seat_table_dir(turf/seat_turf)
	var/obj/structure/chair/chair = locate() in seat_turf
	if(chair)
		var/turf/front = get_step(seat_turf, chair.dir)
		if(front && (locate(/obj/structure/table) in front))
			return chair.dir
	for(var/direction in GLOB.cardinals)
		var/turf/neighbour = get_step(seat_turf, direction)
		if(neighbour && (locate(/obj/structure/table) in neighbour))
			return direction
	return 0


/obj/machinery/restaurant_terminal/restaurant
	name = "terminal restauracji"
	linked_venue = /datum/venue/restaurant

/obj/machinery/restaurant_terminal/bar
	name = "terminal baru"
	desc = "Panel z listą gości z portalu baru i ich zamówień. Bar otwiera się sam na czas zlecenia gości ze stacji handlowej."
	linked_venue = /datum/venue/bar
