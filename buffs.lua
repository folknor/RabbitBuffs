_G.MINUTE_ONELETTER_ABBR = "|cffffffff%dm|r"
_G.HOUR_ONELETTER_ABBR = "|cffffffff%dh|r"
_G.DAY_ONELETTER_ABBR = "|cffffffff%dd|r"
_G.SECOND_ONELETTER_ABBR = "|cffffffff%d|r"

local glosstex1 = "Interface\\AddOns\\rActionButtonStyler\\media\\gloss"
local glosstex2 = "Interface\\AddOns\\rActionButtonStyler\\media\\gloss_grey"

local function anchorToTempEnchants(self)
	if not self:IsShown() then return end
	local main, _, _, off = GetWeaponEnchantInfo()
	self:ClearAllPoints()
	if main and off then
		self:SetPoint("TOPRIGHT", TempEnchant2, "TOPLEFT", -5, 0)
	elseif main or off then
		self:SetPoint("TOPRIGHT", TempEnchant1, "TOPLEFT", -5, 0)
	elseif not main and not off then
		self:SetPoint("TOPRIGHT", TempEnchant1)
	end
end

TemporaryEnchantFrame:ClearAllPoints()
TemporaryEnchantFrame:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -17, 0)
TemporaryEnchantFrame.SetPoint = function() end

TempEnchant2:ClearAllPoints()
TempEnchant2:SetPoint("TOPRIGHT", TempEnchant1, "TOPLEFT", -5, 0)

for i = 1, 2 do
	local icon = _G["TempEnchant"..i.."Icon"]
	icon:SetTexCoord(0.03, 0.97, 0.03, 0.97)
end
--[[
do
	local total = 0
	BuffFrame:SetScript("OnUpdate", function(self, elapsed)
		total = total + elapsed
		if total > TOOLTIP_UPDATE_TIME then
			total = 0
			anchorToTempEnchants(BuffButton1)
		end
	end)
end]]

BuffFrame_UpdateAllBuffAnchors = function()
	local previousBuff, aboveBuff
	local index = 0

	for i = 1, BUFF_ACTUAL_DISPLAY do
		local buff = _G["BuffButton"..i]


		if buff.consolidated then
			if buff.parent == BuffFrame then
				buff:SetParent(ConsolidatedBuffsContainer)
				buff.parent = ConsolidatedBuffsContainer
			end
		else
			if buff.parent ~= BuffFrame then
				buff.count:SetFontObject(NumberFontNormal)
				buff:SetParent(BuffFrame)
				buff.parent = BuffFrame
			end
			index = index + 1
			buff:ClearAllPoints()
			if index > 1 and mod(index, BUFFS_PER_ROW) == 1 then
				if index == BUFFS_PER_ROW + 1 then
					buff:SetPoint("TOP", TempEnchant1, "BOTTOM", 0, -BUFF_ROW_SPACING)
				else
					buff:SetPoint("TOP", aboveBuff, "BOTTOM", 0, -BUFF_ROW_SPACING)
				end
				aboveBuff = buff
			elseif index == 1 then
				anchorToTempEnchants(buff)
			else
				buff:SetPoint("RIGHT", previousBuff, "LEFT", -5, 0)
			end
			previousBuff = buff
		end
	end

	ConsolidatedBuffs:ClearAllPoints()
	ConsolidatedBuffs:SetPoint("TOPLEFT", Minimap, -10, 10)
	ConsolidatedBuffsIcon:SetAlpha(0)

	TemporaryEnchantFrame:ClearAllPoints()
	TemporaryEnchantFrame:SetPoint("TOPRIGHT", -22, -180)

	if ConsolidatedBuffsTooltip:IsShown() then
		ConsolidatedBuffs_UpdateAllAnchors()
	end
end

DebuffButton_UpdateAnchors = function(buttonName, index)
	local numBuffs = BUFF_ACTUAL_DISPLAY + BuffFrame.numEnchants - BuffFrame.numConsolidated
	local rows = ceil(numBuffs/BUFFS_PER_ROW);
	local buff = _G[buttonName..index];
	local buffHeight = TempEnchant1:GetHeight();

	-- Position debuffs
	if index > 1 and mod(index, BUFFS_PER_ROW) == 1 then
		-- New row
		buff:SetPoint("TOP", _G[buttonName..(index - BUFFS_PER_ROW)], "BOTTOM", 0, -BUFF_ROW_SPACING);
	elseif index == 1 then
		buff:SetPoint("TOPRIGHT", TempEnchant1, "BOTTOMRIGHT", 0, -rows*(BUFF_ROW_SPACING+buffHeight));
	else
		buff:SetPoint("RIGHT", _G[buttonName..(index-1)], "LEFT", -5, 0);
	end
end

local addon = CreateFrame("Frame")

addon:SetScript("OnEvent", function(self, event, unit)
	if event=="PLAYER_ENTERING_WORLD" then
		addon:runthroughicons()
	elseif event == "UNIT_AURA" and unit == PlayerFrame.unit then
		addon:runthroughicons()
	end
end)

function addon:runthroughicons()
	local i = 1
	while _G["BuffButton"..i] do
		addon:checkgloss("BuffButton"..i, 1)
		i = i + 1
	end
	i = 1
	while _G["DebuffButton"..i] do
		addon:checkgloss("DebuffButton"..i, 2)
		i = i + 1
	end
	i = 1
	while _G["TempEnchant"..i] do
		addon:checkgloss("TempEnchant"..i, 3)
		i = i + 1
	end
end

function addon:checkgloss(name,icontype)
	local b = _G[name.."Border"]
	local i = _G[name.."Icon"]
	local f = _G[name]
	local c = _G[name.."Gloss"]

	if not c then
		local fg = CreateFrame("Frame", name.."Gloss", f)
		fg:SetAllPoints(f)

		local t = f:CreateTexture(name.."GlossTexture","ARTWORK")
		t:SetTexture(glosstex1)
		t:SetAllPoints(fg)

		i:SetTexCoord(0.1,0.9,0.1,0.9)
		i:SetPoint("TOPLEFT", fg, 2, -2)
		i:SetPoint("BOTTOMRIGHT", fg, -2, 2)

		local back = f:CreateTexture(nil, "BACKGROUND")
		back:SetPoint("TOPLEFT", i, -5, 5)
		back:SetPoint("BOTTOMRIGHT", i, 5, -5)
		back:SetTexture("Interface\\AddOns\\RabbitTextures\\simplesquare_glow")
		back:SetVertexColor(0, 0, 0, 1)
	end

	local tex = _G[name.."GlossTexture"]

	if icontype == 2 and b then
		local red, green, blue = b:GetVertexColor()
		tex:SetTexture(glosstex2)
		tex:SetVertexColor(red*0.5, green*0.5, blue*0.5)
	elseif icontype == 3 and b then
		tex:SetTexture(glosstex2)
		tex:SetVertexColor(0.5,0,0.5)
	else
		tex:SetTexture(glosstex1)
		tex:SetVertexColor(0.47,0.4,0.4)
	end

	if b then b:SetAlpha(0) end
end

addon:RegisterEvent("UNIT_AURA")
addon:RegisterEvent("PLAYER_ENTERING_WORLD")

