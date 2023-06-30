/// Max number of atoms a broom can sweep at once
#define BROOM_PUSH_LIMIT 20

/obj/item/pushbroom
	name = "push broom"
	desc = "This is my BROOMSTICK! It can be used manually or braced with two hands to sweep items as you move."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "pushbroom1"
	force = 8
	var/force_wielded = 12
	throwforce = 10
	throw_speed = 1
	throw_range = 7
	w_class = W_CLASS_MEDIUM
	attack_verb = list("sweeps", "brushes off", "bludgeons", "whacks")
	flags = FPRINT | TWOHANDABLE
	autoignition_temperature = AUTOIGNITION_PLASTIC

/obj/item/pushbroom/update_wield(mob/user)
	..()
	icon_state = "pushbroom[wielded ? 0 : 1]"
	force = wielded ? force_wielded : initial(force)
	if(user)
		user.update_inv_hands()
	if(wielded)
		to_chat(user, "<span class='notice'>You brace the [src] against the ground in a firm sweeping stance.</span>")
		user.register_event(/event/moved, src, src::sweep())
	else
		user.unregister_event(/event/moved, src, src::sweep())

/obj/item/pushbroom/afterattack(atom/A, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return
	sweep(user, A)


// Attempts to push up to BROOM_PUSH_LIMIT atoms from a given location the user's faced direction

/obj/item/pushbroom/proc/sweep(mob/user, atom/A)
	var/turf/current_item_loc = isturf(A) ? A : A.loc
	if (!isturf(current_item_loc))
		return
	var/turf/new_item_loc = get_step(current_item_loc, user.dir)
	var/obj/machinery/disposal/target_bin = locate(/obj/machinery/disposal) in new_item_loc.contents
	var/i = 1
	for (var/obj/item/garbage in current_item_loc.contents)
		if (!garbage.anchored)
			if (target_bin)
				garbage.forceMove(target_bin)
			else
				garbage.Move(new_item_loc, user.dir)
			i++
		if (i > BROOM_PUSH_LIMIT)
			break
	if (i > 1)
		if (target_bin)
			target_bin.update_icon()
			to_chat(user, "<span class='notice'>You sweep the pile of garbage into [target_bin].</span>")
		playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1)

/*
/obj/item/pushbroom/cyborg
	name = "cyborg push broom"

/obj/item/pushbroom/cyborg/Initialize(mapload)
	. = ..()
	cant_drop = 1
*/
#undef BROOM_PUSH_LIMIT
