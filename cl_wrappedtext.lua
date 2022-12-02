local PANEL = {}

function PANEL:Init()
	self.align = "center"
	self.width = self.GetParent and self:GetParent():GetWide() or 0
end

function PANEL:SetAlign(align)
	self.align = align

	local curText = self:GetText()
	if !curText then return end

	self:SetWrappedText(curText)
end

function PANEL:GetText()
	return self.text or false
end

function PANEL:SetFont(font)
	self.font = font

	local curText = self:GetText()
	if !curText then return end

	self:SetText(curText)
end

function PANEL:SetText(text)
	self.text = text

	--remove previous lines
	for _, v in pairs(self:GetChildren()) do
		v:Remove()
	end

	--some calculations
	local temp = self:Add("DLabel")
	temp:SetText(self.text)
	temp:SetFont(self.font or "mTooltip")
	temp:SizeToContents()
	temp:SetVisible(false)

	local textWidth = temp:GetWide()
	local letterCount = string.len(text)
	local letterChunks = math.floor(letterCount / (textWidth / self.width))
	local iters = math.ceil(letterCount / letterChunks)
	local _, replaces = text:gsub("\n", "\n")
	--add new line breaks
	iters = iters + replaces

	--split string in lines
	self.height = 0
	local last = 1

	for i = 1, iters do
		local part = text:sub(last, last + letterChunks-1)
		local lastSpace = 0
		local newLine = false
		local len = string.len(part)
		local startStr = string.find(part, "\n")

		if startStr != nil then
			lastSpace = startStr - 1
			last = last + 1
			newLine = true
		end

		if lastSpace == 0 then
			--finding last space
			for i2 = 1, len do
				if part:find(" ", -i2) != nil then
					lastSpace = ((len - i2) + 1)
					break
				end
			end
		end

		if lastSpace > 0 and i != iters then
			last = last + lastSpace
			part = part:sub(1, lastSpace)
		else
			last = last + letterChunks
		end

		local line = self:Add("DLabel")
		line:SetText(part)
		line:SetFont(self.font or "mTooltip")
		line:SizeToContents()

		if self.align == "left" or (newLine and self.align == "justify") then
			line:SetPos(0, self.height)
		elseif self.align == "right" then
			line:SetPos(self.width - line:GetWide(), self.height)
		elseif self.align == "center" then
			line:SetPos((self.width - line:GetWide()) / 2, self.height)
		elseif self.align == "justify" then
			local diff = self.width - line:GetWide()
			--if no difference or last line
			if diff == 0 or i == iters then
				line:SetPos(0, self.height)
			else
				local res, spaceCount = part:gsub(" ", "")

				local newLine2 = self:Add("DLabel")
				newLine2:SetText(res)
				newLine2:SetFont(self.font or "mTooltip")
				newLine2:SizeToContents()
				newLine2:SetVisible(false)
				line:SetVisible(false)

				diff = self.width - newLine2:GetWide()

				local eachSpace = diff/(spaceCount-1)
				local lastPos = 0

				for wordString in part:gmatch("[^%s]+") do
					local word = self:Add("DLabel")
					word:SetText(wordString)
					word:SetFont(self.font or "mTooltip")
					word:SizeToContents()
					word:SetPos(lastPos, self.height)

					lastPos = lastPos + word:GetWide() + eachSpace
				end
			end
		end

		self.height = self.height + line:GetTall()
	end

	self:SetTall(self.height)
end

vgui.Register("mWrappedText", PANEL, "DPanel")
