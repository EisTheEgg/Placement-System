local Grid = {}
Grid.__index = Grid

local function RoundVector2(vector, multiple)
	local x = vector.X / multiple
	local y = vector.Y / multiple
	
	return Vector2.new(
		multiple * vector.X > 0 and math.ceil(x) or math.floor(x),
		multiple * vector.Y > 0 and math.ceil(y) or math.floor(y)
	)
end

local function GetModelSize(Model)
	local ModelSize = CFrame.fromEulerAnglesXYZ(0, math.rad(Model.PrimaryPart.Orientation.Y), 0) * Model.PrimaryPart.Size
	ModelSize = Vector3.new(math.abs(ModelSize.X), math.abs(ModelSize.Y), math.abs(ModelSize.Z))
	ModelSize = Vector3.new(math.floor(ModelSize.X + 0.5), 0, math.floor(ModelSize.Z + 0.5))
	
	return ModelSize
end

function Grid.new()
	local self = {}
	self.Grid = {}
	self.GridUnit = 4
	
	return setmetatable(self, Grid)
end

function Grid:translate(x, y)
	local Vector = RoundVector2(Vector2.new(math.floor(x), math.floor(y)), self.GridUnit)
	return Vector.X, Vector.Y
end

function Grid:_GetModelCells(Model, x, y, Callback)
	local ModelSize = GetModelSize(Model)
	local GridUnit = self.GridUnit
	
	-- Get top corner of model
	x = math.floor(x + 0.5) - ModelSize.X / 2; y = math.floor(y + 0.5) - ModelSize.Z / 2
	
	for i = 1, ModelSize.X / GridUnit do
		local x = x + (GridUnit / 2 + (i - 1) * GridUnit)
		-- i = 1
		-- x = x + (4 / 2 + (0) * 4)
		-- x = x + 2
		
		for j = 1, ModelSize.Z / GridUnit do
			local y = y + (GridUnit / 2 + (j - 1) * GridUnit)
			local x, y = self:translate(x, y)
			
			Callback(x, y)
		end
	end
end

function Grid:GetCell(Model, x, y)
	local CellHasObject = false
	
	self:_GetModelCells(Model, x, y, function(x, y)
		if self.Grid[x] and self.Grid[x][y] then
			CellHasObject = true
		end
	end)
	
	return CellHasObject
end

function Grid:AddCell(Model, x, y)
	self:_GetModelCells(Model, x, y, function(x, y)
		self.Grid[x] = self.Grid[x] or {}
		self.Grid[x][y]= true
	end)
end

function Grid:RemoveCell(Model, x, y)	
	self:_GetModelCells(Model, x, y, function(x, y)
		self.Grid[x][y] = nil
	end)
end

return Grid
