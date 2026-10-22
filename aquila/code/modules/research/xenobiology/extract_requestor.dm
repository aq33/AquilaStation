// Pad zamówień ekstraktów (port SLIMECORE z Monkestation 2.0).
// Członek załogi wybiera ekstrakt, liczbę sztuk i nagrodę w kredytach, płacąc z konta na karcie.
// Xenobiolog oddaje ekstrakty przez pad rynku. Gotowe zamówienie odbiera się na tym padzie.
// Nagroda trafia na konto działu nauki, a rynek dolicza xenobio points (3 za kredyt).

/// Ile xenobio points za każdy kredyt nagrody z ukończonego zamówienia
// Używane też w slime_market.dm, który go #undefuje
#define SLIME_REQUEST_POINTS_PER_CREDIT 3
/// Ile ekstraktów można zamówić naraz
#define EXTRACT_REQUEST_MAX_AMOUNT 15

/obj/machinery/slime_extract_requestor
	name = "extract requestor pad"
	desc = "Pad do zamawiania ekstraktów szlamu u xenobiologów. Płacisz z konta na karcie, odbierasz tutaj."
	icon = 'aquila/icons/obj/xenobiology/slime_market.dmi'
	icon_state = "civilian_pad"
	base_icon_state = "civilian_pad"
	density = TRUE
	layer = BELOW_OBJ_LAYER
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	active_power_usage = 250
	circuit = /obj/item/circuitboard/machine/slime_extract_requestor
	var/obj/machinery/computer/slime_market/console
	var/list/datum/extract_request_data/current_requests = list()
	/// nazwa ekstraktu -> obrazek do menu radialnego
	var/static/list/extracts
	/// nazwa ekstraktu -> typ
	var/static/list/name_to_path

/obj/machinery/slime_extract_requestor/Initialize(mapload)
	. = ..()
	if(!extracts)
		extracts = list()
		name_to_path = list()
		for(var/obj/item/slime_extract/extract as anything in subtypesof(/obj/item/slime_extract))
			extracts[initial(extract.name)] = image(icon = initial(extract.icon), icon_state = initial(extract.icon_state))
			name_to_path[initial(extract.name)] = extract
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/slime_extract_requestor/LateInitialize()
	if(GLOB.default_slime_market && !GLOB.default_slime_market.request_pad)
		link_console(GLOB.default_slime_market)

/obj/machinery/slime_extract_requestor/Destroy()
	for(var/datum/extract_request_data/request as anything in current_requests)
		request.cancel_request_early(console, drop_location())
	current_requests.Cut()
	if(console?.request_pad == src)
		console.request_pad = null
	console = null
	return ..()

/obj/machinery/slime_extract_requestor/proc/link_console(obj/machinery/computer/slime_market/new_console)
	if(console?.request_pad == src)
		console.request_pad = null
	console = new_console
	if(new_console.request_pad && new_console.request_pad != src)
		new_console.request_pad.console = null
	new_console.request_pad = src

/obj/machinery/slime_extract_requestor/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Kliknij z kartą ID, żeby zamówić ekstrakty albo odebrać gotowe zamówienie.</span>"
	if(!console)
		. += "<span class='warning'>Nie jest połączony z konsolą rynku szlamów. Połącz go multitoolem przy otwartym panelu.</span>"

/obj/machinery/slime_extract_requestor/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, W))
		return
	if(default_unfasten_wrench(user, W))
		return
	if(default_deconstruction_crowbar(W))
		return
	return ..()

/obj/machinery/slime_extract_requestor/multitool_act(mob/living/user, obj/item/I)
	var/obj/item/multitool/M = I
	if(!istype(M))
		return FALSE
	if(!panel_open)
		to_chat(user, "<span class='warning'>Najpierw otwórz panel [src].</span>")
		return TRUE
	M.buffer = src
	to_chat(user, "<span class='notice'>Zapisujesz [src] w buforze multitoola. Użyj go na konsoli rynku szlamów.</span>")
	return TRUE

/obj/machinery/slime_extract_requestor/interact(mob/user)
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if(!console)
		to_chat(user, "<span class='warning'>[src] nie jest połączony z konsolą rynku szlamów!</span>")
		return
	var/obj/item/card/id/card = user.get_idcard(TRUE)
	if(!card)
		to_chat(user, "<span class='warning'>Nie wykryto karty ID!</span>")
		return
	var/datum/extract_request_data/request = find_request(card)
	if(request)
		if(request.ready_for_pickup)
			collect_request(request)
			return
		if(tgui_alert(user, "Masz już otwarte zamówienie. Anulować je? Dostaniesz zwrot połowy nagrody.", name, list("Tak", "Nie")) == "Tak" && !QDELETED(request))
			current_requests -= request
			request.cancel_request_early(console, drop_location())
		return
	create_request(user, card)

/obj/machinery/slime_extract_requestor/proc/find_request(obj/item/card/id/card)
	for(var/datum/extract_request_data/request as anything in current_requests)
		if(request.host_card == card)
			return request

/obj/machinery/slime_extract_requestor/proc/collect_request(datum/extract_request_data/request)
	var/obj/item/storage/box/box = new(drop_location())
	box.name = "pudełko ekstraktów"
	for(var/i in 1 to request.extracts_needed)
		new request.extract_path(box)
	flick("[base_icon_state]_vend", src)
	current_requests -= request
	request.finish_request(console)

/obj/machinery/slime_extract_requestor/proc/create_request(mob/user, obj/item/card/id/card)
	if(!card.registered_account)
		to_chat(user, "<span class='warning'>Ta karta nie ma przypisanego konta!</span>")
		return
	var/choice = show_radial_menu(user, src, extracts, require_near = TRUE, tooltips = TRUE)
	if(!(choice in name_to_path))
		return
	var/amount = tgui_input_number(user, "Ile ekstraktów zamawiasz?", name, 1, EXTRACT_REQUEST_MAX_AMOUNT, 1)
	if(!amount || QDELETED(src) || !user.canUseTopic(src, BE_CLOSE))
		return
	var/payout = tgui_input_number(user, "Ile kredytów nagrody dla xenobiologów? Za każdy kredyt rynek doliczy [SLIME_REQUEST_POINTS_PER_CREDIT] xenobio points.", name, 0, card.registered_account.account_balance, 0)
	if(isnull(payout) || QDELETED(src) || QDELETED(card) || !user.canUseTopic(src, BE_CLOSE) || find_request(card))
		return
	if(payout && !card.registered_account.adjust_money(-payout))
		to_chat(user, "<span class='warning'>Na koncie nie ma tylu kredytów!</span>")
		return

	var/datum/extract_request_data/request = new
	request.host_card = card
	request.linked_console = console
	request.extract_path = name_to_path[choice]
	request.extracts_needed = amount
	request.payout = payout
	request.request_name = "[card.registered_name]: [choice] ×[amount]"
	request.on_creation()
	current_requests += request
	console.say("Nowe zamówienie: [request.request_name], nagroda [payout] kr.")

/// Jedno zamówienie ekstraktów
/datum/extract_request_data
	var/request_name
	var/obj/machinery/computer/slime_market/linked_console
	/// Karta, z której złożono zamówienie. Tylko z nią można je odebrać.
	var/obj/item/card/id/host_card
	var/extract_path
	var/extracts_needed = 1
	/// Nagroda w kredytach, już pobrana z konta zamawiającego
	var/payout = 0
	var/extracts_given = 0
	var/ready_for_pickup = FALSE

/datum/extract_request_data/proc/on_creation()
	RegisterSignal(host_card, COMSIG_PARENT_QDELETING, PROC_REF(end_request_qdeleted))

/datum/extract_request_data/Destroy(force)
	if(host_card)
		UnregisterSignal(host_card, COMSIG_PARENT_QDELETING)
	host_card = null
	linked_console = null
	return ..()

/// Karta zniknęła: ekstrakty wracają do xenobiologów, połowa nagrody na konto nauki
/datum/extract_request_data/proc/end_request_qdeleted()
	SIGNAL_HANDLER
	if(linked_console)
		linked_console.say("Zamówienie anulowane: [request_name].")
		linked_console.return_extracts(extract_path, extracts_given)
		linked_console.request_pad?.current_requests -= src
	pay_science(payout * 0.5)
	qdel(src)

/// Bez konsoli dostarczone ekstrakty wypadają w return_location
/datum/extract_request_data/proc/cancel_request_early(obj/machinery/computer/slime_market/console, atom/return_location)
	if(console)
		console.say("Zamówienie anulowane: [request_name].")
		console.return_extracts(extract_path, extracts_given)
	else if(return_location)
		for(var/i in 1 to extracts_given)
			new extract_path(return_location)
	var/refund = round(payout * 0.5)
	if(refund)
		host_card.registered_account?.adjust_money(refund)
	pay_science(payout - refund)
	qdel(src)

/datum/extract_request_data/proc/finish_request(obj/machinery/computer/slime_market/console)
	console?.say("Odebrano zamówienie: [request_name].")
	pay_science(payout)
	GLOB.slime_market.points += payout * SLIME_REQUEST_POINTS_PER_CREDIT
	qdel(src)

/datum/extract_request_data/proc/pay_science(amount)
	amount = round(amount)
	if(amount <= 0)
		return
	var/datum/bank_account/science = SSeconomy.get_dep_account(ACCOUNT_SCI)
	science?.adjust_money(amount)

/datum/extract_request_data/proc/add_extract()
	extracts_given++
	if(extracts_given >= extracts_needed)
		ready_for_pickup = TRUE
		host_card.say("Zamówienie ekstraktów jest gotowe do odbioru.")

/obj/item/circuitboard/machine/slime_extract_requestor
	name = "Extract Requestor Pad (Machine Board)"
	icon_state = "science"
	build_path = /obj/machinery/slime_extract_requestor
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/sheet/glass = 1)

/datum/design/board/slime_extract_requestor
	name = "Machine Design (Extract Requestor Pad)"
	desc = "The circuit board for an extract requestor pad."
	id = "slime_extract_requestor"
	build_path = /obj/item/circuitboard/machine/slime_extract_requestor
	category = list("Research Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_SERVICE

#undef EXTRACT_REQUEST_MAX_AMOUNT
