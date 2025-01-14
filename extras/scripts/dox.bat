::This script is used to create the dox pages, this means you must get the game to compile the xml first. (Set DOX_GENERATION to true in Project.hxp)
@echo off
cd ../../
cd docs/dox
@echo on
haxelib run dox -i ./