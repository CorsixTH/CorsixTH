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

local pathsep = package.config:sub(1, 1)

--! Custom Campaign Window
class "UICustomCampaign" (UIMenuList)

---@type UICustomCampaign
local UICustomCampaign = _G["UICustomCampaign"]

local col_scrollbar = {
  red = 164,
  green = 156,
  blue = 208,
}

local max_details_rows = 14
local details_width = 280

function UICustomCampaign:UICustomCampaign(ui)
  self.label_font = TheApp.gfx:loadFont("QData", "Font01V")

  local local_path = debug.getinfo(1, "S").source:sub(2, -61)
  local dir = "Campaigns" .. pathsep
  local path = local_path .. dir

  local campaigns = self:createCampaignList(path)

  self:UIMenuList(ui, "menu", _S.custom_campaign_window.caption, campaigns, 10, details_width + 40)

  -- Create a toolbar ready to be used if the description for a level is
  -- too long to fit
  local scrollbar_base = self:addBevelPanel(560, 40, 20, self.num_rows*17, self.col_bg)
  scrollbar_base.lowered = true
  self.details_scrollbar = scrollbar_base:makeScrollbar(col_scrollbar, --[[persistable:campaign_details_scrollbar_callback]] function()
    self:updateDescriptionOffset()
  end, 1, 1, self.num_rows)

  self.description_offset = 0

  -- Finally the load button
  self:addBevelPanel(420, 220, 160, 40, self.col_bg)
    :setLabel(_S.custom_campaign_window.start_selected_campaign)
    :makeButton(0, 0, 160, 40, 11, self.buttonStartCampaign)
    :setTooltip(_S.tooltip.custom_campaign_window.start_selected_campaign)
end

function UICustomCampaign:createCampaignList(path)
  local campaigns = {}

  for file in lfs.dir(path) do
    if file:match"%.campaign$" then
      local campaign_info, err = TheApp:readCampaignFile(file)
      if not campaign_info then
        print(err)
      else
        if campaign_info.levels and #campaign_info.levels > 0 then
          campaigns[#campaigns + 1] = {
            name = campaign_info.name,
            tooltip = _S.tooltip.custom_campaign_window.choose_campaign,
            no_levels = #campaign_info.levels,
            path = file,
            description = campaign_info.description,
          }
        else
          print("Warning: Loaded campaign that had no levels specified")
        end
      end
    end
  end
  return campaigns
end

-- Overrides the function in the UIMenuList, choosing what should happen when the player
-- clicks a choice in the list.
function UICustomCampaign:buttonClicked(num)
  local item = self.items[num + self.scrollbar.value - 1]
  self.chosen_item = item
  if item.description then
    local x, y, rows = self.label_font:sizeOf(item.description, details_width)
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
  x, y = self.x + x, self.y + y

  if self.chosen_item and self.chosen_item.name then
    self.label_font:drawWrapped(canvas, self.chosen_item.name,
                                x + 270, y + 10, details_width)
    self.label_font:drawWrapped(canvas, "(levels: " ..
        self.chosen_item.no_levels .. ")", x+ 270, y + 22, details_width)
  end
  if self.chosen_item and self.chosen_item.description then
    self.label_font:drawWrapped(canvas, self.chosen_item.description,
              x + 270, y + 40, details_width, nil, 13, self.description_offset)
  end
end
