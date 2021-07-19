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

local function GetModelSize(Plot, Model)
	-- Get size of model with orientation taken into account.
	local ModelSize = CFrame.fromEulerAnglesXYZ(0, math.rad(Model.PrimaryPart.Orientation.Y - Plot.Orientation.Y), 0) * Model.PrimaryPart.Size
	ModelSize = Vector3.new(math.abs(ModelSize.X), math.abs(ModelSize.Y), math.abs(ModelSize.Z))
	ModelSize = Vector3.new(math.round(ModelSize.X), 0, math.round(ModelSize.Z))
	
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

function Grid:_GetModelCells(Plot, Model, x, y, Callback)
	-- Gets all the cells that the model covers. (8x4 will cover two cells.)
	local ModelSize = GetModelSize(Plot, Model)
	local GridUnit = self.GridUnit
	
	-- Get top corner of model
	x = math.round(x) - ModelSize.X / 2; y = math.round(y) - ModelSize.Z / 2
	
	for i = 1, ModelSize.X / GridUnit do
		local x = x + (GridUnit / 2 + (i - 1) * GridUnit)
		-- i = 1
		-- x = x + (4 / 2 + (0) * 4)
		-- x = x + 2
		
		for j = 1, ModelSize.Z / GridUnit do
			local x, y = self:translate(x, y + (GridUnit / 2 + (j - 1) * GridUnit))
			
			Callback(x, y)
		end
	end
end

function Grid:GetCell(Plot, Model, x, y)
	local CellHasObject = false
	
	self:_GetModelCells(Plot, Model, x, y, function(x, y)
		if self.Grid[x] and self.Grid[x][y] then
			CellHasObject = true
		end
	end)
	
	return CellHasObject
end

function Grid:AddCell(Plot, Model, x, y)
	self:_GetModelCells(Plot, Model, x, y, function(x, y)
		self.Grid[x] = self.Grid[x] or {}
		self.Grid[x][y]= true
	end)
end

function Grid:RemoveCell(Plot, Model, x, y)
	self:_GetModelCells(Plot, Model, x, y, function(x, y)
		self.Grid[x][y] = nil
	end)
end

return Grid
