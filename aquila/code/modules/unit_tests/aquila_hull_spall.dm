/// AQUILA - odłamki i wybuch kierunkowy po przebiciu poszycia (aquila/code/modules/overmap/modules/hull_spall.dm): pocisk
/// przekazany na pokład, który ginie, wypuszcza odłamki w głąb, a wybuch kierunkowy idzie wzdłuż lotu i rośnie z głębokością.
/datum/unit_test/aquila_hull_spall

/datum/unit_test/aquila_hull_spall/Run()
	var/turf/origin = run_loc_floor_bottom_left
	var/list/before = list()
	for(var/obj/item/projectile/bullet/shrapnel/hull_spall/old in world)
		before += old
	// płytkie przebicie (bez wybuchów, żeby nie ruszać pokoju testowego): sam pocisk zginął na podłodze
	var/obj/item/projectile/bullet/shell = new(origin)
	shell.hull_spall = list(1, 0, 1)
	qdel(shell)
	var/shards = 0
	for(var/obj/item/projectile/bullet/shrapnel/hull_spall/shard in world)
		if(!(shard in before))
			shards++
	if(shards < 4)
		return Fail("Pocisk przekazany na pokład wypuścił [shards] odłamków zamiast co najmniej 4")
	if(hull_spall(origin, 1, 0, 6) <= hull_spall(origin, 1, 0, 1))
		return Fail("Głębszy wyłom nie daje więcej odłamków")
	var/list/shallow = directional_explosion_plan(origin, 1, 0, 2)
	var/list/deep = directional_explosion_plan(locate(origin.x, origin.y, origin.z), 1, 0, 8)
	if(!length(shallow) || length(deep) < length(shallow))
		return Fail("Wybuch kierunkowy nie rośnie z głębokością ([length(shallow)] i [length(deep)] wybuchów)")
	var/list/first = deep[1]
	if(first[1] != origin || first[2] != 0)
		return Fail("Wybuch kierunkowy nie zaczyna się słabym epicentrum w miejscu trafienia")
	for(var/i in 2 to length(deep))
		var/list/blast = deep[i]
		var/turf/T = blast[1]
		if(T.y != origin.y || T.x <= origin.x)
			return Fail("Wybuch kierunkowy poszedł poza kierunek lotu ([T.x],[T.y])")
