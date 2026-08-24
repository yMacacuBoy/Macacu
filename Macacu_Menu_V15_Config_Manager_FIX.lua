--[[
    MACACU MENU - V15 FIX

    VISUAIS FUNCIONAIS:
    - Ativar ESP
    - Team Check
    - Usar cor dos times
    - Box
    - Distância
    - Nomes
    - Armas
    - Barra de vida
    - Vida
    - Tracers
    - Chams

    CONFIGS:
    - Tecla do menu
    - Cor do menu
    - Opacidade
    - Tamanho
    - Configs nomeadas
    - Mostrar keybinds
    - Unload
]]

--========================================================
-- SERVIÇOS
--========================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--========================================================
-- CONFIG FILES
--========================================================

local CONFIG_FOLDER = "MacacuMenu_Configs"
local CONFIG_INDEX = CONFIG_FOLDER .. "/index.json"

local function EncodeEnumItem(item)
    if typeof(item) ~= "EnumItem" then
        return nil
    end

    return {
        EnumType = tostring(item.EnumType),
        Name = item.Name
    }
end

local function DecodeEnumItem(data)
    if type(data) ~= "table" or type(data.Name) ~= "string" then
        return nil
    end

    local enumTypeName =
        tostring(data.EnumType or ""):gsub("^Enum%.", "")

    local enumType = Enum[enumTypeName]

    if enumType then
        return enumType[data.Name]
    end

    return nil
end

local function SanitizeConfigName(name)
    name = tostring(name or "")
    name = name:gsub("^%s+", "")
    name = name:gsub("%s+$", "")
    name = name:gsub("[<>:\"/\\|%?%*]", "_")

    if #name > 40 then
        name = name:sub(1, 40)
    end

    return name
end

local function ConfigPath(name)
    return CONFIG_FOLDER
        .. "/"
        .. SanitizeConfigName(name)
        .. ".json"
end

local function EnsureConfigFolder()
    if type(makefolder) ~= "function" then
        return false
    end

    if type(isfolder) == "function" then
        if not isfolder(CONFIG_FOLDER) then
            local ok = pcall(makefolder, CONFIG_FOLDER)
            if not ok then
                return false
            end
        end
    else
        pcall(makefolder, CONFIG_FOLDER)
    end

    return true
end

-- IMPORTANTE:
-- nenhuma config é carregada automaticamente ao executar o menu.

--========================================================
-- GUI PARENT
--========================================================

local function GetGuiParent()

    if gethui then
        local success, result = pcall(gethui)

        if success and result then
            return result
        end
    end

    local success, coreGui = pcall(function()
        return game:GetService("CoreGui")
    end)

    if success and coreGui then
        return coreGui
    end

    return LocalPlayer:WaitForChild("PlayerGui")
end

local GuiParent = GetGuiParent()

--========================================================
-- LIMPAR EXECUÇÃO ANTERIOR
--========================================================

for _, name in ipairs({
    "MacacuMenu",
    "MacacuESP"
}) do

    local old = GuiParent:FindFirstChild(name)

    if old then
        old:Destroy()
    end
end

--========================================================
-- CONEXÕES
--========================================================

local Connections = {}

local function Connect(signal, callback)

    local connection =
        signal:Connect(callback)

    table.insert(
        Connections,
        connection
    )

    return connection
end

--========================================================
-- SETTINGS
--========================================================

local Settings = {
    MenuKey = Enum.KeyCode.RightControl,
    AccentColor = Color3.fromRGB(240, 240, 240),
    Opacity = 1,
    Scale = 1
}

local VisualSettings = {
    ESP = false,
    TeamCheck = false,
    TeamColor = false,
    Box = false,
    Distance = false,
    Names = false,
    Weapons = false,
    HealthBar = false,
    Health = false,
    Tracers = false,
    Chams = false
}


--========================================================
-- CORES
--========================================================

local Colors = {

    Main =
        Color3.fromRGB(
            14,
            14,
            14
        ),

    Header =
        Color3.fromRGB(
            12,
            12,
            12
        ),

    Sidebar =
        Color3.fromRGB(
            13,
            13,
            13
        ),

    Content =
        Color3.fromRGB(
            18,
            18,
            18
        ),

    Selected =
        Color3.fromRGB(
            37,
            37,
            37
        ),

    Hover =
        Color3.fromRGB(
            29,
            29,
            29
        ),

    Border =
        Color3.fromRGB(
            42,
            42,
            42
        ),

    Text =
        Color3.fromRGB(
            240,
            240,
            240
        ),

    SecondaryText =
        Color3.fromRGB(
            150,
            150,
            150
        ),

    Search =
        Color3.fromRGB(
            9,
            9,
            9
        ),

    Red =
        Color3.fromRGB(
            230,
            70,
            70
        )
}

--========================================================
-- GUI DO ESP
--========================================================

local ESPGui =
    Instance.new("ScreenGui")

ESPGui.Name = "MacacuESP"

ESPGui.ResetOnSpawn = false

ESPGui.IgnoreGuiInset = true

ESPGui.ZIndexBehavior =
    Enum.ZIndexBehavior.Sibling

ESPGui.DisplayOrder = 5

ESPGui.Parent = GuiParent

local ESPContainer =
    Instance.new("Frame")

ESPContainer.Parent = ESPGui

ESPContainer.Size =
    UDim2.new(
        1,
        0,
        1,
        0
    )

ESPContainer.BackgroundTransparency = 1

ESPContainer.Active = false

--========================================================
-- MENU GUI
--========================================================

local ScreenGui =
    Instance.new("ScreenGui")

ScreenGui.Name = "MacacuMenu"

ScreenGui.ResetOnSpawn = false

ScreenGui.IgnoreGuiInset = true

ScreenGui.ZIndexBehavior =
    Enum.ZIndexBehavior.Sibling

ScreenGui.DisplayOrder = 100

ScreenGui.Parent = GuiParent

--========================================================
-- MAIN
--========================================================

local MainFrame =
    Instance.new("Frame")

MainFrame.Name = "MainFrame"

MainFrame.Parent = ScreenGui

MainFrame.AnchorPoint =
    Vector2.new(
        0.5,
        0.5
    )

MainFrame.Position =
    UDim2.new(
        0.5,
        0,
        0.5,
        0
    )

MainFrame.Size =
    UDim2.new(
        0,
        760,
        0,
        510
    )

MainFrame.BackgroundColor3 =
    Colors.Main

MainFrame.BorderSizePixel = 0

local UIScale =
    Instance.new("UIScale")

UIScale.Scale = Settings.Scale

UIScale.Parent = MainFrame

local MainCorner =
    Instance.new("UICorner")

MainCorner.CornerRadius =
    UDim.new(
        0,
        12
    )

MainCorner.Parent = MainFrame

local MainStroke =
    Instance.new("UIStroke")

MainStroke.Color =
    Colors.Border

MainStroke.Thickness = 1

MainStroke.Transparency = 0.15

MainStroke.Parent = MainFrame

--========================================================
-- HEADER
--========================================================

local Header =
    Instance.new("Frame")

Header.Parent = MainFrame

Header.Size =
    UDim2.new(
        1,
        0,
        0,
        65
    )

Header.BackgroundColor3 =
    Colors.Header

Header.BorderSizePixel = 0

local HeaderCorner =
    Instance.new("UICorner")

HeaderCorner.CornerRadius =
    UDim.new(
        0,
        12
    )

HeaderCorner.Parent = Header

local HeaderFix =
    Instance.new("Frame")

HeaderFix.Parent = Header

HeaderFix.Position =
    UDim2.new(
        0,
        0,
        1,
        -15
    )

HeaderFix.Size =
    UDim2.new(
        1,
        0,
        0,
        15
    )

HeaderFix.BackgroundColor3 =
    Colors.Header

HeaderFix.BorderSizePixel = 0

local HeaderLine =
    Instance.new("Frame")

HeaderLine.Parent = Header

HeaderLine.Position =
    UDim2.new(
        0,
        0,
        1,
        -1
    )

HeaderLine.Size =
    UDim2.new(
        1,
        0,
        0,
        1
    )

HeaderLine.BackgroundColor3 =
    Colors.Border

HeaderLine.BorderSizePixel = 0

--========================================================
-- TÍTULO
--========================================================

local Title =
    Instance.new("TextLabel")

Title.Parent = Header

Title.Position =
    UDim2.new(
        0,
        22,
        0,
        0
    )

Title.Size =
    UDim2.new(
        0,
        300,
        1,
        0
    )

Title.BackgroundTransparency = 1

Title.Text = "Macacu Menu"

Title.TextColor3 =
    Colors.Text

Title.TextXAlignment =
    Enum.TextXAlignment.Left

Title.Font =
    Enum.Font.GothamBold

Title.TextSize = 25

--========================================================
-- SEARCH
--========================================================

local SearchFrame =
    Instance.new("Frame")

SearchFrame.Parent = Header

SearchFrame.AnchorPoint =
    Vector2.new(
        1,
        0.5
    )

SearchFrame.Position =
    UDim2.new(
        1,
        -18,
        0.5,
        0
    )

SearchFrame.Size =
    UDim2.new(
        0,
        190,
        0,
        38
    )

SearchFrame.BackgroundColor3 =
    Colors.Search

SearchFrame.BorderSizePixel = 0

local SearchCorner =
    Instance.new("UICorner")

SearchCorner.CornerRadius =
    UDim.new(
        0,
        10
    )

SearchCorner.Parent =
    SearchFrame

local SearchStroke =
    Instance.new("UIStroke")

SearchStroke.Color =
    Colors.Border

SearchStroke.Transparency =
    0.25

SearchStroke.Parent =
    SearchFrame

local SearchBox =
    Instance.new("TextBox")

SearchBox.Parent =
    SearchFrame

SearchBox.Position =
    UDim2.new(
        0,
        14,
        0,
        0
    )

SearchBox.Size =
    UDim2.new(
        1,
        -28,
        1,
        0
    )

SearchBox.BackgroundTransparency = 1

SearchBox.Text = ""

SearchBox.PlaceholderText =
    "Buscar..."

SearchBox.PlaceholderColor3 =
    Colors.SecondaryText

SearchBox.TextColor3 =
    Colors.Text

SearchBox.TextXAlignment =
    Enum.TextXAlignment.Left

SearchBox.Font =
    Enum.Font.Gotham

SearchBox.TextSize = 14

SearchBox.ClearTextOnFocus = false

--========================================================
-- SIDEBAR
--========================================================

local Sidebar =
    Instance.new("Frame")

Sidebar.Parent = MainFrame

Sidebar.Position =
    UDim2.new(
        0,
        12,
        0,
        77
    )

Sidebar.Size =
    UDim2.new(
        0,
        165,
        1,
        -89
    )

Sidebar.BackgroundColor3 =
    Colors.Sidebar

Sidebar.BorderSizePixel = 0

local SidebarCorner =
    Instance.new("UICorner")

SidebarCorner.CornerRadius =
    UDim.new(
        0,
        10
    )

SidebarCorner.Parent =
    Sidebar

local SidebarStroke =
    Instance.new("UIStroke")

SidebarStroke.Color =
    Colors.Border

SidebarStroke.Transparency =
    0.25

SidebarStroke.Parent =
    Sidebar

--========================================================
-- CONTENT
--========================================================

local Content =
    Instance.new("Frame")

Content.Parent = MainFrame

Content.Position =
    UDim2.new(
        0,
        187,
        0,
        77
    )

Content.Size =
    UDim2.new(
        1,
        -199,
        1,
        -89
    )

Content.BackgroundColor3 =
    Colors.Content

Content.BorderSizePixel = 0

local ContentCorner =
    Instance.new("UICorner")

ContentCorner.CornerRadius =
    UDim.new(
        0,
        10
    )

ContentCorner.Parent =
    Content

local ContentStroke =
    Instance.new("UIStroke")

ContentStroke.Color =
    Colors.Border

ContentStroke.Transparency =
    0.25

ContentStroke.Parent =
    Content

--========================================================
-- PÁGINAS
--========================================================

local Pages = {}

local function CreatePage(name)

    local Page =
        Instance.new("Frame")

    Page.Name = name

    Page.Parent = Content

    Page.Size =
        UDim2.new(
            1,
            0,
            1,
            0
        )

    Page.BackgroundTransparency = 1

    Page.Visible = false

    Pages[name] = Page

    return Page
end

local VisualsPage =
    CreatePage("Visuais")

local CombatPage =
    CreatePage("Combate")

local ExploitsPage =
    CreatePage("Exploits")

local ConfigsPage =
    CreatePage("Configs")

--========================================================
-- ÍCONE COMBATE
--========================================================

local function CreateCombatIcon(parent)

    local Holder =
        Instance.new("Frame")

    Holder.Parent = parent

    Holder.Position =
        UDim2.new(
            0,
            15,
            0.5,
            -11
        )

    Holder.Size =
        UDim2.new(
            0,
            22,
            0,
            22
        )

    Holder.BackgroundTransparency = 1

    local Circle =
        Instance.new("Frame")

    Circle.Parent = Holder

    Circle.AnchorPoint =
        Vector2.new(
            0.5,
            0.5
        )

    Circle.Position =
        UDim2.new(
            0.5,
            0,
            0.5,
            0
        )

    Circle.Size =
        UDim2.new(
            0,
            13,
            0,
            13
        )

    Circle.BackgroundTransparency = 1

    local Corner =
        Instance.new("UICorner")

    Corner.CornerRadius =
        UDim.new(
            1,
            0
        )

    Corner.Parent = Circle

    local Stroke =
        Instance.new("UIStroke")

    Stroke.Name =
        "CombatStroke"

    Stroke.Color =
        Colors.SecondaryText

    Stroke.Thickness = 1.5

    Stroke.Parent = Circle

    local Center =
        Instance.new("Frame")

    Center.Name =
        "CombatPart"

    Center.Parent =
        Holder

    Center.AnchorPoint =
        Vector2.new(
            0.5,
            0.5
        )

    Center.Position =
        UDim2.new(
            0.5,
            0,
            0.5,
            0
        )

    Center.Size =
        UDim2.new(
            0,
            3,
            0,
            3
        )

    Center.BackgroundColor3 =
        Colors.SecondaryText

    Center.BorderSizePixel = 0

    local CenterCorner =
        Instance.new("UICorner")

    CenterCorner.CornerRadius =
        UDim.new(
            1,
            0
        )

    CenterCorner.Parent =
        Center

    local function CreateLine(
        position,
        size
    )

        local Line =
            Instance.new("Frame")

        Line.Name =
            "CombatPart"

        Line.Parent =
            Holder

        Line.Position =
            position

        Line.Size =
            size

        Line.BackgroundColor3 =
            Colors.SecondaryText

        Line.BorderSizePixel = 0
    end

    CreateLine(
        UDim2.new(
            0.5,
            0,
            0,
            0
        ),

        UDim2.new(
            0,
            1,
            0,
            5
        )
    )

    CreateLine(
        UDim2.new(
            0.5,
            0,
            1,
            -5
        ),

        UDim2.new(
            0,
            1,
            0,
            5
        )
    )

    CreateLine(
        UDim2.new(
            0,
            0,
            0.5,
            0
        ),

        UDim2.new(
            0,
            5,
            0,
            1
        )
    )

    CreateLine(
        UDim2.new(
            1,
            -5,
            0.5,
            0
        ),

        UDim2.new(
            0,
            5,
            0,
            1
        )
    )

    return Holder
end

local function SetCombatColor(
    icon,
    color
)

    for _, object in
        ipairs(
            icon:GetDescendants()
        )
    do

        if object.Name ==
            "CombatPart"
        then

            object.BackgroundColor3 =
                color

        elseif object.Name ==
            "CombatStroke"
        then

            object.Color =
                color
        end
    end
end

--========================================================
-- SIDEBAR
--========================================================

local Buttons = {}

local CurrentTab =
    "Visuais"

local function SetTab(tabName)

    CurrentTab = tabName

    for name, page in
        pairs(Pages)
    do

        page.Visible =
            name == tabName
    end

    for name, info in
        pairs(Buttons)
    do

        local selected =
            name == tabName

        local target =
            selected
            and Colors.Selected
            or Colors.Sidebar

        TweenService:Create(
            info.Button,

            TweenInfo.new(
                0.15
            ),

            {
                BackgroundColor3 =
                    target
            }
        ):Play()

        local color =
            selected
            and Settings.AccentColor
            or Colors.SecondaryText

        info.Text.TextColor3 =
            color

        if info.IconType ==
            "Combat"
        then

            SetCombatColor(
                info.Icon,
                color
            )

        else

            info.Icon.TextColor3 =
                color
        end
    end
end

local function CreateSidebarButton(
    name,
    iconText,
    y,
    iconType
)

    local Button =
        Instance.new("TextButton")

    Button.Parent =
        Sidebar

    Button.Position =
        UDim2.new(
            0,
            8,
            0,
            y
        )

    Button.Size =
        UDim2.new(
            1,
            -16,
            0,
            52
        )

    Button.BackgroundColor3 =
        Colors.Sidebar

    Button.BorderSizePixel = 0

    Button.Text = ""

    Button.AutoButtonColor = false

    local Corner =
        Instance.new("UICorner")

    Corner.CornerRadius =
        UDim.new(
            0,
            9
        )

    Corner.Parent =
        Button

    local Icon

    if iconType ==
        "Combat"
    then

        Icon =
            CreateCombatIcon(
                Button
            )

    else

        Icon =
            Instance.new(
                "TextLabel"
            )

        Icon.Parent =
            Button

        Icon.Position =
            UDim2.new(
                0,
                15,
                0,
                0
            )

        Icon.Size =
            UDim2.new(
                0,
                30,
                1,
                0
            )

        Icon.BackgroundTransparency = 1

        Icon.Text =
            iconText

        Icon.TextColor3 =
            Colors.SecondaryText

        Icon.Font =
            Enum.Font.Gotham

        Icon.TextSize = 21
    end

    local Text =
        Instance.new("TextLabel")

    Text.Parent =
        Button

    Text.Position =
        UDim2.new(
            0,
            53,
            0,
            0
        )

    Text.Size =
        UDim2.new(
            1,
            -60,
            1,
            0
        )

    Text.BackgroundTransparency = 1

    Text.Text =
        name

    Text.TextColor3 =
        Colors.SecondaryText

    Text.TextXAlignment =
        Enum.TextXAlignment.Left

    Text.Font =
        Enum.Font.GothamMedium

    Text.TextSize = 15

    Buttons[name] = {

        Button = Button,

        Icon = Icon,

        Text = Text,

        IconType =
            iconType
    }

    Connect(
        Button.MouseEnter,

        function()

            if CurrentTab ~=
                name
            then

                TweenService:Create(
                    Button,

                    TweenInfo.new(
                        0.12
                    ),

                    {
                        BackgroundColor3 =
                            Colors.Hover
                    }
                ):Play()
            end
        end
    )

    Connect(
        Button.MouseLeave,

        function()

            if CurrentTab ~=
                name
            then

                TweenService:Create(
                    Button,

                    TweenInfo.new(
                        0.12
                    ),

                    {
                        BackgroundColor3 =
                            Colors.Sidebar
                    }
                ):Play()
            end
        end
    )

    Connect(
        Button.MouseButton1Click,

        function()
            SetTab(name)
        end
    )
end

CreateSidebarButton(
    "Visuais",
    "◉",
    10,
    "Text"
)

CreateSidebarButton(
    "Combate",
    "",
    72,
    "Combat"
)

CreateSidebarButton(
    "Exploits",
    ">_",
    134,
    "Text"
)

CreateSidebarButton(
    "Configs",
    "⚙",
    196,
    "Text"
)

--========================================================
-- ABA VISUAIS
-- SUB-ABAS: GERAL / INFORMAÇÕES / VIDA / EFEITOS
--========================================================

local VisualHeader =
    Instance.new("Frame")

VisualHeader.Parent =
    VisualsPage

VisualHeader.Position =
    UDim2.new(
        0,
        16,
        0,
        14
    )

VisualHeader.Size =
    UDim2.new(
        1,
        -32,
        0,
        42
    )

VisualHeader.BackgroundColor3 =
    Color3.fromRGB(
        14,
        14,
        14
    )

VisualHeader.BorderSizePixel = 0

local VisualHeaderCorner =
    Instance.new("UICorner")

VisualHeaderCorner.CornerRadius =
    UDim.new(
        0,
        8
    )

VisualHeaderCorner.Parent =
    VisualHeader

local VisualHeaderStroke =
    Instance.new("UIStroke")

VisualHeaderStroke.Color =
    Colors.Border

VisualHeaderStroke.Transparency =
    0.25

VisualHeaderStroke.Parent =
    VisualHeader

local VisualSubPages = {}
local VisualSubButtons = {}
local CurrentVisualSubTab = "Geral"

local function CreateVisualSubPage(name)

    local Page =
        Instance.new("Frame")

    Page.Name =
        name

    Page.Parent =
        VisualsPage

    Page.Position =
        UDim2.new(
            0,
            16,
            0,
            68
        )

    Page.Size =
        UDim2.new(
            1,
            -32,
            1,
            -82
        )

    Page.BackgroundTransparency = 1

    Page.Visible = false

    VisualSubPages[name] =
        Page

    return Page
end

local GeneralVisualPage =
    CreateVisualSubPage("Geral")

local InfoVisualPage =
    CreateVisualSubPage("Informações")

local HealthVisualPage =
    CreateVisualSubPage("Vida")

local EffectsVisualPage =
    CreateVisualSubPage("Efeitos")

local function SetVisualSubTab(name)

    CurrentVisualSubTab =
        name

    for pageName, page in
        pairs(VisualSubPages)
    do

        page.Visible =
            pageName == name
    end

    for buttonName, button in
        pairs(VisualSubButtons)
    do

        local selected =
            buttonName == name

        TweenService:Create(
            button,

            TweenInfo.new(
                0.12
            ),

            {
                BackgroundColor3 =
                    selected
                    and Colors.Selected
                    or Color3.fromRGB(
                        14,
                        14,
                        14
                    ),

                TextColor3 =
                    selected
                    and Settings.AccentColor
                    or Colors.SecondaryText
            }
        ):Play()
    end
end

local VisualSubTabNames = {
    "Geral",
    "Informações",
    "Vida",
    "Efeitos"
}

for index, name in
    ipairs(VisualSubTabNames)
do

    local Button =
        Instance.new("TextButton")

    Button.Name =
        name

    Button.Parent =
        VisualHeader

    Button.Position =
        UDim2.new(
            (index - 1) / 4,
            4,
            0,
            4
        )

    Button.Size =
        UDim2.new(
            0.25,
            -8,
            1,
            -8
        )

    Button.BackgroundColor3 =
        Color3.fromRGB(
            14,
            14,
            14
        )

    Button.BorderSizePixel = 0

    Button.Text =
        name

    Button.TextColor3 =
        Colors.SecondaryText

    Button.Font =
        Enum.Font.GothamMedium

    Button.TextSize = 12

    Button.AutoButtonColor = false

    local Corner =
        Instance.new("UICorner")

    Corner.CornerRadius =
        UDim.new(
            0,
            7
        )

    Corner.Parent =
        Button

    VisualSubButtons[name] =
        Button

    Connect(
        Button.MouseEnter,

        function()

            if CurrentVisualSubTab ~=
                name
            then

                TweenService:Create(
                    Button,

                    TweenInfo.new(
                        0.1
                    ),

                    {
                        BackgroundColor3 =
                            Colors.Hover
                    }
                ):Play()
            end
        end
    )

    Connect(
        Button.MouseLeave,

        function()

            if CurrentVisualSubTab ~=
                name
            then

                TweenService:Create(
                    Button,

                    TweenInfo.new(
                        0.1
                    ),

                    {
                        BackgroundColor3 =
                            Color3.fromRGB(
                                14,
                                14,
                                14
                            )
                    }
                ):Play()
            end
        end
    )

    Connect(
        Button.MouseButton1Click,

        function()
            SetVisualSubTab(name)
        end
    )
end

local VisualToggles = {}

local function CreateVisualToggle(
    parent,
    title,
    description,
    setting,
    y
)

    local Button =
        Instance.new(
            "TextButton"
        )

    Button.Parent =
        parent

    Button.Position =
        UDim2.new(
            0,
            0,
            0,
            y
        )

    Button.Size =
        UDim2.new(
            1,
            0,
            0,
            54
        )

    Button.BackgroundColor3 =
        Color3.fromRGB(
            15,
            15,
            15
        )

    Button.BorderSizePixel = 0

    Button.Text = ""

    Button.AutoButtonColor = false

    local ButtonCorner =
        Instance.new("UICorner")

    ButtonCorner.CornerRadius =
        UDim.new(
            0,
            8
        )

    ButtonCorner.Parent =
        Button

    local ButtonStroke =
        Instance.new("UIStroke")

    ButtonStroke.Color =
        Colors.Border

    ButtonStroke.Transparency =
        0.45

    ButtonStroke.Parent =
        Button

    local TitleLabel =
        Instance.new(
            "TextLabel"
        )

    TitleLabel.Parent =
        Button

    TitleLabel.Position =
        UDim2.new(
            0,
            12,
            0,
            6
        )

    TitleLabel.Size =
        UDim2.new(
            1,
            -86,
            0,
            21
        )

    TitleLabel.BackgroundTransparency = 1

    TitleLabel.Text =
        title

    TitleLabel.TextColor3 =
        Colors.Text

    TitleLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    TitleLabel.Font =
        Enum.Font.GothamMedium

    TitleLabel.TextSize = 14

    local Description =
        Instance.new(
            "TextLabel"
        )

    Description.Parent =
        Button

    Description.Position =
        UDim2.new(
            0,
            12,
            0,
            28
        )

    Description.Size =
        UDim2.new(
            1,
            -86,
            0,
            17
        )

    Description.BackgroundTransparency = 1

    Description.Text =
        description

    Description.TextColor3 =
        Colors.SecondaryText

    Description.TextXAlignment =
        Enum.TextXAlignment.Left

    Description.Font =
        Enum.Font.Gotham

    Description.TextSize = 11

    local Switch =
        Instance.new(
            "Frame"
        )

    Switch.Parent =
        Button

    Switch.AnchorPoint =
        Vector2.new(
            1,
            0.5
        )

    Switch.Position =
        UDim2.new(
            1,
            -12,
            0.5,
            0
        )

    Switch.Size =
        UDim2.new(
            0,
            42,
            0,
            22
        )

    Switch.BorderSizePixel = 0

    local SwitchCorner =
        Instance.new(
            "UICorner"
        )

    SwitchCorner.CornerRadius =
        UDim.new(
            1,
            0
        )

    SwitchCorner.Parent =
        Switch

    local Knob =
        Instance.new(
            "Frame"
        )

    Knob.Parent =
        Switch

    Knob.AnchorPoint =
        Vector2.new(
            0.5,
            0.5
        )

    Knob.Size =
        UDim2.new(
            0,
            16,
            0,
            16
        )

    Knob.BorderSizePixel = 0

    local KnobCorner =
        Instance.new(
            "UICorner"
        )

    KnobCorner.CornerRadius =
        UDim.new(
            1,
            0
        )

    KnobCorner.Parent =
        Knob

    local function Update(
        animated
    )

        local enabled =
            VisualSettings[
                setting
            ]

        local switchColor =
            enabled
            and Settings.AccentColor
            or Color3.fromRGB(
                48,
                48,
                48
            )

        local knobColor =
            enabled
            and Color3.fromRGB(
                20,
                20,
                20
            )
            or Color3.fromRGB(
                155,
                155,
                155
            )

        local knobPosition =
            enabled
            and UDim2.new(
                1,
                -11,
                0.5,
                0
            )
            or UDim2.new(
                0,
                11,
                0.5,
                0
            )

        if animated then

            TweenService:Create(
                Switch,

                TweenInfo.new(
                    0.15
                ),

                {
                    BackgroundColor3 =
                        switchColor
                }
            ):Play()

            TweenService:Create(
                Knob,

                TweenInfo.new(
                    0.15
                ),

                {
                    Position =
                        knobPosition,

                    BackgroundColor3 =
                        knobColor
                }
            ):Play()

        else

            Switch.BackgroundColor3 =
                switchColor

            Knob.Position =
                knobPosition

            Knob.BackgroundColor3 =
                knobColor
        end
    end

    Connect(
        Button.MouseEnter,

        function()

            TweenService:Create(
                Button,

                TweenInfo.new(
                    0.1
                ),

                {
                    BackgroundColor3 =
                        Colors.Hover
                }
            ):Play()
        end
    )

    Connect(
        Button.MouseLeave,

        function()

            TweenService:Create(
                Button,

                TweenInfo.new(
                    0.1
                ),

                {
                    BackgroundColor3 =
                        Color3.fromRGB(
                            15,
                            15,
                            15
                        )
                }
            ):Play()
        end
    )

    Connect(
        Button.MouseButton1Click,

        function()

            VisualSettings[
                setting
            ] =
                not VisualSettings[
                    setting
                ]

            Update(true)
        end
    )

    VisualToggles[
        setting
    ] = {
        Update = Update
    }

    Update(false)
end

--========================================================
-- GERAL
--========================================================

CreateVisualToggle(
    GeneralVisualPage,
    "Ativar ESP",
    "Ativa ou desativa todo o ESP.",
    "ESP",
    0
)

CreateVisualToggle(
    GeneralVisualPage,
    "Team Check",
    "Ignora jogadores do mesmo time.",
    "TeamCheck",
    62
)

CreateVisualToggle(
    GeneralVisualPage,
    "Usar cor dos times",
    "Usa a cor correspondente ao time.",
    "TeamColor",
    124
)

CreateVisualToggle(
    GeneralVisualPage,
    "Box",
    "Desenha uma caixa ao redor do jogador.",
    "Box",
    186
)

--========================================================
-- INFORMAÇÕES
--========================================================

CreateVisualToggle(
    InfoVisualPage,
    "Nomes",
    "Mostra o nome do jogador.",
    "Names",
    0
)

CreateVisualToggle(
    InfoVisualPage,
    "Distância (em metros)",
    "Mostra a distância até o jogador.",
    "Distance",
    62
)

CreateVisualToggle(
    InfoVisualPage,
    "Armas",
    "Mostra a arma ou ferramenta equipada.",
    "Weapons",
    124
)

--========================================================
-- VIDA
--========================================================

CreateVisualToggle(
    HealthVisualPage,
    "Barra de vida",
    "Mostra uma barra de vida.",
    "HealthBar",
    0
)

CreateVisualToggle(
    HealthVisualPage,
    "Vida",
    "Mostra a porcentagem de vida.",
    "Health",
    62
)

--========================================================
-- EFEITOS
--========================================================

CreateVisualToggle(
    EffectsVisualPage,
    "Tracers",
    "Desenha linhas até os jogadores.",
    "Tracers",
    0
)

CreateVisualToggle(
    EffectsVisualPage,
    "Chams",
    "Destaca os personagens.",
    "Chams",
    62
)

SetVisualSubTab("Geral")


--========================================================
-- ESP OBJECTS
--========================================================

local ESPObjects = {}

local function CreateESPObject(player)

    if player == LocalPlayer then
        return
    end

    if ESPObjects[player] then
        return
    end

    local Holder =
        Instance.new("Frame")

    Holder.Name =
        player.Name

    Holder.Parent =
        ESPContainer

    Holder.BackgroundTransparency = 1

    Holder.BorderSizePixel = 0

    Holder.Visible = false

    --====================================================
    -- BOX
    --====================================================

    local Box =
        Instance.new("Frame")

    Box.Parent =
        Holder

    Box.Size =
        UDim2.new(
            1,
            0,
            1,
            0
        )

    Box.BackgroundTransparency = 1

    Box.BorderSizePixel = 0

    local BoxStroke =
        Instance.new("UIStroke")

    BoxStroke.Parent =
        Box

    BoxStroke.Thickness = 1.5

    BoxStroke.Color =
        Color3.new(
            1,
            1,
            1
        )

    --====================================================
    -- NAME
    --====================================================

    local NameLabel =
        Instance.new("TextLabel")

    NameLabel.Parent =
        Holder

    NameLabel.AnchorPoint =
        Vector2.new(
            0.5,
            1
        )

    NameLabel.Position =
        UDim2.new(
            0.5,
            0,
            0,
            -4
        )

    NameLabel.Size =
        UDim2.new(
            0,
            220,
            0,
            18
        )

    NameLabel.BackgroundTransparency = 1

    NameLabel.Text =
        player.Name

    NameLabel.TextColor3 =
        Color3.new(
            1,
            1,
            1
        )

    NameLabel.TextStrokeTransparency =
        0

    NameLabel.TextStrokeColor3 =
        Color3.new(
            0,
            0,
            0
        )

    NameLabel.Font =
        Enum.Font.Gotham

    NameLabel.TextSize = 13

    --====================================================
    -- WEAPON
    --====================================================

    local WeaponLabel =
        Instance.new("TextLabel")

    WeaponLabel.Parent =
        Holder

    WeaponLabel.AnchorPoint =
        Vector2.new(
            0.5,
            0
        )

    WeaponLabel.Position =
        UDim2.new(
            0.5,
            0,
            1,
            3
        )

    WeaponLabel.Size =
        UDim2.new(
            0,
            220,
            0,
            17
        )

    WeaponLabel.BackgroundTransparency = 1

    WeaponLabel.Text =
        "Nenhuma"

    WeaponLabel.TextColor3 =
        Color3.fromRGB(
            210,
            210,
            210
        )

    WeaponLabel.TextStrokeTransparency =
        0

    WeaponLabel.Font =
        Enum.Font.Gotham

    WeaponLabel.TextSize = 11

    --====================================================
    -- DISTANCE
    --====================================================

    local DistanceLabel =
        Instance.new("TextLabel")

    DistanceLabel.Parent =
        Holder

    DistanceLabel.AnchorPoint =
        Vector2.new(
            0,
            0.5
        )

    DistanceLabel.Position =
        UDim2.new(
            1,
            5,
            0.5,
            0
        )

    DistanceLabel.Size =
        UDim2.new(
            0,
            100,
            0,
            18
        )

    DistanceLabel.BackgroundTransparency = 1

    DistanceLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    DistanceLabel.TextColor3 =
        Color3.new(
            1,
            1,
            1
        )

    DistanceLabel.TextStrokeTransparency =
        0

    DistanceLabel.Font =
        Enum.Font.Gotham

    DistanceLabel.TextSize = 11

    --====================================================
    -- HEALTH BAR BG
    --====================================================

    local HealthBackground =
        Instance.new("Frame")

    HealthBackground.Parent =
        Holder

    HealthBackground.AnchorPoint =
        Vector2.new(
            1,
            0
        )

    HealthBackground.Position =
        UDim2.new(
            0,
            -8,
            0,
            0
        )

    HealthBackground.Size =
        UDim2.new(
            0,
            6,
            1,
            0
        )

    HealthBackground.BackgroundColor3 =
        Color3.fromRGB(
            10,
            10,
            10
        )

    HealthBackground.BorderSizePixel = 0

    local HealthBackgroundStroke =
        Instance.new("UIStroke")

    HealthBackgroundStroke.Parent =
        HealthBackground

    HealthBackgroundStroke.Color =
        Color3.fromRGB(
            0,
            0,
            0
        )

    HealthBackgroundStroke.Thickness = 1

    --====================================================
    -- HEALTH FILL
    --====================================================

    local HealthFill =
        Instance.new("Frame")

    HealthFill.Parent =
        HealthBackground

    HealthFill.AnchorPoint =
        Vector2.new(
            0,
            1
        )

    HealthFill.Position =
        UDim2.new(
            0,
            1,
            1,
            -1
        )

    HealthFill.Size =
        UDim2.new(
            1,
            -2,
            1,
            -2
        )

    HealthFill.BackgroundColor3 =
        Color3.fromRGB(
            0,
            255,
            0
        )

    HealthFill.BorderSizePixel = 0

    --====================================================
    -- HEALTH TEXT
    --====================================================

    local HealthText =
        Instance.new("TextLabel")

    HealthText.Parent =
        Holder

    HealthText.AnchorPoint =
        Vector2.new(
            1,
            0.5
        )

    HealthText.Position =
        UDim2.new(
            0,
            -16,
            0,
            0
        )

    HealthText.Size =
        UDim2.new(
            0,
            55,
            0,
            18
        )

    HealthText.BackgroundTransparency = 1

    HealthText.TextXAlignment =
        Enum.TextXAlignment.Right

    HealthText.TextColor3 =
        Color3.new(
            1,
            1,
            1
        )

    HealthText.TextStrokeTransparency =
        0

    HealthText.Font =
        Enum.Font.Gotham

    HealthText.TextSize = 11

    --====================================================
    -- TRACER
    --====================================================

    local Tracer =
        Instance.new("Frame")

    Tracer.Parent =
        ESPContainer

    Tracer.AnchorPoint =
        Vector2.new(
            0.5,
            0.5
        )

    Tracer.BackgroundColor3 =
        Color3.new(
            1,
            1,
            1
        )

    Tracer.BorderSizePixel = 0

    Tracer.Size =
        UDim2.new(
            0,
            1,
            0,
            1
        )

    Tracer.Visible = false

    --====================================================
    -- DATA
    --====================================================

    ESPObjects[player] = {

        Holder =
            Holder,

        Box =
            Box,

        BoxStroke =
            BoxStroke,

        Name =
            NameLabel,

        Weapon =
            WeaponLabel,

        Distance =
            DistanceLabel,

        HealthBackground =
            HealthBackground,

        HealthFill =
            HealthFill,

        HealthText =
            HealthText,

        Tracer =
            Tracer,

        Highlight = nil
    }
end

local function RemoveESPObject(
    player
)

    local data =
        ESPObjects[player]

    if not data then
        return
    end

    if data.Highlight then

        pcall(function()
            data.Highlight:Destroy()
        end)
    end

    pcall(function()
        data.Holder:Destroy()
    end)

    pcall(function()
        data.Tracer:Destroy()
    end)

    ESPObjects[player] = nil
end

--========================================================
-- CRIAR ESP DE JOGADORES
--========================================================

for _, player in
    ipairs(
        Players:GetPlayers()
    )
do

    if player ~=
        LocalPlayer
    then

        CreateESPObject(
            player
        )
    end
end

Connect(
    Players.PlayerAdded,

    function(player)

        if player ~=
            LocalPlayer
        then

            CreateESPObject(
                player
            )
        end
    end
)

Connect(
    Players.PlayerRemoving,

    function(player)

        RemoveESPObject(
            player
        )
    end
)

--========================================================
-- FUNÇÕES DO ESP
--========================================================

local function HideESP(data)

    data.Holder.Visible =
        false

    data.Tracer.Visible =
        false

    if data.Highlight then
        data.Highlight.Enabled =
            false
    end
end

local function GetESPColor(
    player
)

    if VisualSettings.TeamColor
        and player.Team
    then

        return player.TeamColor.Color
    end

    return Settings.AccentColor
end

local function UpdateTracer(
    tracer,
    from,
    to,
    color
)

    local delta =
        to - from

    local distance =
        delta.Magnitude

    local center =
        (
            from + to
        ) / 2

    tracer.Position =
        UDim2.fromOffset(
            center.X,
            center.Y
        )

    tracer.Size =
        UDim2.fromOffset(
            distance,
            1
        )

    tracer.Rotation =
        math.deg(
            math.atan2(
                delta.Y,
                delta.X
            )
        )

    tracer.BackgroundColor3 =
        color
end

--========================================================
-- LOOP DO ESP
--========================================================

Connect(
    RunService.RenderStepped,

    function()

        Camera =
            workspace.CurrentCamera
            or Camera

        if not Camera then
            return
        end

        for player, data in
            pairs(ESPObjects)
        do

            if not
                VisualSettings.ESP
            then

                HideESP(data)

                continue
            end

            local character =
                player.Character

            local root =
                character
                and character:FindFirstChild(
                    "HumanoidRootPart"
                )

            local humanoid =
                character
                and character:FindFirstChildOfClass(
                    "Humanoid"
                )

            if not character
                or not root
                or not humanoid
                or humanoid.Health <= 0
            then

                HideESP(data)

                continue
            end

            --================================================
            -- TEAM CHECK
            --================================================

            if VisualSettings.TeamCheck
                and player.Team ~= nil
                and LocalPlayer.Team ~= nil
                and player.Team ==
                    LocalPlayer.Team
            then

                HideESP(data)

                continue
            end

            --================================================
            -- SCREEN POSITION
            --================================================

            local rootPosition,
                onScreen =
                Camera:WorldToViewportPoint(
                    root.Position
                )

            if not onScreen
                or rootPosition.Z <= 0
            then

                HideESP(data)

                continue
            end

            local head =
                character:FindFirstChild(
                    "Head"
                )

            local headPosition =
                head
                and head.Position
                or root.Position
                    + Vector3.new(
                        0,
                        2.5,
                        0
                    )

            local top =
                Camera:WorldToViewportPoint(
                    headPosition
                    +
                    Vector3.new(
                        0,
                        0.7,
                        0
                    )
                )

            local bottom =
                Camera:WorldToViewportPoint(
                    root.Position
                    -
                    Vector3.new(
                        0,
                        3.2,
                        0
                    )
                )

            local height =
                math.abs(
                    bottom.Y
                    -
                    top.Y
                )

            if height < 2 then

                HideESP(data)

                continue
            end

            local width =
                height * 0.55

            local x =
                rootPosition.X
                -
                width / 2

            local y =
                top.Y

            local color =
                GetESPColor(
                    player
                )

            --================================================
            -- HOLDER
            --================================================

            data.Holder.Visible =
                true

            data.Holder.Position =
                UDim2.fromOffset(
                    x,
                    y
                )

            data.Holder.Size =
                UDim2.fromOffset(
                    width,
                    height
                )

            --================================================
            -- BOX
            --================================================

            data.Box.Visible =
                VisualSettings.Box

            data.BoxStroke.Color =
                color

            --================================================
            -- NAME
            --================================================

            data.Name.Visible =
                VisualSettings.Names

            data.Name.Text =
                player.Name

            data.Name.TextColor3 =
                color

            --================================================
            -- DISTANCE
            --================================================

            data.Distance.Visible =
                VisualSettings.Distance

            if VisualSettings.Distance then

                local studs =
                    (
                        root.Position
                        -
                        Camera.CFrame.Position
                    ).Magnitude

                -- Aproximação:
                -- 1 stud ~= 0.28 metro

                local meters =
                    math.floor(
                        studs * 0.28
                    )

                data.Distance.Text =
                    tostring(
                        meters
                    )
                    ..
                    "m"

                data.Distance.TextColor3 =
                    color
            end

            --================================================
            -- WEAPON
            --================================================

            data.Weapon.Visible =
                VisualSettings.Weapons

            if VisualSettings.Weapons then

                local tool =
                    character:FindFirstChildOfClass(
                        "Tool"
                    )

                data.Weapon.Text =
                    tool
                    and tool.Name
                    or "Nenhuma"
            end

            --================================================
            -- HEALTH
            --================================================

            local maxHealth =
                math.max(
                    humanoid.MaxHealth,
                    1
                )

            local healthRatio =
                math.clamp(
                    humanoid.Health
                    /
                    maxHealth,

                    0,
                    1
                )

            data.HealthBackground.Visible =
                VisualSettings.HealthBar

            data.HealthFill.Size =
                UDim2.new(
                    1,
                    -2,
                    healthRatio,
                    -2
                )

            -- Verde: 70% a 100%
            -- Amarelo: 30% a 69%
            -- Vermelho: 0% a 29%

            local healthColor

            if healthRatio >= 0.70 then
                healthColor =
                    Color3.fromRGB(
                        0,
                        235,
                        45
                    )
            elseif healthRatio >= 0.30 then
                healthColor =
                    Color3.fromRGB(
                        255,
                        220,
                        0
                    )
            else
                healthColor =
                    Color3.fromRGB(
                        245,
                        35,
                        35
                    )
            end

            data.HealthFill.BackgroundColor3 =
                healthColor

            data.HealthText.Visible =
                VisualSettings.Health

            data.HealthText.Text =
                tostring(
                    math.floor(
                        healthRatio
                        *
                        100
                    )
                )
                ..
                "%"

            -- Faz o número acompanhar o topo da barra de vida.
            -- Assim ele fica ao lado do nível atual de HP.

            data.HealthText.Position =
                UDim2.new(
                    0,
                    -16,
                    1 - healthRatio,
                    -9
                )

            --================================================
            -- TRACERS
            --================================================

            data.Tracer.Visible =
                VisualSettings.Tracers

            if VisualSettings.Tracers then

                local screenSize =
                    Camera.ViewportSize

                local from =
                    Vector2.new(
                        screenSize.X / 2,
                        screenSize.Y
                    )

                local to =
                    Vector2.new(
                        rootPosition.X,
                        bottom.Y
                    )

                UpdateTracer(
                    data.Tracer,
                    from,
                    to,
                    color
                )
            end

            --================================================
            -- CHAMS
            --================================================

            if VisualSettings.Chams then

                if not data.Highlight
                    or not data.Highlight.Parent
                then

                    local Highlight =
                        Instance.new(
                            "Highlight"
                        )

                    Highlight.Name =
                        "MacacuHighlight"

                    Highlight.DepthMode =
                        Enum.HighlightDepthMode.AlwaysOnTop

                    Highlight.FillTransparency =
                        0.75

                    Highlight.OutlineTransparency =
                        0

                    Highlight.Parent =
                        character

                    data.Highlight =
                        Highlight
                end

                data.Highlight.Enabled =
                    true

                data.Highlight.FillColor =
                    color

                data.Highlight.OutlineColor =
                    color

            elseif data.Highlight then

                data.Highlight.Enabled =
                    false
            end
        end
    end
)

--========================================================
-- ABA COMBATE - AIMBOT + HITBOX EXPANDER
--========================================================

local CombatSettings = {
    AimbotEnabled = false,
    ShowFOV = false,
    AimbotBind = Enum.UserInputType.MouseButton2,
    AimbotMethod = "Mouse",
    AimbotTeamCheck = false,
    AimbotAliveCheck = false,
    AimbotWallCheck = false,
    AimbotPart = "Cabeça",
    FOVSize = 150,
    HorizontalSmoothing = 6,
    VerticalSmoothing = 6,
    Prediction = 0,

    HitboxEnabled = false,
    HitboxTeamCheck = false,
    HitboxAliveCheck = false,
    HitboxSize = 6,
    HitboxTransparency = 65,
    HitboxPart = "Cabeça"
}

local CombatAccentObjects = {}
local CombatToggleRefreshers = {}
local CombatDropdownClosers = {}
local ListeningForAimbotKey = false
local AimbotHeld = false
local OriginalHitboxParts = {}
local HitboxVisuals = {}

local function RegisterCombatAccent(object, property)
    table.insert(CombatAccentObjects, {
        Object = object,
        Property = property or "BackgroundColor3"
    })
end

local function RefreshCombatAccent()
    for _, item in ipairs(CombatAccentObjects) do
        if item.Object and item.Object.Parent then
            pcall(function()
                item.Object[item.Property] = Settings.AccentColor
            end)
        end
    end

    for _, refresh in pairs(CombatToggleRefreshers) do
        refresh(false)
    end
end

local function CreateCombatPanel(titleText, xScale, widthScale)
    local Panel = Instance.new("Frame")
    Panel.Parent = CombatPage
    Panel.Position = UDim2.new(xScale, 0, 0, 12)
    Panel.Size = UDim2.new(widthScale, -9, 1, -24)
    Panel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Panel.BorderSizePixel = 0

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Panel

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Colors.Border
    Stroke.Transparency = 0.2
    Stroke.Thickness = 1
    Stroke.Parent = Panel

    local Title = Instance.new("TextLabel")
    Title.Parent = Panel
    Title.Position = UDim2.new(0, 14, 0, 9)
    Title.Size = UDim2.new(1, -28, 0, 24)
    Title.BackgroundTransparency = 1
    Title.Text = titleText
    Title.TextColor3 = Colors.Text
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 15

    local Line = Instance.new("Frame")
    Line.Parent = Panel
    Line.Position = UDim2.new(0, 12, 0, 39)
    Line.Size = UDim2.new(1, -24, 0, 1)
    Line.BackgroundColor3 = Colors.Border
    Line.BackgroundTransparency = 0.3
    Line.BorderSizePixel = 0

    return Panel
end

local AimbotPanel = CreateCombatPanel("Aimbot", 0.018, 0.59)
local HitboxPanel = CreateCombatPanel("Hitbox Expander", 0.615, 0.367)

local function CreateCombatToggle(parent, titleText, settingName, y)
    local Button = Instance.new("TextButton")
    Button.Parent = parent
    Button.Position = UDim2.new(0, 12, 0, y)
    Button.Size = UDim2.new(1, -24, 0, 27)
    Button.BackgroundTransparency = 1
    Button.Text = ""
    Button.AutoButtonColor = false

    local Label = Instance.new("TextLabel")
    Label.Parent = Button
    Label.Position = UDim2.new(0, 2, 0, 0)
    Label.Size = UDim2.new(1, -52, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = titleText
    Label.TextColor3 = Colors.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 12

    local Switch = Instance.new("Frame")
    Switch.Parent = Button
    Switch.AnchorPoint = Vector2.new(1, 0.5)
    Switch.Position = UDim2.new(1, -2, 0.5, 0)
    Switch.Size = UDim2.new(0, 36, 0, 19)
    Switch.BorderSizePixel = 0

    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = Switch

    local Knob = Instance.new("Frame")
    Knob.Parent = Switch
    Knob.AnchorPoint = Vector2.new(0.5, 0.5)
    Knob.Size = UDim2.new(0, 13, 0, 13)
    Knob.BorderSizePixel = 0

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    local function Update(animated)
        local enabled = CombatSettings[settingName]
        local switchColor = enabled and Settings.AccentColor or Color3.fromRGB(48, 48, 48)
        local knobColor = enabled and Color3.fromRGB(18, 18, 18) or Color3.fromRGB(155, 155, 155)
        local knobPosition = enabled and UDim2.new(1, -9.5, 0.5, 0) or UDim2.new(0, 9.5, 0.5, 0)

        if animated then
            TweenService:Create(Switch, TweenInfo.new(0.14), {BackgroundColor3 = switchColor}):Play()
            TweenService:Create(Knob, TweenInfo.new(0.14), {
                Position = knobPosition,
                BackgroundColor3 = knobColor
            }):Play()
        else
            Switch.BackgroundColor3 = switchColor
            Knob.Position = knobPosition
            Knob.BackgroundColor3 = knobColor
        end
    end

    Connect(Button.MouseButton1Click, function()
        CombatSettings[settingName] = not CombatSettings[settingName]
        Update(true)
    end)

    CombatToggleRefreshers[settingName] = Update
    Update(false)
end

local function CreateCombatValueButton(parent, titleText, y, initialText, onClick)
    local Label = Instance.new("TextLabel")
    Label.Parent = parent
    Label.Position = UDim2.new(0, 14, 0, y)
    Label.Size = UDim2.new(0.52, -14, 0, 28)
    Label.BackgroundTransparency = 1
    Label.Text = titleText
    Label.TextColor3 = Colors.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 12

    local Button = Instance.new("TextButton")
    Button.Parent = parent
    Button.AnchorPoint = Vector2.new(1, 0)
    Button.Position = UDim2.new(1, -14, 0, y)
    Button.Size = UDim2.new(0.45, 0, 0, 27)
    Button.BackgroundColor3 = Colors.Selected
    Button.BorderSizePixel = 0
    Button.Text = initialText
    Button.TextColor3 = Colors.Text
    Button.Font = Enum.Font.GothamMedium
    Button.TextSize = 11
    Button.AutoButtonColor = false

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 7)
    Corner.Parent = Button

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Colors.Border
    Stroke.Transparency = 0.2
    Stroke.Parent = Button

    Connect(Button.MouseButton1Click, function()
        onClick(Button)
    end)

    return Button
end

local function CreateCombatDropdown(parent, titleText, y, values, getValue, setValue)
    local Open = false
    local Popup

    local Button = CreateCombatValueButton(parent, titleText, y, getValue(), function(valueButton)
        Open = not Open
        if Popup then
            Popup.Visible = Open
        end
    end)

    Popup = Instance.new("Frame")
    Popup.Parent = parent
    Popup.Position = UDim2.new(0.53, 0, 0, y + 29)
    Popup.Size = UDim2.new(0.45, -14, 0, (#values * 24) + 8)
    Popup.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    Popup.BorderSizePixel = 0
    Popup.Visible = false
    Popup.ZIndex = 30

    local PopupCorner = Instance.new("UICorner")
    PopupCorner.CornerRadius = UDim.new(0, 7)
    PopupCorner.Parent = Popup

    local PopupStroke = Instance.new("UIStroke")
    PopupStroke.Color = Colors.Border
    PopupStroke.Transparency = 0.1
    PopupStroke.Parent = Popup

    for i, value in ipairs(values) do
        local Option = Instance.new("TextButton")
        Option.Parent = Popup
        Option.Position = UDim2.new(0, 4, 0, 4 + ((i - 1) * 24))
        Option.Size = UDim2.new(1, -8, 0, 22)
        Option.BackgroundTransparency = 1
        Option.Text = value
        Option.TextColor3 = Colors.SecondaryText
        Option.Font = Enum.Font.Gotham
        Option.TextSize = 10
        Option.ZIndex = 31

        Connect(Option.MouseButton1Click, function()
            setValue(value)
            Button.Text = value
            Open = false
            Popup.Visible = false
        end)
    end

    table.insert(CombatDropdownClosers, function()
        Open = false
        Popup.Visible = false
    end)

    return Button
end

local function CreateCompactSlider(parent, titleText, y, minValue, maxValue, defaultValue, suffix, decimals, callback)
    local Label = Instance.new("TextLabel")
    Label.Parent = parent
    Label.Position = UDim2.new(0, 14, 0, y)
    Label.Size = UDim2.new(0.62, 0, 0, 16)
    Label.BackgroundTransparency = 1
    Label.Text = titleText
    Label.TextColor3 = Colors.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 11

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Parent = parent
    ValueLabel.AnchorPoint = Vector2.new(1, 0)
    ValueLabel.Position = UDim2.new(1, -14, 0, y)
    ValueLabel.Size = UDim2.new(0, 75, 0, 16)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.TextColor3 = Colors.SecondaryText
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Font = Enum.Font.Gotham
    ValueLabel.TextSize = 10

    -- Área grande e invisível para facilitar clicar/arrastar.
    local HitArea = Instance.new("TextButton")
    HitArea.Parent = parent
    HitArea.Position = UDim2.new(0, 8, 0, y + 14)
    HitArea.Size = UDim2.new(1, -16, 0, 24)
    HitArea.BackgroundTransparency = 1
    HitArea.Text = ""
    HitArea.AutoButtonColor = false
    HitArea.BorderSizePixel = 0
    HitArea.ZIndex = 8

    local Bar = Instance.new("Frame")
    Bar.Parent = HitArea
    Bar.AnchorPoint = Vector2.new(0, 0.5)
    Bar.Position = UDim2.new(0, 6, 0.5, 0)
    Bar.Size = UDim2.new(1, -12, 0, 5)
    Bar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Bar.BorderSizePixel = 0
    Bar.ZIndex = 9

    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(1, 0)
    BarCorner.Parent = Bar

    local Fill = Instance.new("Frame")
    Fill.Parent = Bar
    Fill.BackgroundColor3 = Settings.AccentColor
    Fill.BorderSizePixel = 0
    Fill.ZIndex = 10
    RegisterCombatAccent(Fill)

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = Fill

    -- Bolinha maior: antes era 11x11.
    local Knob = Instance.new("Frame")
    Knob.Parent = Bar
    Knob.AnchorPoint = Vector2.new(0.5, 0.5)
    Knob.Size = UDim2.new(0, 17, 0, 17)
    Knob.BackgroundColor3 = Color3.fromRGB(235, 235, 235)
    Knob.BorderSizePixel = 0
    Knob.ZIndex = 11

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    local dragging = false

    local function FormatValue(value)
        if decimals and decimals > 0 then
            return string.format("%." .. decimals .. "f", value) .. suffix
        end

        return tostring(math.floor(value + 0.5)) .. suffix
    end

    local function SetByPercent(percent)
        percent = math.clamp(percent, 0, 1)

        local value =
            minValue
            +
            ((maxValue - minValue) * percent)

        Fill.Size = UDim2.new(percent, 0, 1, 0)
        Knob.Position = UDim2.new(percent, 0, 0.5, 0)
        ValueLabel.Text = FormatValue(value)

        callback(value)
    end

    local initialPercent =
        math.clamp(
            (defaultValue - minValue)
            /
            (maxValue - minValue),
            0,
            1
        )

    Fill.Size = UDim2.new(initialPercent, 0, 1, 0)
    Knob.Position = UDim2.new(initialPercent, 0, 0.5, 0)
    ValueLabel.Text = FormatValue(defaultValue)

    local function UpdateFromX(x)
        if Bar.AbsoluteSize.X <= 0 then
            return
        end

        SetByPercent(
            (x - Bar.AbsolutePosition.X)
            /
            Bar.AbsoluteSize.X
        )
    end

    Connect(HitArea.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            UpdateFromX(UserInputService:GetMouseLocation().X)
        end
    end)

    Connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Atualiza todo frame enquanto estiver segurando.
    -- Isso evita perder o arraste quando o mouse sai da barra.
    Connect(RunService.RenderStepped, function()
        if dragging then
            UpdateFromX(UserInputService:GetMouseLocation().X)
        end
    end)

    return {
        HitArea = HitArea,
        Bar = Bar,
        Fill = Fill,
        Knob = Knob,
        ValueLabel = ValueLabel
    }
end

-- AIMBOT CONTROLS
CreateCombatToggle(AimbotPanel, "Ativar aimbot", "AimbotEnabled", 49)
CreateCombatToggle(AimbotPanel, "Mostrar FOV", "ShowFOV", 76)
CreateCombatToggle(AimbotPanel, "Team Check", "AimbotTeamCheck", 103)
CreateCombatToggle(AimbotPanel, "Alive Check", "AimbotAliveCheck", 130)
CreateCombatToggle(AimbotPanel, "Wall Check", "AimbotWallCheck", 157)

local function BindName(bind)
    if typeof(bind) == "EnumItem" then
        if bind.EnumType == Enum.UserInputType then
            if bind == Enum.UserInputType.MouseButton1 then return "Mouse 1" end
            if bind == Enum.UserInputType.MouseButton2 then return "Mouse 2" end
            if bind == Enum.UserInputType.MouseButton3 then return "Mouse 3" end
        end
        return bind.Name
    end
    return tostring(bind)
end

local AimbotKeyButton = CreateCombatValueButton(AimbotPanel, "Tecla do aimbot", 188, BindName(CombatSettings.AimbotBind), function(button)
    ListeningForAimbotKey = true
    button.Text = "..."
end)

CreateCombatDropdown(
    AimbotPanel,
    "Método",
    220,
    {"Mouse", "Câmera"},
    function() return CombatSettings.AimbotMethod end,
    function(value) CombatSettings.AimbotMethod = value end
)

CreateCombatDropdown(
    AimbotPanel,
    "Parte",
    252,
    {"Cabeça", "Torso", "Braço direito", "Braço esquerdo", "Perna direita", "Perna esquerda"},
    function() return CombatSettings.AimbotPart end,
    function(value) CombatSettings.AimbotPart = value end
)

CreateCompactSlider(AimbotPanel, "Tamanho do FOV", 278, 40, 500, CombatSettings.FOVSize, " px", 0, function(value)
    CombatSettings.FOVSize = value
end)

CreateCompactSlider(AimbotPanel, "Horizontal smoothing", 309, 1, 20, CombatSettings.HorizontalSmoothing, "", 1, function(value)
    CombatSettings.HorizontalSmoothing = math.max(value, 1)
end)

CreateCompactSlider(AimbotPanel, "Vertical smoothing", 340, 1, 20, CombatSettings.VerticalSmoothing, "", 1, function(value)
    CombatSettings.VerticalSmoothing = math.max(value, 1)
end)

CreateCompactSlider(AimbotPanel, "Prediction", 371, 0, 250, CombatSettings.Prediction, " ms", 0, function(value)
    CombatSettings.Prediction = value
end)

-- HITBOX CONTROLS
CreateCombatToggle(HitboxPanel, "Ativar hitbox", "HitboxEnabled", 49)
CreateCombatToggle(HitboxPanel, "Team Check", "HitboxTeamCheck", 76)
CreateCombatToggle(HitboxPanel, "Alive Check", "HitboxAliveCheck", 103)

CreateCombatDropdown(
    HitboxPanel,
    "Parte",
    142,
    {"Cabeça", "Torso", "Braço direito", "Braço esquerdo", "Perna direita", "Perna esquerda"},
    function() return CombatSettings.HitboxPart end,
    function(value) CombatSettings.HitboxPart = value end
)

CreateCompactSlider(HitboxPanel, "Tamanho da hitbox", 183, 1, 25, CombatSettings.HitboxSize, "", 1, function(value)
    CombatSettings.HitboxSize = value
end)

CreateCompactSlider(HitboxPanel, "Transparência", 221, 0, 100, CombatSettings.HitboxTransparency, "%", 0, function(value)
    CombatSettings.HitboxTransparency =
        math.clamp(value, 0, 100)
end)

--========================================================
-- FOV VISUAL - SEGUE O MOUSE
--========================================================

local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "MacacuFOV"
FOVCircle.Parent = ESPContainer
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = false
FOVCircle.ZIndex = 50

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVCircle

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Parent = FOVCircle
FOVStroke.Color = Settings.AccentColor
FOVStroke.Thickness = 1.5
FOVStroke.Transparency = 0.1
RegisterCombatAccent(FOVStroke, "Color")

--========================================================
-- TARGET HELPERS
--========================================================

local function GetCharacterPart(character, selection)
    if not character then return nil end

    local names

    if selection == "Cabeça" then
        names = {"Head"}
    elseif selection == "Torso" then
        names = {"UpperTorso", "Torso", "LowerTorso"}
    elseif selection == "Braço direito" then
        names = {"RightHand", "RightLowerArm", "RightUpperArm", "Right Arm"}
    elseif selection == "Braço esquerdo" then
        names = {"LeftHand", "LeftLowerArm", "LeftUpperArm", "Left Arm"}
    elseif selection == "Perna direita" then
        names = {"RightFoot", "RightLowerLeg", "RightUpperLeg", "Right Leg"}
    elseif selection == "Perna esquerda" then
        names = {"LeftFoot", "LeftLowerLeg", "LeftUpperLeg", "Left Leg"}
    end

    for _, name in ipairs(names or {}) do
        local part = character:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            return part
        end
    end

    return character:FindFirstChild("HumanoidRootPart")
end

local function IsSameTeam(player)
    return player.Team ~= nil
        and LocalPlayer.Team ~= nil
        and player.Team == LocalPlayer.Team
end

local function HasLineOfSight(character, targetPart)
    if not Camera or not targetPart then
        return false
    end

    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {
        LocalPlayer.Character,
        Camera
    }
    params.IgnoreWater = true

    local result = workspace:Raycast(origin, direction, params)

    if not result then
        return true
    end

    return result.Instance and result.Instance:IsDescendantOf(character)
end

local function GetPredictedPosition(part)
    local predictionSeconds = CombatSettings.Prediction / 1000
    return part.Position + (part.AssemblyLinearVelocity * predictionSeconds)
end

local function GetBestAimbotTarget()
    if not Camera then
        return nil, nil, nil
    end

    local mousePosition = UserInputService:GetMouseLocation()
    local bestPlayer
    local bestPart
    local bestScreen
    local bestDistance = CombatSettings.FOVSize

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local part = GetCharacterPart(character, CombatSettings.AimbotPart)

            if character and humanoid and part then
                if CombatSettings.AimbotTeamCheck and IsSameTeam(player) then
                    continue
                end

                if CombatSettings.AimbotAliveCheck and humanoid.Health <= 0 then
                    continue
                end

                if CombatSettings.AimbotWallCheck and not HasLineOfSight(character, part) then
                    continue
                end

                local predictedPosition = GetPredictedPosition(part)
                local screen, visible = Camera:WorldToViewportPoint(predictedPosition)

                if visible and screen.Z > 0 then
                    local screenVector = Vector2.new(screen.X, screen.Y)
                    local distance = (screenVector - mousePosition).Magnitude

                    if distance <= bestDistance then
                        bestDistance = distance
                        bestPlayer = player
                        bestPart = part
                        bestScreen = screenVector
                    end
                end
            end
        end
    end

    return bestPlayer, bestPart, bestScreen
end

local function InputMatchesBind(input, bind)
    if typeof(bind) ~= "EnumItem" then
        return false
    end

    if bind.EnumType == Enum.KeyCode then
        return input.KeyCode == bind
    end

    if bind.EnumType == Enum.UserInputType then
        return input.UserInputType == bind
    end

    return false
end

local function ApplyAimbot(targetPart, targetScreen)
    if not Camera or not targetPart or not targetScreen then
        return
    end

    local mousePosition = UserInputService:GetMouseLocation()
    local delta = targetScreen - mousePosition

    local smoothX = math.max(CombatSettings.HorizontalSmoothing, 1)
    local smoothY = math.max(CombatSettings.VerticalSmoothing, 1)

    local moveX = delta.X / smoothX
    local moveY = delta.Y / smoothY

    if CombatSettings.AimbotMethod == "Mouse" then
        local mover = mousemoverel

        if not mover and syn then
            mover = syn.mousemoverel
        end

        if mover then
            pcall(function()
                mover(moveX, moveY)
            end)
        end
    else
        local adjustedPoint = mousePosition + Vector2.new(moveX, moveY)
        local ray = Camera:ViewportPointToRay(adjustedPoint.X, adjustedPoint.Y)
        Camera.CFrame = CFrame.lookAt(
            Camera.CFrame.Position,
            Camera.CFrame.Position + ray.Direction
        )
    end
end

--========================================================
-- HITBOX HELPERS
--========================================================

local function SaveOriginalHitbox(part)
    if not part or OriginalHitboxParts[part] then
        return
    end

    OriginalHitboxParts[part] = {
        Size = part.Size,
        Transparency = part.Transparency,
        LocalTransparencyModifier = part.LocalTransparencyModifier,
        CanCollide = part.CanCollide,
        Massless = part.Massless
    }
end

local function GetOrCreateHitboxVisual(part)
    local visual = HitboxVisuals[part]

    if visual and visual.Parent then
        return visual
    end

    visual = Instance.new("SphereHandleAdornment")
    visual.Name = "MacacuHitboxVisual"
    visual.Adornee = part
    visual.AlwaysOnTop = false
    visual.ZIndex = 1
    visual.Color3 = Settings.AccentColor
    visual.Transparency = 0.65
    visual.Radius = math.max(
        part.Size.X,
        part.Size.Y,
        part.Size.Z
    ) / 2
    visual.Parent = ESPGui

    HitboxVisuals[part] = visual

    return visual
end

local function RemoveHitboxVisual(part)
    local visual = HitboxVisuals[part]

    if visual then
        pcall(function()
            visual:Destroy()
        end)

        HitboxVisuals[part] = nil
    end
end

local function RestoreHitboxPart(part)
    local data = OriginalHitboxParts[part]

    RemoveHitboxVisual(part)

    if not data then
        return
    end

    if part and part.Parent then
        pcall(function()
            part.Size = data.Size
            part.Transparency = data.Transparency
            part.LocalTransparencyModifier = data.LocalTransparencyModifier or 0
            part.CanCollide = data.CanCollide
            part.Massless = data.Massless
        end)
    end

    OriginalHitboxParts[part] = nil
end

local function RestoreAllHitboxes()
    local parts = {}

    for part in pairs(OriginalHitboxParts) do
        table.insert(parts, part)
    end

    for _, part in ipairs(parts) do
        RestoreHitboxPart(part)
    end

    local visualParts = {}

    for part in pairs(HitboxVisuals) do
        table.insert(visualParts, part)
    end

    for _, part in ipairs(visualParts) do
        RemoveHitboxVisual(part)
    end
end

local HitboxAccumulator = 0

Connect(RunService.Heartbeat, function(deltaTime)
    HitboxAccumulator += deltaTime

    if HitboxAccumulator < 0.05 then
        return
    end

    HitboxAccumulator = 0

    if not CombatSettings.HitboxEnabled then
        RestoreAllHitboxes()
        return
    end

    local activeParts = {}

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local part = GetCharacterPart(character, CombatSettings.HitboxPart)

            local allowed = character and humanoid and part

            if allowed and CombatSettings.HitboxTeamCheck and IsSameTeam(player) then
                allowed = false
            end

            if allowed and CombatSettings.HitboxAliveCheck and humanoid.Health <= 0 then
                allowed = false
            end

            if allowed then
                activeParts[part] = true
                SaveOriginalHitbox(part)

                local size = CombatSettings.HitboxSize
                part.Size = Vector3.new(size, size, size)

                -- A geometria real usada pela hitbox fica invisível.
                -- Isso evita diferenças entre cabeça clássica, MeshPart,
                -- dynamic head, decals e outros tipos de avatar.
                part.Transparency = 1
                part.LocalTransparencyModifier = 1

                -- A esfera abaixo é apenas a visualização da hitbox.
                -- A transparência do slider controla este objeto,
                -- portanto fica idêntica em todos os personagens.
                local visual =
                    GetOrCreateHitboxVisual(part)

                visual.Radius =
                    size / 2

                visual.Color3 =
                    Settings.AccentColor

                visual.Transparency =
                    math.clamp(
                        CombatSettings.HitboxTransparency / 100,
                        0,
                        1
                    )

                part.CanCollide = false
                part.Massless = true
            end
        end
    end

    local restore = {}
    for part in pairs(OriginalHitboxParts) do
        if not activeParts[part] then
            table.insert(restore, part)
        end
    end

    for _, part in ipairs(restore) do
        RestoreHitboxPart(part)
    end
end)

--========================================================
-- AIMBOT + FOV LOOP
--========================================================

Connect(RunService.RenderStepped, function()
    Camera = workspace.CurrentCamera or Camera

    local mousePosition = UserInputService:GetMouseLocation()
    local diameter = CombatSettings.FOVSize * 2

    FOVCircle.Position = UDim2.fromOffset(mousePosition.X, mousePosition.Y)
    FOVCircle.Size = UDim2.fromOffset(diameter, diameter)
    FOVCircle.Visible = CombatSettings.ShowFOV

    if CombatSettings.AimbotEnabled and AimbotHeld then
        local _, targetPart, targetScreen = GetBestAimbotTarget()
        if targetPart and targetScreen then
            ApplyAimbot(targetPart, targetScreen)
        end
    end
end)

Connect(UserInputService.InputBegan, function(input, gameProcessed)
    if ListeningForAimbotKey then
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
            CombatSettings.AimbotBind = input.KeyCode
            AimbotKeyButton.Text = BindName(input.KeyCode)
            ListeningForAimbotKey = false

            if RefreshKeybindOverlay then
                RefreshKeybindOverlay()
            end

            return
        elseif input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.MouseButton2
            or input.UserInputType == Enum.UserInputType.MouseButton3
        then
            CombatSettings.AimbotBind = input.UserInputType
            AimbotKeyButton.Text = BindName(input.UserInputType)
            ListeningForAimbotKey = false

            if RefreshKeybindOverlay then
                RefreshKeybindOverlay()
            end

            return
        end
    end

    if gameProcessed then
        return
    end

    if InputMatchesBind(input, CombatSettings.AimbotBind) then
        AimbotHeld = true
    end
end)

Connect(UserInputService.InputEnded, function(input)
    if InputMatchesBind(input, CombatSettings.AimbotBind) then
        AimbotHeld = false
    end
end)



--========================================================
-- ABA EXPLOITS
-- DOIS PAINÉIS SEMPRE ABERTOS
--========================================================

local ExploitSettings = {
    InfiniteJump = false,
    InfiniteJumpBind = nil,

    Fly = false,
    FlyBind = nil,
    FlySpeed = 60,

    Speed = false,
    SpeedBind = nil,
    WalkSpeed = 32,

    SuperJump = false,
    SuperJumpBind = nil,
    JumpPower = 90,

    Noclip = false,
    NoclipBind = nil,

    ShowKeybinds = false
}

local ExploitToggleRefreshers = {}
local ExploitBindButtons = {}
local ListeningForExploitBind = nil

-- Forward declarations:
-- essas funções são atribuídas mais abaixo, mas os callbacks
-- dos botões já podem referenciá-las com segurança.
local RefreshKeybindOverlay
local SetExploitState

local function CreateExploitPanel(titleText, xScale, widthScale)
    local Panel = Instance.new("Frame")
    Panel.Parent = ExploitsPage
    Panel.Position = UDim2.new(xScale, 0, 0, 12)
    Panel.Size = UDim2.new(widthScale, -9, 1, -24)
    Panel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Panel.BorderSizePixel = 0

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Panel

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Colors.Border
    Stroke.Transparency = 0.2
    Stroke.Thickness = 1
    Stroke.Parent = Panel

    local Title = Instance.new("TextLabel")
    Title.Parent = Panel
    Title.Position = UDim2.new(0, 14, 0, 9)
    Title.Size = UDim2.new(1, -28, 0, 24)
    Title.BackgroundTransparency = 1
    Title.Text = titleText
    Title.TextColor3 = Colors.Text
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 15

    local Line = Instance.new("Frame")
    Line.Parent = Panel
    Line.Position = UDim2.new(0, 12, 0, 39)
    Line.Size = UDim2.new(1, -24, 0, 1)
    Line.BackgroundColor3 = Colors.Border
    Line.BackgroundTransparency = 0.3
    Line.BorderSizePixel = 0

    return Panel
end

local MovementPanel =
    CreateExploitPanel("Movimento", 0.018, 0.49)

local CharacterPanel =
    CreateExploitPanel("Personagem", 0.515, 0.467)

local function RefreshExploitAccent()
    for _, refresh in pairs(ExploitToggleRefreshers) do
        refresh(false)
    end
end

local function CreateExploitToggle(parent, titleText, settingName, y)
    local Button = Instance.new("TextButton")
    Button.Parent = parent
    Button.Position = UDim2.new(0, 12, 0, y)
    Button.Size = UDim2.new(1, -24, 0, 26)
    Button.BackgroundTransparency = 1
    Button.Text = ""
    Button.AutoButtonColor = false

    local Label = Instance.new("TextLabel")
    Label.Parent = Button
    Label.Position = UDim2.new(0, 2, 0, 0)
    Label.Size = UDim2.new(1, -52, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = titleText
    Label.TextColor3 = Colors.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 12

    local Switch = Instance.new("Frame")
    Switch.Parent = Button
    Switch.AnchorPoint = Vector2.new(1, 0.5)
    Switch.Position = UDim2.new(1, -2, 0.5, 0)
    Switch.Size = UDim2.new(0, 36, 0, 19)
    Switch.BorderSizePixel = 0

    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = Switch

    local Knob = Instance.new("Frame")
    Knob.Parent = Switch
    Knob.AnchorPoint = Vector2.new(0.5, 0.5)
    Knob.Size = UDim2.new(0, 13, 0, 13)
    Knob.BorderSizePixel = 0

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    local function Update(animated)
        local enabled = ExploitSettings[settingName]
        local switchColor =
            enabled and Settings.AccentColor
            or Color3.fromRGB(48, 48, 48)

        local knobColor =
            enabled and Color3.fromRGB(18, 18, 18)
            or Color3.fromRGB(155, 155, 155)

        local knobPosition =
            enabled and UDim2.new(1, -9.5, 0.5, 0)
            or UDim2.new(0, 9.5, 0.5, 0)

        if animated then
            TweenService:Create(
                Switch,
                TweenInfo.new(0.14),
                {BackgroundColor3 = switchColor}
            ):Play()

            TweenService:Create(
                Knob,
                TweenInfo.new(0.14),
                {
                    Position = knobPosition,
                    BackgroundColor3 = knobColor
                }
            ):Play()
        else
            Switch.BackgroundColor3 = switchColor
            Knob.Position = knobPosition
            Knob.BackgroundColor3 = knobColor
        end
    end

    Connect(Button.MouseButton1Click, function()
        local newValue =
            not ExploitSettings[settingName]

        if SetExploitState then
            SetExploitState(
                settingName,
                newValue
            )
        else
            -- Fallback defensivo. Normalmente nunca será necessário,
            -- pois o usuário só consegue clicar depois que o script termina.
            ExploitSettings[settingName] =
                newValue

            Update(true)

            if RefreshKeybindOverlay then
                RefreshKeybindOverlay()
            end
        end
    end)

    ExploitToggleRefreshers[settingName] = Update
    Update(false)
end

local function ExploitBindName(bind)
    if not bind then
        return "Nenhuma"
    end
    return BindName(bind)
end

local function CreateExploitBind(parent, titleText, settingName, y)
    local Button =
        CreateCombatValueButton(
            parent,
            titleText,
            y,
            ExploitBindName(ExploitSettings[settingName]),
            function(valueButton)
                ListeningForExploitBind = settingName
                valueButton.Text = "..."
            end
        )

    ExploitBindButtons[settingName] = Button
    return Button
end

-- PAINEL MOVIMENTO
CreateExploitToggle(MovementPanel, "Infinite Jump", "InfiniteJump", 49)
CreateExploitBind(MovementPanel, "Keybind", "InfiniteJumpBind", 77)

CreateExploitToggle(MovementPanel, "Fly", "Fly", 112)
CreateExploitBind(MovementPanel, "Keybind", "FlyBind", 140)

CreateCompactSlider(
    MovementPanel,
    "Velocidade do Fly",
    172,
    10,
    200,
    ExploitSettings.FlySpeed,
    "",
    0,
    function(value)
        ExploitSettings.FlySpeed = math.floor(value + 0.5)
    end
)

CreateExploitToggle(MovementPanel, "Speed", "Speed", 213)
CreateExploitBind(MovementPanel, "Keybind", "SpeedBind", 241)

CreateCompactSlider(
    MovementPanel,
    "Velocidade",
    273,
    16,
    150,
    ExploitSettings.WalkSpeed,
    "",
    0,
    function(value)
        ExploitSettings.WalkSpeed = math.floor(value + 0.5)
    end
)

-- PAINEL PERSONAGEM
CreateExploitToggle(CharacterPanel, "Super Jump", "SuperJump", 49)
CreateExploitBind(CharacterPanel, "Keybind", "SuperJumpBind", 77)

CreateCompactSlider(
    CharacterPanel,
    "Altura do pulo",
    109,
    50,
    250,
    ExploitSettings.JumpPower,
    "",
    0,
    function(value)
        ExploitSettings.JumpPower = math.floor(value + 0.5)
    end
)

CreateExploitToggle(CharacterPanel, "Noclip", "Noclip", 154)
CreateExploitBind(CharacterPanel, "Keybind", "NoclipBind", 182)

--========================================================
-- KEYBIND OVERLAY
--========================================================

local KeybindOverlay = Instance.new("Frame")
KeybindOverlay.Name = "MacacuKeybinds"
KeybindOverlay.Parent = ScreenGui
KeybindOverlay.Position = UDim2.new(0, 18, 0.5, -115)
KeybindOverlay.Size = UDim2.new(0, 250, 0, 180)
KeybindOverlay.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
KeybindOverlay.BackgroundTransparency = 0.78
KeybindOverlay.BorderSizePixel = 0
KeybindOverlay.Visible = ExploitSettings.ShowKeybinds

local KeybindCorner = Instance.new("UICorner")
KeybindCorner.CornerRadius = UDim.new(0, 9)
KeybindCorner.Parent = KeybindOverlay

local KeybindStroke = Instance.new("UIStroke")
KeybindStroke.Parent = KeybindOverlay
KeybindStroke.Color = Colors.Border
KeybindStroke.Transparency = 0.72

local KeybindTitle = Instance.new("TextLabel")
KeybindTitle.Parent = KeybindOverlay
KeybindTitle.Position = UDim2.new(0, 12, 0, 8)
KeybindTitle.Size = UDim2.new(1, -24, 0, 22)
KeybindTitle.BackgroundTransparency = 1
KeybindTitle.Text = "Exploit Keybinds"
KeybindTitle.TextColor3 = Colors.Text
KeybindTitle.TextXAlignment = Enum.TextXAlignment.Left
KeybindTitle.Font = Enum.Font.GothamBold
KeybindTitle.TextSize = 14

local KeybindLine = Instance.new("Frame")
KeybindLine.Parent = KeybindOverlay
KeybindLine.Position = UDim2.new(0, 10, 0, 35)
KeybindLine.Size = UDim2.new(1, -20, 0, 1)
KeybindLine.BackgroundColor3 = Colors.Border
KeybindLine.BorderSizePixel = 0

local KeybindList = Instance.new("Frame")
KeybindList.Parent = KeybindOverlay
KeybindList.Position = UDim2.new(0, 10, 0, 43)
KeybindList.Size = UDim2.new(1, -20, 1, -53)
KeybindList.BackgroundTransparency = 1

local KeybindLayout = Instance.new("UIListLayout")
KeybindLayout.Parent = KeybindList
KeybindLayout.Padding = UDim.new(0, 4)

local KeybindRows = {}

local function CreateKeybindRow()
    local Row = Instance.new("Frame")
    Row.Parent = KeybindList
    Row.Size = UDim2.new(1, 0, 0, 22)
    Row.BackgroundTransparency = 1

    local Bind = Instance.new("TextLabel")
    Bind.Name = "Bind"
    Bind.Parent = Row
    Bind.Size = UDim2.new(0, 82, 1, 0)
    Bind.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
    Bind.BorderSizePixel = 0
    Bind.TextColor3 = Settings.AccentColor
    Bind.Font = Enum.Font.GothamMedium
    Bind.TextSize = 10

    local BindCorner = Instance.new("UICorner")
    BindCorner.CornerRadius = UDim.new(0, 5)
    BindCorner.Parent = Bind

    local Function = Instance.new("TextLabel")
    Function.Name = "Function"
    Function.Parent = Row
    Function.Position = UDim2.new(0, 90, 0, 0)
    Function.Size = UDim2.new(1, -90, 1, 0)
    Function.BackgroundTransparency = 1
    Function.TextColor3 = Colors.Text
    Function.TextXAlignment = Enum.TextXAlignment.Left
    Function.Font = Enum.Font.Gotham
    Function.TextSize = 10

    return Row
end

for i = 1, 5 do
    KeybindRows[i] = CreateKeybindRow()
end

RefreshKeybindOverlay = function()
    local entries = {
        {
            Bind = ExploitSettings.InfiniteJumpBind,
            Name = "Infinite Jump",
            Enabled = ExploitSettings.InfiniteJump
        },
        {
            Bind = ExploitSettings.FlyBind,
            Name = "Fly",
            Enabled = ExploitSettings.Fly
        },
        {
            Bind = ExploitSettings.SpeedBind,
            Name = "Speed",
            Enabled = ExploitSettings.Speed
        },
        {
            Bind = ExploitSettings.SuperJumpBind,
            Name = "Super Jump",
            Enabled = ExploitSettings.SuperJump
        },
        {
            Bind = ExploitSettings.NoclipBind,
            Name = "Noclip",
            Enabled = ExploitSettings.Noclip
        }
    }

    for index, row in ipairs(KeybindRows) do
        local entry = entries[index]
        local bindLabel = row:FindFirstChild("Bind")
        local functionLabel = row:FindFirstChild("Function")

        row.Visible = entry ~= nil

        if entry then
            bindLabel.Text = ExploitBindName(entry.Bind)
            bindLabel.TextColor3 = Settings.AccentColor

            functionLabel.Text =
                entry.Name
                ..
                "  "
                ..
                (
                    entry.Enabled
                    and "[ON]"
                    or "[OFF]"
                )

            functionLabel.TextColor3 =
                entry.Enabled
                and Color3.fromRGB(90, 220, 120)
                or Color3.fromRGB(200, 200, 200)
        end
    end

    KeybindOverlay.Visible =
        ExploitSettings.ShowKeybinds
end

RefreshKeybindOverlay()

--========================================================
-- MOVEMENT STATE
--========================================================

local OriginalWalkSpeed = nil
local OriginalJumpPower = nil
local OriginalJumpHeight = nil
local OriginalAutoRotate = nil
local OriginalCollisions = {}

local FlyVelocity = nil
local FlyGyro = nil

local function GetLocalCharacterData()
    local character = LocalPlayer.Character
    if not character then
        return nil
    end

    local humanoid =
        character:FindFirstChildOfClass("Humanoid")

    local root =
        character:FindFirstChild("HumanoidRootPart")

    return character, humanoid, root
end

local function StopFly()
    if FlyVelocity then
        pcall(function() FlyVelocity:Destroy() end)
        FlyVelocity = nil
    end

    if FlyGyro then
        pcall(function() FlyGyro:Destroy() end)
        FlyGyro = nil
    end

    local _, humanoid = GetLocalCharacterData()

    if humanoid and OriginalAutoRotate ~= nil then
        humanoid.AutoRotate = OriginalAutoRotate
    end

    OriginalAutoRotate = nil
end

local function RestoreSpeed()
    local _, humanoid = GetLocalCharacterData()

    if humanoid and OriginalWalkSpeed then
        humanoid.WalkSpeed = OriginalWalkSpeed
    end

    OriginalWalkSpeed = nil
end

local function RestoreJump()
    local _, humanoid = GetLocalCharacterData()

    if not humanoid then
        return
    end

    if humanoid.UseJumpPower then
        if OriginalJumpPower then
            humanoid.JumpPower = OriginalJumpPower
        end
    else
        if OriginalJumpHeight then
            humanoid.JumpHeight = OriginalJumpHeight
        end
    end

    OriginalJumpPower = nil
    OriginalJumpHeight = nil
end

local function RestoreNoclip()
    local parts = {}

    for part in pairs(OriginalCollisions) do
        table.insert(parts, part)
    end

    for _, part in ipairs(parts) do
        if part and part.Parent then
            pcall(function()
                part.CanCollide = OriginalCollisions[part]
            end)
        end

        OriginalCollisions[part] = nil
    end
end

SetExploitState = function(settingName, value)
    ExploitSettings[settingName] = value

    local refresh = ExploitToggleRefreshers[settingName]
    if refresh then
        refresh(true)
    end

    if RefreshKeybindOverlay then
        RefreshKeybindOverlay()
    end

    if settingName == "Fly" and not value then
        StopFly()
    elseif settingName == "Speed" and not value then
        RestoreSpeed()
    elseif settingName == "SuperJump" and not value then
        RestoreJump()
    elseif settingName == "Noclip" and not value then
        RestoreNoclip()
    end
end

local function ToggleExploit(settingName)
    SetExploitState(
        settingName,
        not ExploitSettings[settingName]
    )
end

Connect(UserInputService.JumpRequest, function()
    if not ExploitSettings.InfiniteJump then
        return
    end

    local _, humanoid = GetLocalCharacterData()

    if humanoid then
        humanoid:ChangeState(
            Enum.HumanoidStateType.Jumping
        )
    end
end)

Connect(RunService.Stepped, function()
    local character, humanoid, root =
        GetLocalCharacterData()

    if not character or not humanoid or not root then
        return
    end

    if ExploitSettings.Speed then
        if OriginalWalkSpeed == nil then
            OriginalWalkSpeed = humanoid.WalkSpeed
        end

        humanoid.WalkSpeed = ExploitSettings.WalkSpeed
    end

    if ExploitSettings.SuperJump then
        if humanoid.UseJumpPower then
            if OriginalJumpPower == nil then
                OriginalJumpPower = humanoid.JumpPower
            end

            humanoid.JumpPower = ExploitSettings.JumpPower
        else
            if OriginalJumpHeight == nil then
                OriginalJumpHeight = humanoid.JumpHeight
            end

            humanoid.JumpHeight =
                math.max(
                    7.2,
                    ExploitSettings.JumpPower / 7
                )
        end
    end

    if ExploitSettings.Noclip then
        for _, object in ipairs(character:GetDescendants()) do
            if object:IsA("BasePart") then
                if OriginalCollisions[object] == nil then
                    OriginalCollisions[object] = object.CanCollide
                end

                object.CanCollide = false
            end
        end
    end

    if ExploitSettings.Fly then
        if not FlyVelocity or not FlyVelocity.Parent then
            FlyVelocity = Instance.new("BodyVelocity")
            FlyVelocity.Name = "MacacuFlyVelocity"
            FlyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            FlyVelocity.P = 9000
            FlyVelocity.Parent = root

            FlyGyro = Instance.new("BodyGyro")
            FlyGyro.Name = "MacacuFlyGyro"
            FlyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            FlyGyro.P = 9000
            FlyGyro.Parent = root

            OriginalAutoRotate = humanoid.AutoRotate
            humanoid.AutoRotate = false
        end

        local move = Vector3.zero
        local camera = workspace.CurrentCamera

        if camera then
            local forward = camera.CFrame.LookVector
            local right = camera.CFrame.RightVector

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                move += forward
            end

            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                move -= forward
            end

            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                move += right
            end

            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                move -= right
            end

            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                move += Vector3.new(0, 1, 0)
            end

            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
                or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
            then
                move -= Vector3.new(0, 1, 0)
            end

            if move.Magnitude > 0 then
                move = move.Unit
            end

            FlyVelocity.Velocity =
                move * ExploitSettings.FlySpeed

            local flatForward =
                Vector3.new(
                    forward.X,
                    0,
                    forward.Z
                )

            if flatForward.Magnitude > 0.001 then
                FlyGyro.CFrame =
                    CFrame.lookAt(
                        root.Position,
                        root.Position + flatForward
                    )
            end
        end
    elseif FlyVelocity or FlyGyro then
        StopFly()
    end
end)

Connect(LocalPlayer.CharacterAdded, function()
    StopFly()
    OriginalWalkSpeed = nil
    OriginalJumpPower = nil
    OriginalJumpHeight = nil
    OriginalCollisions = {}
end)

--========================================================
-- EXPLOIT KEYBINDS
--========================================================

local function BindMatches(input, bind)
    if not bind then
        return false
    end

    if bind.EnumType == Enum.KeyCode then
        return input.KeyCode == bind
    end

    if bind.EnumType == Enum.UserInputType then
        return input.UserInputType == bind
    end

    return false
end

local function CaptureExploitBind(input)
    if not ListeningForExploitBind then
        return false
    end

    local chosen = nil

    if input.UserInputType == Enum.UserInputType.Keyboard
        and input.KeyCode ~= Enum.KeyCode.Unknown
    then
        chosen = input.KeyCode

    elseif input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.MouseButton2
        or input.UserInputType == Enum.UserInputType.MouseButton3
    then
        chosen = input.UserInputType
    end

    if chosen then
        local settingName = ListeningForExploitBind
        ExploitSettings[settingName] = chosen

        local button = ExploitBindButtons[settingName]
        if button then
            button.Text = ExploitBindName(chosen)
        end

        ListeningForExploitBind = nil
        RefreshKeybindOverlay()
        return true
    end

    return false
end

Connect(UserInputService.InputBegan, function(input, gameProcessed)
    if CaptureExploitBind(input) then
        return
    end

    if gameProcessed then
        return
    end

    if BindMatches(input, ExploitSettings.InfiniteJumpBind) then
        ToggleExploit("InfiniteJump")
    end

    if BindMatches(input, ExploitSettings.FlyBind) then
        ToggleExploit("Fly")
    end

    if BindMatches(input, ExploitSettings.SpeedBind) then
        ToggleExploit("Speed")
    end

    if BindMatches(input, ExploitSettings.SuperJumpBind) then
        ToggleExploit("SuperJump")
    end

    if BindMatches(input, ExploitSettings.NoclipBind) then
        ToggleExploit("Noclip")
    end
end)

--========================================================
-- CONFIGS HELPERS
--========================================================

local function ConfigLabel(
    title,
    description,
    y
)

    local Label =
        Instance.new(
            "TextLabel"
        )

    Label.Parent =
        ConfigsPage

    Label.Position =
        UDim2.new(
            0,
            24,
            0,
            y
        )

    Label.Size =
        UDim2.new(
            1,
            -48,
            0,
            22
        )

    Label.BackgroundTransparency = 1

    Label.Text =
        title

    Label.TextColor3 =
        Colors.Text

    Label.TextXAlignment =
        Enum.TextXAlignment.Left

    Label.Font =
        Enum.Font.GothamMedium

    Label.TextSize = 15

    local Description =
        Instance.new(
            "TextLabel"
        )

    Description.Parent =
        ConfigsPage

    Description.Position =
        UDim2.new(
            0,
            24,
            0,
            y + 22
        )

    Description.Size =
        UDim2.new(
            1,
            -48,
            0,
            18
        )

    Description.BackgroundTransparency = 1

    Description.Text =
        description

    Description.TextColor3 =
        Colors.SecondaryText

    Description.TextXAlignment =
        Enum.TextXAlignment.Left

    Description.Font =
        Enum.Font.Gotham

    Description.TextSize = 12
end

local function SmallButton(
    text,
    y
)

    local Button =
        Instance.new(
            "TextButton"
        )

    Button.Parent =
        ConfigsPage

    Button.Position =
        UDim2.new(
            1,
            -124,
            0,
            y
        )

    Button.Size =
        UDim2.new(
            0,
            100,
            0,
            32
        )

    Button.BackgroundColor3 =
        Colors.Selected

    Button.BorderSizePixel = 0

    Button.Text =
        text

    Button.TextColor3 =
        Colors.Text

    Button.Font =
        Enum.Font.GothamMedium

    Button.TextSize = 12

    local Corner =
        Instance.new(
            "UICorner"
        )

    Corner.CornerRadius =
        UDim.new(
            0,
            8
        )

    Corner.Parent =
        Button

    return Button
end

--========================================================
-- MENU KEY
--========================================================

ConfigLabel(
    "Tecla do menu",
    "Tecla usada para abrir ou fechar o menu.",
    18
)

local KeyButton =
    SmallButton(
        Settings.MenuKey.Name,
        22
    )

local ListeningForKey =
    false

Connect(
    KeyButton.MouseButton1Click,

    function()

        ListeningForKey =
            true

        KeyButton.Text =
            "..."
    end
)

--========================================================
-- COR DO MENU
--========================================================

ConfigLabel(
    "Cor do menu",
    "Escolha a cor de destaque da interface.",
    82
)

local ColorPreview =
    Instance.new(
        "TextButton"
    )

ColorPreview.Parent =
    ConfigsPage

ColorPreview.Position =
    UDim2.new(
        1,
        -58,
        0,
        88
    )

ColorPreview.Size =
    UDim2.new(
        0,
        34,
        0,
        34
    )

ColorPreview.Text = ""

ColorPreview.BackgroundColor3 =
    Settings.AccentColor

ColorPreview.BorderSizePixel = 0

local ColorCorner =
    Instance.new(
        "UICorner"
    )

ColorCorner.CornerRadius =
    UDim.new(
        1,
        0
    )

ColorCorner.Parent =
    ColorPreview

local ColorPicker =
    Instance.new("Frame")

ColorPicker.Parent =
    ConfigsPage

ColorPicker.Position =
    UDim2.new(
        1,
        -246,
        0,
        125
    )

ColorPicker.Size =
    UDim2.new(
        0,
        222,
        0,
        55
    )

ColorPicker.BackgroundColor3 =
    Color3.fromRGB(
        22,
        22,
        22
    )

ColorPicker.BorderSizePixel = 0

ColorPicker.Visible = false

local PickerCorner =
    Instance.new(
        "UICorner"
    )

PickerCorner.CornerRadius =
    UDim.new(
        0,
        8
    )

PickerCorner.Parent =
    ColorPicker

local Palette = {

    Color3.fromRGB(
        240,
        240,
        240
    ),

    Color3.fromRGB(
        80,
        160,
        255
    ),

    Color3.fromRGB(
        170,
        100,
        255
    ),

    Color3.fromRGB(
        255,
        80,
        120
    ),

    Color3.fromRGB(
        60,
        210,
        120
    ),

    Color3.fromRGB(
        255,
        170,
        55
    )
}

local function UpdateAccent(
    color
)

    Settings.AccentColor =
        color

    ColorPreview.BackgroundColor3 =
        color

    SetTab(CurrentTab)

    for _, toggle in
        pairs(
            VisualToggles
        )
    do

        toggle.Update(
            false
        )
    end

    if RefreshCombatAccent then
        RefreshCombatAccent()
    end

    if RefreshExploitAccent then
        RefreshExploitAccent()
    end

    if RefreshKeybindOverlay then
        RefreshKeybindOverlay()
    end
end

for index, color in
    ipairs(Palette)
do

    local Swatch =
        Instance.new(
            "TextButton"
        )

    Swatch.Parent =
        ColorPicker

    Swatch.Position =
        UDim2.new(
            0,
            10
            +
            (
                (
                    index - 1
                )
                *
                35
            ),
            0,
            13
        )

    Swatch.Size =
        UDim2.new(
            0,
            28,
            0,
            28
        )

    Swatch.Text = ""

    Swatch.BackgroundColor3 =
        color

    Swatch.BorderSizePixel = 0

    local Corner =
        Instance.new(
            "UICorner"
        )

    Corner.CornerRadius =
        UDim.new(
            1,
            0
        )

    Corner.Parent =
        Swatch

    Connect(
        Swatch.MouseButton1Click,

        function()

            UpdateAccent(
                color
            )

            ColorPicker.Visible =
                false
        end
    )
end

Connect(
    ColorPreview.MouseButton1Click,

    function()

        ColorPicker.Visible =
            not ColorPicker.Visible
    end
)

--========================================================
-- SLIDER
--========================================================

local SliderFills = {}

local function CreateSlider(
    title,
    description,
    y,
    minimum,
    maximum,
    defaultValue,
    callback
)

    ConfigLabel(
        title,
        description,
        y
    )

    local Value =
        Instance.new(
            "TextLabel"
        )

    Value.Parent =
        ConfigsPage

    Value.Position =
        UDim2.new(
            1,
            -92,
            0,
            y
        )

    Value.Size =
        UDim2.new(
            0,
            68,
            0,
            22
        )

    Value.BackgroundTransparency = 1

    Value.Text =
        tostring(
            defaultValue
        )
        ..
        "%"

    Value.TextColor3 =
        Colors.SecondaryText

    Value.TextXAlignment =
        Enum.TextXAlignment.Right

    Value.Font =
        Enum.Font.Gotham

    Value.TextSize = 12

    local Bar =
        Instance.new(
            "Frame"
        )

    Bar.Parent =
        ConfigsPage

    Bar.Position =
        UDim2.new(
            0,
            24,
            0,
            y + 48
        )

    Bar.Size =
        UDim2.new(
            1,
            -48,
            0,
            5
        )

    Bar.BackgroundColor3 =
        Color3.fromRGB(
            45,
            45,
            45
        )

    Bar.BorderSizePixel = 0

    local BarCorner =
        Instance.new(
            "UICorner"
        )

    BarCorner.CornerRadius =
        UDim.new(
            1,
            0
        )

    BarCorner.Parent =
        Bar

    local percent =
        (
            defaultValue
            -
            minimum
        )
        /
        (
            maximum
            -
            minimum
        )

    local Fill =
        Instance.new(
            "Frame"
        )

    Fill.Parent =
        Bar

    Fill.Size =
        UDim2.new(
            percent,
            0,
            1,
            0
        )

    Fill.BackgroundColor3 =
        Settings.AccentColor

    Fill.BorderSizePixel = 0

    local FillCorner =
        Instance.new(
            "UICorner"
        )

    FillCorner.CornerRadius =
        UDim.new(
            1,
            0
        )

    FillCorner.Parent =
        Fill

    table.insert(
        SliderFills,
        Fill
    )

    local Knob =
        Instance.new(
            "Frame"
        )

    Knob.Parent =
        Bar

    Knob.AnchorPoint =
        Vector2.new(
            0.5,
            0.5
        )

    Knob.Position =
        UDim2.new(
            percent,
            0,
            0.5,
            0
        )

    Knob.Size =
        UDim2.new(
            0,
            14,
            0,
            14
        )

    Knob.BackgroundColor3 =
        Color3.fromRGB(
            235,
            235,
            235
        )

    Knob.BorderSizePixel = 0

    local KnobCorner =
        Instance.new(
            "UICorner"
        )

    KnobCorner.CornerRadius =
        UDim.new(
            1,
            0
        )

    KnobCorner.Parent =
        Knob

    local Dragging =
        false

    local function Update(
        x
    )

        local percentage =
            math.clamp(
                (
                    x
                    -
                    Bar.AbsolutePosition.X
                )
                /
                Bar.AbsoluteSize.X,

                0,
                1
            )

        local value =
            minimum
            +
            (
                (
                    maximum
                    -
                    minimum
                )
                *
                percentage
            )

        Fill.Size =
            UDim2.new(
                percentage,
                0,
                1,
                0
            )

        Knob.Position =
            UDim2.new(
                percentage,
                0,
                0.5,
                0
            )

        Value.Text =
            tostring(
                math.floor(
                    value + 0.5
                )
            )
            ..
            "%"

        callback(value)
    end

    Connect(
        Bar.InputBegan,

        function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1
            then

                Dragging = true

                Update(
                    input.Position.X
                )
            end
        end
    )

    Connect(
        UserInputService.InputChanged,

        function(input)

            if Dragging
                and input.UserInputType ==
                    Enum.UserInputType.MouseMovement
            then

                Update(
                    input.Position.X
                )
            end
        end
    )

    Connect(
        UserInputService.InputEnded,

        function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1
            then

                Dragging = false
            end
        end
    )

    -- Aplica imediatamente o valor inicial carregado do config.
    callback(defaultValue)
end

CreateSlider(
    "Opacidade do menu",
    "Controle a transparência da interface.",
    160,
    45,
    100,
    math.floor(Settings.Opacity * 100 + 0.5),

    function(value)

        Settings.Opacity =
            value / 100

        local transparency =
            1
            -
            Settings.Opacity

        MainFrame.BackgroundTransparency =
            transparency

        Header.BackgroundTransparency =
            transparency

        HeaderFix.BackgroundTransparency =
            transparency

        Sidebar.BackgroundTransparency =
            transparency

        Content.BackgroundTransparency =
            transparency

        SearchFrame.BackgroundTransparency =
            transparency
    end
)

CreateSlider(
    "Tamanho do menu",
    "Aumente ou diminua o tamanho da interface.",
    238,
    70,
    130,
    math.floor(Settings.Scale * 100 + 0.5),

    function(value)

        Settings.Scale =
            value / 100

        UIScale.Scale =
            Settings.Scale
    end
)


--========================================================
-- CONFIG MANAGER + KEYBINDS
--========================================================

do
    local ConfigNameBox =
        Instance.new("TextBox")

    ConfigNameBox.Parent =
        ConfigsPage

    ConfigNameBox.Position =
        UDim2.new(
            0,
            24,
            0,
            307
        )

    ConfigNameBox.Size =
        UDim2.new(
            0.56,
            -4,
            0,
            30
        )

    ConfigNameBox.BackgroundColor3 =
        Colors.Selected

    ConfigNameBox.BorderSizePixel = 0
    ConfigNameBox.Text = ""
    ConfigNameBox.PlaceholderText =
        "Nome da config..."
    ConfigNameBox.PlaceholderColor3 =
        Colors.SecondaryText
    ConfigNameBox.TextColor3 =
        Colors.Text
    ConfigNameBox.Font =
        Enum.Font.Gotham
    ConfigNameBox.TextSize = 10
    ConfigNameBox.ClearTextOnFocus = false

    local NameCorner =
        Instance.new("UICorner")

    NameCorner.CornerRadius =
        UDim.new(0, 7)

    NameCorner.Parent =
        ConfigNameBox

    local SaveButton =
        Instance.new("TextButton")

    SaveButton.Parent =
        ConfigsPage

    SaveButton.AnchorPoint =
        Vector2.new(1, 0)

    SaveButton.Position =
        UDim2.new(
            1,
            -24,
            0,
            307
        )

    SaveButton.Size =
        UDim2.new(
            0.41,
            -2,
            0,
            30
        )

    SaveButton.BackgroundColor3 =
        Colors.Selected
    SaveButton.BorderSizePixel = 0
    SaveButton.Text = "Salvar config"
    SaveButton.TextColor3 =
        Colors.Text
    SaveButton.Font =
        Enum.Font.GothamMedium
    SaveButton.TextSize = 10
    SaveButton.AutoButtonColor = false

    local SaveCorner =
        Instance.new("UICorner")

    SaveCorner.CornerRadius =
        UDim.new(0, 7)

    SaveCorner.Parent =
        SaveButton

    local SelectButton =
        Instance.new("TextButton")

    SelectButton.Parent =
        ConfigsPage

    SelectButton.Position =
        UDim2.new(
            0,
            24,
            0,
            343
        )

    SelectButton.Size =
        UDim2.new(
            0.46,
            -4,
            0,
            30
        )

    SelectButton.BackgroundColor3 =
        Colors.Selected
    SelectButton.BorderSizePixel = 0
    SelectButton.Text =
        "Selecionar config"
    SelectButton.TextColor3 =
        Colors.Text
    SelectButton.Font =
        Enum.Font.GothamMedium
    SelectButton.TextSize = 10
    SelectButton.AutoButtonColor = false

    local SelectCorner =
        Instance.new("UICorner")

    SelectCorner.CornerRadius =
        UDim.new(0, 7)

    SelectCorner.Parent =
        SelectButton

    local LoadButton =
        Instance.new("TextButton")

    LoadButton.Parent =
        ConfigsPage

    LoadButton.Position =
        UDim2.new(
            0.48,
            0,
            0,
            343
        )

    LoadButton.Size =
        UDim2.new(
            0.24,
            -4,
            0,
            30
        )

    LoadButton.BackgroundColor3 =
        Colors.Selected
    LoadButton.BorderSizePixel = 0
    LoadButton.Text = "Carregar"
    LoadButton.TextColor3 =
        Colors.Text
    LoadButton.Font =
        Enum.Font.GothamMedium
    LoadButton.TextSize = 9
    LoadButton.AutoButtonColor = false

    local LoadCorner =
        Instance.new("UICorner")

    LoadCorner.CornerRadius =
        UDim.new(0, 7)

    LoadCorner.Parent =
        LoadButton

    local DeleteButton =
        Instance.new("TextButton")

    DeleteButton.Parent =
        ConfigsPage

    DeleteButton.AnchorPoint =
        Vector2.new(1, 0)

    DeleteButton.Position =
        UDim2.new(
            1,
            -24,
            0,
            343
        )

    DeleteButton.Size =
        UDim2.new(
            0.24,
            -4,
            0,
            30
        )

    DeleteButton.BackgroundColor3 =
        Color3.fromRGB(
            38,
            20,
            20
        )

    DeleteButton.BorderSizePixel = 0
    DeleteButton.Text = "Excluir"
    DeleteButton.TextColor3 =
        Colors.Red
    DeleteButton.Font =
        Enum.Font.GothamMedium
    DeleteButton.TextSize = 9
    DeleteButton.AutoButtonColor = false

    local DeleteCorner =
        Instance.new("UICorner")

    DeleteCorner.CornerRadius =
        UDim.new(0, 7)

    DeleteCorner.Parent =
        DeleteButton

    local SelectedConfig = nil

    local Popup =
        Instance.new("Frame")

    Popup.Parent =
        ConfigsPage

    Popup.Position =
        UDim2.new(
            0,
            24,
            0,
            160
        )

    Popup.Size =
        UDim2.new(
            0,
            245,
            0,
            176
        )

    Popup.BackgroundColor3 =
        Color3.fromRGB(
            20,
            20,
            20
        )

    Popup.BorderSizePixel = 0
    Popup.Visible = false
    Popup.ZIndex = 90

    local PopupCorner =
        Instance.new("UICorner")

    PopupCorner.CornerRadius =
        UDim.new(0, 8)

    PopupCorner.Parent =
        Popup

    local PopupStroke =
        Instance.new("UIStroke")

    PopupStroke.Parent =
        Popup

    PopupStroke.Color =
        Colors.Border

    PopupStroke.Transparency =
        0.1

    local Scroll =
        Instance.new("ScrollingFrame")

    Scroll.Parent =
        Popup

    Scroll.Position =
        UDim2.new(
            0,
            5,
            0,
            5
        )

    Scroll.Size =
        UDim2.new(
            1,
            -10,
            1,
            -10
        )

    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 3
    Scroll.AutomaticCanvasSize =
        Enum.AutomaticSize.Y
    Scroll.CanvasSize =
        UDim2.new(0, 0, 0, 0)
    Scroll.ZIndex = 91

    local Layout =
        Instance.new("UIListLayout")

    Layout.Parent =
        Scroll

    Layout.Padding =
        UDim.new(0, 4)

    local function ReadIndex()
        if type(readfile) ~= "function"
            or type(isfile) ~= "function"
        then
            return {}
        end

        if not isfile(CONFIG_INDEX) then
            return {}
        end

        local ok, raw =
            pcall(
                readfile,
                CONFIG_INDEX
            )

        if not ok then
            return {}
        end

        local decodeOk, data =
            pcall(
                HttpService.JSONDecode,
                HttpService,
                raw
            )

        if decodeOk
            and type(data) == "table"
        then
            return data
        end

        return {}
    end

    local function WriteIndex(names)
        if type(writefile) ~= "function" then
            return false
        end

        EnsureConfigFolder()

        local ok =
            pcall(
                function()
                    writefile(
                        CONFIG_INDEX,
                        HttpService:JSONEncode(
                            names
                        )
                    )
                end
            )

        return ok
    end

    local function AddToIndex(name)
        local names =
            ReadIndex()

        for _, current in
            ipairs(names)
        do
            if current == name then
                return
            end
        end

        table.insert(
            names,
            name
        )

        table.sort(names)
        WriteIndex(names)
    end

    local function RemoveFromIndex(name)
        local old =
            ReadIndex()

        local new = {}

        for _, current in
            ipairs(old)
        do
            if current ~= name then
                table.insert(
                    new,
                    current
                )
            end
        end

        WriteIndex(new)
    end

    local function BuildConfig()
        local combat = {}

        for key, value in
            pairs(CombatSettings)
        do
            if key ~= "AimbotBind" then
                combat[key] = value
            end
        end

        combat.AimbotBind =
            EncodeEnumItem(
                CombatSettings.AimbotBind
            )

        return {
            Version = 15,

            Settings = {
                MenuKey =
                    EncodeEnumItem(
                        Settings.MenuKey
                    ),

                AccentColor = {
                    math.floor(
                        Settings.AccentColor.R
                        *
                        255
                        +
                        0.5
                    ),

                    math.floor(
                        Settings.AccentColor.G
                        *
                        255
                        +
                        0.5
                    ),

                    math.floor(
                        Settings.AccentColor.B
                        *
                        255
                        +
                        0.5
                    )
                },

                Opacity =
                    Settings.Opacity,

                Scale =
                    Settings.Scale
            },

            VisualSettings =
                VisualSettings,

            CombatSettings =
                combat,

            ExploitSettings = {
                InfiniteJump =
                    ExploitSettings.InfiniteJump,

                InfiniteJumpBind =
                    EncodeEnumItem(
                        ExploitSettings.InfiniteJumpBind
                    ),

                Fly =
                    ExploitSettings.Fly,

                FlyBind =
                    EncodeEnumItem(
                        ExploitSettings.FlyBind
                    ),

                FlySpeed =
                    ExploitSettings.FlySpeed,

                Speed =
                    ExploitSettings.Speed,

                SpeedBind =
                    EncodeEnumItem(
                        ExploitSettings.SpeedBind
                    ),

                WalkSpeed =
                    ExploitSettings.WalkSpeed,

                SuperJump =
                    ExploitSettings.SuperJump,

                SuperJumpBind =
                    EncodeEnumItem(
                        ExploitSettings.SuperJumpBind
                    ),

                JumpPower =
                    ExploitSettings.JumpPower,

                Noclip =
                    ExploitSettings.Noclip,

                NoclipBind =
                    EncodeEnumItem(
                        ExploitSettings.NoclipBind
                    ),

                ShowKeybinds =
                    ExploitSettings.ShowKeybinds
            }
        }
    end

    local function ApplyOpacity()
        local transparency =
            1 - Settings.Opacity

        MainFrame.BackgroundTransparency =
            transparency

        Header.BackgroundTransparency =
            transparency

        HeaderFix.BackgroundTransparency =
            transparency

        Sidebar.BackgroundTransparency =
            transparency

        Content.BackgroundTransparency =
            transparency

        SearchFrame.BackgroundTransparency =
            transparency
    end

    local function ApplyConfig(data)
        if type(data) ~= "table" then
            return false
        end

        -- limpa alterações físicas antes
        -- de aplicar outra configuração
        if SetExploitState then
            SetExploitState(
                "InfiniteJump",
                false
            )

            SetExploitState(
                "Fly",
                false
            )

            SetExploitState(
                "Speed",
                false
            )

            SetExploitState(
                "SuperJump",
                false
            )

            SetExploitState(
                "Noclip",
                false
            )
        end

        if RestoreAllHitboxes then
            pcall(
                RestoreAllHitboxes
            )
        end

        if type(data.Settings) ==
            "table"
        then
            local s =
                data.Settings

            local key =
                DecodeEnumItem(
                    s.MenuKey
                )

            if key then
                Settings.MenuKey = key
                KeyButton.Text =
                    key.Name
            end

            if type(s.AccentColor) ==
                "table"
            then
                local color =
                    Color3.fromRGB(
                        tonumber(
                            s.AccentColor[1]
                        )
                        or 240,

                        tonumber(
                            s.AccentColor[2]
                        )
                        or 240,

                        tonumber(
                            s.AccentColor[3]
                        )
                        or 240
                    )

                UpdateAccent(color)
            end

            if type(s.Opacity) ==
                "number"
            then
                Settings.Opacity =
                    math.clamp(
                        s.Opacity,
                        0.45,
                        1
                    )

                ApplyOpacity()
            end

            if type(s.Scale) ==
                "number"
            then
                Settings.Scale =
                    math.clamp(
                        s.Scale,
                        0.7,
                        1.3
                    )

                UIScale.Scale =
                    Settings.Scale
            end
        end

        if type(data.VisualSettings) ==
            "table"
        then
            for key in pairs(
                VisualSettings
            ) do
                if type(
                    data.VisualSettings[key]
                ) == "boolean"
                then
                    VisualSettings[key] =
                        data.VisualSettings[key]
                end
            end

            for _, toggle in
                pairs(VisualToggles)
            do
                toggle.Update(false)
            end
        end

        if type(data.CombatSettings) ==
            "table"
        then
            local c =
                data.CombatSettings

            for key in pairs(
                CombatSettings
            ) do
                if key ~= "AimbotBind"
                    and c[key] ~= nil
                then
                    CombatSettings[key] =
                        c[key]
                end
            end

            local bind =
                DecodeEnumItem(
                    c.AimbotBind
                )

            if bind then
                CombatSettings.AimbotBind =
                    bind

                AimbotKeyButton.Text =
                    BindName(bind)
            end

            for _, refresh in
                pairs(
                    CombatToggleRefreshers
                )
            do
                refresh(false)
            end
        end

        if type(data.ExploitSettings) ==
            "table"
        then
            local e =
                data.ExploitSettings

            if type(e.FlySpeed) ==
                "number"
            then
                ExploitSettings.FlySpeed =
                    e.FlySpeed
            end

            if type(e.WalkSpeed) ==
                "number"
            then
                ExploitSettings.WalkSpeed =
                    e.WalkSpeed
            end

            if type(e.JumpPower) ==
                "number"
            then
                ExploitSettings.JumpPower =
                    e.JumpPower
            end

            for _, bindName in
                ipairs({
                    "InfiniteJumpBind",
                    "FlyBind",
                    "SpeedBind",
                    "SuperJumpBind",
                    "NoclipBind"
                })
            do
                ExploitSettings[
                    bindName
                ] =
                    DecodeEnumItem(
                        e[bindName]
                    )

                local button =
                    ExploitBindButtons[
                        bindName
                    ]

                if button then
                    button.Text =
                        ExploitBindName(
                            ExploitSettings[
                                bindName
                            ]
                        )
                end
            end

            if type(e.ShowKeybinds) ==
                "boolean"
            then
                ExploitSettings.ShowKeybinds =
                    e.ShowKeybinds
            end

            for _, name in
                ipairs({
                    "InfiniteJump",
                    "Fly",
                    "Speed",
                    "SuperJump",
                    "Noclip"
                })
            do
                SetExploitState(
                    name,
                    e[name] == true
                )
            end
        end

        if RefreshKeybindOverlay then
            RefreshKeybindOverlay()
        end

        return true
    end

    local function LoadFile(name)
        if type(readfile) ~= "function"
            or type(isfile) ~= "function"
        then
            return nil
        end

        local path =
            ConfigPath(name)

        if not isfile(path) then
            return nil
        end

        local ok, raw =
            pcall(
                readfile,
                path
            )

        if not ok then
            return nil
        end

        local decodeOk, data =
            pcall(
                HttpService.JSONDecode,
                HttpService,
                raw
            )

        if decodeOk then
            return data
        end

        return nil
    end

    local function RefreshList()
        for _, child in
            ipairs(
                Scroll:GetChildren()
            )
        do
            if child:IsA(
                "TextButton"
            )
                or child:IsA(
                    "TextLabel"
                )
            then
                child:Destroy()
            end
        end

        local names =
            ReadIndex()

        if #names == 0 then
            local Empty =
                Instance.new(
                    "TextLabel"
                )

            Empty.Parent =
                Scroll

            Empty.Size =
                UDim2.new(
                    1,
                    0,
                    0,
                    28
                )

            Empty.BackgroundTransparency = 1
            Empty.Text =
                "Nenhuma config salva"
            Empty.TextColor3 =
                Colors.SecondaryText
            Empty.Font =
                Enum.Font.Gotham
            Empty.TextSize = 10
            Empty.ZIndex = 92

            return
        end

        for _, name in
            ipairs(names)
        do
            local Item =
                Instance.new(
                    "TextButton"
                )

            Item.Parent =
                Scroll

            Item.Size =
                UDim2.new(
                    1,
                    0,
                    0,
                    28
                )

            Item.BackgroundColor3 =
                Color3.fromRGB(
                    29,
                    29,
                    29
                )

            Item.BorderSizePixel = 0
            Item.Text = name
            Item.TextColor3 =
                Colors.Text
            Item.Font =
                Enum.Font.GothamMedium
            Item.TextSize = 10
            Item.AutoButtonColor = false
            Item.ZIndex = 92

            local Corner =
                Instance.new(
                    "UICorner"
                )

            Corner.CornerRadius =
                UDim.new(0, 6)

            Corner.Parent =
                Item

            Connect(
                Item.MouseButton1Click,

                function()
                    SelectedConfig =
                        name

                    SelectButton.Text =
                        name

                    Popup.Visible =
                        false
                end
            )
        end
    end

    Connect(
        SelectButton.MouseButton1Click,

        function()
            RefreshList()

            Popup.Visible =
                not Popup.Visible
        end
    )

    Connect(
        SaveButton.MouseButton1Click,

        function()
            local name =
                SanitizeConfigName(
                    ConfigNameBox.Text
                )

            if name == "" then
                SaveButton.Text =
                    "Digite um nome"

                task.delay(
                    1.2,
                    function()
                        if SaveButton.Parent then
                            SaveButton.Text =
                                "Salvar config"
                        end
                    end
                )

                return
            end

            if type(writefile) ~=
                "function"
            then
                SaveButton.Text =
                    "Indisponível"
                return
            end

            if not EnsureConfigFolder() then
                SaveButton.Text =
                    "Sem acesso"
                return
            end

            local ok =
                pcall(
                    function()
                        writefile(
                            ConfigPath(name),

                            HttpService:JSONEncode(
                                BuildConfig()
                            )
                        )
                    end
                )

            if ok then
                AddToIndex(name)

                SelectedConfig =
                    name

                SelectButton.Text =
                    name

                ConfigNameBox.Text =
                    ""

                SaveButton.Text =
                    "Salvo!"
            else
                SaveButton.Text =
                    "Erro"
            end

            task.delay(
                1.2,

                function()
                    if SaveButton.Parent then
                        SaveButton.Text =
                            "Salvar config"
                    end
                end
            )
        end
    )

    Connect(
        LoadButton.MouseButton1Click,

        function()
            if not SelectedConfig then
                LoadButton.Text =
                    "Selecione"

                task.delay(
                    1.1,
                    function()
                        if LoadButton.Parent then
                            LoadButton.Text =
                                "Carregar"
                        end
                    end
                )

                return
            end

            local data =
                LoadFile(
                    SelectedConfig
                )

            if not data then
                LoadButton.Text =
                    "Erro"
                return
            end

            local ok =
                ApplyConfig(data)

            LoadButton.Text =
                ok
                and "Carregado!"
                or "Erro"

            task.delay(
                1.2,

                function()
                    if LoadButton.Parent then
                        LoadButton.Text =
                            "Carregar"
                    end
                end
            )
        end
    )

    Connect(
        DeleteButton.MouseButton1Click,

        function()
            if not SelectedConfig then
                DeleteButton.Text =
                    "Selecione"
                return
            end

            if type(delfile) ~=
                "function"
                or type(isfile) ~=
                    "function"
            then
                DeleteButton.Text =
                    "Indisponível"
                return
            end

            local path =
                ConfigPath(
                    SelectedConfig
                )

            if isfile(path) then
                local ok =
                    pcall(
                        delfile,
                        path
                    )

                if ok then
                    RemoveFromIndex(
                        SelectedConfig
                    )

                    SelectedConfig =
                        nil

                    SelectButton.Text =
                        "Selecionar config"

                    DeleteButton.Text =
                        "Excluída!"
                else
                    DeleteButton.Text =
                        "Erro"
                end
            end

            task.delay(
                1.2,

                function()
                    if DeleteButton.Parent then
                        DeleteButton.Text =
                            "Excluir"
                    end
                end
            )
        end
    )

    -- KEYBIND LIST

    local ShowKeybindsButton =
        Instance.new("TextButton")

    ShowKeybindsButton.Parent =
        ConfigsPage

    ShowKeybindsButton.Position =
        UDim2.new(
            0,
            24,
            0,
            381
        )

    ShowKeybindsButton.Size =
        UDim2.new(
            0.48,
            -4,
            0,
            30
        )

    ShowKeybindsButton.BackgroundColor3 =
        Colors.Selected
    ShowKeybindsButton.BorderSizePixel = 0
    ShowKeybindsButton.Font =
        Enum.Font.GothamMedium
    ShowKeybindsButton.TextSize = 10
    ShowKeybindsButton.AutoButtonColor = false

    local KeyCorner =
        Instance.new("UICorner")

    KeyCorner.CornerRadius =
        UDim.new(0, 7)

    KeyCorner.Parent =
        ShowKeybindsButton

    local function RefreshKeyButton()
        if ExploitSettings.ShowKeybinds then
            ShowKeybindsButton.Text =
                "Keybinds: ON"

            ShowKeybindsButton.BackgroundColor3 =
                Settings.AccentColor

            ShowKeybindsButton.TextColor3 =
                Color3.fromRGB(
                    18,
                    18,
                    18
                )
        else
            ShowKeybindsButton.Text =
                "Keybinds: OFF"

            ShowKeybindsButton.BackgroundColor3 =
                Colors.Selected

            ShowKeybindsButton.TextColor3 =
                Colors.Text
        end
    end

    RefreshKeyButton()

    Connect(
        ShowKeybindsButton.MouseButton1Click,

        function()
            ExploitSettings.ShowKeybinds =
                not ExploitSettings.ShowKeybinds

            RefreshKeyButton()
            RefreshKeybindOverlay()
        end
    )
end

--========================================================
-- UNLOAD
--========================================================

local UnloadButton =
    Instance.new(
        "TextButton"
    )

UnloadButton.Parent =
    ConfigsPage

UnloadButton.AnchorPoint =
    Vector2.new(
        1,
        0
    )

UnloadButton.Position =
    UDim2.new(
        1,
        -24,
        0,
        381
    )

UnloadButton.Size =
    UDim2.new(
        0.48,
        -4,
        0,
        30
    )

UnloadButton.BackgroundColor3 =
    Color3.fromRGB(
        35,
        18,
        18
    )

UnloadButton.BorderSizePixel = 0

UnloadButton.Text =
    "Unload Menu"

UnloadButton.TextColor3 =
    Colors.Red

UnloadButton.Font =
    Enum.Font.GothamBold

UnloadButton.TextSize = 14

local UnloadCorner =
    Instance.new(
        "UICorner"
    )

UnloadCorner.CornerRadius =
    UDim.new(
        0,
        9
    )

UnloadCorner.Parent =
    UnloadButton

local Unloaded = false

local function Unload()

    if Unloaded then
        return
    end

    Unloaded = true

    if RestoreAllHitboxes then
        pcall(RestoreAllHitboxes)
    end

    if StopFly then
        pcall(StopFly)
    end

    if RestoreSpeed then
        pcall(RestoreSpeed)
    end

    if RestoreJump then
        pcall(RestoreJump)
    end

    if RestoreNoclip then
        pcall(RestoreNoclip)
    end

    for player in
        pairs(ESPObjects)
    do

        RemoveESPObject(
            player
        )
    end

    for _, connection in
        ipairs(Connections)
    do

        pcall(function()
            connection:Disconnect()
        end)
    end

    table.clear(
        Connections
    )

    pcall(function()
        ESPGui:Destroy()
    end)

    pcall(function()
        ScreenGui:Destroy()
    end)
end

Connect(
    UnloadButton.MouseButton1Click,
    Unload
)

--========================================================
-- DRAG MENU
--========================================================

local DraggingMenu =
    false

local DragStart

local StartPosition

Connect(
    Header.InputBegan,

    function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton1
        then

            local mouse =
                UserInputService:GetMouseLocation()

            local position =
                SearchFrame.AbsolutePosition

            local size =
                SearchFrame.AbsoluteSize

            if mouse.X >=
                position.X
                and mouse.X <=
                    position.X
                    +
                    size.X
                and mouse.Y >=
                    position.Y
                and mouse.Y <=
                    position.Y
                    +
                    size.Y
            then

                return
            end

            DraggingMenu =
                true

            DragStart =
                input.Position

            StartPosition =
                MainFrame.Position
        end
    end
)

Connect(
    UserInputService.InputChanged,

    function(input)

        if DraggingMenu
            and input.UserInputType ==
                Enum.UserInputType.MouseMovement
        then

            local delta =
                input.Position
                -
                DragStart

            MainFrame.Position =
                UDim2.new(

                    StartPosition.X.Scale,

                    StartPosition.X.Offset
                    +
                    delta.X,

                    StartPosition.Y.Scale,

                    StartPosition.Y.Offset
                    +
                    delta.Y
                )
        end
    end
)

Connect(
    UserInputService.InputEnded,

    function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton1
        then

            DraggingMenu =
                false
        end
    end
)

--========================================================
-- TECLA DO MENU
--========================================================

local MenuVisible =
    true

Connect(
    UserInputService.InputBegan,

    function(
        input,
        gameProcessed
    )

        if input.UserInputType ~=
            Enum.UserInputType.Keyboard
        then

            return
        end

        if ListeningForKey then

            if input.KeyCode ~=
                Enum.KeyCode.Unknown
            then

                Settings.MenuKey =
                    input.KeyCode

                KeyButton.Text =
                    input.KeyCode.Name

                ListeningForKey =
                    false

                if RefreshKeybindOverlay then
                    RefreshKeybindOverlay()
                end
            end

            return
        end

        if gameProcessed then
            return
        end

        if input.KeyCode ==
            Settings.MenuKey
        then

            MenuVisible =
                not MenuVisible

            MainFrame.Visible =
                MenuVisible
        end
    end
)

--========================================================
-- INICIAL
--========================================================

SetTab("Visuais")