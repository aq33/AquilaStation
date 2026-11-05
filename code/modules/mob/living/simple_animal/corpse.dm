//Meant for simple animals to drop lootable human bodies.

//If someone can do this in a neater way, be my guest-Kor

//This has to be separate from the Away Mission corpses, because New() doesn't work for those, and initialize() doesn't work for these.

//To do: Allow corpses to appear mangled, bloody, etc. Allow customizing the bodies appearance (they're all bald and white right now).

//List of different corpse types

/obj/effect/mob_spawn/human/corpse/syndicatesoldier
	name = "agent Syndykatu"
	id_job = "Agent"
	hair_style = "Bald"
	facial_hair_style = "Shaved"
	outfit = /datum/outfit/syndicatesoldiercorpse

/datum/outfit/syndicatesoldiercorpse
	name = "Zwłoki agenta Syndykatu"
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset
	mask = /obj/item/clothing/mask/gas/old
	head = /obj/item/clothing/head/helmet/swat
	back = /obj/item/storage/backpack
	id = /obj/item/card/id/syndicate

/obj/effect/mob_spawn/human/corpse/syndicatecommando
	name = "komandos Syndykatu"
	id_job = "Agent"
	hair_style = "Bald"
	facial_hair_style = "Shaved"
	outfit = /datum/outfit/syndicatecommandocorpse

/datum/outfit/syndicatecommandocorpse
	name = "Zwłoki komandosa Syndykatu"
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/space/hardsuit/syndi
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset
	mask = /obj/item/clothing/mask/gas/syndicate
	back = /obj/item/tank/jetpack/oxygen
	r_pocket = /obj/item/tank/internals/emergency_oxygen
	id = /obj/item/card/id/syndicate


/obj/effect/mob_spawn/human/corpse/syndicatestormtrooper
	name = "szturmowiec Syndykatu"
	id_job = "Agent"
	hair_style = "Bald"
	facial_hair_style = "Shaved"
	outfit = /datum/outfit/syndicatestormtroopercorpse

/datum/outfit/syndicatestormtroopercorpse
	name = "Zwłoki szturmowca Syndykatu"
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/space/hardsuit/syndi/elite
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset
	mask = /obj/item/clothing/mask/gas/syndicate
	back = /obj/item/tank/jetpack/oxygen/harness
	id = /obj/item/card/id/syndicate


/obj/effect/mob_spawn/human/clown/corpse
	roundstart = FALSE
	instant = TRUE
	skin_tone = "caucasian1"
	hair_style = "Bald"
	facial_hair_style = "Shaved"

/obj/effect/mob_spawn/human/corpse/pirate
	name = "pirat"
	skin_tone = "caucasian1" //all pirates are white because it's easier that way
	outfit = /datum/outfit/piratecorpse
	hair_style = "Bald"
	facial_hair_style = "Shaved"

/datum/outfit/piratecorpse
	name = "Zwłoki pirata"
	uniform = /obj/item/clothing/under/costume/pirate
	shoes = /obj/item/clothing/shoes/jackboots
	glasses = /obj/item/clothing/glasses/eyepatch
	head = /obj/item/clothing/head/bandana


/obj/effect/mob_spawn/human/corpse/pirate/ranged
	name = "pirat strzelec"
	outfit = /datum/outfit/piratecorpse/ranged

/datum/outfit/piratecorpse/ranged
	name = "Zwłoki pirata strzelca"
	suit = /obj/item/clothing/suit/pirate
	head = /obj/item/clothing/head/pirate


/obj/effect/mob_spawn/human/corpse/russian
	name = "Rosjanin"
	outfit = /datum/outfit/russiancorpse
	hair_style = "Bald"
	facial_hair_style = "Shaved"

/datum/outfit/russiancorpse
	name = "Zwłoki Rosjanina"
	uniform = /obj/item/clothing/under/costume/soviet
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/bearpelt
	gloves = /obj/item/clothing/gloves/color/black
	mask = /obj/item/clothing/mask/gas/old



/obj/effect/mob_spawn/human/corpse/russian/ranged
	outfit = /datum/outfit/russiancorpse/ranged

/datum/outfit/russiancorpse/ranged
	name = "Zwłoki Rosjanina strzelca"
	head = /obj/item/clothing/head/ushanka


/obj/effect/mob_spawn/human/corpse/russian/ranged/trooper
	outfit = /datum/outfit/russiancorpse/ranged/trooper

/datum/outfit/russiancorpse/ranged/trooper
	name = "Zwłoki rosyjskiego żołnierza strzelca"
	uniform = /obj/item/clothing/under/syndicate/camo
	suit = /obj/item/clothing/suit/armor/bulletproof
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset
	head = /obj/item/clothing/head/helmet/alt
	mask = /obj/item/clothing/mask/balaclava


/obj/effect/mob_spawn/human/corpse/russian/ranged/officer
	name = "rosyjski oficer"
	outfit = /datum/outfit/russiancorpse/officer

/datum/outfit/russiancorpse/officer
	name = "Zwłoki rosyjskiego oficera"
	uniform = /obj/item/clothing/under/costume/russian_officer
	suit = /obj/item/clothing/suit/security/officer/russian
	shoes = /obj/item/clothing/shoes/combat
	ears = /obj/item/radio/headset
	head = /obj/item/clothing/head/ushanka


/obj/effect/mob_spawn/human/corpse/wizard
	name = "zwłoki kosmicznego czarodzieja"
	outfit = /datum/outfit/wizardcorpse
	hair_style = "Bald"
	facial_hair_style = "Long Beard"
	skin_tone = "caucasian1"

/datum/outfit/wizardcorpse
	name = "Zwłoki kosmicznego czarodzieja"
	uniform = /obj/item/clothing/under/color/lightpurple
	suit = /obj/item/clothing/suit/wizrobe
	shoes = /obj/item/clothing/shoes/sandal/magic
	head = /obj/item/clothing/head/wizard


/obj/effect/mob_spawn/human/corpse/nanotrasensoldier
	name = "\improper prywatny ochroniarz Nanotrasen"
	id_job = "Prywatne Siły Ochrony"
	id_access = JOB_NAME_SECURITYOFFICER
	outfit = /datum/outfit/nanotrasensoldiercorpse2
	hair_style = "Bald"
	facial_hair_style = "Shaved"

/datum/outfit/nanotrasensoldiercorpse2
	name = "Zwłoki prywatnego ochroniarza NT"
	uniform = /obj/item/clothing/under/rank/security/officer
	suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	head = /obj/item/clothing/head/helmet/swat/nanotrasen
	back = /obj/item/storage/backpack/security
	id = /obj/item/card/id/job/security_officer

/obj/effect/mob_spawn/human/corpse/cat_butcher
	name = "Koci Chirurg"
	id_job = "Koci chirurg"
	id_access_list = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_MAINT)
	hair_style = "Cut Hair"
	facial_hair_style = "Watson Mustache"
	skin_tone = "caucasian1"
	outfit = /datum/outfit/cat_butcher

/datum/outfit/cat_butcher
	name = "Strój Kociego Chirurga"
	uniform = /obj/item/clothing/under/rank/medical/doctor/green
	suit = /obj/item/clothing/suit/apron/surgical
	shoes = /obj/item/clothing/shoes/sneakers/white
	gloves = /obj/item/clothing/gloves/color/latex/nitrile
	ears = /obj/item/radio/headset
	back = /obj/item/storage/backpack/satchel/med
	id = /obj/item/card/id
	glasses = /obj/item/clothing/glasses/hud/health

/obj/effect/mob_spawn/human/corpse/bee_terrorist
	name = "agent BLF"
	outfit = /datum/outfit/bee_terrorist

/datum/outfit/bee_terrorist
	name = "Agent BLF"
	uniform = /obj/item/clothing/under/color/yellow
	suit = /obj/item/clothing/suit/hooded/bee_costume
	shoes = /obj/item/clothing/shoes/sneakers/yellow
	gloves = /obj/item/clothing/gloves/color/yellow
	ears = /obj/item/radio/headset
	belt = /obj/item/storage/belt/fannypack/yellow/bee_terrorist
	id = /obj/item/card/id
	l_pocket = /obj/item/paper/fluff/bee_objectives
	mask = /obj/item/clothing/mask/rat/bee

/obj/effect/mob_spawn/human/corpse/sniper
	name = "snajper"
	outfit = /datum/outfit/sniper
	skin_tone = "caucasian1"
	hair_style = "Bald"
	facial_hair_style = "Full beard"
	id_job = JOB_NAME_WARDEN
	mob_gender = MALE

/datum/outfit/sniper
	name = "Snajper"
	uniform = /obj/item/clothing/under/syndicate/camo
	suit = /obj/item/clothing/suit/armor/bulletproof
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	belt = /obj/item/storage/belt/military/assault
	mask = /obj/item/clothing/mask/cigarette/cigar
	head = /obj/item/clothing/head/beret/corpwarden
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses/eyepatch
	back = /obj/item/storage/backpack/satchel/sec
	id = /obj/item/card/id/job/warden

/obj/effect/mob_spawn/human/corpse/psychost
	name = "psychol"
	hair_style = "Bald"
	facial_hair_style = "Shaved"
	skin_tone = "caucasian1"
	brute_damage = 100
	outfit = /datum/outfit/straightjacket

/datum/outfit/straightjacket
	name = "Kaftan bezpieczeństwa"
	suit = /obj/item/clothing/suit/straight_jacket

/obj/effect/mob_spawn/human/corpse/psychost/muzzle
	name = "psychol w kagańcu"
	outfit = /datum/outfit/straightmuz

/datum/outfit/straightmuz
	name = "Kaftan bezpieczeństwa i kaganiec"
	suit = /obj/item/clothing/suit/straight_jacket
	mask = /obj/item/clothing/mask/muzzle

/obj/effect/mob_spawn/human/corpse/psychost/trap
	name = "psychol w pułapce"
	outfit = /datum/outfit/straighttrap

/datum/outfit/straighttrap
	name = "Kaftan bezpieczeństwa i odwrócone wnyki"
	suit = /obj/item/clothing/suit/straight_jacket
	head = /obj/item/reverse_bear_trap

/obj/effect/mob_spawn/human/corpse/heavy
	name = "ciężki strzelec"
	brute_damage = 300
	hair_style = "Bald"
	facial_hair_style = "Shaved"
	mob_gender = MALE
	skin_tone = "caucasian1"
	outfit = /datum/outfit/minigunheavy

/datum/outfit/minigunheavy
	name = "Ciężki strzelec"
	uniform = /obj/item/clothing/under/rank/security/head_of_security/alt
	shoes = /obj/item/clothing/shoes/combat/swat
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/gas/sechailer/swat/emagged
	suit = /obj/item/clothing/suit/armor/heavy
	back = /obj/item/minigunpack
	head = /obj/item/clothing/head/helmet/swat

/obj/effect/mob_spawn/human/corpse/zombie
	name = "zombie"
	mob_species = /datum/species/zombie
	brute_damage = 100

/obj/effect/mob_spawn/human/corpse/suicidezombie
	mob_species = /datum/species/zombie
	brute_damage = 100
	outfit = /datum/outfit/suicidezombie

/datum/outfit/suicidezombie
	name = "Gość z granatem"
	mask = /obj/item/clothing/mask/gas/cyborg
	uniform = /obj/item/clothing/under/pants/camo
	belt = /obj/item/storage/belt/bandolier
	shoes = /obj/item/clothing/shoes/combat

/obj/effect/mob_spawn/human/corpse/facboss
	name = "szef Fabryki"
	mob_species = /datum/species/ipc
	brute_damage = 800
	burn_damage = 100
	hair_style = "Crewcut"
	facial_hair_style = "Shaved"
	skin_tone = "caucasian1"
	mob_gender = MALE
	outfit = /datum/outfit/facboss

/datum/outfit/facboss
	name = "Szef Fabryki"
	glasses = /obj/item/clothing/glasses/hud/terminator
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/jacket/leather
	shoes = /obj/item/clothing/shoes/combat/swat
	gloves = /obj/item/clothing/gloves/fingerless
	id = /obj/item/card/id/gold
