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

local action_seek_room_interrupt = permanent"action_seek_room_interrupt"( function(action, humanoid)
  humanoid:setMood("patient_wait", nil)
  humanoid.world:unregisterRoomBuildCallback(action.build_callback)
  humanoid:finishAction()
end)

local function action_seek_room_start(action, humanoid)
  local room = humanoid.world:findRoomNear(humanoid, action.room_type, nil, "advanced")
  if not room and action.diagnosis_room then
    -- Go through the diagnosis rooms, maybe there's one of another type?
    if not action.tried_rooms then
      action.tried_rooms = {}
    end
    action.tried_rooms[action.diagnosis_room] = true
    if #action.tried_rooms >= #humanoid.available_diagnosis_rooms then
      -- No room could be found, we will have to wait.
      humanoid:setNextAction{
        name = "seek_room", 
        room_type = humanoid.available_diagnosis_rooms[1],
      }
    else
      while action.tried_rooms[action.next_to_try] do
        -- TODO: Not good, this could theoretically take forever
        action.next_to_try = math.random(1, #humanoid.available_diagnosis_rooms)
      end
      action.room_type = humanoid.available_diagnosis_rooms[action.next_to_try]
      action.diagnosis_room = action.next_to_try
      humanoid:setNextAction(action)
    end
  elseif room then
    humanoid:setNextAction(room:createEnterAction())
    humanoid.next_room_to_visit = room
    humanoid:updateDynamicInfo()
    room.door.queue:expect(humanoid)
    room.door:updateDynamicInfo()
    if not room:testStaffCriteria(room:getRequiredStaffCriteria()) then
      humanoid.world:callForStaff(room)
    end
    if action.diagnosis_room then
      -- The diagnosis room was found, remove it from the list
      table.remove(humanoid.available_diagnosis_rooms, action.diagnosis_room)
    end
  else
    if not action.done_init then
      action.done_init = true
      action.must_happen = true
      action.build_callback = --[[persistable:action_seek_room_build_callback]] function(room)
        local found = false
        if room.room_info.id == action.room_type then
          found = true
        end
        if not humanoid.diagnosed then
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
          humanoid:setNextAction(room:createEnterAction())
          humanoid.next_room_to_visit = room
          humanoid:updateDynamicInfo()
        end
      end
      humanoid.world:registerRoomBuildCallback(action.build_callback)
      action.on_interrupt = action_seek_room_interrupt
    end
    if not action.done_walk and not action.got_answer then
      -- Make a message about that something needs to be done about this patient
      if humanoid.diagnosed then
        -- The patient is diagnosed, a treatment room is missing
        -- Wait two months before going home anyway.
        humanoid.waiting = 60
        local room_name, required_staff, staff_name
        for _, room in ipairs(TheApp.rooms) do
          if room.id == action.room_type then
            room_name = room.name
            required_staff = room.required_staff
          end
        end
        for key, _ in pairs(required_staff) do
          staff_name = key
        end
        local output_text = _S.fax.disease_discovered_patient_choice.need_to_build:format(room_name)
        if not humanoid.hospital:hasStaffOfCategory(staff_name) then
          if staff_name == "Nurse" then
            staff_name = _S.staff_title.nurse
          elseif staff_name == "Psychiatrist" then
            staff_name = _S.staff_title.psychiatrist
          elseif staff_name == "Researcher" then
            staff_name = _S.staff_title.researcher
          elseif staff_name == "Surgeon" then
            staff_name = _S.staff_title.surgeon
          end
          output_text = _S.fax.disease_discovered_patient_choice.need_to_build_and_employ:format(room_name, staff_name)
        end
        -- TODO: In the future the treatment room might be unavailable
        local message = {
          {text = _S.fax.disease_discovered_patient_choice.disease_name:format(humanoid.disease.name)},
          {text = output_text},
          {text = _S.fax.disease_discovered_patient_choice.what_to_do_question},
          choices = {
            {text = _S.fax.disease_discovered_patient_choice.choices.send_home, choice = "send_home", offset = 50},
            {text = _S.fax.disease_discovered_patient_choice.choices.wait,      choice = "wait",      offset = 40},
            {text = _S.fax.disease_discovered_patient_choice.choices.research,  choice = "disabled",  offset = 40}, -- TODO: research
          },
        }
        TheApp.ui.bottom_panel:queueMessage("information", message, humanoid)
        humanoid:setMood("patient_wait", true)
        humanoid:updateDynamicInfo(_S.dynamic_info.patient.actions.awaiting_decision)
        -- Only one message should appear.
        action.got_answer = true
      else
        -- No more diagnosis rooms can be found
        -- The GP's office is a special case. TODO: Make a custom message anyway?
        if action.room_type == "gp" then
          humanoid:setMood("patient_wait", true)
          humanoid:updateDynamicInfo(_S.dynamic_info.patient.actions.no_gp_available)
        else
          -- Now, depending on hospital policy three things can happen:
          if humanoid.diagnosis_progress < humanoid.hospital.policies["send_home"] then
            -- Send home automatically
            humanoid:goHome()
            humanoid:updateDynamicInfo(_S.dynamic_info.patient.actions.no_diagnoses_available)
          elseif humanoid.diagnosis_progress < humanoid.hospital.policies["guess_cure"] then
            -- Ask the player
            -- Wait two months before going home anyway.
            humanoid:setMood("patient_wait", true)
            humanoid.waiting = 60
            local middle_choice = "disabled"
            local more_text = ""
            if humanoid.diagnosis_progress > 0.7 then -- TODO: What value here?
              middle_choice = "guess_cure"
              more_text = _S.fax.diagnosis_failed.partial_diagnosis_percentage_name:format(humanoid.diagnosis_progress*100, humanoid.disease.name)
            end
            local message = {
              {text = _S.fax.diagnosis_failed.situation},
              {text = _S.fax.diagnosis_failed.what_to_do_question},
              choices = {
                {text = _S.fax.diagnosis_failed.choices.send_home,   choice = "send_home",   offset = 50},
                {text = _S.fax.diagnosis_failed.choices.take_chance, choice = middle_choice, offset = 40},
                {text = _S.fax.diagnosis_failed.choices.wait,        choice = "wait",        offset = 40},
              },
            }
            if more_text ~= "" then
              table.insert(message, 2, {text = more_text})
            end
            TheApp.ui.bottom_panel:queueMessage("information", message, humanoid)
            humanoid:updateDynamicInfo(_S.dynamic_info.patient.actions.awaiting_decision)
            -- Only one message should appear.
            action.got_answer = true
          else
            -- Guess "type of disease" automatically
            humanoid:setDiagnosed(true)
            humanoid:queueAction({
              name = "seek_room", 
              room_type = humanoid.disease.treatment_rooms[1]
            }, 1)
            humanoid:finishAction()
            return
          end
        end
      end
      humanoid:queueAction({name = "meander", count = 1, must_happen = true}, 0)
      action.done_walk = true
      return
    else
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
