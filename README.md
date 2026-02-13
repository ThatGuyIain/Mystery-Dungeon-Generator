# Mystery Dungeon Generator

Hello! Welcome to my Pokemon Mystery Dungeon inspired map generator!

## What it Generates:

In the most simple terms the Mystery dungeon generator randomly generates rooms across a given map space and then connects paths to each room.

To do this, the program uses a Binary Space Partition (BSP) to continously divide the map space into boxes. This allows the program to constrain room generation and prevent cases where rooms can generate over another room.

## Parameters

The current list of parameters are:

### Map Bounds

The ability to change the size constraints in which the map occupies

### Room Quantities

The amount of rooms the map generator generates

### Subdivision Depth

Controls the amount of times the program divides the map space into useable room spaces. It also acts as a proxy control for controlling room sizes.

### Room Probability

Controls the probability of rooms spawning. Gives some variation in map generation by changing the range of rooms that can be generated.

## Known Limitations

There are currently quite a few known limitations:

1. Path generation is done through each subdivision rather from room to room. This means that paths follow a very similar pattern across each generation with very little variation
2. Subdivision depth isn't constrained to creating plausable room spaces. This results in cases where rooms generate into long constrained corridors or creates spaces in which room generation isn't possible.
3. Path generation gets really funky beyond a certain point when doing a deep subdivision. This is primarily due to map constraints and the way paths are created between rooms. In some circumstances, paths will generate tiles that exceed the map's bounds.
    
