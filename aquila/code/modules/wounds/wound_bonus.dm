// AQUILA - wound bonuses from tgstation. A weapon's wound_bonus is added to the wound roll, bare_wound_bonus
// only when the hit limb isn't covered by clothing. CANT_WOUND turns wounds off for the attack.
// Projectiles can't wound unless they say so (tg): bullets roll pierce wounds, beams burns.
// The values below are copied from tgstation (df23e00) for the types we share with it.

/obj/item
	/// Added to the wound roll of hits with this item (tg)
	var/wound_bonus = 0
	/// Added to the wound roll when the hit limb is bare (tg exposed_wound_bonus)
	var/bare_wound_bonus = 0
	/// Wound kind rolled by brute hits, null: slash for sharp items, blunt otherwise
	var/wound_kind

/obj/item/proc/get_wound_kind()
	if(wound_kind)
		return wound_kind
	return is_sharp() ? WOUND_SLASH : WOUND_BLUNT

/obj/item/projectile
	wound_bonus = CANT_WOUND
	wound_kind = WOUND_BLUNT

/obj/item/projectile/bullet
	wound_kind = WOUND_PIERCE
	wound_bonus = 0

/obj/item/projectile/beam
	wound_bonus = -20
	bare_wound_bonus = 10

// Non-lethal bullets bruise instead of piercing
/obj/item/projectile/bullet/shotgun_beanbag
	wound_kind = WOUND_BLUNT
/obj/item/projectile/bullet/c9mm/rubber
	wound_kind = WOUND_BLUNT
/obj/item/projectile/bullet/c46x30mm_rubber
	wound_kind = WOUND_BLUNT
/obj/item/projectile/bullet/pellet/shotgun_rubbershot
	wound_kind = WOUND_BLUNT
/obj/item/projectile/bullet/shotgun_stunslug
	wound_kind = WOUND_BLUNT
/obj/item/projectile/bullet/reusable
	wound_bonus = CANT_WOUND
/obj/item/projectile/bullet/dart
	wound_bonus = CANT_WOUND

// Pointy weapons pierce
/obj/item/spear
	wound_kind = WOUND_PIERCE
/obj/item/pitchfork
	wound_kind = WOUND_PIERCE

// Series penalties of the light wounds (tg threshold_penalty / series_threshold_penalty)
/datum/wound/blunt/dislocation
	series_threshold_penalty = 15
/datum/wound/blunt/fracture
	series_threshold_penalty = 30
/datum/wound/blunt/compound
	threshold_penalty = 15
/datum/wound/slash/deep
	series_threshold_penalty = 25
/datum/wound/slash/artery
	threshold_penalty = 15
/datum/wound/burn/second_degree
	threshold_penalty = 15
	series_threshold_penalty = 40
/datum/wound/burn/third_degree
	threshold_penalty = 25

// --- Values from tgstation ---

/obj/item/circular_saw
	wound_bonus = 15
	bare_wound_bonus = 10

/obj/item/dualsaber
	wound_bonus = -10
	bare_wound_bonus = 20

/obj/item/food/grown/nettle/death
	wound_bonus = CANT_WOUND

/obj/item/food/powercrepe
	wound_bonus = -50

/obj/item/key/janitor
	wound_bonus = -1
	bare_wound_bonus = 2

/obj/item/light_eater
	wound_bonus = -30
	bare_wound_bonus = 20

/obj/item/melee/arm_blade
	wound_bonus = 10
	bare_wound_bonus = 10

/obj/item/melee/baseball_bat
	wound_bonus = -10

/obj/item/melee/chainofcommand
	wound_bonus = 15
	bare_wound_bonus = 10

/obj/item/melee/cultblade
	wound_bonus = -50
	bare_wound_bonus = 20

/obj/item/melee/cultblade/dagger
	wound_bonus = -10
	bare_wound_bonus = 20

/obj/item/melee/rune_carver
	wound_bonus = 20

/obj/item/melee/sabre
	wound_bonus = 10
	bare_wound_bonus = 25

/obj/item/melee/sickly_blade
	wound_bonus = 5
	bare_wound_bonus = 15

/obj/item/melee/sickly_blade/cursed
	wound_bonus = 25
	bare_wound_bonus = 15

/obj/item/mutant_hand/shattered_risen
	wound_bonus = -30
	bare_wound_bonus = 15

/obj/item/nullrod
	wound_bonus = -10

/obj/item/nullrod/armblade
	wound_bonus = -20
	bare_wound_bonus = 25

/obj/item/pen/edagger
	bare_wound_bonus = 10

/obj/item/projectile/beam
	wound_bonus = -20
	bare_wound_bonus = 10

/obj/item/projectile/beam/emitter
	wound_bonus = -40
	bare_wound_bonus = 70

/obj/item/projectile/beam/laser
	wound_bonus = -20
	bare_wound_bonus = 40

/obj/item/projectile/beam/pulse
	wound_bonus = 10

/obj/item/projectile/beam/scatter
	wound_bonus = 5
	bare_wound_bonus = 5

/obj/item/projectile/blood_worm_spit/adult
	wound_bonus = 5

/obj/item/projectile/blood_worm_spit/adult_burst
	wound_bonus = 2

/obj/item/projectile/blood_worm_spit/juvenile
	wound_bonus = 0

/obj/item/projectile/bullet/c38
	wound_bonus = -20
	bare_wound_bonus = 10

/obj/item/projectile/bullet/c38/dumdum
	wound_bonus = 20
	bare_wound_bonus = 20

/obj/item/projectile/bullet/c45
	wound_bonus = -10

/obj/item/projectile/bullet/c46x30mm
	wound_bonus = -5
	bare_wound_bonus = 5

/obj/item/projectile/bullet/incendiary/shotgun/dragonsbreath
	wound_bonus = 5

/obj/item/projectile/bullet/pellet/shotgun_buckshot
	wound_bonus = 5
	bare_wound_bonus = 5

/obj/item/projectile/bullet/shotgun_beanbag
	wound_bonus = 20

/obj/item/projectile/bullet/shotgun_slug
	wound_bonus = 0
	bare_wound_bonus = 15

/obj/item/projectile/bullet/shrapnel
	wound_bonus = 30

/obj/item/projectile/bullet/strilka310
	wound_bonus = -45

/obj/item/projectile/floating_blade
	wound_bonus = 15

/obj/item/projectile/floating_blade/haunted
	wound_bonus = 25

/obj/item/scalpel
	wound_bonus = 10
	bare_wound_bonus = 15

/obj/item/scythe
	wound_bonus = 10

/obj/item/spear
	wound_bonus = -15
	bare_wound_bonus = 15

/obj/item/storage/toolbox
	wound_bonus = 5

/obj/item/surgicaldrill
	wound_bonus = 10
	bare_wound_bonus = 10

/obj/item/void_eater
	wound_bonus = -30
	bare_wound_bonus = 20

/obj/item/weldingtool
	wound_bonus = 10
	bare_wound_bonus = 15
