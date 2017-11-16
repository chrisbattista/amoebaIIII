# amoebaIIII

A quick experimental project to test modeling of primitive soft body dynamics in a rigid body engine. Specifically, the simulation builds cellular membranes out of small rigid "rods," similar to the method used to enable deformable objects in some commercial physics engines.

The method more or less works, although I suspect it would be prohibitively expensive computationally if utilized at scale. Some interesting steady-state vibrational effects in the membranes can be spotted.

Use the \ key to start the simulation, asdw to scroll the viewport, - and = keys zoom out and in, respectively. You can change the simulation speed with the [ and ] keys.

Dependencies:
-Lua LOVE library
