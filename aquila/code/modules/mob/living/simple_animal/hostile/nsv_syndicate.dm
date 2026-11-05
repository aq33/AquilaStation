// Strzelec Syndykatu w skafandrze dziedziczy po /space, a nie po /ranged, więc w nsv13/ ma ranged = 1 bez amunicji
// i Shoot() niczego nie wystrzeliwuje. Ta sama amunicja co u zwykłego strzelca; wersje smg i shotgun ustawiają własną.
/mob/living/simple_animal/hostile/nsv/syndicate/space/ranged
	casingtype = /obj/item/ammo_casing/c10mm
	projectilesound = 'sound/weapons/gunshot.ogg'
