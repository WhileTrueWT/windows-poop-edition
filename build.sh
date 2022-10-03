for dir in ./windows-src/*/ ; do
    lua exe-packager.lua $dir
done
