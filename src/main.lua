-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- --Desativa barra de notificações.
display.setStatusBar( display.HiddenStatusBar )


-- Incluindo módulo "storyboard" do Corona
local storyboard = require "storyboard"

-- Carregando Tela Inicial
storyboard.gotoScene( "menu" )