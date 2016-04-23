# AlienCivilisations
####Game project
Main features:
* Regionalisation
* Simulation of growth of population based on food and age and overpopulation factors
* Turn-based
* AI player opposing human


Project written in language D
Compiler:
DMD64 D Compiler v2.068 or newer

----------------------------------------------------------------------------------------------------
Using monodevelop requires installation of add-in:
*Tools > Add-in Manager > Gallery > Languge Bindings > D Language Binding*

----------------------------------------------------------------------------------------------------
Project utilises the Dlang UI  
https://github.com/buggins/dlangui  
which uses Derelict libraries for dynamic binding of OpenGL, SDL and other C++ libraries to D.  
https://github.com/DerelictOrg

----------------------------------------------------------------------------------------------------
HOW TO USE:  
1. Clone this repository  
2. Run `clone_script` from projects main directory, to clone dependencies  

Compatible DLangUI SHA: 7ab93a22f5b54442aa631de50241662fbf70f328

---------------------------------------------------------------------------------------------------


Sources of the Derelict and Dlang UI must be used to `includes`  
*Project Options > Build > Includes > add source folders*

Also add dlangui-monod-linux to project, and set it as dependency to your project  
*Project Options > Build > Project Dependencies*

In *Project Options > Build > Compiling > Linking* tick `Link in static/shared libraries from nested dependencies`  


In *Project Options > Build > Compiling > Compiling* add to *Version constants* `USE_OPENGL;USE_SDL;USE_FREETYPE;EmbedStandardResources`  
and in *Extra Compiler Options* add
```
-Jviews
-Jviews/res
-Jviews/res/i18n
-Jviews/res/mdpi
-Jviews/res/hdpi
```

----------------------------------------------------------------------------------------------------
In older version of the program library GLFW3 had to be installed on the system.
It can be downloaded from official website: http://www.glfw.org/
```
#Install dependencies
sudo apt-get install cmake xorg-dev libglu1-mesa-dev
git clone https://github.com/glfw/glfw.git
cd glfw
#Generate makefiles
cmake -DBUILD_SHARED_LIBS=ON -G "Unix Makefiles"
#Install compiled files
sudo make install
```

-----------------------------------------
Now these files should be present in the directory */usr/local/lib/*
* libglfw.so
* libglfw.so.3
* libglfw.so.3.2






