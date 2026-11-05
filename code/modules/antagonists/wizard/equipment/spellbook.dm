#define WIZARD_WILDMAGIC_SPELLPOINT_MULTIPLIER 1.7

/datum/spellbook_entry
	var/name = "Entry Name"

	var/spell_type = null
	var/desc = ""
	var/category = "Offensive"
	var/cost = 2
	var/refundable = TRUE
	var/surplus = -1 // -1 for infinite, not used by anything atm
	var/obj/effect/proc_holder/spell/S = null //Since spellbooks can be used by only one person anyway we can track the actual spell
	var/buy_word = "Learn"
	var/limit //used to prevent a spellbook_entry from being bought more than X times with one wizard spellbook
	var/list/no_coexistance_typecache //Used so you can't have specific spells together

/datum/spellbook_entry/New()
	..()
	no_coexistance_typecache = typecacheof(no_coexistance_typecache)

/datum/spellbook_entry/proc/IsAvailable() // For config prefs / gamemode restrictions - these are round applied
	return TRUE

/datum/spellbook_entry/proc/CanBuy(mob/living/carbon/human/user,obj/item/spellbook/book) // Specific circumstances
	if(book.uses<cost || limit == 0)
		return FALSE
	for(var/spell in user.mind.spell_list)
		if(is_type_in_typecache(spell, no_coexistance_typecache))
			return FALSE
	return TRUE

/datum/spellbook_entry/proc/Buy(mob/living/carbon/human/user,obj/item/spellbook/book) //return TRUE on success
	if(!S || QDELETED(S))
		S = new spell_type()
	//Check if we got the spell already
	for(var/obj/effect/proc_holder/spell/aspell in user.mind.spell_list)
		if(initial(S.name) == initial(aspell.name)) // Not using directly in case it was learned from one spellbook then upgraded in another
			if(aspell.spell_level >= aspell.level_max)
				to_chat(user,  "<span class='warning'>Tego zaklęcia nie da się już ulepszyć.</span>")
				return FALSE
			else
				aspell.name = initial(aspell.name)
				aspell.spell_level++
				aspell.charge_max = round(initial(aspell.charge_max) - aspell.spell_level * (initial(aspell.charge_max) - aspell.cooldown_min)/ aspell.level_max)
				if(aspell.charge_max < aspell.charge_counter)
					aspell.charge_counter = aspell.charge_max
				switch(aspell.spell_level)
					if(1)
						to_chat(user, "<span class='notice'>Ulepszasz [aspell.name] do wersji wydajnej.</span>")
						aspell.name = "[aspell.name] (wersja wydajna)"
					if(2)
						to_chat(user, "<span class='notice'>Dalej ulepszasz [aspell.name] do wersji przyspieszonej.</span>")
						aspell.name = "[aspell.name] (wersja przyspieszona)"
					if(3)
						to_chat(user, "<span class='notice'>Dalej ulepszasz [aspell.name] do wersji darmowej.</span>")
						aspell.name = "[aspell.name] (wersja darmowa)"
					if(4)
						to_chat(user, "<span class='notice'>Dalej ulepszasz [aspell.name] do wersji natychmiastowej.</span>")
						aspell.name = "[aspell.name] (wersja natychmiastowa)"
				if(aspell.spell_level >= aspell.level_max)
					to_chat(user, "<span class='notice'>Tego zaklęcia nie da się już bardziej wzmocnić.</span>")
				SSblackbox.record_feedback("nested tally", "wizard_spell_improved", 1, list("[name]", "[aspell.spell_level]"))
				return TRUE
	//No same spell found - just learn it
	SSblackbox.record_feedback("tally", "wizard_spell_learned", 1, name)
	user.mind.AddSpell(S)
	to_chat(user, "<span class='notice'>Uczysz się zaklęcia [S.name].</span>")
	return TRUE

/datum/spellbook_entry/proc/CanRefund(mob/living/carbon/human/user,obj/item/spellbook/book)
	if(!refundable)
		return FALSE
	if(!S)
		S = new spell_type()
	for(var/obj/effect/proc_holder/spell/aspell in user.mind.spell_list)
		if(initial(S.name) == initial(aspell.name))
			return TRUE
	return FALSE

/datum/spellbook_entry/proc/Refund(mob/living/carbon/human/user,obj/item/spellbook/book) //return point value or -1 for failure
	var/area/wizard_station/A = GLOB.areas_by_type[/area/wizard_station]
	if(!(user in A.contents))
		to_chat(user, "<span class='warning'>Zaklęcia możesz zwracać tylko w kryjówce czarodzieja</span>")
		return -1
	if(!S)
		S = new spell_type()
	var/spell_levels = 0
	for(var/obj/effect/proc_holder/spell/aspell in user.mind.spell_list)
		if(initial(S.name) == initial(aspell.name))
			spell_levels = aspell.spell_level
			user.mind.spell_list.Remove(aspell)
			qdel(S)
			return cost * (spell_levels+1)
	return -1
/// Dane wpisu dla okna TGUI "Spellbook"
/datum/spellbook_entry/proc/get_ui_data(mob/living/carbon/human/user, obj/item/spellbook/book)
	var/list/data = list(
		"ref" = REF(src),
		"cost" = cost,
		"cat" = category,
		"refundable" = refundable,
		"buyword" = buy_word,
		"limit" = limit,
		"times" = 0,
		"active" = FALSE,
		"can_buy" = FALSE,
		"can_refund" = FALSE,
	)
	if(ishuman(user) && user.mind)
		data["can_buy"] = CanBuy(user, book)
		data["can_refund"] = refundable && CanRefund(user, book)
	return data

/// Stałe dane wpisu (nazwa, opis) dla okna "Spellbook"
/datum/spellbook_entry/proc/get_static_ui_data()
	if(!S)
		S = new spell_type()
	return list(
		"name" = initial(S.name),
		"desc" = "[S.desc][desc]",
		"requires_wizard_garb" = S.clothes_req,
		"cooldown" = S.charge_type == "recharge" ? S.charge_max / 10 : 0,
	)

/datum/spellbook_entry/fireball
	name = "Fireball"
	spell_type = /obj/effect/proc_holder/spell/aimed/fireball

/datum/spellbook_entry/spell_cards
	name = "Spell Cards"
	spell_type = /obj/effect/proc_holder/spell/aimed/spell_cards
	cost = 1

/datum/spellbook_entry/rod_form
	name = "Rod Form"
	spell_type = /obj/effect/proc_holder/spell/targeted/rod_form

/datum/spellbook_entry/magicm
	name = "Magic Missile"
	spell_type = /obj/effect/proc_holder/spell/targeted/projectile/magic_missile
	category = "Defensive"

/datum/spellbook_entry/disintegrate
	name = "Disintegrate"
	spell_type = /obj/effect/proc_holder/spell/targeted/touch/disintegrate

/datum/spellbook_entry/disabletech
	name = "Disable Tech"
	spell_type = /obj/effect/proc_holder/spell/targeted/emplosion/disable_tech
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/repulse
	name = "Repulse"
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/repulse
	category = "Defensive"

/datum/spellbook_entry/lightningPacket
	name = "Lightning bolt!  Lightning bolt!"
	spell_type = /obj/effect/proc_holder/spell/targeted/conjure_item/spellpacket
	category = "Defensive"

/datum/spellbook_entry/timestop
	name = "Time Stop"
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/timestop
	category = "Defensive"

/datum/spellbook_entry/smoke
	name = "Smoke"
	spell_type = /obj/effect/proc_holder/spell/targeted/smoke
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/blind
	name = "Blind"
	spell_type = /obj/effect/proc_holder/spell/targeted/blind
	cost = 1

/datum/spellbook_entry/mindswap
	name = "Mindswap"
	spell_type = /obj/effect/proc_holder/spell/targeted/mind_transfer
	category = "Mobility"

/datum/spellbook_entry/forcewall
	name = "Force Wall"
	spell_type = /obj/effect/proc_holder/spell/targeted/forcewall
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/blink
	name = "Blink"
	spell_type = /obj/effect/proc_holder/spell/targeted/turf_teleport/blink
	category = "Mobility"

/datum/spellbook_entry/teleport
	name = "Teleport"
	spell_type = /obj/effect/proc_holder/spell/targeted/area_teleport/teleport
	category = "Mobility"

/datum/spellbook_entry/mutate
	name = "Mutate"
	spell_type = /obj/effect/proc_holder/spell/targeted/genetic/mutate

/datum/spellbook_entry/jaunt
	name = "Ethereal Jaunt"
	spell_type = /obj/effect/proc_holder/spell/targeted/ethereal_jaunt
	category = "Mobility"

/datum/spellbook_entry/knock
	name = "Knock"
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/knock
	category = "Mobility"
	cost = 1

/datum/spellbook_entry/fleshtostone
	name = "Flesh to Stone"
	spell_type = /obj/effect/proc_holder/spell/targeted/touch/flesh_to_stone

/datum/spellbook_entry/summonitem
	name = "Summon Item"
	spell_type = /obj/effect/proc_holder/spell/targeted/summonitem
	category = "Assistance"
	cost = 1

/datum/spellbook_entry/lichdom
	name = "Bind Soul"
	spell_type = /obj/effect/proc_holder/spell/targeted/lichdom
	category = "Defensive"
	cost = 3

/datum/spellbook_entry/teslablast
	name = "Tesla Blast"
	spell_type = /obj/effect/proc_holder/spell/targeted/tesla

/datum/spellbook_entry/lightningbolt
	name = "Lightning Bolt"
	spell_type = /obj/effect/proc_holder/spell/aimed/lightningbolt

/datum/spellbook_entry/lightningbolt/Buy(mob/living/carbon/human/user,obj/item/spellbook/book) //return TRUE on success
	. = ..()
	user.flags_1 |= TESLA_IGNORE_1

/datum/spellbook_entry/infinite_guns
	name = "Lesser Summon Guns"
	spell_type = /obj/effect/proc_holder/spell/targeted/infinite_guns/gun
	cost = 3
	no_coexistance_typecache = /obj/effect/proc_holder/spell/targeted/infinite_guns/arcane_barrage

/datum/spellbook_entry/arcane_barrage
	name = "Arcane Barrage"
	spell_type = /obj/effect/proc_holder/spell/targeted/infinite_guns/arcane_barrage
	no_coexistance_typecache = /obj/effect/proc_holder/spell/targeted/infinite_guns/gun

/datum/spellbook_entry/barnyard
	name = "Barnyard Curse"
	spell_type = /obj/effect/proc_holder/spell/targeted/barnyardcurse

/datum/spellbook_entry/charge
	name = "Charge"
	spell_type = /obj/effect/proc_holder/spell/targeted/charge
	category = "Assistance"
	cost = 1

/datum/spellbook_entry/shapeshift
	name = "Wild Shapeshift"
	spell_type = /obj/effect/proc_holder/spell/targeted/shapeshift
	category = "Assistance"
	cost = 1

/datum/spellbook_entry/tap
	name = "Soul Tap"
	spell_type = /obj/effect/proc_holder/spell/self/tap
	category = "Assistance"
	cost = 1

/datum/spellbook_entry/spacetime_dist
	name = "Spacetime Distortion"
	spell_type = /obj/effect/proc_holder/spell/spacetime_dist
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/the_traps
	name = "The Traps!"
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/conjure/the_traps
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/bees
	name = "Lesser Summon Bees"
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/conjure/creature/bee
	category = "Defensive"

/datum/spellbook_entry/item
	name = "Buy Item"
	refundable = FALSE
	buy_word = "Summon"
	var/item_path= null


/datum/spellbook_entry/item/Buy(mob/living/carbon/human/user,obj/item/spellbook/book)
	new item_path(get_turf(user))
	SSblackbox.record_feedback("tally", "wizard_spell_learned", 1, name)
	return TRUE

/datum/spellbook_entry/item/get_static_ui_data()
	return list(
		"name" = name,
		"desc" = desc,
		"requires_wizard_garb" = FALSE,
		"cooldown" = 0,
	)

/datum/spellbook_entry/item/staffchange
	name = "Laska przemiany"
	desc = "Artefakt miotający pociski migoczącej energii, które przekształcają samą postać celu."
	item_path = /obj/item/gun/magic/staff/change

/datum/spellbook_entry/item/staffanimation
	name = "Laska ożywienia"
	desc = "Tajemna laska strzelająca pociskami niesamowitej energii, które ożywiają martwe przedmioty. Ta magia nie działa na maszyny."
	item_path = /obj/item/gun/magic/staff/animate
	category = "Assistance"

/datum/spellbook_entry/item/staffchaos
	name = "Laska chaosu"
	desc = "Kapryśne narzędzie, które miota wszelkiego rodzaju magią bez ładu i składu. Nie zaleca się używania go na ludziach, na których ci zależy."
	item_path = /obj/item/gun/magic/staff/chaos

/datum/spellbook_entry/item/spellblade
	name = "Zaklęte ostrze"
	desc = "Miecz strzelający wybuchami energii, które rozrywają cele na kawałki."
	item_path = /obj/item/gun/magic/staff/spellblade

/datum/spellbook_entry/item/staffdoor
	name = "Laska tworzenia drzwi"
	desc = "Osobliwa laska, która przekształca lite ściany w zdobione drzwi. Przydaje się do poruszania się, gdy brak innego transportu. Nie działa na szkło."
	item_path = /obj/item/gun/magic/staff/door
	cost = 1
	category = "Mobility"

/datum/spellbook_entry/item/staffhealing
	name = "Laska uzdrowienia"
	desc = "Altruistyczna laska, która leczy kalekich i wskrzesza zmarłych."
	item_path = /obj/item/gun/magic/staff/healing
	cost = 1
	category = "Defensive"

/datum/spellbook_entry/item/lockerstaff
	name = "Laska szafki"
	desc = "Laska strzelająca szafkami. Pochłania każdego, kogo trafi po drodze, i zostawia za sobą zaspawaną szafkę z twoimi ofiarami."
	item_path = /obj/item/gun/magic/staff/locker
	category = "Defensive"

/datum/spellbook_entry/item/scryingorb
	name = "Kula jasnowidzenia"
	desc = "Rozżarzona kula trzaskającej energii. Pozwala uwolnić ducha za życia, dzięki czemu możesz szpiegować statek i rozmawiać ze zmarłymi. Do tego zakup na stałe daje ci wzrok rentgenowski."
	item_path = /obj/item/scrying
	category = "Defensive"

/datum/spellbook_entry/item/soulstones
	name = "Sześć odłamków kamienia duszy i zaklęcie Rzemieślnik"
	desc = "Odłamki kamienia duszy to pradawne narzędzia zdolne chwytać i ujarzmiać dusze zmarłych i umierających. Zaklęcie Rzemieślnik pozwala tworzyć tajemne maszyny, którymi sterują schwytane dusze."
	item_path = /obj/item/storage/belt/soulstone/full
	category = "Assistance"

/datum/spellbook_entry/item/soulstones/Buy(mob/living/carbon/human/user,obj/item/spellbook/book)
	. =..()
	if(.)
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/construct(null))
	return .

/datum/spellbook_entry/item/necrostone
	name = "Kamień nekromancji"
	desc = "Kamień nekromancji potrafi wskrzesić trzy martwe osoby jako szkieletowe sługi pod twoim rozkazem."
	item_path = /obj/item/necromantic_stone
	category = "Assistance"

/datum/spellbook_entry/item/wands
	name = "Zestaw różdżek"
	desc = "Kolekcja różdżek o najróżniejszych zastosowaniach. Różdżki mają ograniczoną liczbę ładunków, więc używaj ich oszczędnie. W komplecie poręczny pas."
	item_path = /obj/item/storage/belt/wands/full
	category = "Defensive"

/datum/spellbook_entry/item/armor
	name = "Mistrzowski komplet zbroi"
	desc = "Zbroja-artefakt, która pozwala rzucać zaklęcia i lepiej chroni przed atakami i próżnią kosmosu."
	item_path = /obj/item/clothing/suit/space/hardsuit/wizard
	category = "Defensive"

/datum/spellbook_entry/item/armor/Buy(mob/living/carbon/human/user,obj/item/spellbook/book)
	. = ..()
	if(.)
		new /obj/item/clothing/shoes/sandal/magic(get_turf(user)) //In case they've lost them.
		new /obj/item/clothing/gloves/color/purple(get_turf(user))//To complete the outfit
		new /obj/item/clothing/mask/breath(get_turf(user)) // so the air gets to your mouth. Just an average mask.
		new /obj/item/tank/internals/emergency_oxygen/magic_oxygen(get_turf(user)) // so you have something to actually breathe. Near infinite.

/datum/spellbook_entry/item/contract
	name = "Umowa terminowania"
	desc = "Magiczna umowa wiążąca ucznia czarodzieja z twoją służbą. Jej użycie przywoła go u twojego boku."
	item_path = /obj/item/antag_spawner/contract
	category = "Assistance"

/datum/spellbook_entry/item/guardian
	name = "Talia strażników"
	desc = "Talia kart tarota strażników, zdolna związać osobistego strażnika z twoim ciałem. Dostępnych jest kilka rodzajów strażników, ale każdy przenosi na ciebie część obrażeń. \
	Rozsądnie będzie nie kupować jej razem z niczym, co może sprawić, że zamienisz się z kimś ciałem."
	item_path = /obj/item/guardiancreator/wizard
	category = "Assistance"

/datum/spellbook_entry/item/bloodbottle
	name = "Butelka krwi"
	desc = "Butelka magicznie nasyconej krwi, której zapach po rozbiciu przyciąga istoty \
		spoza tego wymiaru. Uważaj jednak: stworzenia przyzywane magią krwi zabijają \
		bez wyboru i sam też możesz paść ich ofiarą."
	item_path = /obj/item/antag_spawner/slaughter_demon
	limit = 1
	category = "Assistance"

/datum/spellbook_entry/item/hugbottle
	name = "Butelka łaskotek"
	desc = "Butelka magicznie nasyconej zabawy, której zapach po rozbiciu \
		przyciąga urocze istoty spoza tego wymiaru. Istoty te \
		przypominają demony rzezi, ale nie zabijają swoich ofiar na zawsze, \
		tylko umieszczają je w międzywymiarowej przestrzeni przytulasów, \
		z której wychodzą po śmierci demona. Chaotyczne, ale w gruncie rzeczy \
		nieszkodliwe. Za to reakcja załogi może być bardzo \
		niszczycielska."
	item_path = /obj/item/antag_spawner/slaughter_demon/laughter
	cost = 1 //non-destructive; it's just a jape, sibling!
	limit = 1
	category = "Assistance"

/datum/spellbook_entry/item/mjolnir
	name = "Mjolnir"
	desc = "Potężny młot pożyczony od Thora, boga piorunów. Trzeszczy z ledwo powstrzymywanej mocy."
	item_path = /obj/item/mjollnir

/datum/spellbook_entry/item/singularity_hammer
	name = "Młot osobliwości"
	desc = "Młot, który w miejscu uderzenia tworzy niezwykle silne pole grawitacyjne i przyciąga wszystko w pobliżu do punktu trafienia."
	item_path = /obj/item/singularityhammer

/datum/spellbook_entry/item/battlemage
	name = "Zbroja maga bitewnego"
	desc = "Zaczarowany MODsuit, który pozwala rzucać zaklęcia, jest chroniony potężną, odnawialną tarczą i szczelny w próżni kosmosu."
	item_path = /obj/item/mod/control/pre_equipped/enchanted
	limit = 1
	category = "Defensive"

/datum/spellbook_entry/item/battlemage/Buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	var/obj/item/mod/control/mod = new item_path(get_turf(user))
	SSblackbox.record_feedback("tally", "wizard_spell_learned", 1, name)
	var/obj/item/mod/module/storage/storage = locate() in mod.modules
	var/obj/item/back = user.back
	if(back && user.dropItemToGround(back) && storage)
		for(var/obj/item/item as anything in back.contents)
			item.forceMove(storage)
	if(!user.equip_to_slot_if_possible(mod, mod.slot_flags, qdel_on_fail = FALSE, disable_warning = TRUE))
		return TRUE
	user.dropItemToGround(user.wear_suit)
	user.dropItemToGround(user.head)
	mod.quick_activation()
	return TRUE

/datum/spellbook_entry/item/battlemage_charge
	name = "Ładunki zbroi maga bitewnego"
	desc = "Potężna runa obronna, która daje zbroi maga bitewnego osiem dodatkowych ładunków."
	item_path = /obj/item/wizard_armour_charge
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/item/warpwhistle
	name = "Gwizdek przenosin"
	desc = "Dziwny gwizdek, który przenosi cię w odległe, bezpieczne miejsce na statku. Na początku każdego użycia przez chwilę jesteś bezbronny."
	item_path = /obj/item/warpwhistle
	category = "Mobility"
	cost = 1

/// How much threat we need to let these rituals happen on dynamic
#define MINIMUM_THREAT_FOR_RITUALS 85

/datum/spellbook_entry/summon
	name = "Summon Stuff"
	category = "Rituals"
	refundable = FALSE
	buy_word = "Cast"
	var/active = FALSE
	var/ritual_invocation // This does nothing. This is a flavor to ghosts observing a wizard.

/datum/spellbook_entry/summon/CanBuy(mob/living/carbon/human/user,obj/item/spellbook/book)
	return ..() && !active

/datum/spellbook_entry/summon/get_static_ui_data()
	return list(
		"name" = name,
		"desc" = desc,
		"requires_wizard_garb" = FALSE,
		"cooldown" = 0,
	)

/datum/spellbook_entry/summon/get_ui_data(mob/living/carbon/human/user, obj/item/spellbook/book)
	. = ..()
	.["active"] = active

/datum/spellbook_entry/summon/proc/say_invocation(mob/living/carbon/human/user)
	if(ritual_invocation)
		user.say(ritual_invocation, forced = "spell")

/datum/spellbook_entry/summon/ghosts
	name = "Przywołanie duchów"
	desc = "Przestrasz załogę, sprawiając, że zobaczy zmarłych. Uwaga: duchy są kapryśne i czasem mściwe, a niektóre użyją swoich niezwykle drobnych zdolności, żeby uprzykrzyć ci życie."
	cost = 0
	ritual_invocation = "ALADAL DESINARI ODORI'IN TUUR'IS OVOR'E POR"

/datum/spellbook_entry/summon/ghosts/Buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	SSblackbox.record_feedback("tally", "wizard_spell_learned", 1, name)
	new /datum/round_event/wizard/ghost()
	active = TRUE
	to_chat(user, "<span class='notice'>Rzucasz przywołanie duchów!</span>")
	playsound(get_turf(user), 'sound/effects/ghost2.ogg', 50, 1)
	say_invocation(user)
	return TRUE

/datum/spellbook_entry/summon/guns
	name = "Przywołanie broni"
	desc = "Cóż złego mogłoby wyniknąć z uzbrojenia załogi szaleńców, którzy tylko czekają na pretekst, żeby cię zabić? Jest spora szansa, że najpierw postrzelają się nawzajem."
	ritual_invocation = "ALADAL DESINARI ODORI'IN DOL'G FLAM OVOR'E POR"

/datum/spellbook_entry/summon/guns/IsAvailable()
	if(!SSticker.mode) // In case spellbook is placed on map
		return FALSE
	if(istype(SSticker.mode, /datum/game_mode/dynamic)) // Disable events on dynamic
		var/datum/game_mode/dynamic/mode = SSticker.mode
		if(mode.threat_level < MINIMUM_THREAT_FOR_RITUALS)
			return FALSE
	return !CONFIG_GET(flag/no_summon_guns)

/datum/spellbook_entry/summon/guns/Buy(mob/living/carbon/human/user,obj/item/spellbook/book)
	SSblackbox.record_feedback("tally", "wizard_spell_learned", 1, name)
	rightandwrong(SUMMON_GUNS, user, 10)
	active = TRUE
	playsound(get_turf(user), 'sound/magic/castsummon.ogg', 50, 1)
	to_chat(user, "<span class='notice'>Rzucasz przywołanie broni!</span>")
	say_invocation(user)
	return TRUE

/datum/spellbook_entry/summon/magic
	name = "Przywołanie magii"
	desc = "Podziel się z załogą cudami magii i przy okazji pokaż, czemu nie można jej jej powierzać."
	ritual_invocation = "ALADAL DESINARI ODORI'IN IDO'LEX SPERMITA OVOR'E POR"

/datum/spellbook_entry/summon/magic/IsAvailable()
	if(!SSticker.mode) // In case spellbook is placed on map
		return FALSE
	if(istype(SSticker.mode, /datum/game_mode/dynamic)) // Disable events on dynamic
		var/datum/game_mode/dynamic/mode = SSticker.mode
		if(mode.threat_level < MINIMUM_THREAT_FOR_RITUALS)
			return FALSE
	return !CONFIG_GET(flag/no_summon_magic)

/datum/spellbook_entry/summon/magic/Buy(mob/living/carbon/human/user,obj/item/spellbook/book)
	SSblackbox.record_feedback("tally", "wizard_spell_learned", 1, name)
	rightandwrong(SUMMON_MAGIC, user, 10)
	active = TRUE
	playsound(get_turf(user), 'sound/magic/castsummon.ogg', 50, 1)
	to_chat(user, "<span class='notice'>Rzucasz przywołanie magii!</span>")
	say_invocation(user)
	return TRUE

/datum/spellbook_entry/summon/events
	name = "Przywołanie wydarzeń"
	desc = "Popchnij nieco prawo Murphy'ego i zastąp wszystkie wydarzenia specjalnymi wydarzeniami czarodziejskimi, które wszystkich zdezorientują i zmylą. Każde kolejne rzucenie zwiększa ich częstotliwość."
	var/times = 0
	ritual_invocation = "ALADAL DESINARI ODORI'IN IDO'LEX MANAG'ROKT OVOR'E POR"

/datum/spellbook_entry/summon/events/IsAvailable()
	if(!SSticker.mode) // In case spellbook is placed on map
		return FALSE
	if(istype(SSticker.mode, /datum/game_mode/dynamic)) // Disable events on dynamic
		var/datum/game_mode/dynamic/mode = SSticker.mode
		if(mode.threat_level < MINIMUM_THREAT_FOR_RITUALS)
			return FALSE
	return !CONFIG_GET(flag/no_summon_events)

/datum/spellbook_entry/summon/events/Buy(mob/living/carbon/human/user,obj/item/spellbook/book)
	SSblackbox.record_feedback("tally", "wizard_spell_learned", 1, name)
	summonevents()
	times++
	playsound(get_turf(user), 'sound/magic/castsummon.ogg', 50, 1)
	to_chat(user, "<span class='notice'>Rzucasz przywołanie wydarzeń.</span>")
	say_invocation(user)
	return TRUE

/datum/spellbook_entry/summon/events/get_ui_data(mob/living/carbon/human/user, obj/item/spellbook/book)
	. = ..()
	.["times"] = times

/datum/spellbook_entry/summon/curse_of_madness
	name = "Klątwa obłędu"
	desc = "Przeklina statek, wypaczając umysły wszystkich na pokładzie i wywołując trwałe traumy. Uwaga: zaklęcie może dotknąć i ciebie, jeśli nie rzucisz go z bezpiecznej odległości."
	cost = 4
	ritual_invocation = "ALADAL DESINARI ODORI'IN PORES ENHIDO'LEN MORI MAKA TU"

/datum/spellbook_entry/summon/curse_of_madness/Buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	SSblackbox.record_feedback("tally", "wizard_spell_learned", 1, name)
	active = TRUE
	var/message
	while(!message)
		message = stripped_input(user, "Wyszepcz sekretną prawdę, która doprowadzi twoje ofiary do szaleństwa.", "Szepty szaleństwa")
	curse_of_madness(user, message)
	to_chat(user, "<span class='notice'>Rzucasz klątwę obłędu!</span>")
	playsound(user, 'sound/magic/mandswap.ogg', 50, 1)
	return TRUE

/datum/spellbook_entry/summon/wild_magic
	name = "Manipulacja dziką magią"
	desc = "Mnoży pozostałe punkty zaklęć o 70% (w dół) i wydaje je wszystkie na Manipulację dziką magią. \
		Kupujesz losowe zaklęcia i przedmioty za wydane punkty. Zaklęć z tego rytuału nie da się zwrócić, nawet jeśli nauczysz się ich ręcznie, a księga nie przyjmie już przedmiotów do zwrotu."
	cost = 0
	ritual_invocation = "ALADAL DESINARI ODORI'IN A'EN SPERMITEN G'ATUA H'UN OVORA DUN SPERMITUN"

/datum/spellbook_entry/summon/wild_magic/Buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	if(!book.uses)
		to_chat(user, "<span class='notice'>Nie masz punktów zaklęć na ten rytuał.</span>") // You can cast it again as long as you get more spell points somehow
		return FALSE
	SSblackbox.record_feedback("tally", "wizard_spell_learned", 1, name)
	book.uses = round(book.uses*WIZARD_WILDMAGIC_SPELLPOINT_MULTIPLIER) // more spell points
	book.refuses_refund = TRUE
	book.desc = "Nieziemska księga, która kiedyś miała wielką moc."
	while(book.uses)
		var/datum/spellbook_entry/target = pick(book.entries)
		if(istype(target, /datum/spellbook_entry/summon/wild_magic))
			continue // Too lucky to get more spell points, but no.
		if(target.CanBuy(user,book))
			if(target.Buy(user,book))
				book.uses -= target.cost
				target.refundable = FALSE
	say_invocation(user)
	return TRUE


#undef MINIMUM_THREAT_FOR_RITUALS

/obj/item/spellbook
	name = "księga zaklęć"
	desc = "Nieziemska księga, która lśni mocą."
	icon = 'icons/obj/library.dmi'
	icon_state ="book"
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	var/uses = 10
	var/refuses_refund = FALSE
	var/mob/living/carbon/human/owner
	var/list/datum/spellbook_entry/entries = list()
	var/list/categories = list()

/obj/item/spellbook/examine(mob/user)
	. = ..()
	if(owner)
		. += {"Na przedniej okładce widnieje mały podpis: "[owner]"."}
	else
		. += "Wygląda na to, że nie ma autora."

/obj/item/spellbook/Initialize(mapload)
	. = ..()
	prepare_spells()

/obj/item/spellbook/proc/prepare_spells()
	var/entry_types = subtypesof(/datum/spellbook_entry) - /datum/spellbook_entry/item - /datum/spellbook_entry/summon
	for(var/T in entry_types)
		var/datum/spellbook_entry/E = new T
		if(E.IsAvailable())
			entries |= E
			categories |= E.category
		else
			qdel(E)

/obj/item/spellbook/attackby(obj/item/O, mob/user, params)
	if(refuses_refund)
		to_chat(user, "<span class='warning'>Twoja księga jest bezsilna przez rytuał Manipulacji Dziką Magią. Księga nie przyjmuje przedmiotu.</span>")
		return
	if(istype(O, /obj/item/antag_spawner/contract))
		var/obj/item/antag_spawner/contract/contract = O
		if(contract.used)
			to_chat(user, "<span class='warning'>Umowa została wykorzystana, nie odzyskasz już punktów!</span>")
		else
			to_chat(user, "<span class='notice'>Oddajesz umowę księdze zaklęć i odzyskujesz punkty.</span>")
			uses++
			for(var/datum/spellbook_entry/item/contract/CT in entries)
				if(!isnull(CT.limit))
					CT.limit++
			qdel(O)
	else if(istype(O, /obj/item/antag_spawner/slaughter_demon))
		to_chat(user, "<span class='notice'>Po namyśle przywołanie demona to może zły pomysł. Odzyskujesz punkty.</span>")
		uses++
		for(var/datum/spellbook_entry/item/bloodbottle/BB in entries)
			if(!isnull(BB.limit))
				BB.limit++
		qdel(O)

/obj/item/spellbook/attack_self(mob/user)
	if(!owner)
		to_chat(user, "<span class='notice'>Wiążesz księgę zaklęć ze sobą.</span>")
		owner = user
		return
	if(user != owner)
		to_chat(user, "<span class='warning'>[name] nie rozpoznaje w tobie właściciela i nie chce się otworzyć!</span>")
		return
	ui_interact(user)

/obj/item/spellbook/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Spellbook")
		ui.open()

/obj/item/spellbook/ui_static_data(mob/user)
	var/list/data = list()
	data["owner"] = "[owner]"
	return data

/obj/item/spellbook/ui_data(mob/user)
	var/list/data = list()
	data["points"] = uses
	var/list/entry_data = list()
	for(var/datum/spellbook_entry/entry as anything in entries)
		var/list/one_entry = entry.get_static_ui_data()
		var/list/dynamic_data = entry.get_ui_data(user, src)
		for(var/key in dynamic_data)
			one_entry[key] = dynamic_data[key]
		entry_data += list(one_entry)
	data["entries"] = entry_data
	return data

/obj/item/spellbook/ui_act(action, params)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = usr
	if(!ishuman(H) || !H.mind)
		return
	if(H.stat || H.restrained())
		return
	if(H != owner)
		return
	if(H.mind.special_role == "apprentice")
		to_chat(H, "<span class='warning'>Gdyby cię przyłapano na podglądaniu księgi nauczyciela, pewnie wyrzucono by cię z Akademii Czarodziejów. Lepiej nie.</span>")
		return
	if(!(loc == H || (in_range(src, H) && isturf(loc))))
		return

	switch(action)
		if("purchase")
			var/datum/spellbook_entry/E = locate(params["spellref"]) in entries
			if(E?.CanBuy(H, src) && E.Buy(H, src))
				if(E.limit)
					E.limit--
				uses -= E.cost
				log_game("[initial(E.name)] purchased by [H.ckey]/[H.name] the [H.job] for [E.cost] SP, [uses] SP remaining.")
			return TRUE
		if("refund")
			var/datum/spellbook_entry/E = locate(params["spellref"]) in entries
			if(E?.refundable)
				var/result = E.Refund(H, src)
				if(result > 0)
					if(!isnull(E.limit))
						E.limit += result
					uses += result
			return TRUE

#undef WIZARD_WILDMAGIC_SPELLPOINT_MULTIPLIER
