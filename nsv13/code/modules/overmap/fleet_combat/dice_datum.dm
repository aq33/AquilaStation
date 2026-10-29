/*
A datum assigned to a overmap ship, dictating its dice rolls in fights between NPC-fleets in nonloaded systems.
Different ships have different combat dice, some have the same as eachother.
*/

/datum/combat_dice
	var/name = "kości bojowe: typ bazowy"	//No actual ship should have these.

	var/evade_dice = 1		//How many evade dice?
	var/evade_roll = 4		//How many sides? Result 1 to X.
	var/evade_bonus = 0		//Bonus that gets added to the evade roll total.

	var/target_dice = 1		//How many target dice?
	var/target_roll = 6		//How many sides? Result 1 to X.
	var/target_bonus = 0	//Bonus that gets added to the target roll total.

	var/armor_dice = 1		//How many armor dice?
	var/armor_roll = 4		//How many sides? Result 1 to X.
	var/armor_bonus = 0		//Bonus that gets added to the armor roll total.

	var/damage_dice = 1		//How many damage dice?
	var/damage_roll = 6		//How many sides? Result 1 to X.
	var/damage_bonus = 0	//Bonus that gets added to the damage roll total.

	var/affinity_flags = NONE		//Affinity: All dice end values are increased by 50% (rounded down) if the target AI type contains the affinity type.

/datum/combat_dice/civilian
	name = "kości bojowe: cywilne"

	evade_roll = 3

	target_roll = 4

	armor_roll = 2

	damage_roll = 2

/datum/combat_dice/fighter
	name = "kości bojowe: myśliwiec"

	evade_dice = 2
	evade_roll = 5

	armor_roll = 3
	armor_bonus = -1

	damage_roll = 3

	affinity_flags = AI_FLAG_SWARMER	//Great at shooting other fighters.

/datum/combat_dice/bomber
	name = "kości bojowe: bombowiec"

	evade_roll = 3

	target_dice = 2
	target_roll = 4
	target_bonus = 2

	armor_roll = 3
	armor_bonus = -1

	damage_dice = 2
	damage_roll = 5
	damage_bonus = 3

	affinity_flags = AI_FLAG_BATTLESHIP	//Loves taking out capital ships.


/datum/combat_dice/carrier
	name = "kości bojowe: lotniskowiec"

	evade_roll = 2

	target_roll = 4
	target_bonus = 1

	armor_roll = 4
	armor_bonus = -2

	damage_dice = 2
	damage_roll = 2

/datum/combat_dice/frigate
	name = "kości bojowe: fregata"

	evade_roll = 6
	evade_bonus = 1

	target_roll = 5
	target_bonus = 1

	armor_roll = 4

	damage_dice = 2
	damage_roll = 3
	damage_bonus = 1

	affinity_flags = AI_FLAG_SWARMER

/datum/combat_dice/destroyer
	name = "kości bojowe: niszczyciel"

	evade_roll = 3

	target_dice = 2
	target_roll = 4

	armor_roll = 4
	armor_bonus = 2

	damage_roll = 4
	damage_bonus = 2

	affinity_flags = AI_FLAG_SUPPLY

/datum/combat_dice/destroyer/flycatcher
	name = "kości bojowe: niszczyciel przeciwlotniczy"

	target_dice = 4

	damage_dice = 2
	damage_bonus = 0

	affinity_flags = AI_FLAG_SWARMER

/datum/combat_dice/destroyer/conflagration
	name = "kości bojowe: niszczyciel Hellfire"

	target_bonus = 2

	armor_bonus = 0

	damage_dice = 4

	affinity_flags = AI_FLAG_BATTLESHIP

/datum/combat_dice/cruiser
	name = "kości bojowe: krążownik"

	evade_roll = 2

	target_dice = 2
	target_roll = 5
	target_bonus = 1

	armor_dice = 2
	armor_roll = 3
	armor_bonus = 1

	damage_dice = 2
	damage_roll = 4
	damage_bonus = 2

	affinity_flags = AI_FLAG_SUPPLY

/datum/combat_dice/battleship
	name = "kości bojowe: pancernik"

	evade_roll = 3
	evade_bonus = -1

	target_dice = 4
	target_roll = 4
	target_bonus = 2

	armor_dice = 4
	armor_roll = 3

	damage_dice = 4
	damage_roll = 3
	damage_bonus = 2

	affinity_flags = AI_FLAG_DESTROYER

/datum/combat_dice/flagship
	name = "kości bojowe: okręt flagowy"

	evade_roll = 4
	evade_bonus = -2

	target_dice = 6
	target_roll = 3
	target_bonus = 4

	armor_dice = 6
	armor_roll = 2
	armor_bonus = 3

	damage_dice = 6
	damage_roll = 4
	damage_bonus = 5

	affinity_flags = AI_FLAG_BATTLESHIP
