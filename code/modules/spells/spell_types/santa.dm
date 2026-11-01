//Santa spells!
/obj/effect/proc_holder/spell/aoe_turf/conjure/presents
	name = "Wyczaruj prezenty!"
	desc = "To zaklęcie pozwala ci sięgnąć do przestrzeni S i wyjąć z niej prezenty! Hura!"
	school = "santa"
	charge_max = 600
	clothes_req = FALSE
	antimagic_allowed = TRUE
	invocation = "HO HO HO"
	invocation_type = "shout"
	range = 3
	cooldown_min = 50

	summon_type = list("/obj/item/a_gift")
	summon_lifespan = 0
	summon_amt = 5
