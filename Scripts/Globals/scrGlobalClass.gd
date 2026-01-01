"""
This is a global class. Inside of it, we have an enum which has all kinds
of weapons/projectiles we want. Since we're defining a new class, we don't
need to extend a node or even make it into an autoload. We just reference
it from anywhere else, and it works!

If you game has multiple weapons, this is a good way to organize the damage
interactions, for example.
"""

class_name GlobalClass

enum weapon_type {
	BULLET,
	
	# Not implemented, but put here anyway just to give an idea of what you
	# can do with it. Custom classes are powerful!
	SWORD
}
