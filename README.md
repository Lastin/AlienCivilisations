# AlienCivilisations
Project written in language D:
http://dlang.org/

Compiler:
DMD64 D Compiler v2.068.2
Copyright (c) 1999-2015 by Digital Mars written by Walter Bright

=================================================
Using monodevelop requires installation of add-in:
*Tools > Add-in Manager > Gallery > Languge Bindings > D Language Binding*

=================================================
Project uses set of Derelict libraries.
Those are build using "dub" (http://code.dlang.org/download)
```
cd $DERELICT
git clone https://github.com/DerelictOrg/DerelictSDL2.git
git clone https://github.com/DerelictOrg/DerelictGL3.git
git clone https://github.com/DerelictOrg/DerelictUtil.git

cd DerelictSDL2
dub build
cd ../DerelictGL3
dub build
cd ../DerelictUtil
dub build
```
I have placed them in:
AlienCivilisations/AlienCivilisations/lib/derelict/

=================================================
Derelict files have to be linked to project:
*Project > :AlienCivilisations: Options > Build > Compiling*
Libraries filed contains:
```
-Ilib/derelict/DerelictSDL2/source
-Ilib/derelict/DerelictGL3/source
-Ilib/derelict/DerelictUtil/source
-Ilib/derelict/DerelictGLFW3/source
```

Extra linker options contain:
```
lib/derelict/DerelictSDL2/lib/libDerelictSDL2.a
-Llib/derelict/DerelictGL3/lib/libDerelictGL3.a
-Llib/derelict/DerelictGLFW3/lib/libDerelictGLFW3.a
-Llib/derelict/DerelictUtil/lib/libDerelictUtil.a
-L-ldl -lglfw3
```

(all but this first one in linker options must have -L prefix, otherwise it will not be passed as linkerflag refer to: -Llinkerflag)

=================================================
Library GLFW3 must be installed on the system.
It can be downloaded from official website: http://www.glfw.org/

Steps:
1. Install dependencies
```
sudo apt-get install cmake xorg-dev libglu1-mesa-dev
git clone https://github.com/glfw/glfw.git
cd glfw
```
2. Generate makefiles
```cmake -DBUILD_SHARED_LIBS=ON -G "Unix Makefiles"```
3. Install compiled files
```sudo make install```

-----------------------------------------
Now these files should be present in the directory */usr/local/lib/*
-libglfw.so
-libglfw.so.3
-libglfw.so.3.2
-----------------------------------------






