% corsix-th(6) | Games Manual
%
% 2018-08-13

# NAME

corsix-th - A Theme Hospital engine reimplementation.

# SYNOPSIS

**corsix-th** [--interpreter=*luafile*] [--config-file *configfile*] [--load= *savefile*] [--dump=strings]

# DESCRIPTION

Theme Hospital was a simulation computer game developed by Bullfrog
Productions and published by Electronic Arts in 1997, in which the player
designs and operates a hospital.

This project aims to reimplement the game engine
of Theme Hospital, and be able to load the original
game data files. This means that you will need a
purchased copy of Theme Hospital, or a copy of the
demo, in order to use CorsixTH.

On Debian systems these data files can be
packaged with *game-data-packager*

# OPTIONS
This is a list of the options accepted by **corsix-th**

--interpreter=*luafile*
: Specify an alternative file to use as the main interpreter (bootstrap code)

--config-file *configfile*
: Use an alternative configuration file

--load=*savefile*
: If specified, loads the given save file immediately on start-up

--dump=strings
: Turns on debugging mode

# FILES
The save files are stored in *~/.config/CorsixTH/Saves/*

# SEE ALSO
*game-data-packager*(6)

# AUTHOR

CorsixTH was written by Peter "Corsix" Cawley et al.

Copyright © 2012 Chris Butler *<chrisb@debian.org>*
Copyright © 2015 Alexandre Detiste *<alexandre@detiste.be>*
This man page was written for the Debian project,
but may be used by others.
