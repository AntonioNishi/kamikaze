-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- --Desativa barra de notifica��es.
display.setStatusBar( display.HiddenStatusBar )


-- Incluindo m�dulo "storyboard" do Corona
local storyboard = require "storyboard"

-- Carregando Tela Inicial
storyboard.gotoScene( "menu" )