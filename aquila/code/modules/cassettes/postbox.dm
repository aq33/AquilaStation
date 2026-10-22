// AQUILA - skrzynka i recenzja kaset z Monkestation (machines/postbox.dm, cassette_approval.dm).
// Zgłoszenie kosztuje CASSETTE_SUBMIT_COST aquilosów (u Monke 5000 Monkecoinów), przy odrzuceniu wracają.

/// id recenzji (tekst) -> /datum/cassette_review
GLOBAL_LIST_EMPTY(cassette_reviews)

/obj/machinery/cassette_postbox
	name = "skrzynka Kosmicznej Rady Muzycznej"
	desc = "Ma szczelinę w sam raz na kasetę. Rada ocenia nagrania, a zatwierdzone trafiają do biblioteki kaset."
	icon = 'aquila/icons/obj/cassettes/radio_station.dmi'
	icon_state = "postbox"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	use_power = NO_POWER_USE
	anchored = TRUE
	density = TRUE

/obj/machinery/cassette_postbox/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Zgłoszenie kosztuje [CASSETTE_SUBMIT_COST] [CONFIG_GET(string/metacurrency_name)]. Przy odrzuceniu zwracamy całość.</span>"

/obj/machinery/cassette_postbox/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/cassette_tape))
		return ..()
	try_submit(I, user)
	return TRUE

/obj/machinery/cassette_postbox/proc/try_submit(obj/item/cassette_tape/tape, mob/user)
	var/client/C = user.client
	if(!C)
		return FALSE
	var/datum/cassette/cassette = tape.cassette_data
	if(cassette.status == CASSETTE_STATUS_APPROVED)
		to_chat(user, "<span class='notice'>Ta kaseta jest już zatwierdzona.</span>")
		return FALSE
	if(cassette.status == CASSETTE_STATUS_REVIEWING)
		to_chat(user, "<span class='notice'>Ta kaseta czeka już na recenzję.</span>")
		return FALSE
	if(cassette.is_blank())
		to_chat(user, "<span class='notice'>Ta kaseta jest pusta.</span>")
		return FALSE
	if(!cassette.name || !cassette.desc)
		to_chat(user, "<span class='notice'>Najpierw nadaj kasecie nazwę i opis (długopisem) - po zgłoszeniu nie da się ich zmienić.</span>")
		return FALSE
	if(!length(get_admin_counts(R_FUN)["present"]))
		to_chat(user, "<span class='notice'>Skrzynka nie przyjmuje kasety - wygląda na to, że Rada wyszła na obiad. (Brak adminów, spróbuj później.)</span>")
		return FALSE
	var/currency = CONFIG_GET(string/metacurrency_name)
	if(tgui_alert(user, "Zgłoszenie kosztuje [CASSETTE_SUBMIT_COST] [currency]. Jeśli kaseta zostanie odrzucona, zwrócimy całość. Zgłosić?", "Kosmiczna Rada Muzyczna", list("Tak", "Nie")) != "Tak")
		return FALSE
	if(QDELETED(tape) || tape.loc != user || !user.Adjacent(src))
		return FALSE
	if(SSdbcore.IsConnected()) // bez bazy (gra lokalna) nie pobieramy opłaty
		if(C.get_metabalance() < CASSETTE_SUBMIT_COST)
			to_chat(user, "<span class='warning'>Masz za mało [currency], żeby zgłosić kasetę.</span>")
			return FALSE
		C.inc_metabalance(-CASSETTE_SUBMIT_COST, TRUE, "Zgłoszenie kasety do Kosmicznej Rady Muzycznej.")
	if(!user.temporarilyRemoveItemFromInventory(tape))
		return FALSE
	submit_cassette_for_review(user, tape)
	return TRUE

/datum/cassette_review
	var/datum/cassette/cassette_data
	/// Kaseta czeka w nullspace i wraca do zgłaszającego po decyzji
	var/obj/item/cassette_tape/tape
	var/submitter_ckey
	var/datum/weakref/submitter_mob
	var/review_id
	/// Czy pobrano opłatę (bez bazy nie pobieramy, więc nie zwracamy)
	var/paid = FALSE

/datum/cassette_review/New(mob/submitter, obj/item/cassette_tape/tape, paid)
	. = ..()
	var/static/last_review_id = 0
	src.tape = tape
	cassette_data = tape.cassette_data
	submitter_ckey = submitter.ckey
	submitter_mob = WEAKREF(submitter)
	src.paid = paid
	review_id = "[++last_review_id]"
	GLOB.cassette_reviews[review_id] = src

/datum/cassette_review/Destroy(force)
	GLOB.cassette_reviews -= review_id
	return_tape()
	cassette_data = null
	submitter_mob = null
	return ..()

/// Oddaje kasetę zgłaszającemu (do ręki albo pod nogi), a gdy go nie ma - usuwa
/datum/cassette_review/proc/return_tape()
	if(QDELETED(tape))
		tape = null
		return
	var/mob/living/submitter = submitter_mob?.resolve()
	if(istype(submitter) && !QDELETED(submitter))
		tape.forceMove(submitter.drop_location())
		submitter.put_in_hands(tape)
		tape = null
	else
		QDEL_NULL(tape)

/datum/cassette_review/ui_state(mob/user)
	return GLOB.admin_state

/datum/cassette_review/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CassetteReview", "Kaseta od [submitter_ckey]")
		ui.open()

/datum/cassette_review/ui_static_data(mob/user)
	var/list/sides = list()
	for(var/i in 1 to 2)
		var/datum/cassette_side/side = cassette_data.get_side(i == 1)
		sides += list(list("name" = i == 1 ? "A" : "B", "songs" = side.ui_songs()))
	return list(
		"submitter" = submitter_ckey,
		"name" = html_decode(cassette_data.name),
		"desc" = html_decode(cassette_data.desc),
		"author" = cassette_data.author.name,
		"sides" = sides,
		"can_approve" = check_rights_for(user.client, R_FUN),
	)

/datum/cassette_review/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(!check_rights(R_FUN))
		return
	var/mob/user = usr
	switch(action)
		if("approve")
			approve(user)
			return TRUE
		if("deny")
			deny(user)
			return TRUE

/datum/cassette_review/proc/approve(mob/user)
	cassette_data.id = "[random_string(16, GLOB.hex_characters)]_[submitter_ckey]"
	cassette_data.status = CASSETTE_STATUS_APPROVED
	cassette_data.approved_ckey = user.ckey
	cassette_data.approved_time = rustg_unix_timestamp()
	SScassettes.add_approved(cassette_data)
	tape.cassette_data = cassette_data.copy()
	log_admin("[key_name(user)] approved [submitter_ckey]'s cassette \"[cassette_data.name]\" ([cassette_data.id])")
	message_admins("[key_name_admin(user)] zatwierdził(a) kasetę [submitter_ckey]: \"[cassette_data.name]\"")
	notify_submitter("<span class='big notice'>Kosmiczna Rada Muzyczna <b>zatwierdziła</b> twoją kasetę „[cassette_data.name]”. Jest już w bibliotece kaset.</span>")
	qdel(src)

/datum/cassette_review/proc/deny(mob/user)
	cassette_data.status = CASSETTE_STATUS_DENIED
	cassette_data.deleted_ckey = user.ckey
	cassette_data.deleted_time = rustg_unix_timestamp()
	log_admin("[key_name(user)] denied [submitter_ckey]'s cassette \"[cassette_data.name]\"")
	message_admins("[key_name_admin(user)] odrzucił(a) kasetę [submitter_ckey]: \"[cassette_data.name]\"")
	notify_submitter("<span class='big notice'>Kosmiczna Rada Muzyczna <b>odrzuciła</b> twoją kasetę „[cassette_data.name]”.</span>")
	refund()
	qdel(src)

/// Zwrot opłaty, także gdy zgłaszający jest teraz w innym mobie albo w lobby; offline - zapis w bazie po ckeyu
/datum/cassette_review/proc/refund()
	if(!paid)
		return
	var/client/C = GLOB.directory[submitter_ckey]
	if(C)
		C.set_metacoin_count(C.get_metabalance() + CASSETTE_SUBMIT_COST, FALSE)
		to_chat(C, "<span class='rose bold'>Zwrócono [CASSETTE_SUBMIT_COST] [CONFIG_GET(string/metacurrency_name)] za odrzuconą kasetę.</span>")
		return
	var/datum/DBQuery/query_refund = SSdbcore.NewQuery(
		"UPDATE [format_table_name("player")] SET metacoins = metacoins + :amount WHERE ckey = :ckey",
		list("amount" = CASSETTE_SUBMIT_COST, "ckey" = submitter_ckey)
	)
	query_refund.warn_execute()
	qdel(query_refund)

/datum/cassette_review/proc/notify_submitter(message)
	var/client/C = GLOB.directory[submitter_ckey]
	if(C)
		to_chat(C, message)

/proc/submit_cassette_for_review(mob/user, obj/item/cassette_tape/tape)
	tape.cassette_data.author.name = user.real_name
	tape.cassette_data.author.ckey = user.ckey
	tape.cassette_data.status = CASSETTE_STATUS_REVIEWING
	tape.cassette_data.submitted_time = rustg_unix_timestamp()
	tape.moveToNullspace()
	var/datum/cassette_review/review = new(user, tape, SSdbcore.IsConnected())
	log_game("[key_name(user)] submitted cassette \"[tape.cassette_data.name]\" for review")
	var/link = "<a href='byond://?src=[REF(review)];[HrefToken()];open_review=1'>Otwórz recenzję</a>"
	for(var/client/admin as anything in GLOB.admins)
		if(!check_rights_for(admin, R_FUN))
			continue
		to_chat(admin, "<span class='big admin'><span class='prefix'>KASETA:</span> <b>[key_name(user)]</b> zgłasza kasetę „[tape.cassette_data.name]” do zatwierdzenia. [link]</span>")
		SEND_SOUND(admin, sound('sound/items/bikehorn.ogg'))
	to_chat(user, "<span class='big notice'>Kaseta trafiła do Kosmicznej Rady Muzycznej. Dostaniesz wiadomość, gdy zapadnie decyzja.</span>")

/datum/cassette_review/Topic(href, list/href_list)
	. = ..()
	if(href_list["open_review"] && check_rights(R_FUN))
		ui_interact(usr)

/// Admin: lista kaset czekających na zatwierdzenie
/client/proc/cassette_reviews()
	set category = "Fun"
	set name = "Recenzje kaset"
	set desc = "Zatwierdzanie kaset zgłoszonych przez graczy"
	if(!check_rights(R_FUN))
		return
	if(!length(GLOB.cassette_reviews))
		to_chat(src, "<span class='warning'>Żadna kaseta nie czeka na recenzję.</span>")
		return
	var/list/options = list()
	for(var/review_id in GLOB.cassette_reviews)
		var/datum/cassette_review/review = GLOB.cassette_reviews[review_id]
		options["#[review_id] [review.submitter_ckey]: [html_decode(review.cassette_data.name)]"] = review
	var/choice = tgui_input_list(src, "Którą kasetę otworzyć?", "Recenzje kaset", options)
	var/datum/cassette_review/review = options[choice]
	if(review && !QDELETED(review))
		review.ui_interact(mob)
