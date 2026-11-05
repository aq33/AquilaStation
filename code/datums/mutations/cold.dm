/datum/mutation/geladikinesis
	name = "Geladykineza"
	desc = "Pozwala skupić wilgoć i ujemne temperatury w śnieg."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Twoja dłoń wydaje się zimna.</span>"
	instability = 10
	difficulty = 10
	synchronizer_coeff = 1
	power = /obj/effect/proc_holder/spell/targeted/conjure_item/snow

/obj/effect/proc_holder/spell/targeted/conjure_item/snow
	name = "Stwórz śnieg"
	desc = "Skupia siły kriokinetyczne w śnieg, przydatny do śnieżnych budowli."
	item_type = /obj/item/stack/sheet/mineral/snow
	charge_max = 50
	delete_old = FALSE
	action_icon_state = "snow"

/datum/mutation/wax_saliva
	name = "Woskowa ślina"
	desc = "Pozwala wydzielać wosk."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Twoje usta wydają się woskowe.</span>"
	instability = 10
	difficulty = 10
	synchronizer_coeff = 1
	locked = TRUE
	power = /obj/effect/proc_holder/spell/targeted/conjure_item/wax

/obj/effect/proc_holder/spell/targeted/conjure_item/wax
	name = "Wydziel wosk"
	desc = "Skup się, żeby wypluć trochę wosku, przydatnego do pszczelich budowli."
	item_type = /obj/item/stack/sheet/mineral/wax
	charge_max = 50
	delete_old = FALSE
	action_icon_state = "honey"

/datum/mutation/cryokinesis
	name = "Kriokineza"
	desc = "Czerpie negatywną energię z lodowatej pustki, by na życzenie zamrażać otoczenie."
	quality = POSITIVE //upsides and downsides
	text_gain_indication = "<span class='notice'>Twoja dłoń wydaje się zimna.</span>"
	instability = 20
	difficulty = 12
	synchronizer_coeff = 1
	power = /obj/effect/proc_holder/spell/aimed/cryo

/obj/effect/proc_holder/spell/aimed/cryo
	name = "Krio-promień"
	desc = "Ta moc wystrzeliwuje w cel zamrożony pocisk."
	charge_max = 150
	cooldown_min = 150
	clothes_req = FALSE
	range = 3
	projectile_type = /obj/item/projectile/temp/cryo
	base_icon_state = "icebeam"
	action_icon_state = "icebeam"
	active_msg = "Skupiasz swoją kriokinezę!"
	deactive_msg = "Rozluźniasz się."
	active = FALSE

