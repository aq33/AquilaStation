// AQUILA - program PDA „Katalog NIFSoftów”: kupno programów prosto do własnego NIF-u, płatne z konta karty ID w PDA.
// Port z Monkestation (nifsoft_catalog.dm), bez punktów nagród. Okno: NtosNifsoftCatalog.tsx.

/// NIFSofty do kupienia w katalogu
GLOBAL_LIST_INIT(purchasable_nifsofts, list(
	/datum/nifsoft/hivemind,
	/datum/nifsoft/money_sense,
	/datum/nifsoft/soul_poem,
))

/datum/computer_file/program/nifsoft_downloader
	filename = "nifsoftcatalog"
	filedesc = "Katalog NIFSoftów"
	category = PROGRAM_CATEGORY_CREW
	program_icon_state = "generic"
	extended_desc = "Wirtualny sklep, w którym kupisz NIFSofty i od razu zainstalujesz je w swoim NIF-ie."
	size = 3
	tgui_id = "NtosNifsoftCatalog"
	program_icon = "bag-shopping"
	usage_flags = PROGRAM_TABLET

/// Konto z karty ID włożonej do komputera
/datum/computer_file/program/nifsoft_downloader/proc/get_paying_account()
	var/obj/item/card/id/id_card = computer?.GetID()
	return id_card?.registered_account

/// NIF użytkownika, jeśli go ma
/datum/computer_file/program/nifsoft_downloader/proc/get_user_nif(mob/user)
	if(!ishuman(user))
		return null
	var/mob/living/carbon/human/nif_user = user
	var/obj/item/organ/cyberimp/nif/user_nif = nif_user.getorganslot(ORGAN_SLOT_BRAIN_NIF)
	return istype(user_nif) ? user_nif : null

/datum/computer_file/program/nifsoft_downloader/ui_data(mob/user)
	var/list/data = list()
	var/datum/bank_account/paying_account = get_paying_account()
	data["paying_account"] = !!paying_account
	data["current_balance"] = paying_account?.account_balance || 0
	data["has_nif"] = !!get_user_nif(user)
	return data

/datum/computer_file/program/nifsoft_downloader/ui_static_data(mob/user)
	var/list/data = list()
	var/list/product_list = list()

	for(var/datum/nifsoft/buyable_nifsoft as anything in GLOB.purchasable_nifsofts)
		var/category = initial(buyable_nifsoft.buying_category)
		if(!product_list[category])
			product_list[category] = list("name" = category, "products" = list())

		product_list[category]["products"] += list(list(
			"name" = initial(buyable_nifsoft.name),
			"desc" = initial(buyable_nifsoft.program_desc),
			"price" = initial(buyable_nifsoft.purchase_price),
			"ui_icon" = initial(buyable_nifsoft.ui_icon),
			"reference" = "[buyable_nifsoft]",
		))

	data["product_list"] = list()
	for(var/product_category in product_list)
		data["product_list"] += list(product_list[product_category])

	return data

/datum/computer_file/program/nifsoft_downloader/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("purchase_product")
			var/datum/nifsoft/product_to_buy = text2path(params["product_to_buy"])
			var/datum/bank_account/paying_account = get_paying_account()
			if(!product_to_buy || !paying_account || !(product_to_buy in GLOB.purchasable_nifsofts))
				return FALSE

			var/obj/item/organ/cyberimp/nif/buyer_nif = get_user_nif(usr)
			if(!buyer_nif)
				paying_account.bank_card_talk("Do tego zakupu potrzebujesz implantu NIF.")
				return FALSE

			var/amount_to_charge = initial(product_to_buy.purchase_price)
			if(!paying_account.has_money(amount_to_charge))
				paying_account.bank_card_talk("Masz za mało pieniędzy na ten zakup.")
				return FALSE

			var/datum/nifsoft/installed_nifsoft = new product_to_buy(buyer_nif)
			if(QDELETED(installed_nifsoft) || !installed_nifsoft.parent_nif)
				paying_account.bank_card_talk("Instalacja nieudana, nie pobrano opłaty.")
				return FALSE

			if(amount_to_charge)
				paying_account.adjust_money(-amount_to_charge)
				paying_account.bank_card_talk("Transakcja zakończona, pobrano [amount_to_charge] kr.")
			return TRUE
