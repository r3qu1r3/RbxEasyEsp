local PLAYERS = game:GetService('Players'); 
local RUNSERVICE = game:GetService("RunService");

local DRAW = Drawing.new;
local CAMERA = workspace.CurrentCamera;
local LOCAL = PLAYERS.LocalPlayer;
local VECTOR2 = Vector2.new;
local RGB = Color3.fromRGB;
local CFRAME = CFrame.new;
local MIN, MAX, ATAN2, CLAMP = math.min, math.max, math.atan2, math.clamp;
local PI, COS, SIN = math.pi, math.cos, math.sin;
local CASTPARAMS = RaycastParams.new();
local function LERP(a, b, c) return a + (b - a) * c; end; 

local Esp = {};
Esp.RenderTime = 0;
Esp.RenderCounts = 0;
Esp.DebugStats = true;
Esp.ModelCache = {};
Esp.PartCache = {};
Esp.PlayerCache = {};
Esp.__Drawings = {};
Esp.__Instances = {};

Esp.Utils = {};
Esp.PartUtils = {};
Esp.ModelUtils = {};
Esp.PlayerUtils = {};

Esp.DefaultSettingGroup = {
    General = {MasterSwitch = true; FadeOut = false; FadeStep = 100};
    Box3D = {Enabled = true; Color = RGB(255, 0, 0); Filled = true; Transparency = 1};
    Box = {Enabled = true; Transparency = 1; InlineColor = RGB(255, 255, 255); OutlineColor = RGB(0, 0, 0); InlineThickness = 1};
    Tag = {Enabled = true; Transparency = 1; InlineColor = RGB(255, 255, 255); Font = 3; Scale = 0.2; Outline = true; Min = 10; Max = 20};
    GetTagData = function(Object) return Object.Name; end;
    Validate = function(Object) return Object; end;
};

Esp.ModelUtils.SettingGroups = {Default = Esp.DefaultSettingGroup};
Esp.PartUtils.SettingGroups = {Default = Esp.DefaultSettingGroup};

Esp.PlayerUtils.Settings = { 
    General = {DrawTeam = true; MasterSwitch = true; CheckHealth = true; FadeOut = false; FadeStep = 100};
    Backtrack = {Enabled = true; PointColor = RGB(255, 255, 255); ConnectorColor = RGB(20, 20, 20); DeletionDelay = 0.4; UpdateDelay = 0.1};
    Pointer = {Enabled = true; Color = RGB(255, 255, 255); Filled = true; Transparency = 0.5; Radius = 100; Size = VECTOR2(10, 10)};
    Box3D = {Enabled = true; Color = RGB(32, 42, 68); Filled = true; Transparency = 0};
    Box = {Enabled =  true; Transparency = 1; InlineColor = RGB(255, 255, 255); OutlineColor = RGB(0, 0, 0); InlineThickness = 1};
    Tag = {Enabled = true; Transparency = 1; InlineColor = RGB(255, 255, 255); Font = 3; Scale = 0.2; Outline = true; Min = 10; Max = 18};
    DrawingChams = {Enabled = false; Color = RGB(255, 255, 255); OccludedColor = RGB(0, 0, 0); Dynamic = true; Transparency = 0.5; Filled = false; ParentOpaque = 1};
    Health = {Enabled = true; OutlineColor = RGB(0, 0, 0); Transparency = 1; InlineColor = RGB(0, 255, 0); OutlineThickness = 3; Scale = 0.02; Offset = 1; Min = 1; Max = 2}; 
};

Esp.CubePattern = {
    Back = {2, 1, 4, 3};
    Front = {5, 6, 7, 8};
    Left = {1, 5, 8, 4};
    Right = {6, 2, 3, 7};
    Top = {5, 6, 2, 1};
    Bottom = {7, 8, 4, 3};
};

Esp.DebugWatermark = Drawing.new('Text');

CASTPARAMS.FilterType = Enum.RaycastFilterType.Blacklist;

function Esp:Instance(Class, Properties) 
    local Object = Instance.new(Class);
    table.insert(self.__Instances, Object);
    if (not Properties) then return Object; end; 

    for Property, Value in next, Properties do 
        Object[Property] = Value;
    end; 

    return Object;
end; 

function Esp:Draw(Class, Properties)
    local Drawing = DRAW(Class); 
    rawset(Drawing, 'FadeFrame', 0);
    table.insert(Esp.__Drawings, Drawing);
    if (not Properties) then return Drawing; end;

    for Property, Value in next, Properties do 
        Drawing[Property] = Value;
    end; 

    return Drawing;
end;

function Esp:MassDraw(Class, Properties, Quantity)
    local Array = {};
    for i = 1, Quantity do 
        table.insert(Array, self:Draw(Class, Properties));
    end;
    return Array;
end; 

function Esp:Edit(Object, Properties)
    for Property, Value in next, Properties do 
        Object[Property] = Value;
    end;  
end; 

function Esp:GroupEdit(Drawings, Properties) 
    for Property, Value in next, Properties do 
        for _, Drawing in next, Drawings do 
            Drawing[Property] = Value;
        end; 
    end; 
end; 

function Esp.Utils.IsPositionOccluded(Position, ...)
    local Difference = (Position - CAMERA.CFrame.Position);
    CASTPARAMS.FilterDescendantsInstances = {CAMERA; LOCAL.Character; ...}

    return workspace:Raycast(CAMERA.CFrame.Position, Difference.Unit * Difference.Magnitude, CASTPARAMS);
end; 

function Esp.Utils.Get3DInstanceCorners(Object, Convert2D, Offsets)
    if (not Object) then return end; 

    local CFrame; 
    local X, Y, Z = 0, 0, 0;

    if (Object:IsA('Model')) then 
        local BoundingCFrame, Size = Object:GetBoundingBox();
        CFrame = BoundingCFrame; 
        X, Y, Z = Size.X, Size.Y, Size.Z;
    else 
        CFrame = Object.CFrame; 
        X, Y, Z = Object.Size.X, Object.Size.Y, Object.Size.Z;
    end; 
    
    local Corners = {
      CFrame * CFRAME(-X / 2, Y / 2, Z / 2), -- Top left 1
      CFrame * CFRAME(X / 2, Y / 2, Z / 2), -- Top Right 2
      CFrame * CFRAME(X / 2, -Y / 2, Z / 2), -- Bottom Right 3
      CFrame * CFRAME(-X / 2, -Y / 2, Z / 2), -- Bottom Left 4
      CFrame * CFRAME(-X / 2, Y / 2, -Z / 2), -- Front Top Left 5
      CFrame * CFRAME(X / 2, Y / 2, -Z / 2), -- Front Top Right 6
      CFrame * CFRAME(X / 2, -Y / 2, -Z / 2), -- Front Bottom Right 7
      CFrame * CFRAME(-X / 2, -Y / 2, -Z / 2), -- Front Bottom Left 8
    };

    if (Offsets) then 
        for index, offset in next, Offsets do 
            Corners[index] = Corners[index] * offset;
        end; 
    end; 

    if (Convert2D) then 
        for i, Corner in next, Corners do 
            local P = CAMERA:WorldToViewportPoint(Corner.Position);
            Corners[i] = VECTOR2(P.X, P.Y);
        end;
    end; 

    return Corners, CornerData;
end; 

function Esp.Utils.ResolvePointerPoints(Position, Dimensions)
    local CameraPosition = CAMERA.CFrame.Position;
    local ScreenCenter = CAMERA.ViewportSize / 2;

    local LookVector = VECTOR2(CAMERA.CFrame.LookVector.X, CAMERA.CFrame.LookVector.Z).Unit;
    local DifferenceVector = VECTOR2(Position.X - CameraPosition.X, Position.Z - CameraPosition.Z).Unit;
    local Angle = ATAN2(DifferenceVector.X * LookVector.Y - DifferenceVector.Y * LookVector.X, DifferenceVector.X * LookVector.X + DifferenceVector.Y * LookVector.Y);

    Angle = (Angle < 0) and (Angle + math.pi*2) or Angle;

    local RotatedVector = VECTOR2(-1*SIN(Angle), -1*COS(Angle)); 

    return {
        PointA = ScreenCenter + RotatedVector * (Dimensions.Radius + Dimensions.Size.Y);
        PointB = ScreenCenter + RotatedVector * Dimensions.Radius + VECTOR2(RotatedVector.Y, -RotatedVector.X) * (Dimensions.Size.X/2);
        PointC = ScreenCenter + RotatedVector * Dimensions.Radius + VECTOR2(-RotatedVector.Y, RotatedVector.X) * (Dimensions.Size.X/2);
    };
end;

function Esp.Utils.DrawFaces(Faces, Corners, ExcludedFaces) ExcludedFaces = ExcludedFaces or  {};
    local index = 0;
    for i, v in next, Esp.CubePattern do
        index = index + 1;
        if (table.find(ExcludedFaces, i)) then continue; end;
        Esp:Edit(Faces[index], { 
            PointA = Corners[v[1]];
            PointB = Corners[v[2]];
            PointC = Corners[v[3]];
            PointD = Corners[v[4]];
        });
    end; 
end;

function Esp.Utils.Get2DBoundingBox(Model)
    local MaxiumX, MiniumX = 0, CAMERA.ViewportSize.X;
    local MaxiumY, MiniumY = 0, CAMERA.ViewportSize.Y;
    local Corners = Esp.Utils.Get3DInstanceCorners(Model);
    local InFov = true;
  
    for _, corner in next, Corners do
      local Point, _InFov = CAMERA.WorldToViewportPoint(CAMERA, corner.Position);
      local X, Y = Point.X, Point.Y;
  
      if X > MaxiumX then MaxiumX = X end;
      if X < MiniumX then MiniumX = X end;
      if Y > MaxiumY then MaxiumY = Y end;
      if Y < MiniumY then MiniumY = Y end;

      InFov = _InFov;
    end;
  
    return InFov, MiniumX, MaxiumX, MiniumY, MaxiumY;
end;

function Esp.NewStruct(Object)
    Object.Hidden = false;
    
    function Object:HideObjects(Exclusions) 
        if (self.Hidden) then return end;
        for Name, List in next, self.Drawings do 
            if (Exclusions and table.find(Exclusions, Name)) then continue; end;
            for _, Object in next, List do
                Object.Visible = false;
            end; 
        end; 
        self.Hidden = true;
    end;
    
    function Object:FadeObjects(Step) Step = Step or 1
        if (self.Hidden) then return end;
        local Completed = false;
        local _, Frame = RUNSERVICE.Stepped:wait();
    
        for _, List in next, self.Drawings do 
            for _, Object in next, List do
                Object.FadeFrame = Object.FadeFrame + (Frame / Step);
                Object.Transparency = LERP(Object.Transparency, 0, Object.FadeFrame);
    
                if (Object.FadeFrame >= 1) then 
                    Object.Visible = false;
                    Object.Transparency = 1; 
                    Object.FadeFrame = 0;
                    Completed = true;
                end; 
            end;
        end;
    
        self.Hidden = Completed;
    end; 
end;

-- Part 
function Esp.PartUtils:CreateSettingsGroup(Name)
    local NewSettings =  {};
    for c,k in next, Esp.DefaultSettingGroup do NewSettings[c] = k; end; 
    self.SettingGroups[Name] = NewSettings; 
    return self.SettingGroups[Name];
end; 

function Esp.PartUtils.CreateObject(Part, Group)
    local Data = {Part = Part; Instances = {}; Group = Group or 'Default'};
    Esp.NewStruct(Data);

    Data.Drawings = {
        Box = {Outline = Esp:Draw('Square', {Thickness = 3; Filled = false}); Inline = Esp:Draw('Square', {Thickness = 1; Filled = false})};
        Line = {Inline = Esp:Draw('Line'); Outline = Esp:Draw('Line')};
        Tag = {Text = Esp:Draw('Text')};
        Box3D = Esp:MassDraw('Quad', {Thickness = 1}, 6);
    };

    function Data:Destruct()
        for _, List in next, self.Drawings do 
            for _, Object in next, List do 
                Object:Remove();
            end; 
        end; 
        Esp.PartCache[self.Index] = nil;
    end;

    local Index = #Esp.PartCache + 1;
    Esp.PartCache[Index] = Data;
    Data.Index = Index;
    return Data;
end;

function Esp.PartUtils:UpdatePartCache()
    for _, Cache in next, Esp.PartCache do 
        self.Settings = self.SettingGroups[Cache.Group];
        local Drawings = Cache.Drawings;
        local Instances = Cache.Instances;

        if (not Cache.Part or not Cache.Part:IsDescendantOf(workspace)) then   
            Cache:Destruct();
            continue;
        end; 

        if (not self.Settings.General.MasterSwitch or not self.Settings.Validate(Cache.Part)) then 
            Cache:HideObjects();
            continue;
        end; 

        local InFov, MiniumX, MaxiumX, MiniumY, MaxiumY = Esp.Utils.Get2DBoundingBox(Cache.Part);
        local SizeX, SizeY = (MaxiumX - MiniumX), (MaxiumY - MiniumY);
        if (not InFov) then Cache:HideObjects(); continue; end;

        Cache.Hidden = false;

        -- Boxes
        do 
            Esp:Edit(Drawings.Box.Inline, {
                Visible = self.Settings.Box.Enabled;
                Thickness = self.Settings.Box.InlineThickness;
                Transparency = self.Settings.Box.Transparency;
                Size = VECTOR2(SizeX, SizeY); Position = VECTOR2(MaxiumX - SizeX, MaxiumY - SizeY); Color = self.Settings.Box.InlineColor})

            Esp:Edit(Drawings.Box.Outline, {
                Visible = self.Settings.Box.Enabled;
                Thickness = self.Settings.Box.OutlineThickness;
                Transparency = self.Settings.Box.Transparency;
                Size = Drawings.Box.Inline.Size; Position = Drawings.Box.Inline.Position; Color = self.Settings.Box.OutlineColor});
        end; 

        -- 3D Box
        do
            if (self.Settings.Box3D.Enabled) then 
                local Corners = Esp.Utils.Get3DInstanceCorners(Cache.Part, true);
                Esp.Utils.DrawFaces(Drawings.Box3D, Corners);
            end; 
    
            Esp:GroupEdit(Drawings.Box3D, {
                Visible = self.Settings.Box3D.Enabled;
                Color = self.Settings.Box3D.Color;
                Filled = self.Settings.Box3D.Filled;
                Transparency = self.Settings.Box3D.Transparency;
            });
        end;

        -- Tag 
        do 
            local Tag = self.Settings.GetTagData(Cache.Part);

            Esp:Edit(Drawings.Tag.Text, {
                Visible = self.Settings.Tag.Enabled;
                Text = (Tag or 'Amongus');
                Color = self.Settings.Tag.InlineColor;
                Font = self.Settings.Tag.Font;
                Outline = self.Settings.Tag.Outline;
                Transparency = self.Settings.Tag.Transparency;
                Size = CLAMP(SizeX * self.Settings.Tag.Scale, self.Settings.Tag.Min, self.Settings.Tag.Max);
            });

            if (self.Settings.Tag.Enabled) then 
                Drawings.Tag.Text.Position = VECTOR2(Drawings.Box.Inline.Position.X, Drawings.Box.Inline.Position.Y - Drawings.Tag.Text.TextBounds.Y);
            end; 
        end; 

        -- Pointer 

    end;
end;

-- Player 
function Esp.PlayerUtils.GetTeam(Player, Character)
    return Player.Team;
end; 

function Esp.PlayerUtils.GetCharacter(Player)
    return Player.Character;
end;

function Esp.PlayerUtils.GetTagData(Player, Character, ...)
    local Tag = '';
    Tag = Tag .. 'Player: ' .. Player.Name .. '\n';

    -- local Health, MaxHealth = Esp.PlayerUtils.GetHealth(Player, Character);
    -- if (Health) then Tag = Tag .. 'Health: ' .. (Health / (MaxHealth or 100)) * 100 .. '%' end;

    return Tag;
end; 

function Esp.PlayerUtils.GetHealth(Player, Character)
    local Humanoid = Character:FindFirstChild('Humanoid');
    local Alive = (Humanoid and Humanoid.Health > 0);
    if (not Alive) then return false; end;
    return Humanoid.Health, Humanoid.MaxHealth;
end; 

function Esp.PlayerUtils.CreateObject(Player)
    local Data = {Player = Player; Instances = {};};
    Esp.NewStruct(Data);

    Data.PlayerName = Player.Name;
    Data.FrameTarget = 'Head';
    Data.LastFramePosition = Vector3.new(0, 0, 0);
    Data.LastFrameTime = tick();
    Data.Frames = {};

    Data.Drawings = {
        Pointer = {Triangle = Esp:Draw('Triangle', {Thickness = 1})};
        Box = {Outline = Esp:Draw('Square', {Thickness = 3; Filled = false}); Inline = Esp:Draw('Square', {Thickness = 1; Filled = false})};
        Line = {Inline = Esp:Draw('Line'); Outline = Esp:Draw('Line')};
        Tag = {Bar = Esp:Draw('Square', {Filled = true; Color = RGB(30, 30, 30)}); Text = Esp:Draw('Text')};
        Box3D = Esp:MassDraw('Quad', {Thickness = 1}, 6);
        Health = {Outline = Esp:Draw('Square', {Filled = true}); Inline = Esp:Draw('Square', {Filled = true})};    
    };

    function Data:Destruct(Index)
        for _, List in next, self.Drawings do 
            for _, Object in next, List do 
                Object:Remove();
            end; 
        end; 
        for _, k in next, self.Frames do 
            k.Connector:Remove();
            k.Point:Remove();
        end; 
        table.remove(Esp.PlayerCache, Index);
    end;

    table.insert(Esp.PlayerCache, Data);
    return true;
end;

function Esp.PlayerUtils:UpdatePlayerCache()
    for index, Cache in next, Esp.PlayerCache do 
        local Drawings = Cache.Drawings;
        local Instances = Cache.Instances;
        local Character = self.GetCharacter(Cache.Player);
        local LocalCharacter = self.GetCharacter(LOCAL);
        local LocalTeam, PlayerTeam = self.GetTeam(LOCAL, LocalCharacter) or '0', self.GetTeam(Cache.Player, Character) or '1';

        if (not PLAYERS:FindFirstChild(Cache.PlayerName)) then 
            Cache:Destruct(index);
            continue;
        end;

        if ((not self.Settings.General.DrawTeam) and (not Character or LocalTeam == PlayerTeam)) or (not self.Settings.General.MasterSwitch) then 
            Cache:HideObjects();
            continue; 
        end; 

        for _, instance in next, Character:GetChildren() do 
            if (not instance:IsA('BasePart') or instance.Transparency == 1) then continue; end; 
            local DrawingObject = Drawings[instance.Name];

            if (not DrawingObject and self.Settings.DrawingChams.Enabled) then
                Drawings[instance.Name] = Esp:MassDraw('Quad', {Thickness = 1}, 6);
            elseif (DrawingObject and not self.Settings.DrawingChams.Enabled) then 
                for _, Drawing in next, DrawingObject do Drawing:Remove(); Drawings[instance.Name] = nil; end; 
            end;
        end; 

        local FrameTarget = Character:FindFirstChild(Cache.FrameTarget);
        if (FrameTarget and self.Settings.Backtrack.Enabled) then 
            local TimePassed = tick() - Cache.LastFrameTime; 
            if (TimePassed >= self.Settings.Backtrack.UpdateDelay) and ((FrameTarget.Position - Cache.LastFramePosition).Magnitude >= 10) then 
                Cache.LastFrameTime = tick();
                table.insert(Cache.Frames, {
                    Position = FrameTarget.Position; 
                    CreationTime = tick();
                    Connector = Esp:Draw('Line', {Thickness = 1});
                    Point = Esp:Draw('Square', {Thickness = 1; Filled = false});
                });
            end;
        end; 

        for index, Frame in next, Cache.Frames do 
            local TimePassed = tick() - Frame.CreationTime;

            if (TimePassed >= self.Settings.Backtrack.DeletionDelay) then 
                Cache.Frames[index] = nil; 
                Frame.Point:Remove(); 
                Frame.Connector:Remove();
            else 
                local ScreenPoint, Visible = CAMERA:WorldToViewportPoint(Frame.Position);

                if (not Visible) then 
                    Frame.Point.Visible = false; 
                    Frame.Connector.Visible = false;
                    continue;
                end; 

                local LastFrame = Cache.Frames[index - 1] or Frame;
                local LastFramePoint = CAMERA:WorldToViewportPoint(LastFrame.Position);

                Frame.Point.Color = self.Settings.Backtrack.PointColor;
                Frame.Point.Position = VECTOR2(ScreenPoint.X, ScreenPoint.Y); 
                Frame.Point.Size = VECTOR2(5, 5);
                Frame.Point.Visible = self.Settings.Backtrack.Enabled;

                Frame.Connector.From = VECTOR2(LastFramePoint.X, LastFramePoint.Y); 
                Frame.Connector.To = VECTOR2(ScreenPoint.X, ScreenPoint.Y);
                Frame.Connector.Color = self.Settings.Backtrack.ConnectorColor;
                Frame.Connector.Visible = self.Settings.Backtrack.Enabled;
            end; 
        end; 

        local InFov, MiniumX, MaxiumX, MiniumY, MaxiumY = Esp.Utils.Get2DBoundingBox(Character);
        local SizeX, SizeY = (MaxiumX - MiniumX), (MaxiumY - MiniumY);

        Cache.Hidden = false;
        local Health, MaxHealth = self.GetHealth(Cache.Player, Character);
        Health = (Health or 0);
        MaxHealth = (MaxHealth or 100);
        if (self.Settings.General.CheckHealth and Health <= 0) then 
            if (self.Settings.General.FadeOut) then 
                Cache:FadeObjects(); 
            else 
                Cache:HideObjects(); 
            end;
            continue; 
        end;

        -- Pointer 
        do 
            Esp:Edit(Drawings.Pointer.Triangle, {
                Visible = self.Settings.Pointer.Enabled and not InFov;
                Color = self.Settings.Pointer.Color; 
                Transparency = self.Settings.Pointer.Transparency; 
                Filled = self.Settings.Pointer.Filled;
            });

            if (self.Settings.Pointer.Enabled and Character.PrimaryPart and self.Settings.Pointer.Enabled and not InFov) then 
                local Points = Esp.Utils.ResolvePointerPoints(Character.PrimaryPart.Position, {Radius = self.Settings.Pointer.Radius, Size = self.Settings.Pointer.Size});
                for Name, Point in next, Points do 
                    Drawings.Pointer.Triangle[Name] = Point;
                end; 
            end; 
        end; 

        if (not InFov) then Cache:HideObjects({'Pointer'}); continue; end;
        Cache.Hidden = false;

        -- Boxes
        do 
            Esp:Edit(Drawings.Box.Inline, {
                Visible = self.Settings.Box.Enabled;
                Thickness = self.Settings.Box.InlineThickness;
                Transparency = self.Settings.Box.Transparency;
                Size = VECTOR2(SizeX, SizeY); Position = VECTOR2(MaxiumX - SizeX, MaxiumY - SizeY); Color = self.Settings.Box.InlineColor})

            Esp:Edit(Drawings.Box.Outline, {
                Visible = self.Settings.Box.Enabled;
                Thickness = self.Settings.Box.OutlineThickness;
                Transparency = self.Settings.Box.Transparency;
                Size = Drawings.Box.Inline.Size; Position = Drawings.Box.Inline.Position; Color = self.Settings.Box.OutlineColor});
        end; 

        -- Health Bar 
        do 
            local Ratio = (Health / MaxHealth);
            local HealthWidth = math.clamp(SizeX * self.Settings.Health.Scale, self.Settings.Health.Min, self.Settings.Health.Max);
            local OutlineOffset = ((Drawings.Box.Outline.Thickness - Drawings.Box.Inline.Thickness) / 2);
            local FarLeft = (Drawings.Box.Inline.Position.X - OutlineOffset - self.Settings.Health.Offset)

            Esp:Edit(Drawings.Health.Inline, {
                Visible = self.Settings.Health.Enabled;
                Color = self.Settings.Health.InlineColor; 
                Size = VECTOR2(HealthWidth, -(SizeY * Ratio)); 
                Transparency = self.Settings.Health.Transparency;
                Position = VECTOR2(FarLeft - HealthWidth, MaxiumY)});
    
            Esp:Editw(Drawings.Health.Outline, {
                Visible = self.Settings.Health.Enabled;
                Color = self.Settings.Health.OutlineColor; 
                Transparency = self.Settings.Health.Transparency;
                Size = VECTOR2(HealthWidth, -(SizeY)); Position = Drawings.Health.Inline.Position});
        end;

        -- Tag 
        do 
            local Tag = self.GetTagData(Cache.Player, Character);
            Drawings.Tag.Text.Visible = self.Settings.Tag.Enabled;

            if (self.Settings.Tag.Enabled) then 
                Esp:Edit(Drawings.Tag.Text, {
                    Text = (Tag or 'Amongus');
                    Color = self.Settings.Tag.InlineColor;
                    Font = self.Settings.Tag.Font;
                    Outline = self.Settings.Tag.Outline;
                    OutlineColor = self.Settings.Tag.OutlineColor;
                    Transparency = self.Settings.Tag.Transparency;
                    Size = CLAMP(SizeX * self.Settings.Tag.Scale, self.Settings.Tag.Min, self.Settings.Tag.Max);
                });

                Drawings.Tag.Text.Position = VECTOR2(Drawings.Box.Inline.Position.X, Drawings.Box.Inline.Position.Y - Drawings.Tag.Text.TextBounds.Y);
            end; 
        end; 

        -- 3D Box 
        do 
            if (self.Settings.Box3D.Enabled) then 
                local Corners, CornerData = Esp.Utils.Get3DInstanceCorners(Character, true);
                Esp.Utils.DrawFaces(Drawings.Box3D, Corners);
            end; 
            
            Esp:GroupEdit(Drawings.Box3D, {
                Visible = self.Settings.Box3D.Enabled;
                Color = self.Settings.Box3D.Color;
                Filled = self.Settings.Box3D.Filled;
                Transparency = self.Settings.Box3D.Transparency;
            });

        end;
        
        -- Drawing Chams
        for _, instance in next, Character:GetChildren() do 
            if (not instance:IsA('BasePart') or not Drawings[instance.Name] or not InFov) then continue; end; 

            local Object = Drawings[instance.Name];

            local Occluded;
            if (self.Settings.DrawingChams.Enabled) then 
                local Corners = Esp.Utils.Get3DInstanceCorners(instance, true);
                Esp.Utils.DrawFaces(Object, Corners, {'Left', 'Right'})

                if (self.Settings.DrawingChams.Dynamic) then 
                    Occluded = Esp.Utils.IsPositionOccluded(instance.Position, Character, instance); 
                end; 
            end; 

            Esp:GroupEdit(Object, {
                Visible = self.Settings.DrawingChams.Enabled; 
                Filled = self.Settings.DrawingChams.Filled;
                Transparency = self.Settings.DrawingChams.Transparency; 
                Color = (Occluded and self.Settings.DrawingChams.OccludedColor) or (self.Settings.DrawingChams.Color);
            })
        end;
    end; 
end;

function Esp:Render()
    local Time = tick();
    Esp.PlayerUtils:UpdatePlayerCache();
    Esp.PartUtils:UpdatePartCache();
    local RenderTime = tick() - Time;

    if (Esp.DebugStats) then 
        Esp.DebugWatermark.Color = RGB(255, 255, 255);
        Esp.DebugWatermark.Text = ('Drawn: %s\nRender Time: %s ms\nRender Fps: %s'):format(#Esp.__Drawings, round(RenderTime, 3), math.floor(1/RenderTime));
        Esp.DebugWatermark.Position = Vector2.new(5, CAMERA.ViewportSize.Y / 2);
    end; 

    Esp.DebugWatermark.Visible = Esp.DebugStats;

    self.RenderTime = RenderTime;
    self.RenderCounts = self.RenderCounts + 1; 
    return RenderTime;
end; 

--// Loading Methods (regular example)
function Esp.PlayerUtils:DefaultLoad()
    for c, k in next, PLAYERS:GetPlayers() do if (k == LOCAL) then continue; end; Esp.PlayerUtils.CreateObject(k); end; 
    Esp.PLAYERLISTENER = PLAYERS.PlayerAdded:Connect(Esp.PlayerUtils.CreateObject);

    function round(num, numDecimalPlaces)
        local mult = 10^(numDecimalPlaces or 0)
        return math.floor(num * mult + 0.5) / mult
    end

    coroutine.wrap(function()
        while true do
            task.wait();
            Esp:Render();
        end; 
    end)();
end;

return Esp;
