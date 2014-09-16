-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local cena = storyboard.newScene()

-- Incluindo "widget" da biblioteca Corona
local widget = require "widget"

-- Cria a Cena de Título:
function cena:createScene( event )
  local group = self.view

  -- Plano de Fundo
  local titulo = display.newImageRect("imagens/titulo2.png", display.contentWidth, display.contentHeight )
  titulo.x = display.contentCenterX
  titulo.y = display.contentCenterY
  group:insert(titulo)

  local function onPlayBtnRelease()
    storyboard.gotoScene("game")
    return true
  end

  -- Cria o botão de Iniciar
  local iniciar = widget.newButton{
    label="INICIAR",
    onRelease = onPlayBtnRelease
  }
  iniciar.x = 205
  iniciar.y = 288
  group:insert( iniciar )
  
  local function onCreditoBtnRelease()
    storyboard.gotoScene("credito")
    return true
  end
  
  local credito = widget.newButton{
    label="CREDITO",
    onRelease = onCreditoBtnRelease
  }
  credito.x = 205
  credito.y = 450
  group:insert( credito )
  
  end

  cena:addEventListener( "createScene", cena )

return cena