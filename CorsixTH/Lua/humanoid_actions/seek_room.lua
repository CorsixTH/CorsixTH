--[[ Copyright (c) 2009 Peter "Corsix" Cawley

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

local function action_seek_room_find_room(action, humanoid)
  local room_type = action.room_type
  if action.diagnosis_room then
    local tried_rooms = 0
    -- Make numbers for each available diagnosis room. A random index from this list will be chosen,
    -- and then the corresponding room index is taken as next room. (The list decrease for each room
    -- missing)
    local available_rooms = {}
    local room_at_index
    for i=1, #humanoid.available_diagnosis_rooms do
      available_rooms[i] = i
    end
    while tried_rooms < #humanoid.available_diagnosis_rooms do
      -- Choose a diagnosis room from the list at random. Note: This ignores the initial diagnosis room!
      room_at_index = math.random(1,#available_rooms)
      room_type = humanoid.available_diagnosis_rooms[available_rooms[room_at_index]]
      -- Try to find the room
      local room = humanoid.world:findRoomNear(humanoid, room_type, nil, "advanced")
      if room then
        return room
      else
        tried_rooms = tried_rooms + 1
        -- Remove the index of this room from the list of indeces available in available_diagnosis_rooms
        table.remove(available_rooms, room_at_index)
        -- If the room can be built, set the flag for it.
        local diag = humanoid.world.available_rooms[room_type]
        if diag and humanoid.hospital.discovered_rooms[diag] then
          action.diagnosis_exists = room_type
        end
      end
    end
    -- No room found. If the last room to be checked was one that is not yet discovered
    -- but another one exists that can be built, return to that one.
    if not humanoid.world.available_rooms[room_type] and action.diagnosis_exists then
      action.room_type = action.diagnosis_exists
    end
    return nil
  elseif action.treatment_room then
    -- Treatment rooms etc either exist, or they don't.
    -- However, if many rooms are needed to treat the patient they all need to be available.
    -- Example: ward + operating theatre.
    for _, rooms in pairs(humanoid.disease.treatment_rooms) do
      if not humanoid.world:findRoomNear(humanoid, rooms, nil, "advanced") then
        action.room_type_needed = rooms
        return nil
      end
    end
  end
  return humanoid.world:findRoomNear(humanoid, room_type, nil, "advanced")
end

local action_seek_room_goto_room = permanent"action_seek_room_goto_room"( function(room, humanoid, diagnosis_room)
  humanoid:setMood("patient_wait", "deactivate")
  humanoid.waiting = nil
  humanoid.message_callback = nil
  humanoid:setNextAction(room:createEnterAction(humanoid))
  humanoid.next_room_to_visit = room
  humanoid:updateDynamicInfo(_S.dynamic_info.patient.actions.on_my_way_to
    :format(room.room_info.name))
  room.door.queue:expect(humanoid)
  room.door:updateDynamicInfo()
  if not room:testStaffCriteria(room:getRequiredStaffCriteria()) then
    humanoid.world.dispatcher:callForStaff(room)
  end
  if diagnosis_room then
    -- The diagnosis room was found, remove it from the list
    table.remove(humanoid.available_diagnosis_rooms, diagnosis_room)
  end
end)

local function action_seek_room_no_treatment_room_found(room_type, humanoid)
  -- Emergency patients also don't need to ask what to do, they'll just wait for the player
  -- to build the necessary room.
  if humanoid.is_emergency then
    return
  end
  -- Wait two months before going home anyway.
  humanoid.waiting = 60
  local strings = _S.fax.disease_discovered_patient_choice
  -- Can this room be built right now? What is then missing?
  -- TODO: Change to make use of Hospital:checkDiseaseRequirements
  local output_text = strings.can_not_cure
  -- TODO: can we really assert this? Or should we just make the patient go home?
  local room = assert(humanoid.world.available_rooms[room_type], "room " .. room_type .. " not available")

  local room_discovered = false
  if humanoid.hospital.discovered_rooms[room] then
    room_discovered = true
    local room_name, required_staff, staff_name = humanoid.world:getRoomNameAndRequiredStaffName(room_type)
    if humanoid.hospital:hasStaffOfCategory(required_staff) then
      output_text = strings.need_to_build:format(room_name)
    else
      output_text = strings.need_to_build_and_employ:format(room_name, staff_name)
    end
  end
  local research_enabled = not room_discovered and humanoid.hospital:hasRoomOfType("research")
  local message = {
    {text = strings.disease_name:format(humanoid.disease.name)},
    {text = " "},
    {text = output_text},
    {text = strings.what_to_do_question},
    choices = {
      {text = strings.choices.send_home, choice = "send_home"},
      {text = strings.choices.wait,      choice = "wait"},
      {text = strings.choices.research,  choice = "research", enabled = research_enabled},
    },
  }
  -- Ok, send the message in all channels.
  TheApp.ui.bottom_panel:queueMessage("information", message, humanoid)
  humanoid:setMood("patient_wait", "activate")
  humanoid:updateDynamicInfo(_S.dynamic_info.patient.actions.awaiting_decision)
end

local function action_seek_room_no_diagnosis_room_found(action, humanoid)
   --If it's the VIP then there's been an explosion. Skip the exploded room
  if humanoid.humanoid_class == "VIP" then
    humanoid.waiting = 1
    return
  end

  -- If none of the diagnosis rooms can be built yet, go home anyway.
  -- Otherwise, depending on hospital policy three things can happen:
  if humanoid.diagnosis_progress < humanoid.hospital.policies["send_home"] then
    -- Send home automatically
    humanoid:goHome("kicked")
    humanoid:updateDynamicInfo(_S.dynamic_info.patient.actions.no_diagnoses_available)
  elseif humanoid.diagnosis_progress < humanoid.hospital.policies["guess_cure"]
    or not humanoid.hospital.disease_casebook[humanoid.disease.id].discovered then
    -- If the disease hasn't been discovered yet it cannot be guessed, go here instead.
    -- Ask the player
    -- Wait two months before going home anyway.
    humanoid:setMood("patient_wait", "activate")
    humanoid.waiting = 60
    local guess_enabled = humanoid.hospital.disease_casebook[humanoid.disease.id].discovered
    local message = {
      {text = _S.fax.diagnosis_failed.situation},
      {text = " "},
      {text = _S.fax.diagnosis_failed.what_to_do_question},
      choices = {
        {text = _S.fax.diagnosis_failed.choices.send_home,   choice = "send_home"},
        {text = _S.fax.diagnosis_failed.choices.take_chance, choice = "guess_cure", enabled = guess_enabled},
        {text = _S.fax.diagnosis_failed.choices.wait,        choice = "wait"},
      },
    }
    if guess_enabled then
      table.insert(message, 3, {text = _S.fax.diagnosis_failed.partial_diagnosis_percentage_name
        :format(math.round(humanoid.diagnosis_progress*100), humanoid.disease.name)})
    end
    TheApp.ui.bottom_panel:queueMessage("information", message, humanoid)
    humanoid:updateDynamicInfo(_S.dynamic_info.patient.actions.awaiting_decision)
    -- This seek_room action will be reused, return that it's valid.
    return true
  else
    -- Guess "type of disease" automatically.
    -- A patient with an undiscovered disease should never get here.
    assert(humanoid.hospital.disease_casebook[humanoid.disease.id].discovered)
    humanoid:setDiagnosed(true)
    humanoid:queueAction({
      name = "seek_room",
      room_type = humanoid.disease.treatment_rooms[1],
      treatment_room = true,
    }, 1)
    humanoid:finishAction()
  end
end

local action_seek_room_interrupt = permanent"action_seek_room_interrupt"( function(action, humanoid)
  humanoid:setMood("patient_wait", "deactivate")
  -- Just in case we are somehow started again:
  -- FIXME: This seems to be used for intermediate actions like peeing while the patient is waiting
  --        Unfortunately this means that if you finish the required room while the patient is peeing
  --        the callback does not happen, meaning that the message does not disappear.
  humanoid:unregisterRoomBuildCallback(action.build_callback)
  humanoid:unregisterRoomRemoveCallback(action.remove_callback)
  action.build_callback = nil
  action.remove_callback = nil
  action.done_init = false
  humanoid:finishAction()
end)

local function action_seek_room_start(action, humanoid)
  if action.todo_interrupt then
    humanoid:finishAction()
    return
  end
  -- Seeking for toilets is a special case with its own action.
  if action.room_type == "toilets" then
    humanoid:queueAction({name = "seek_toilets"}, 1)
    humanoid:finishAction()
    return
  end
  -- Tries to find the room, if it is a diagnosis room, try to find any room in the diagnosis list.
  local room = action_seek_room_find_room(action, humanoid)

  if room then
    action_seek_room_goto_room(room, humanoid, action.diagnosis_room)
  else
    if not action.done_init then
      action.done_init = true
      action.must_happen = true

      local remove_callback = --[[persistable:action_seek_room_remove_callback]] function(room)
        if room.room_info.id == "research" then
          humanoid:updateMessage("research")
        end
      end -- End of remove_callback function
      action.remove_callback = remove_callback
      humanoid:registerRoomRemoveCallback(remove_callback)

      local build_callback
      build_callback = --[[persistable:action_seek_room_build_callback]] function(room)
        -- if research room was built, message may need to be updated
        if room.room_info.id == "research" then
          humanoid:updateMessage("research")
        end

        local found = false
        if room.room_info.id == action.room_type then
          found = true
        elseif room.room_info.id == action.room_type_needed then
          -- So the room that we're going to is not actually the room we waited for to be built.
          -- Example: Will go to ward, but is waiting for the operating theatre.
          -- Clean up and start over to find the room we actually want to go to.
          TheApp.ui.bottom_panel:removeMessage(humanoid)
          humanoid:unregisterRoomBuildCallback(build_callback)
          humanoid:unregisterRoomRemoveCallback(remove_callback)
          action.room_type_needed = nil
          action_seek_room_start(action, humanoid)
        elseif not humanoid.diagnosed then
          -- Waiting for a diagnosis room, we need to go through the list - unless it is gp
          if action.room_type ~= "gp" then
            for i = 1, #humanoid.available_diagnosis_rooms do
              if humanoid.available_diagnosis_rooms[i].id == room.room_info.id then
                found = true
              end
            end
          end
        end
        if found then
          action_seek_room_goto_room(room, humanoid, action.diagnosis_room)
          TheApp.ui.bottom_panel:removeMessage(humanoid)
          humanoid:unregisterRoomBuildCallback(build_callback)
          humanoid:unregisterRoomRemoveCallback(remove_callback)
        end
      end -- End of build_callback function
      action.build_callback = build_callback
      humanoid:registerRoomBuildCallback(build_callback)

      action.on_interrupt = action_seek_room_interrupt
    end

    -- Things needed to get the patient to the correct room in due time are done. Now it's
    -- time to let the player know about it too.
    -- If done_walk is set the meander action that takes place after not finding any room has been
    -- done = nothing more to do right now.
    if not action.done_walk then
      local action_still_valid = true
      if not action.message_sent then
        -- Make a message about that something needs to be done about this patient
        if humanoid.diagnosed then
          -- The patient is diagnosed, a treatment room is missing.
          -- It may happen that it is another room in a series which is missing.
          local room_to_find = action.room_type_needed and action.room_type_needed or action.room_type
          action_seek_room_no_treatment_room_found(room_to_find, humanoid)
        else
          -- No more diagnosis rooms can be found
          -- The GP's office is a special case. TODO: Make a custom message anyway?
          if action.room_type == "gp" then
            humanoid:setMood("patient_wait", "activate")
            humanoid:updateDynamicInfo(_S.dynamic_info.patient.actions.no_gp_available)
          else
            action_still_valid = action_seek_room_no_diagnosis_room_found(action, humanoid)
          end
        end
      end
      if action_still_valid then
        action.done_walk = true
        humanoid:queueAction({name = "meander", count = 1, must_happen = true}, 0)
      end
    else
      -- Make sure the patient stands in a correct way as he/she is waiting.
      local direction = humanoid.last_move_direction
      local anims = humanoid.walk_anims
      if direction == "north" then
        humanoid:setAnimation(anims.idle_north, 0)
      elseif direction == "east" then
        humanoid:setAnimation(anims.idle_east, 0)
      elseif direction == "south" then
        humanoid:setAnimation(anims.idle_east, 1)
      elseif direction == "west" then
        humanoid:setAnimation(anims.idle_north, 1)
      end
      humanoid:setTilePositionSpeed(humanoid.tile_x, humanoid.tile_y)
    end
  end
end

return action_seek_room_start
