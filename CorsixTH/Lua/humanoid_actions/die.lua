--[[ Copyright (c) 2009 Edvin "Lego3" Linge

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. --]]

local action_die_tick; action_die_tick = permanent"action_die_tick"( function(humanoid)
  local action = humanoid.action_queue[1]
  local phase = action.phase
  local mirror = humanoid.last_move_direction == "east" and 0 or 1
  if phase == 0 then
    action.phase = 1
    if humanoid.die_anims.extra_east ~= nil then
      humanoid:setTimer(humanoid.world:getAnimLength(humanoid.die_anims.extra_east), action_die_tick)
      humanoid:setAnimation(humanoid.die_anims.extra_east, mirror)
    else
      action_die_tick(humanoid)
    end
  elseif phase == 1 then
    action.phase = 2
    humanoid:setTimer(11, action_die_tick)
    humanoid:setAnimation(humanoid.die_anims.rise_east, mirror)
  elseif phase == 2 then
    -- Female slack tongue head layer is missing from wings animation onwards
    -- So we change the head to its standard equivalent
    if humanoid.humanoid_class == "Slack Female Patient" then
      humanoid:setLayer(0, humanoid.layers[0] - 8)
    end

    action.phase = 3
    humanoid:setTimer(11, action_die_tick)
    humanoid:setAnimation(humanoid.die_anims.wings_east, mirror)
  elseif phase == 3 then
    action.phase = 4
    humanoid:setTimer(15, action_die_tick)
    humanoid:setAnimation(humanoid.die_anims.hands_east, mirror)
  elseif phase == 4 then
    action.phase = 5
    humanoid:setTimer(30, action_die_tick)
    humanoid:setAnimation(humanoid.die_anims.fly_east, mirror)
    humanoid:setTilePositionSpeed(humanoid.tile_x, humanoid.tile_y, nil, nil, 0, -4)
  else
    humanoid:setHospital(nil)
    humanoid.world:destroyEntity(humanoid)
  end
end)

-- What happens when patients go to hell is based on what happens in Theme Hospital:
local action_die_tick_reaper; action_die_tick_reaper = permanent"action_die_tick_reaper"( function(humanoid)
  local action = humanoid.action_queue[1]
  local mirror = humanoid.last_move_direction == "east" and 0 or 1
  local phase = action.phase
  
  if phase == 0 then
    action.phase = 1
    
    if humanoid.die_anims.extra_east ~= nil then
      humanoid:setTimer(humanoid.world:getAnimLength(humanoid.die_anims.extra_east), action_die_tick_reaper)
      humanoid:setAnimation(humanoid.die_anims.extra_east, mirror)
    else
      action_die_tick_reaper(humanoid)
    end
  --1: The grim reaper and lava hole appear, if spawn points are available:
  elseif phase == 1 then
    if humanoid.humanoid_class ~= "Standard Male Patient" then 
      humanoid:setType("Standard Male Patient") 
    end
    humanoid:setAnimation(humanoid.on_ground_anim, mirror)
    
    -- Find suitable spawn points if they are available:
    -- 1. South spawns plenty of space scenario (based on spawn point positions I've seen in TH):
    local hole_x, hole_y = humanoid.world.pathfinder:findIdleTile(humanoid.tile_x, humanoid.tile_y + 4, 0)
    local grim_x, grim_y = humanoid.world.pathfinder:findIdleTile(hole_x - 5, hole_y + 2, 0)
    local hell_death_spawns_available = humanoid.world:checkHellDeathSpawnPoints(humanoid, hole_x, hole_y, grim_x, grim_y)
    
    -- 2. South spawns 1 tile wide corridor space scenario:
    if not hell_death_spawns_available then
      grim_x, grim_y = humanoid.world.pathfinder:findIdleTile(hole_x, hole_y + 3)
      hell_death_spawns_available = humanoid.world:checkHellDeathSpawnPoints(humanoid, hole_x, hole_y, grim_x, grim_y)
    end
    
    --3. North spawns not much space scenario:
    if not hell_death_spawns_available then
      hole_x, hole_y = humanoid.world.pathfinder:findIdleTile(humanoid.tile_x, humanoid.tile_y - 3, 0)
      grim_x, grim_y = humanoid.world.pathfinder:findIdleTile(hole_x + 1, hole_y, 0)
      hell_death_spawns_available = humanoid.world:checkHellDeathSpawnPoints(humanoid, hole_x, hole_y, grim_x, grim_y)
    end
    
    -- 4. East spawns 1 tile wide corridor space scenario:
    if not hell_death_spawns_available then
      hole_x, hole_y = humanoid.world.pathfinder:findIdleTile(humanoid.tile_x + 4, humanoid.tile_y, 0)
      grim_x, grim_y = humanoid.world.pathfinder:findIdleTile(hole_x + 3, hole_y, 0)
      hell_death_spawns_available = humanoid.world:checkHellDeathSpawnPoints(humanoid, hole_x, hole_y, grim_x, grim_y)
    end
    
    -- 5. West spawns not much space scenario:
    if not hell_death_spawns_available then
      hole_x, hole_y = humanoid.world.pathfinder:findIdleTile(humanoid.tile_x - 3, humanoid.tile_y, 0)
      grim_x, grim_y = humanoid.world.pathfinder:findIdleTile(hole_x, hole_y + 1, 0)
      hell_death_spawns_available = humanoid.world:checkHellDeathSpawnPoints(humanoid, hole_x, hole_y, grim_x, grim_y)
    end
    
    if hell_death_spawns_available == false then
      action_die_tick(humanoid)
    
    -- If this hell death can happen:
    else
      action.phase = 2
      
      --After spawning the Grim Reaper will stand idle for 40 ticks before doing his next action.
      humanoid.world:spawnGrimReaperAndLavaHole(humanoid.hospital, humanoid, hole_x, hole_y, grim_x, grim_y)
      
      --Decide which use tile the Grim Reaper will use:
      local grim_use_tile_x = nil
      local grim_use_tile_y = nil
      local east_tile_used = 0
      
      local s_use_tile_path_distance = humanoid.world:getPathDistance(humanoid.grim_reaper.tile_x, 
                                                                      humanoid.grim_reaper.tile_y, 
                                                                      hole_x, hole_y + 1)
      local e_use_tile_path_distance = humanoid.world:getPathDistance(humanoid.grim_reaper.tile_x, 
                                                                      humanoid.grim_reaper.tile_y, 
                                                                      hole_x + 1, hole_y)
      
      local s_use_tile_in_room = humanoid.world:getRoom(humanoid.grim_reaper.tile_x, humanoid.grim_reaper.tile_y, hole_x, hole_y + 1) ~= nil
      
      if s_use_tile_path_distance == false then
        --East tile
        grim_use_tile_x = hole_x + 1
        grim_use_tile_y = hole_y
        east_tile_used = 1
      elseif e_use_tile_path_distance == false then  
        --South tile
        grim_use_tile_x = hole_x
        grim_use_tile_y = hole_y + 1
      else
        if s_use_tile_path_distance < e_use_tile_path_distance and not s_use_tile_in_room then
          --South tile
          grim_use_tile_x = hole_x
          grim_use_tile_y = hole_y + 1
        else
          --East tile
          grim_use_tile_x = hole_x + 1
          grim_use_tile_y = hole_y
          east_tile_used = 1
        end
      end
    
      --The Grim Reaper then walks to his hole tile where he will stand waiting for the patient to walk into the lava hole.
      humanoid.grim_reaper:queueAction({name = "walk",
                                        x = grim_use_tile_x,
                                        y = grim_use_tile_y,
                                        no_truncate = true})
      humanoid.grim_reaper:queueAction({name = "idle", loop_callback = 
                                                      --[[persistable:reaper_wait]]function() 
                                                           humanoid.grim_reaper:setAnimation(1002, east_tile_used) 
                                                           humanoid:setTimer(1, action_die_tick_reaper) 
                                                         end})
    end
  --2: When the Grim Reaper has walked up to the lava hole, there will be a brief pause before the patient stands up:
  elseif phase == 2 then
    action.phase = 3 
    humanoid:setTimer(20, action_die_tick_reaper)
  
--  -- 3: The dead patient will now stand up:
  elseif phase == 3 then
    action.phase = 4
    humanoid:setTimer(humanoid.world:getAnimLength(humanoid.die_anims.rise_hell_east), action_die_tick_reaper)
    humanoid:setAnimation(humanoid.die_anims.rise_hell_east, mirror)
  
  --4: The dead patient will now walk in to the lava pool, falling in as the grim reaper does his "sending patient to hell" animation:  
  elseif phase == 4 then
    -- If Grim on south tile then mirror = false:
    local east_tile_used = 0
    if humanoid.grim_reaper.tile_x == humanoid.grim_reaper.lava_hole.tile_x + 1 then
      east_tile_used = 1
    end
    
    --The Grim Reaper's final actions:
    humanoid.grim_reaper:queueAction({name = "idle",
                                      count = humanoid.grim_reaper.world:getAnimLength(1670),
                                      loop_callback = 
                                      --[[persistable:reaper_swipe]]function() 
                                          humanoid.grim_reaper:setAnimation(1670,east_tile_used) 
                                        end})
   
    humanoid.grim_reaper:queueAction({name = "idle",
                                      count = humanoid.grim_reaper.world:getAnimLength(1678),
                                      loop_callback = 
                                      --[[persistable:reaper_leave]]function() 
                                          humanoid.grim_reaper:setAnimation(1678,east_tile_used) 
                                        end})
                                                      
    humanoid.grim_reaper:queueAction({name = "idle",
                                      loop_callback = 
                                      --[[persistable:reaper_destroy]]function() 
                                          humanoid.grim_reaper.lava_hole:setFlagA(false)
                                          humanoid.grim_reaper.lava_hole:setTimer(humanoid.grim_reaper.lava_hole.world:getAnimLength(2552),
                                                                                  --[[persistable:lava_destroy]]function() 
                                                                                    humanoid.world:destroyEntity(humanoid.grim_reaper.lava_hole) 
                                                                                  end)
                                          humanoid.grim_reaper.lava_hole:setAnimation(2552)
                                          humanoid.grim_reaper.world:destroyEntity(humanoid.grim_reaper) 
                                        end})
    
    -- Decide which use tile the patient will use:
    local use_tile_x = nil
    local use_tile_y = nil
    
    local n_use_tile_path_distance = humanoid.world:getPathDistance(humanoid.tile_x, 
                                                                    humanoid.tile_y, 
                                                                    humanoid.grim_reaper.lava_hole.tile_x, 
                                                                    humanoid.grim_reaper.lava_hole.tile_y - 1)
    
    local w_use_tile_path_distance = humanoid.world:getPathDistance(humanoid.tile_x, 
                                                                    humanoid.tile_y, 
                                                                    humanoid.grim_reaper.lava_hole.tile_x - 1, 
                                                                    humanoid.grim_reaper.lava_hole.tile_y)
                                                                    
    local n_use_tile_in_room = humanoid.world:getRoom(humanoid.grim_reaper.lava_hole.tile_x, humanoid.grim_reaper.lava_hole.tile_y - 1) ~= nil
    
    if n_use_tile_path_distance == false then
      -- West tile
      use_tile_x = humanoid.grim_reaper.lava_hole.tile_x - 1
      use_tile_y = humanoid.grim_reaper.lava_hole.tile_y
    elseif w_use_tile_path_distance == false then
      --North tile
      use_tile_x = humanoid.grim_reaper.lava_hole.tile_x
      use_tile_y = humanoid.grim_reaper.lava_hole.tile_y - 1  
    else
      if n_use_tile_path_distance < w_use_tile_path_distance and not n_use_tile_in_room then
        --North tile
        use_tile_x = humanoid.grim_reaper.lava_hole.tile_x
        use_tile_y = humanoid.grim_reaper.lava_hole.tile_y - 1
      else
        --West tile
        use_tile_x = humanoid.grim_reaper.lava_hole.tile_x - 1
        use_tile_y = humanoid.grim_reaper.lava_hole.tile_y
      end
    end
    
    --Give the patient their final actions:
    humanoid:walkTo(use_tile_x, use_tile_y, true)
    humanoid:queueAction({name = "use_object", 
                          object = humanoid.grim_reaper.lava_hole,
                          destroy_user_after_use = true,
                          after_walk_in = 
                          --[[persistable:walk_into_lava]]function() 
                              humanoid.grim_reaper:finishAction() 
                            end})
    humanoid:finishAction()
  end	          
end)
 
local function action_die_start(action, humanoid)
  humanoid:setMoodInfo() -- clear all mood icons
  if math.random(0, 1) == 1 then
    humanoid.last_move_direction = "east"
  else
    humanoid.last_move_direction = "south"
  end
  local direction = humanoid.last_move_direction
  local anims = humanoid.die_anims
  assert(anims, "Error: no death animation for humanoid ".. humanoid.humanoid_class)
  action.must_happen = true
  -- TODO: Right now the angel version of death is the only possibility
  -- The Grim Reaper should sometimes also have a go.
  local fall = anims.fall_east
  
  --If this isn't done their bald head will become bloated instead of suddenly having hair:
  if humanoid.disease.id == "baldness" then humanoid:setLayer(0,2) end
 
  if direction == "east" then
    humanoid:setAnimation(anims.fall_east, 0)
  elseif direction == "south" then
    humanoid:setAnimation(anims.fall_east, 1)
  end
  action.phase = 0

  if humanoid:isMalePatient() and humanoid.disease.id ~= "bloaty_head" then
    if math.random(1, 100) <= 65 then
      humanoid:setTimer(humanoid.world:getAnimLength(fall), action_die_tick_reaper)
    else
      humanoid:setTimer(humanoid.world:getAnimLength(fall), action_die_tick_reaper)
    end
  else
    humanoid:setTimer(humanoid.world:getAnimLength(fall), action_die_tick)
  end
end

return action_die_start
