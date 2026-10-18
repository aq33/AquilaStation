/// Upstream unanchors every window in the singularity's pull range from stage 2, and the engine rooms on our maps
/// have windows a few tiles from the field. Anchored windows now hold until stage 5, which still destroys them.
/obj/structure/window/singularity_pull(S, current_size)
	if(anchored && current_size < STAGE_FIVE)
		return
	return ..()
