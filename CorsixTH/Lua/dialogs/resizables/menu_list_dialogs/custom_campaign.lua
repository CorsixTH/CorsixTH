--[[ Copyright (c) 2014 Edvin "Lego3" Linge

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

--! Custom Campaign Window
class "UICustomCampaign" (UIMenuList)

---@type UICustomCampaign
local UICustomCampaign = _G["UICustomCampaign"]

local col_scrollbar = {
  red = 164,
  green = 156,
  blue = 208,
}

local details_width = 280

function UICustomCampaign:UICustomCampaign(ui)
  self.label_font = TheApp.gfx:loadFontAndSpriteTable("QData", "Font01V", nil, nil, { apply_ui_scale = true })

  self.unique_names, self.campaigns, self.duplicates = {}, {}, 0
  self.paths_table = {ui.app.campaign_dir, ui.app.user_campaign_dir}
  self:_createCampaignList()
  local campaign_count = self.duplicates > 0 and 9 or 10
  table.sort(self.campaigns, function(a,b) return a.name < b.name end)

  self:UIMenuList(ui, "menu", _S.custom_campaign_window.caption, self.campaigns, campaign_count, details_width + 40)

  -- Create a toolbar ready to be used if the description for a level is
  -- too long to fit
  local scrollbar_base = self:addBevelPanel(560, 40, 20, self.num_rows*17, self.col_bg)
  scrollbar_base.lowered = true
  self.details_scrollbar = scrollbar_base:makeScrollbar(col_scrollbar, --[[persistable:campaign_details_scrollbar_callback]] function()
    self:updateDescriptionOffset()
  end, 1, 1, self.num_rows)

  self.description_offset = 0

  -- Warn about hidden duplicate campaigns
  if self.duplicates > 0 then
    self:addBevelPanel(100, 195, 400, 20, self.col_bg)
      :setLabel(_S.custom_campaign_window.duplicates_warning:format(self.duplicates))
      :setTooltip(_S.tooltip.custom_campaign_window.duplicates_warning).lowered = true
  end

  -- Finally the load button
  self:addBevelPanel(420, 220, 160, 40, self.col_bg)
    :setLabel(_S.custom_campaign_window.start_selected_campaign)
    :makeButton(0, 0, 160, 40, 11, self.buttonStartCampaign)
    :setTooltip(_S.tooltip.custom_campaign_window.start_selected_campaign)
end

--! Fetch uniquely named campaigns from given campaign file
function UICustomCampaign:_readCampaignFile(folder, file)
  local full_path = folder .. file
  local campaign_info, err = TheApp:readCampaignFile(full_path)
  if not campaign_info then
    print(err)
  else
    local name = campaign_info.name
    if self.unique_names[name] then
      print("Custom campaign error: duplicate campaign name in file " .. file ..
          ". Check the folders " .. table.concat(self.paths_table, ", "))
      self.duplicates = self.duplicates + 1
    elseif campaign_info.levels and #campaign_info.levels > 0 then
      self.campaigns[#self.campaigns + 1] = {
        name = name,
        tooltip = _S.tooltip.custom_campaign_window.choose_campaign,
        no_levels = #campaign_info.levels,
        path = full_path,
        description = TheApp.strings:getLocalisedText(campaign_info.description,
           campaign_info.description_table)
      }
      self.unique_names[name] = true
    else
      print("Warning: Loaded campaign that had no levels specified")
    end
  end
end

--! Search the user and CorsixTH campaign folders and one-level deep subfolders for campaign files.
function UICustomCampaign:_createCampaignList()
  -- Find all campaign files in given folders and their subfolders (one level deep)
  for _, folder in ipairs(self.paths_table) do
    for item in lfs.dir(folder) do
      local path = folder .. item
      if lfs.attributes(path, "mode") == "directory" and not item:match("^%.") then
        for file in lfs.dir(path) do -- Check subfolders
          if file:match("%.campaign$") then
            self:_readCampaignFile(path .. package.config:sub(1, 1), file)
          end
        end
      elseif path:match("%.campaign$") then
        self:_readCampaignFile(folder, item)
      end
    end
  end
end

function UICustomCampaign:updateDescriptionOffset()
  self.description_offset = self.details_scrollbar.value - 1
end

-- Overrides the function in the UIMenuList, choosing what should happen when the player
-- clicks a choice in the list.
function UICustomCampaign:buttonClicked(num)
  local item = self.items[num + self.scrollbar.value - 1]
  self.chosen_item = item
  if item.description then
    local _, _, rows = self.label_font:sizeOf(item.description, details_width * TheApp.config.ui_scale)
    self.details_scrollbar:setRange(1, rows, 13, 1)
  else
    self.details_scrollbar:setRange(1, 13, 13, 1)
  end
  self.description_offset = 0
end

function UICustomCampaign:buttonStartCampaign()
  if self.chosen_item then
    TheApp:loadCampaign(self.chosen_item.path)
  end
end

function UICustomCampaign:draw(canvas, x, y)
  UIMenuList.draw(self, canvas, x, y)
  local s = TheApp.config.ui_scale
  x, y = self.x * s + x, self.y * s + y

  if self.chosen_item and self.chosen_item.name then
    self.label_font:drawWrapped(canvas, self.chosen_item.name,
                                x + 270 * s, y + 10 * s, details_width * s)
    self.label_font:drawWrapped(canvas, "(levels: " ..
        self.chosen_item.no_levels .. ")", x + 270 * s, y + 22 * s, details_width * s)
  end
  if self.chosen_item and self.chosen_item.description then
    self.label_font:drawWrapped(canvas, self.chosen_item.description,
              x + 270 * s, y + 40 * s, details_width * s, nil, 13, self.description_offset)
  end
end
