/* Cards
 * Contains:
 *		DATA CARD
 *		ID CARD
 *		FINGERPRINT CARD HOLDER
 *		FINGERPRINT CARD
 */



/*
 * DATA CARDS - Used for the IC data card reader
 */
/obj/item/card
	name = "karta"
	desc = "Robi kartowe rzeczy."
	icon = 'nsv13/icons/obj/card.dmi' //NSV13 - old style
	w_class = WEIGHT_CLASS_TINY

	var/list/files = list()

/obj/item/card/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] zaczyna przeciągać [src] po swojej szyi! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	return BRUTELOSS

/obj/item/card/data
	name = "karta danych"
	desc = "Plastikowa karta z paskiem magnetycznym do prostego i szybkiego przechowywania i przenoszenia danych. Przez środek tej biegnie pasek."
	icon_state = "data_1"
	obj_flags = UNIQUE_RENAME
	var/function = "storage"
	var/data = "null"
	var/special = null
	item_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	var/detail_color = COLOR_ASSEMBLY_ORANGE

/obj/item/card/data/Initialize(mapload)
	.=..()
	update_icon()

/obj/item/card/data/update_icon()
	cut_overlays()
	if(detail_color == COLOR_FLOORTILE_GRAY)
		return
	var/mutable_appearance/detail_overlay = mutable_appearance('nsv13/icons/obj/card.dmi', "[icon_state]-color") //NSV13 - old ID style
	detail_overlay.color = detail_color
	add_overlay(detail_overlay)

/obj/item/card/data/full_color
	desc = "Plastikowa karta z paskiem magnetycznym do prostego i szybkiego przechowywania i przenoszenia danych. Ta jest cała kolorowa."
	icon_state = "data_2"

/obj/item/card/data/disk
	desc = "Plastikowa karta z paskiem magnetycznym do prostego i szybkiego przechowywania i przenoszenia danych. Ta z niewiadomego powodu wygląda jak dyskietka."
	icon_state = "data_3"

/*
 * ID CARDS
 */
/obj/item/card/emag
	desc = "To karta ID z odsłoniętym paskiem magnetycznym podłączonym do jakichś układów."
	name = "sekwencer kryptograficzny"
	icon_state = "emag"
	item_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	item_flags = NO_MAT_REDEMPTION | NOBLUDGEON
	var/prox_check = TRUE //If the emag requires you to be in range

/obj/item/card/emag/bluespace
	name = "sekwencer kryptograficzny bluespace"
	desc = "Niebieska karta z paskiem magnetycznym podłączonym do jakichś układów. Wygląda na to, że ma doczepiony jakiś nadajnik."
	icon_state = "emag_bs"
	prox_check = FALSE

/obj/item/card/emag/attack()
	return

/obj/item/card/emag/afterattack(atom/target, mob/user, proximity)
	. = ..()
	var/atom/A = target
	if(!proximity && prox_check)
		return
	log_combat(user, A, "attempted to emag")
	A.emag_act(user)

/obj/item/card/emagfake
	desc = "To karta ID z odsłoniętym paskiem magnetycznym podłączonym do jakichś układów. Po bliższych oględzinach okazuje się, że to kiepska replika z logo „DonkCo” wybitym na odwrocie."
	name = "sekwencer kryptograficzny"
	icon_state = "emag"
	item_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'

/obj/item/card/emagfake/afterattack()
	. = ..()
	playsound(src, 'sound/items/bikehorn.ogg', 50, 1)

/obj/item/card/id
	name = "karta identyfikacyjna"
	desc = "Karta identyfikująca osobę noszącą ją."
	icon_state = "id"
	item_state = "card-id"
	worn_icon_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	slot_flags = ITEM_SLOT_ID
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100, "stamina" = 0, "bleed" = 0)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/mining_points = 0 //For redeeming at mining equipment vendors
	var/list/access = list()
	var/registered_name// The name registered_name on the card
	var/assignment
	var/hud_state = JOB_HUD_UNKNOWN
	var/access_txt // mapping aid
	var/datum/bank_account/registered_account
	var/obj/machinery/paystand/my_store

/obj/item/card/id/Initialize(mapload)
	. = ..()
	if(mapload && access_txt)
		access = text2access(access_txt)

/obj/item/card/id/Destroy()
	if (registered_account)
		registered_account.bank_cards -= src
	if (my_store && my_store.my_card == src)
		my_store.my_card = null
	return ..()

/obj/item/card/id/proc/set_hud_icon_on_spawn(jobname)
	if(jobname)
		var/temp = get_hud_by_jobname(jobname)
		if(temp != JOB_HUD_UNKNOWN)
			hud_state = temp
	// This is needed for some irregular jobs

/obj/item/card/id/attack_self(mob/user)
	if(Adjacent(user))
		user.visible_message("<span class='notice'>[user] pokazuje ci: [icon2html(src, viewers(user))] [src.name].</span>", "<span class='notice'>Pokazujesz [src.name].</span>")
	add_fingerprint(user)

/obj/item/card/id/vv_edit_var(var_name, var_value)
	. = ..()
	if(.)
		switch(var_name)
			if(NAMEOF(src, assignment),NAMEOF(src, registered_name))
				update_label()

/obj/item/card/id/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "---------")
	VV_DROPDOWN_OPTION(VV_ID_PAYDAY, "Wywołaj wypłatę")

/obj/item/card/id/vv_do_topic(list/href_list)
	. = ..()
	if(href_list[VV_ID_PAYDAY])
		if(!registered_account)
			to_chat(usr, "Nie zarejestrowano konta!")
			return
		registered_account.payday(1)

/obj/item/card/id/attackby(obj/item/W, mob/user, params)
	if(iscash(W))
		insert_money(W, user)
		return
	else if(istype(W, /obj/item/storage/bag/money))
		var/obj/item/storage/bag/money/money_bag = W
		var/list/money_contained = money_bag.contents

		var/money_added = mass_insert_money(money_contained, user)

		if (money_added)
			to_chat(user, "<span class='notice'>Wpychasz zawartość do karty! Znika w obłoczku dymu bluespace, a na połączone konto trafia [money_added] kredytów.</span>")
		return
	else
		return ..()

/obj/item/card/id/proc/insert_money(obj/item/I, mob/user)
	if(!registered_account)
		to_chat(user, "<span class='warning'>[src] nie ma połączonego konta, na które można wpłacić [I]!</span>")
		return
	var/cash_money = I.get_item_credit_value()
	if(!cash_money)
		to_chat(user, "<span class='warning'>[I] wydaje się nic nie być wart!</span>")
		return

	registered_account.adjust_money(cash_money)
	if(istype(I, /obj/item/stack/spacecash) || istype(I, /obj/item/coin))
		to_chat(user, "<span class='notice'>Wpychasz [I] do [src]. Znika w małym obłoczku dymu bluespace, a na połączone konto trafia [cash_money] kredytów.</span>")
	else
		to_chat(user, "<span class='notice'>Wkładasz [I] do [src], wpłacając [cash_money] kredytów na połączone konto.</span>")

	to_chat(user, "<span class='notice'>Saldo połączonego konta wynosi teraz $[registered_account.account_balance].</span>")
	qdel(I)

/obj/item/card/id/proc/mass_insert_money(list/money, mob/user)
	if(!registered_account)
		to_chat(user, "<span class='warning'>[src] nie ma połączonego konta do wpłaty!</span>")
		return FALSE

	if (!money || !money.len)
		return FALSE

	var/total = 0

	for (var/obj/item/physical_money in money)
		total += physical_money.get_item_credit_value()
		CHECK_TICK

	registered_account.adjust_money(total)
	SSblackbox.record_feedback("amount", "credits_inserted", total)
	QDEL_LIST(money)

	return total

/obj/item/card/id/proc/alt_click_can_use_id(mob/living/user)
	if(!isliving(user))
		return
	if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return

	return TRUE

// Returns true if new account was set.
/obj/item/card/id/proc/set_new_account(mob/living/user)
	. = FALSE
	var/datum/bank_account/old_account = registered_account

	var/new_bank_id = input(user, "Podaj numer ID swojego konta.", "Odzyskiwanie konta", 111111) as num

	if(!alt_click_can_use_id(user))
		return
	if(!new_bank_id || new_bank_id < 111111 || new_bank_id > 999999)
		to_chat(user, "<span class='warning'>Numer ID konta musi mieścić się w przedziale od 111111 do 999999.</span>")
		return
	if (registered_account && registered_account.account_id == new_bank_id)
		to_chat(user, "<span class='warning'>To ID konta zostało już przypisane do tej karty.</span>")
		return

	for(var/A in SSeconomy.bank_accounts)
		var/datum/bank_account/B = A
		if(B.account_id == new_bank_id)
			if (old_account)
				old_account.bank_cards -= src

			B.bank_cards += src
			registered_account = B
			to_chat(user, "<span class='notice'>Podane konto zostało połączone z tą kartą ID.</span>")

			return TRUE

	to_chat(user, "<span class='warning'>Podany numer ID konta jest nieprawidłowy.</span>")
	return

/obj/item/card/id/AltClick(mob/living/user)
	if(!alt_click_can_use_id(user))
		return

	if(!registered_account)
		set_new_account(user)
		return

	if (world.time < registered_account.withdrawDelay)
		registered_account.bank_card_talk("<span class='warning'>BŁĄD: NIE MOŻNA SIĘ ZALOGOWAĆ Z POWODU PLANOWANEJ KONSERWACJI. KONSERWACJA ZAKOŃCZY SIĘ ZA [(registered_account.withdrawDelay - world.time)/10] S.</span>", TRUE)
		return

	var/amount_to_remove =  FLOOR(input(user, "Ile chcesz wypłacić? Obecne saldo: [registered_account.account_balance]", "Wypłata środków", 5) as num, 1)

	if(!amount_to_remove || amount_to_remove < 0)
		to_chat(user, "<span class='warning'>Jesteś prawie pewien, że pieniądze tak nie działają.</span>")
		return
	if(!alt_click_can_use_id(user))
		return
	if(registered_account.adjust_money(-amount_to_remove))
		var/obj/item/holochip/holochip = new (user.drop_location(), amount_to_remove)
		user.put_in_hands(holochip)
		to_chat(user, "<span class='notice'>Wypłacasz [amount_to_remove] kredytów na holożeton.</span>")
		return
	else
		var/difference = amount_to_remove - registered_account.account_balance
		registered_account.bank_card_talk("<span class='warning'>BŁĄD: do tej wypłaty na połączonym koncie brakuje [difference] kredytów.</span>", TRUE)

/obj/item/card/id/examine(mob/user)
	..()
	if(mining_points)
		. += "Na tej karcie są punkty wymiany sprzętu górniczego: [mining_points]."
	. = ..()
	if(registered_account)
		. += "Konto połączone z tą kartą należy do: '[registered_account.account_holder]', saldo: $[registered_account.account_balance]."
		if(registered_account.account_job)
			var/datum/bank_account/D = SSeconomy.get_dep_account(registered_account.account_department)
			if(D)
				. += "[D.account_holder]: saldo $[D.account_balance]."
		. += "<span class='info'>Alt-kliknij kartę, by wypłacić pieniądze z połączonego konta w postaci holożetonów.</span>"
		. += "<span class='info'>Możesz wpłacać kredyty na połączone konto, przykładając do karty holożetony, gotówkę lub monety.</span>"
		if(registered_account.account_holder == user.real_name)
			. += "<span class='boldnotice'>Jeśli zgubisz tę kartę, możesz odzyskać konto, alt-klikając pustą kartę ID, trzymając ją w ręce, i podając numer ID konta.</span>"
	else
		. += "<span class='info'>Do tej karty nie jest połączone żadne konto. Alt-kliknij, by je dodać.</span>"

/obj/item/card/id/GetAccess()
	return access

/obj/item/card/id/GetID()
	return src

/obj/item/card/id/RemoveID()
	return src

/*
Usage:
update_label()
	Sets the id name to whatever registered_name and assignment is

update_label("John Doe", "Clowny")
	Properly formats the name and occupation and sets the id name to the arguments
*/
/obj/item/card/id/proc/update_label(newname, newjob)
	if(newname || newjob)
		name = "[(!newname)	? "karta identyfikacyjna"	: "karta ID: [newname]"][(!newjob) ? "" : " ([newjob])"]"
		return

	name = "[(!registered_name)	? "karta identyfikacyjna"	: "karta ID: [registered_name]"][(!assignment) ? "" : " ([assignment])"]"

/obj/item/card/id/silver
	name = "srebrna karta identyfikacyjna"
	desc = "Srebrna karta ID wydawana na stanowiskach wymagających honoru i oddania."
	icon_state = "silver"
	item_state = "silver_id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	hud_state = JOB_HUD_RAWCENTCOM

/obj/item/card/id/silver/reaper
	name = "karta ID: Thirteen (Reaper)"
	access = list(ACCESS_MAINT_TUNNELS)
	assignment = "Reaper"
	registered_name = "Thirteen"
	hud_state = JOB_HUD_SYNDICATE

/obj/item/card/id/gold
	name = "złota karta identyfikacyjna"
	desc = "Złota karta ID wydawana na stanowiskach, które dzierżą władzę i siłę."
	icon_state = "gold"
	item_state = "gold_id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	hud_state = JOB_HUD_RAWCOMMAND

/obj/item/card/id/silver/spacepol
	name = "karta dostępu Kosmicznej Policji"
	access = list(ACCESS_HUNTERS)
	hud_state = JOB_HUD_NOTCENTCOM

/obj/item/card/id/silver/spacepol/bounty
	name = "karta dostępu łowcy nagród"
	access = list(ACCESS_HUNTERS)
	hud_state = JOB_HUD_UNKNOWN

/obj/item/card/id/space_russian
	name = "karta kosmicznego Rosjanina"
	access = list(ACCESS_HUNTERS)
	hud_state = JOB_HUD_UNKNOWN

/obj/item/card/id/pirate
	name = "karta statku pirackiego"
	access = list(ACCESS_PIRATES)
	hud_state = JOB_HUD_SYNDICATE

/obj/item/card/id/syndicate
	name = "karta agenta"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE)
	icon_state = "syndicate"
	hud_state = JOB_HUD_SYNDICATE
	var/anyone = FALSE //Can anyone forge the ID or just syndicate?
	var/forged = FALSE //have we set a custom name and job assignment, or will we use what we're given when we chameleon change?

	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/card/id/syndicate/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/card/id
	chameleon_action.chameleon_name = "Karta ID"
	chameleon_action.chameleon_blacklist = typecacheof(list(
		/obj/item/card,
		/obj/item/card/data,
		/obj/item/card/data/full_color,
		/obj/item/card/data/disk,
		/obj/item/card/emag,
		/obj/item/card/emag/bluespace,
		/obj/item/card/emag/halloween,
		/obj/item/card/emagfake,
		/obj/item/card/id/pass/deputy,
		/obj/item/card/id/pass/mining_access_card,
		/obj/item/card/mining_point_card,
		/obj/item/card/id,
		/obj/item/card/id/gulag/one,
		/obj/item/card/id/gulag/two,
		/obj/item/card/id/gulag/three,
		/obj/item/card/id/gulag/four,
		/obj/item/card/id/gulag/five,
		/obj/item/card/id/gulag/six,
		/obj/item/card/id/gulag/seven,
		/obj/item/card/id/departmental_budget,
		/obj/item/card/id/syndicate/anyone,
		/obj/item/card/id/syndicate/nuke_leader,
		/obj/item/card/id/syndicate/debug,
		/obj/item/card/id/syndicate/broken,
		/obj/item/card/id/away/old/apc,
		/obj/item/card/id/away/deep_storage,
		/obj/item/card/id/changeling,
		/obj/item/card/id/mining,
		/obj/item/card/id/pass), only_root_path = TRUE)
	chameleon_action.initialize_disguises()

/obj/item/card/id/syndicate/afterattack(obj/item/O, mob/user, proximity)
	if(!proximity)
		return
	if(istype(O, /obj/item/card/id))
		var/obj/item/card/id/I = O
		src.access |= I.access
		log_id("[key_name(user)] copied all avaliable access from [I] to agent ID [src] at [AREACOORD(user)].")
		if(isliving(user) && user.mind)
			if(user.mind.special_role || anyone)
				to_chat(usr, "<span class='notice'>Mikroskanery karty aktywują się, gdy przesuwasz ją nad kartą ID, kopiując jej dostępy.</span>")

/// AQUILA: lista wyglądów karty (dawniej w attack_self); nagłówki "----X----" nie są wyborem
/obj/item/card/id/syndicate/proc/get_valid_styles()
	var/static/list/valid_jobs = list( // copy-paste from hop card paint machine, but this has more options, and valid to be static.
		"----Command----", "Command (Custom)",JOB_NAME_CAPTAIN,
		"----Service----", "Service (Custom)", JOB_NAME_ASSISTANT, JOB_NAME_HEADOFPERSONNEL, JOB_NAME_BARTENDER, JOB_NAME_COOK,
			JOB_NAME_BOTANIST, JOB_NAME_JANITOR, JOB_NAME_CURATOR,JOB_NAME_CHAPLAIN, JOB_NAME_LAWYER,
			JOB_NAME_CLOWN, JOB_NAME_MIME, JOB_NAME_BARBER, JOB_NAME_STAGEMAGICIAN,
		"----Cargo----","Cargo (Custom)",JOB_NAME_QUARTERMASTER, JOB_NAME_CARGOTECHNICIAN,JOB_NAME_SHAFTMINER,JOB_NAME_BITRUNNER, /* AQ EDIT */
		"----Engineering----","Engineering (Custom)",JOB_NAME_CHIEFENGINEER, JOB_NAME_STATIONENGINEER, JOB_NAME_ATMOSPHERICTECHNICIAN,
		"----Science----","Science (Custom)",JOB_NAME_RESEARCHDIRECTOR, JOB_NAME_SCIENTIST, JOB_NAME_ROBOTICIST, JOB_NAME_EXPLORATIONCREW,
		"----Medical----","Medical (Custom)",JOB_NAME_CHIEFMEDICALOFFICER, JOB_NAME_MEDICALDOCTOR, JOB_NAME_CHEMIST, JOB_NAME_GENETICIST,
			JOB_NAME_VIROLOGIST, JOB_NAME_PARAMEDIC, JOB_NAME_PSYCHIATRIST,
		"----Security----","Security (Custom)",JOB_NAME_HEADOFSECURITY, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE, JOB_NAME_SECURITYOFFICER,
			JOB_NAME_BRIGPHYSICIAN, JOB_NAME_DEPUTY,
		"----Munitions----","Munitions (Custom)",JOB_NAME_MASTERATARMS, JOB_NAME_BRIDGESTAFF, JOB_NAME_AIRTRAFFICCONTROLLER, JOB_NAME_MUNITIONSTECHNICIAN, JOB_NAME_PILOT, JOB_NAME_DECKTECHNICIAN,
		"----MISC----","Unassigned",JOB_NAME_PRISONER,"CentCom (Custom)","CentCom","ERT",JOB_NAME_VIP,JOB_NAME_KING,"Syndicate","Clown Operative"
	)
	return valid_jobs

/// AQUILA: czy ten użytkownik może fałszować kartę (antag, karta "anyone" albo pierwszy użytkownik)
/obj/item/card/id/syndicate/proc/can_forge(mob/user, first_use_unlock = FALSE)
	if(!isliving(user) || !user.mind)
		return FALSE
	if(user.mind.special_role || anyone) //Unless anyone is allowed, only syndies can use the card, to stop metagaming.
		return TRUE
	if(first_use_unlock && !registered_name) //If a non-syndie is the first to forge an unassigned agent ID, then anyone can forge it.
		anyone = TRUE
		return TRUE
	return FALSE

/obj/item/card/id/syndicate/attack_self(mob/user)
	if(!can_forge(user, TRUE))
		return ..()
	ui_interact(user)

// AQUILA: okno TGUI ChameleonCard zamiast serii alert()/input()
/obj/item/card/id/syndicate/ui_state(mob/user)
	return GLOB.hands_state

/obj/item/card/id/syndicate/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChameleonCard", "Karta agenta")
		ui.open()

/obj/item/card/id/syndicate/ui_static_data(mob/user)
	var/list/data = list()
	var/list/styles = list()
	for(var/style in get_valid_styles())
		if(copytext(style, 1, 2) == "-")
			continue
		styles += style
	data["styles"] = styles
	return data

/obj/item/card/id/syndicate/ui_data(mob/user)
	var/list/data = list()
	data["registered_name"] = registered_name
	data["assignment"] = assignment
	data["default_name"] = ishuman(user) ? user.real_name : user.name
	data["forged"] = forged
	data["account_id"] = registered_account?.account_id
	data["account_holder"] = registered_account?.account_holder
	var/list/access_names = list()
	for(var/A in access)
		var/desc = get_access_desc(A)
		if(desc)
			access_names += desc
	data["accesses"] = sort_list(access_names)
	return data

/obj/item/card/id/syndicate/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	var/mob/living/user = usr
	if(!can_forge(user))
		return
	switch(action)
		if("show")
			user.visible_message("<span class='notice'>[user] pokazuje ci: [icon2html(src, viewers(user))] [src.name].</span>", "<span class='notice'>Pokazujesz [src.name].</span>")
			add_fingerprint(user)
			return TRUE
		if("change_account")
			INVOKE_ASYNC(src, PROC_REF(set_new_account), user)
			return TRUE
		if("reset")
			if(!forged)
				return
			registered_name = initial(registered_name)
			assignment = initial(assignment)
			log_id("[key_name(user)] reset agent ID [src] name to default at [AREACOORD(user)].")
			log_game("[key_name(user)] has reset \the [initial(name)] named \"[src]\" to default.")
			update_label()
			forged = FALSE
			to_chat(user, "<span class='notice'>Pomyślnie resetujesz kartę ID.</span>")
			return TRUE
		if("forge")
			var/first_use = registered_name ? FALSE : TRUE
			var/input_name = reject_bad_name(trim(html_encode(params["name"]), MAX_NAME_LEN))
			if(!input_name)
				// Invalid/blank names give a randomly generated one.
				input_name = human_full_name_random()
			var/target_occupation = trim(html_encode(params["assignment"]), MAX_MESSAGE_LEN)
			if(!target_occupation)
				to_chat(user, "<span class='warning'>Podaj stanowisko na karcie.</span>")
				return
			var/target_id_style = params["style"]
			if(!(target_id_style in get_valid_styles()) || copytext(target_id_style, 1, 2) == "-")
				target_id_style = null

			log_id("[key_name(user)] forged agent ID [src] name to [input_name] and occupation to [target_occupation][target_id_style ? " with [target_id_style] card style" : " with non changed [icon_state] shape, [hud_state] hud style"] at [AREACOORD(user)].")
			registered_name = input_name
			assignment = target_occupation
			if(target_id_style)
				icon_state = get_cardstyle_by_jobname(target_id_style)
				hud_state = get_hud_by_jobname(target_id_style)
				if(ishuman(user))
					var/mob/living/carbon/human/H = user
					H.sec_hud_set_ID()
			update_label()
			forged = TRUE
			to_chat(user, "<span class='notice'>Pomyślnie fałszujesz kartę ID.</span>")
			log_game("[key_name(user)] has forged \the [initial(name)] with name \"[registered_name]\" and occupation \"[assignment]\"[target_id_style ? " with [target_id_style] card style" : " with non changed [icon_state] shape, [hud_state] hud style"].")

			// First time use automatically sets the account id to the user.
			if(first_use && !registered_account && ishuman(user))
				var/mob/living/carbon/human/accountowner = user
				for(var/bank_account in SSeconomy.bank_accounts)
					var/datum/bank_account/account = bank_account
					if(account.account_id == accountowner.account_id)
						account.bank_cards += src
						registered_account = account
						to_chat(user, "<span class='notice'>Numer twojego konta został przypisany automatycznie.</span>")
			return TRUE


/obj/item/card/id/syndicate/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

// broken chameleon agent card
/obj/item/card/id/syndicate/broken
	access = list() // their access is even broken

/obj/item/card/id/syndicate/broken/afterattack(obj/item/O, mob/user, proximity)
	return

/obj/item/card/id/syndicate/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/card/id/syndicate/anyone
	anyone = TRUE

/obj/item/card/id/syndicate/nuke_leader
	name = "karta głównego agenta"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER)

/obj/item/card/id/syndicate/ratvar
	name = "karta ID sługi"
	icon_state = "ratvar"
	access = list(ACCESS_CLOCKCULT, ACCESS_MAINT_TUNNELS)
	hud_state = JOB_HUD_UNKNOWN

/obj/item/card/id/syndicate_command
	name = "karta ID Syndykatu"
	desc = "Karta ID prosto od Syndykatu."
	registered_name = "Syndykat"
	icon_state = "syndicate"
	assignment = "Oficer Syndykatu"
	access = list(ACCESS_SYNDICATE)
	hud_state = JOB_HUD_SYNDICATE

/obj/item/card/id/syndicate/debug
	name = "\improper karta ID debugowa"
	desc = "Mieniąca się karta ID, która otwiera wszystko."
	icon_state = "centcom"
	registered_name = JOB_CENTCOM_CENTRAL_COMMAND
	assignment = JOB_CENTCOM_ADMIRAL
	anyone = TRUE
	hud_state = JOB_HUD_CENTCOM

/obj/item/card/id/syndicate/debug/Initialize(mapload)
	access = get_every_access()
	registered_account = SSeconomy.get_dep_account(ACCOUNT_CAR)
	. = ..()

/obj/item/card/id/captains_spare
	name = "zapasowa karta ID kapitana"
	desc = "Zapasowa karta ID samego Najwyższego Pana."
	icon_state = "gold"
	item_state = "gold_id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	registered_name = JOB_NAME_CAPTAIN
	assignment = JOB_NAME_CAPTAIN
	investigate_flags = ADMIN_INVESTIGATE_TARGET
	hud_state = JOB_HUD_ACTINGCAPTAIN

/obj/item/card/id/captains_spare/Initialize(mapload)
	var/datum/job/captain/J = new/datum/job/captain
	access = J.get_access()
	. = ..()

/obj/item/card/id/centcom
	name = "\improper karta ID Centrali"
	desc = "Mieniąca się karta ID Centrali. Dla większości załogi samo jej oglądanie jest nielegalne."
	icon_state = "centcom"
	registered_name = JOB_CENTCOM_CENTRAL_COMMAND
	assignment = "Generał"
	hud_state = JOB_HUD_CENTCOM

/obj/item/card/id/centcom/Initialize(mapload)
	access = get_all_centcom_access()
	. = ..()

/obj/item/card/id/ert
	name = "\improper karta ID Centrali"
	desc = "Mieniąca się karta ID Zespołu Reagowania Kryzysowego. Pełny dostęp, i to ze stylem."
	icon_state = "ert"
	registered_name = JOB_ERT_COMMANDER
	assignment = JOB_ERT_COMMANDER
	hud_state = JOB_HUD_CENTCOM

/obj/item/card/id/ert/Initialize(mapload)
	access = get_all_accesses()+get_ert_access("commander")-ACCESS_CHANGE_IDS
	. = ..()

/obj/item/card/id/ert/Security
	registered_name = JOB_ERT_OFFICER
	assignment = JOB_ERT_OFFICER
	icon_state = "ert"

/obj/item/card/id/ert/Security/Initialize(mapload)
	access = get_all_accesses()+get_ert_access("sec")-ACCESS_CHANGE_IDS
	. = ..()

/obj/item/card/id/ert/Engineer
	registered_name = JOB_ERT_ENGINEER
	assignment = JOB_ERT_ENGINEER
	icon_state = "ert"

/obj/item/card/id/ert/Engineer/Initialize(mapload)
	access = get_all_accesses()+get_ert_access("eng")-ACCESS_CHANGE_IDS
	. = ..()

/obj/item/card/id/ert/Medical
	registered_name = JOB_ERT_MEDICAL_DOCTOR
	assignment = JOB_ERT_MEDICAL_DOCTOR
	icon_state = "ert"

/obj/item/card/id/ert/Medical/Initialize(mapload)
	access = get_all_accesses()+get_ert_access("med")-ACCESS_CHANGE_IDS
	. = ..()

/obj/item/card/id/ert/chaplain
	registered_name = JOB_ERT_CHAPLAIN
	assignment = JOB_ERT_CHAPLAIN
	icon_state = "ert"

/obj/item/card/id/ert/chaplain/Initialize(mapload)
	access = get_all_accesses()+get_ert_access("sec")-ACCESS_CHANGE_IDS
	. = ..()

/obj/item/card/id/ert/Janitor
	registered_name = JOB_ERT_JANITOR
	assignment = JOB_ERT_JANITOR
	icon_state = "ert"

/obj/item/card/id/ert/Janitor/Initialize(mapload)
	access = get_all_accesses()
	. = ..()

/obj/item/card/id/ert/kudzu
	registered_name = "Pogromca chwastów"
	assignment = "Pogromca chwastów"
	icon_state = "ert"

/obj/item/card/id/ert/kudzu/Initialize(mapload)
	access = get_all_accesses()
	. = ..()

/obj/item/card/id/gulag
	name = "karta ID więźnia"
	desc = "Jesteś numerem, a nie wolnym człowiekiem."
	icon_state = "orange"
	item_state = "orange-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	var/goal = 0 //How far from freedom?
	var/points = 0
	var/permanent = FALSE
	hud_state = JOB_HUD_PRISONER

/obj/item/card/id/gulag/examine(mob/user)
	. = ..()

	if(!permanent)
		. += "<span class='notice'>Mały wyświetlacz na karcie pokazuje: zgromadzono [points] z [goal] punktów potrzebnych do wolności.</span>"

	else
		. += "<span class='notice'>Znak na karcie wskazuje, że wyrok jest dożywotni.</span>"

/obj/item/card/id/gulag/one
	name = "Więzień #13-001"
	registered_name = "Więzień #13-001"

/obj/item/card/id/gulag/two
	name = "Więzień #13-002"
	registered_name = "Więzień #13-002"

/obj/item/card/id/gulag/three
	name = "Więzień #13-003"
	registered_name = "Więzień #13-003"

/obj/item/card/id/gulag/four
	name = "Więzień #13-004"
	registered_name = "Więzień #13-004"

/obj/item/card/id/gulag/five
	name = "Więzień #13-005"
	registered_name = "Więzień #13-005"

/obj/item/card/id/gulag/six
	name = "Więzień #13-006"
	registered_name = "Więzień #13-006"

/obj/item/card/id/gulag/seven
	name = "Więzień #13-007"
	registered_name = "Więzień #13-007"

/obj/item/card/id/mining
	name = "karta ID górnika"
	hud_state = JOB_HUD_RAWCARGO
	access = list(ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MECH_MINING, ACCESS_MAILSORTING, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/away
	name = "\proper całkowicie zwyczajna karta identyfikacyjna"
	desc = "Całkowicie zwyczajna karta identyfikacyjna. Przydałoby się jej trochę charakteru."
	hud_state = JOB_HUD_UNKNOWN
	access = list(ACCESS_AWAY_GENERAL)

/obj/item/card/id/away/hotel
	name = "karta ID personelu"
	desc = "Karta ID personelu otwierająca drzwi hotelu."
	hud_state = JOB_HUD_RAWSERVICE
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_MAINT)

/obj/item/card/id/away/hotel/securty
	name = "karta ID ochroniarza"
	hud_state = JOB_HUD_RAWSECURITY
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_MAINT, ACCESS_AWAY_SEC)

/obj/item/card/id/away/old
	name = "\proper całkowicie zwyczajna karta identyfikacyjna"
	desc = "Całkowicie zwyczajna karta identyfikacyjna. Przydałoby się jej trochę charakteru."
	icon_state = "centcom"
	hud_state = JOB_HUD_RAWCENTCOM

/obj/item/card/id/away/old/sec
	name = "karta ID ochroniarza ze Stacji Charlie"
	desc = "Wyblakła karta ID ze Stacji Charlie. Da się odczytać stopień „Ochroniarz”."
	assignment = "Ochroniarz Stacji Charlie"
	hud_state = JOB_HUD_RAWSECURITY
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_SEC)

/obj/item/card/id/away/old/sci
	name = "karta ID naukowca ze Stacji Charlie"
	desc = "Wyblakła karta ID ze Stacji Charlie. Da się odczytać stopień „Naukowiec”."
	assignment = "Naukowiec Stacji Charlie"
	hud_state = JOB_HUD_RAWSCIENCE
	access = list(ACCESS_AWAY_GENERAL)

/obj/item/card/id/away/old/eng
	name = "karta ID inżyniera ze Stacji Charlie"
	desc = "Wyblakła karta ID ze Stacji Charlie. Da się odczytać stopień „Inżynier”."
	assignment = "Inżynier Stacji Charlie"
	hud_state = JOB_HUD_RAWENGINEERING
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_ENGINE)

/obj/item/card/id/away/old/apc
	name = "karta dostępu do APC"
	desc = "Specjalna karta ID dająca dostęp do terminali APC."
	hud_state = JOB_HUD_UNKNOWN
	access = list(ACCESS_ENGINE_EQUIP)

/obj/item/card/id/away/deep_storage //deepstorage.dmm space ruin
	name = "karta dostępu do bunkra"

///Department Budget Cards///

/obj/item/card/id/departmental_budget
	name = "karta działu (budżet)"
	desc = "Daje dostęp do budżetu działu."
	icon_state = "budget"
	var/department_ID = ACCOUNT_CIV
	var/department_name = ACCOUNT_CIV_NAME
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	investigate_flags = ADMIN_INVESTIGATE_TARGET

/obj/item/card/id/departmental_budget/Initialize(mapload)
	. = ..()
	var/datum/bank_account/B = SSeconomy.get_dep_account(department_ID)
	if(B)
		registered_account = B
		if(!B.bank_cards.Find(src))
			B.bank_cards += src
		name = "karta działu ([department_name])"
		desc = "Daje dostęp do konta: [department_name]."
	SSeconomy.dep_cards += src

/obj/item/card/id/departmental_budget/Destroy()
	SSeconomy.dep_cards -= src
	return ..()

/obj/item/card/id/departmental_budget/civ
	department_ID = ACCOUNT_CIV
	department_name = ACCOUNT_CIV_NAME
	icon_state = "budget"
	hud_state = JOB_HUD_RAWCOMMAND

/obj/item/card/id/departmental_budget/eng
	department_ID = ACCOUNT_ENG
	department_name = ACCOUNT_ENG_NAME
	icon_state = "budget_eng"
	hud_state = JOB_HUD_RAWENGINEERING

/obj/item/card/id/departmental_budget/sci
	department_ID = ACCOUNT_SCI
	department_name = ACCOUNT_SCI_NAME
	icon_state = "budget_sci"
	hud_state = JOB_HUD_RAWSCIENCE

/obj/item/card/id/departmental_budget/med
	department_ID = ACCOUNT_MED
	department_name = ACCOUNT_MED_NAME
	icon_state = "budget_med"
	hud_state = JOB_HUD_RAWMEDICAL

/obj/item/card/id/departmental_budget/srv
	department_ID = ACCOUNT_SRV
	department_name = ACCOUNT_SRV_NAME
	icon_state = "budget_srv"
	hud_state = JOB_HUD_RAWSERVICE

/obj/item/card/id/departmental_budget/car
	department_ID = ACCOUNT_CAR
	department_name = ACCOUNT_CAR_NAME
	icon_state = "budget_car"
	hud_state = JOB_HUD_RAWCARGO

/obj/item/card/id/departmental_budget/sec
	department_ID = ACCOUNT_SEC
	department_name = ACCOUNT_SEC_NAME
	icon_state = "budget_sec"
	hud_state = JOB_HUD_RAWSECURITY

// This will never be spawned, but should be trackable by admins anyway.
/obj/item/card/id/departmental_budget/vip
	department_ID = ACCOUNT_VIP
	department_name = ACCOUNT_VIP_NAME
	icon_state = "budget"
	hud_state = JOB_HUD_VIP

/// Job Specific ID Cards///
// These should have default job name and hud state, etc, because chameleon card needs such information
// ---- Command ----
/obj/item/card/id/job/captain
	name = "karta stanowiska (Dow.) – Kapitan"
	icon_state = "captain"
	assignment = JOB_NAME_CAPTAIN
	hud_state = JOB_HUD_CAPTAIN

/obj/item/card/id/job/rawcommand
	name = "karta stanowiska (Dow.) – własna"
	icon_state = JOB_HUD_RAWCOMMAND
	hud_state = JOB_HUD_RAWCOMMAND

// ---- Service ----
/obj/item/card/id/job/assistant
	name = "karta stanowiska (Usł.) – Majtek"
	icon_state = "id"
	assignment = JOB_NAME_ASSISTANT
	hud_state = JOB_HUD_ASSISTANT

/obj/item/card/id/job/head_of_personnel
	name = "karta stanowiska (Usł.) – Starszy Oficer"
	icon_state = "hop"
	assignment = JOB_NAME_HEADOFPERSONNEL
	hud_state = JOB_HUD_HEADOFPERSONNEL

/obj/item/card/id/job/botanist
	name = "karta stanowiska (Usł.) – Botanik"
	icon_state = "serv"
	assignment = JOB_NAME_BOTANIST
	hud_state = JOB_HUD_BOTANIST

/obj/item/card/id/job/cook
	name = "karta stanowiska (Usł.) – Kucharz"
	icon_state = "serv"
	assignment = JOB_NAME_COOK
	hud_state = JOB_HUD_COOK

/obj/item/card/id/job/bartender
	name = "karta stanowiska (Usł.) – Barman"
	icon_state = "serv"
	assignment = JOB_NAME_BARTENDER
	hud_state = JOB_HUD_BARTENDER

/obj/item/card/id/job/barber
	name = "karta stanowiska (Usł.) – Fryzjer"
	icon_state = "serv"
	assignment = JOB_NAME_BARBER
	hud_state = JOB_HUD_BARBER

/obj/item/card/id/job/stage_magician
	name = "karta stanowiska (Usł.) – Magik"
	icon_state = "serv"
	assignment = JOB_NAME_STAGEMAGICIAN
	hud_state = JOB_HUD_STAGEMAGICIAN

/obj/item/card/id/job/curator
	name = "karta stanowiska (Usł.) – Bibliotekarz"
	icon_state = "chap"
	assignment = JOB_NAME_CURATOR
	hud_state = JOB_HUD_CURATOR

/obj/item/card/id/job/chaplain
	name = "karta stanowiska (Usł.) – Kapłan"
	icon_state = "chap"
	assignment = JOB_NAME_CHAPLAIN
	hud_state = JOB_HUD_CHAPLAIN

/obj/item/card/id/job/janitor
	name = "karta stanowiska (Usł.) – Woźny"
	icon_state = "janitor"
	assignment = JOB_NAME_JANITOR
	hud_state = JOB_HUD_JANITOR

/obj/item/card/id/job/clown
	name = "karta stanowiska (Usł.) – Klaun"
	icon_state = "clown"
	assignment = JOB_NAME_CLOWN
	hud_state = JOB_HUD_CLOWN

/obj/item/card/id/job/mime
	name = "karta stanowiska (Usł.) – Mim"
	icon_state = "mime"
	assignment = JOB_NAME_MIME
	hud_state = JOB_HUD_MIME

/obj/item/card/id/job/lawyer
	name = "karta stanowiska (Usł.) – Prawnik"
	icon_state = "lawyer"
	assignment = JOB_NAME_LAWYER
	hud_state = JOB_HUD_LAWYER

/obj/item/card/id/job/rawservice
	name = "karta stanowiska (Usł.) – własna"
	icon_state = JOB_HUD_RAWSERVICE
	hud_state = JOB_HUD_RAWSERVICE

// ---- Cargo ----
/obj/item/card/id/job/quartermaster
	name = "karta stanowiska (Zaop.) – Kwatermistrz"
	icon_state = "qm"
	assignment = JOB_NAME_QUARTERMASTER
	hud_state = JOB_HUD_QUARTERMASTER

/obj/item/card/id/job/shaft_miner
	name = "karta stanowiska (Zaop.) – Górnik"
	icon_state = "miner"
	assignment = JOB_NAME_SHAFTMINER
	hud_state = JOB_HUD_SHAFTMINER

/obj/item/card/id/job/cargo_technician
	name = "karta stanowiska (Zaop.) – Magazynier"
	icon_state = "cargo"
	assignment = JOB_NAME_CARGOTECHNICIAN
	hud_state = JOB_HUD_CARGOTECHNICIAN

// AQ EDIT - bitrunning
/obj/item/card/id/job/bitrunner
	name = "karta stanowiska (Zaop.) – Bitrunner"
	icon_state = "cargo"
	assignment = JOB_NAME_BITRUNNER
	hud_state = JOB_HUD_BITRUNNER

/obj/item/card/id/job/rawcargo
	name = "karta stanowiska (Zaop.) – własna"
	icon_state = "rawcargo"
	hud_state = JOB_HUD_RAWCARGO

// ---- Engineering -----
/obj/item/card/id/job/chief_engineer
	name = "karta stanowiska (Inż.) – Główny Inżynier"
	icon_state = "ce"
	assignment = JOB_NAME_CHIEFENGINEER
	hud_state = JOB_HUD_CHIEFENGINEER

/obj/item/card/id/job/station_engineer
	name = "karta stanowiska (Inż.) – Inżynier"
	icon_state = "engi"
	assignment = JOB_NAME_STATIONENGINEER
	hud_state = JOB_HUD_STATIONENGINEER

/obj/item/card/id/job/atmospheric_technician
	name = "karta stanowiska (Inż.) – Technik Atmosferyki"
	icon_state = "atmos"
	assignment = JOB_NAME_ATMOSPHERICTECHNICIAN
	hud_state = JOB_HUD_ATMOSPHERICTECHNICIAN

/obj/item/card/id/job/rawengineering
	name = "karta stanowiska (Inż.) – własna"
	icon_state = "rawengineering"
	hud_state = JOB_HUD_RAWENGINEERING

// ---- Medical ----
/obj/item/card/id/job/chief_medical_officer
	name = "karta stanowiska (Med.) – Ordynator"
	icon_state = "cmo"
	assignment = JOB_NAME_CHIEFMEDICALOFFICER
	hud_state = JOB_HUD_CHEIFMEDICALOFFICIER

/obj/item/card/id/job/medical_doctor
	name = "karta stanowiska (Med.) – Lekarz"
	icon_state = "med"
	assignment = JOB_NAME_MEDICALDOCTOR
	hud_state = JOB_HUD_MEDICALDOCTOR

/obj/item/card/id/job/paramedic
	name = "karta stanowiska (Med.) – Ratownik Medyczny"
	icon_state = "paramed"
	assignment = JOB_NAME_PARAMEDIC
	hud_state = JOB_HUD_PARAMEDIC

/obj/item/card/id/job/virologist
	name = "karta stanowiska (Med.) – Wirolog"
	icon_state = "viro"
	assignment = JOB_NAME_VIROLOGIST
	hud_state = JOB_HUD_VIROLOGIST

/obj/item/card/id/job/chemist
	name = "karta stanowiska (Med.) – Chemik"
	icon_state = "chemist"
	assignment = JOB_NAME_CHEMIST
	hud_state = JOB_HUD_CHEMIST

/obj/item/card/id/job/geneticist
	name = "karta stanowiska (Med.) – Genetyk"
	icon_state = "gene"
	assignment = JOB_NAME_GENETICIST
	hud_state = JOB_HUD_GENETICIST

/obj/item/card/id/job/psychiatrist
	name = "karta stanowiska (Med.) – Psychiatra"
	icon_state = "med"
	assignment = JOB_NAME_PSYCHIATRIST
	hud_state = JOB_HUD_PSYCHIATRIST

/obj/item/card/id/job/rawmedical
	name = "karta stanowiska (Med.) – własna"
	icon_state = "rawmedical"
	hud_state = JOB_HUD_RAWMEDICAL


// ---- Science -----
/obj/item/card/id/job/research_director
	name = "karta stanowiska (B+R) – Dyrektor Naukowy"
	icon_state = "rd"
	assignment = JOB_NAME_RESEARCHDIRECTOR
	hud_state = JOB_HUD_RESEARCHDIRECTOR

/obj/item/card/id/job/scientist
	name = "karta stanowiska (B+R) – Naukowiec"
	icon_state = "sci"
	assignment = JOB_NAME_SCIENTIST
	hud_state = JOB_HUD_SCIENTIST

/obj/item/card/id/job/roboticist
	name = "karta stanowiska (B+R) – Robotyk"
	icon_state = "roboticist"
	assignment = JOB_NAME_ROBOTICIST
	hud_state = JOB_HUD_ROBOTICIST

/obj/item/card/id/job/exploration_crew
	name = "karta stanowiska (B+R) – Odkrywca"
	icon_state = "exploration"
	assignment = JOB_NAME_EXPLORATIONCREW
	hud_state = JOB_HUD_EXPLORATIONCREW

/obj/item/card/id/job/rawscience
	name = "karta stanowiska (B+R) – własna"
	icon_state = "rawscience"
	hud_state = JOB_HUD_RAWSCIENCE

// ---- Security ----
/obj/item/card/id/job/head_of_security
	name = "karta stanowiska (Ochr.) – Komendant"
	icon_state = "hos"
	assignment = JOB_NAME_HEADOFSECURITY
	hud_state = JOB_HUD_HEADOFSECURITY

/obj/item/card/id/job/warden
	name = "karta stanowiska (Ochr.) – Naczelnik"
	icon_state = "warden"
	assignment = JOB_NAME_WARDEN
	hud_state = JOB_HUD_WARDEN

/obj/item/card/id/job/security_officer
	name = "karta stanowiska (Ochr.) – Policjant"
	icon_state = "sec"
	assignment = JOB_NAME_SECURITYOFFICER
	hud_state = JOB_HUD_SECURITYOFFICER

/obj/item/card/id/job/detective
	name = "karta stanowiska (Ochr.) – Detektyw"
	icon_state = "detective"
	assignment = JOB_NAME_DETECTIVE
	hud_state = JOB_HUD_DETECTIVE

/obj/item/card/id/job/brig_physician
	name = "karta stanowiska (Ochr.) – Lekarz Więzienny"
	icon_state = "brigphys"
	assignment = JOB_NAME_BRIGPHYSICIAN
	hud_state = JOB_HUD_BRIGPHYSICIAN

/obj/item/card/id/job/deputy
	name = "karta stanowiska (Ochr.) – Aspirant"
	icon_state = "deputy"
	assignment = JOB_NAME_DEPUTY
	hud_state = JOB_HUD_DEPUTY

/obj/item/card/id/job/rawsecurity
	name = "karta stanowiska (Ochr.) – własna"
	icon_state = "rawsecurity"
	hud_state = JOB_HUD_RAWSECURITY

// ---- Munitions - NSV13 ----
/obj/item/card/id/job/master_at_arms
	name = "karta stanowiska (Amun.) – Mistrz Broni"
	icon_state = "maa"
	assignment = JOB_NAME_MASTERATARMS
	hud_state = JOB_HUD_MASTERATARMS

/obj/item/card/id/job/munitions_technician
	name = "karta stanowiska (Amun.) – Technik Amunicyjny"
	icon_state = "munitech"
	assignment = JOB_NAME_MUNITIONSTECHNICIAN
	hud_state = JOB_HUD_MUNITIONSTECHNICIAN

/obj/item/card/id/job/deck_technician
	name = "karta stanowiska (Amun.) – Technik Pokładowy"
	icon_state = "munitech" // AQ EDIT: brak stanu "decktechnician" w card.dmi
	assignment = JOB_NAME_DECKTECHNICIAN
	hud_state = JOB_HUD_DECKTECHNICIAN

/obj/item/card/id/job/air_traffic_controller
	name = "karta stanowiska (Amun.) – Kontroler Lotów"
	icon_state = "atc"
	assignment = JOB_NAME_AIRTRAFFICCONTROLLER
	hud_state = JOB_HUD_AIRTRAFFICCONTROLLER

/obj/item/card/id/job/pilot
	name = "karta stanowiska (Amun.) – Pilot"
	icon_state = "pilot"
	assignment = JOB_NAME_PILOT
	hud_state = JOB_HUD_PILOT

/obj/item/card/id/job/bridge_staff
	name = "karta stanowiska (Amun.) – Oficer Pokładowy"
	icon_state = "silver"
	assignment = JOB_NAME_BRIDGESTAFF
	hud_state = JOB_HUD_BRIDGESTAFF

/obj/item/card/id/job/rawsecurity
	name = "karta stanowiska (Ochr.) – własna"
	icon_state = "rawsecurity"
	hud_state = JOB_HUD_RAWSECURITY

 // ---- ???? ----
/obj/item/card/id/job/unknown
	name = "karta stanowiska – nieprzypisana"
	icon_state = "id"
	hud_state = JOB_HUD_UNKNOWN

/obj/item/card/id/gold/vip
	name = "ważna złota karta identyfikacyjna"
	assignment = JOB_NAME_VIP
	hud_state = JOB_HUD_VIP

/obj/item/card/id/gold/king
	name = "złota karta identyfikacyjna Jego Królewskiej Mości"
	assignment = JOB_NAME_KING
	hud_state = JOB_HUD_KING


/obj/item/card/id/pass
	name = "przepustka awansowa"
	desc = "Karta, która po przeciągnięciu przez twoją kartę ID daje ci cały swój dostęp. Nie zastępuje prawdziwej karty ID."
	icon_state = "data_1"
	registered_name = "Niezarejestrowana karta"
	assignment = "Przepustka"
	hud_state = JOB_HUD_UNKNOWN

/obj/item/card/id/pass/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if (!proximity)
		return .
	var/obj/item/card/id/idcard = target
	if(istype(idcard))
		for(var/give_access in access)
			idcard.access |= give_access
		if(assignment!=initial(assignment))
			idcard.assignment = assignment
		if(name!=initial(name))
			idcard.name = name
		to_chat(user, "Ulepszasz [idcard] za pomocą [name].")
		log_id("[key_name(user)] added access to '[idcard]' using [src] at [AREACOORD(user)].")
		qdel(src)
