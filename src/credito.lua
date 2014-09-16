-- Incluindo módulo "storyboard" do Corona
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
--local widget = require "widget"  

function scene:createScene( event )
  
  local fundoTela = display.newRect(0, 0, display.contentWidth, display.contentHeight)
  fundoTela:setFillColor(3, 35, 53)  
  
  local credito = display.newText("Desenvolvido por\nAntonio Nishi Machado", 0, 0, "Arial", 25)
  credito:setTextColor(255, 255, 255)
  credito.x = display.contentCenterX
  credito.y = display.contentCenterY
  end


  scene:addEventListener( "createScene", scene )

return scene