#!/bin/bash

MOVIES="-D WITH_MOVIES=OFF"
echo "Do you want to run CorsixTH with movies enabled? This will require ffmpeg, acquired from a specific PPA."
select yn in "Yes" "No"; do
    case $yn in
        Yes ) 
          MOVIES="-D WITH_MOVIES=ON"
          if ! grep -q "jon-severinsson/ffmpeg" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
            sudo add-apt-repository ppa:jon-severinsson/ffmpeg
            sudo apt-get update
          else
            echo "Jon Severinsson's PPA has already been added on this machine."
          fi
          sudo apt-get install ffmpeg libavcodec-dev libavformat-dev libavresample-dev libavdevice-dev libavutil-dev libavfilter-dev libswscale-dev libpostproc-dev libswresample-dev -y
          break;;
        No ) break;;
    esac
done

sudo apt-get install build-essential cmake libsdl1.2-dev libsdl-mixer1.2-dev timidity libfreetype6-dev libluajit-5.1-dev lua-socket -y
# Try to fix bug in luasocket 3.0-rc1
sudo sed -i 's/ PROXY/ _M.PROXY/g' /usr/share/lua/5.1/socket/http.lua

MAPEDITOR="-D BUILD_MAPEDITOR=OFF"
echo "Do you wish to compile the Map Editor?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) 
          MAPEDITOR="-D BUILD_MAPEDITOR=ON"
          sudo apt-get install libwxgtk3.0-dev -y
          break;;
        No ) break;;
    esac
done

cmake $MAPEDITOR $MOVIES .
cd CorsixTH
make

if [[ $MAPEDITOR == *"ON" ]]; then
  cd ../MapEdit
  make
fi

echo "Do you wish to compile the Level Editor?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) 
          sudo apt-get install default-jdk -y
          cd ../LevelEdit
          mkdir -p bin
          cp src/icon* ./bin/
          javac -d bin -sourcepath src src/com/corsixth/leveledit/Main.java
          echo "#!/bin/bash" > LevelEdit
          echo "java -cp bin com.corsixth.leveledit.Main" >> LevelEdit
          chmod 755 LevelEdit
          break;;
        No ) break;;
    esac
done
