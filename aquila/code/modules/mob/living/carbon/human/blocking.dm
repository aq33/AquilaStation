// Blokowanie z nowego Bee (BeeStation-Hornet code/game/objects/items.dm hit_reaction/on_block) na naszym systemie block_level:
// przerwa między blokami, ciosy nie do zablokowania, kontra, wytrącenie z równowagi, darmowy blok pałek.
// Limit staminy za jeden blok (35) jest hookiem w core on_block.

/mob/living/carbon/human
	COOLDOWN_DECLARE(block_cooldown)

/obj/item/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "atak", damage = 0, attack_type = MELEE_ATTACK)
	// Tylko przedmioty w rękach. Ubrania (reaktywne pancerze, tarcze hardsuitów) działają jak dotąd
	if(!istype(owner) || !(src in owner.held_items))
		return ..()
	if(isitem(hitby))
		var/obj/item/hitting_item = hitby
		if((hitting_item.block_flags & BLOCKING_UNBLOCKABLE) && !(block_flags & BLOCKING_UNBLOCKABLE))
			return FALSE
	var/is_shield = istype(src, /obj/item/shield)
	if(!is_shield && !COOLDOWN_FINISHED(owner, block_cooldown))
		return FALSE
	. = ..()
	if(!.)
		return
	parry_feedback(owner, "blok!")
	if(!is_shield)
		COOLDOWN_START(owner, block_cooldown, BLOCK_CD)

/obj/item/on_block(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "atak", damage = 0, attack_type = MELEE_ATTACK)
	if(isitem(hitby))
		var/obj/item/hitting_item = hitby
		if(hitting_item.block_flags & BLOCKING_EFFORTLESS)
			damage = 0
	. = ..(owner, hitby, attack_text, damage, attack_type)
	block_aftermath(owner, hitby, attack_type)

/// Kontra i wytrącenie z równowagi po udanym bloku (tylko wręcz, z sąsiedniej kratki)
/obj/item/proc/block_aftermath(mob/living/carbon/human/owner, atom/movable/hitby, attack_type)
	var/mob/living/attacker
	if(isliving(hitby))
		attacker = hitby
	else if(isliving(hitby.loc))
		attacker = hitby.loc
	if(!attacker || attacker == owner || !owner.Adjacent(attacker) || attack_type == PROJECTILE_ATTACK || attack_type == THROWN_PROJECTILE_ATTACK)
		return
	// Gołą rękę rani już BLOCKING_NASTY w core, kontra tylko dla broni bez niego
	var/counter_unarmed = attack_type == UNARMED_ATTACK && !(block_flags & BLOCKING_NASTY)
	if(owner.combat_mode && (block_flags & BLOCKING_COUNTERATTACK) && (attack_type == MELEE_ATTACK || counter_unarmed) && prob(50))
		owner.visible_message("<span class='danger'>[owner] zręcznie kontratakuje, odbijając [hitby]!</span>")
		INVOKE_ASYNC(attacker, TYPE_PROC_REF(/atom, attackby), src, owner)
	if((block_flags & BLOCKING_UNBALANCE) && prob(20))
		owner.visible_message("<span class='warning'>[owner] wytrąca [attacker] z równowagi!</span>")
		attacker.Knockdown(1 SECONDS)
		attacker.changeNext_move(CLICK_CD_MELEE * 2)

/obj/item/examine(mob/user)
	. = ..()
	if(block_flags & BLOCKING_COUNTERATTACK)
		. += "<span class='notice'>Po udanym bloku może <b>kontratakować</b>.</span>"
	if(block_flags & BLOCKING_UNBALANCE)
		. += "<span class='notice'>Blokując, może <b>wytrącić z równowagi</b> atakującego.</span>"
	if(block_flags & BLOCKING_UNBLOCKABLE)
		. += "<span class='warning'>Jej ciosów nie zablokuje zwykła broń.</span>"

// Flagi broni jak w Bee (dopisane do naszych dotychczasowych flag)
/obj/item/chainsaw/energy
	block_flags = BLOCKING_ACTIVE | BLOCKING_UNBLOCKABLE
/obj/item/dualsaber
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY | BLOCKING_PROJECTILE | BLOCKING_COUNTERATTACK | BLOCKING_UNBLOCKABLE
/obj/item/nullrod/staff
	block_flags = BLOCKING_PROJECTILE | BLOCKING_UNBALANCE | BLOCKING_UNBLOCKABLE
/obj/item/nullrod/claymore/saber
	block_flags = BLOCKING_ACTIVE | BLOCKING_UNBLOCKABLE
/obj/item/nullrod/scythe
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY | BLOCKING_COUNTERATTACK
/obj/item/melee/baton
	block_flags = BLOCKING_ACTIVE | BLOCKING_EFFORTLESS
/obj/item/melee/classic_baton/police/telescopic
	block_flags = BLOCKING_ACTIVE | BLOCKING_EFFORTLESS
/obj/item/melee/baton/cattleprod/teleprod
	block_flags = BLOCKING_ACTIVE | BLOCKING_COUNTERATTACK
/obj/item/melee/transforming/energy/sword
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY | BLOCKING_UNBLOCKABLE
/obj/item/melee/sabre
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY | BLOCKING_COUNTERATTACK
/obj/item/mop
	block_flags = BLOCKING_ACTIVE | BLOCKING_UNBALANCE
/obj/item/pitchfork
	block_flags = BLOCKING_ACTIVE | BLOCKING_COUNTERATTACK
/obj/item/shield/energy
	block_flags = BLOCKING_PROJECTILE | BLOCKING_UNBLOCKABLE
/obj/item/spear
	block_flags = BLOCKING_ACTIVE | BLOCKING_UNBALANCE | BLOCKING_COUNTERATTACK
/obj/item/staff
	block_flags = BLOCKING_ACTIVE | BLOCKING_UNBALANCE
/obj/item/staff/bostaff
	block_flags = BLOCKING_ACTIVE | BLOCKING_COUNTERATTACK | BLOCKING_UNBALANCE
/obj/item/scythe
	block_flags = BLOCKING_ACTIVE | BLOCKING_COUNTERATTACK
/obj/item/rod_of_asclepius
	block_flags = BLOCKING_UNBALANCE
/obj/item/gun/magic/staff
	block_flags = BLOCKING_ACTIVE | BLOCKING_UNBALANCE
/obj/item/food/powercrepe
	block_flags = BLOCKING_ACTIVE | BLOCKING_UNBLOCKABLE

// Szabla jonowa (NSV13) to w kodzie podtyp pałki teleskopowej: nie blokowała wcale (block_level 0) i tylko rozłożona.
// Broni się teraz jak szabla, także wyłączona, bo to dalej metalowe ostrze.
/obj/item/melee/classic_baton/telescopic
	/// Blokuje też złożona/wyłączona (hook w core hit_reaction)
	var/blocks_when_off = FALSE

/obj/item/melee/classic_baton/telescopic/stunsword
	block_level = 1
	block_flags = BLOCKING_ACTIVE | BLOCKING_COUNTERATTACK
	blocks_when_off = TRUE
