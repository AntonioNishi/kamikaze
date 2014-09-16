-- Incluindo m�dulo "storyboard" do Corona
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

-- Incluindo "widget" da biblioteca Corona
local widget = require "widget"

function scene:createScene( event )

  local group = self.view
  
  -- Incluindo f�sica do Jogo
  local physics = require "physics"
  physics.start(); physics.pause(); physics.setGravity(0, 9)


  -- Jogo divido em camadas (grupos)
  -- Objetos do mesmo grupo, renderizam juntos.
  camadaJogo = display.newGroup()
  camadaTiro = display.newGroup()
  camadaInimigos = display.newGroup()
  camadaVidas = display.newGroup()

  -- Declara��o de vari�veis.
  local jogoAtivo = true
  local textoPlacar
  local sons
  local placar = 0
  local remover = {}
  local fundoTela
  local jogador
  local inimigo
  local explosao
  local telaJogador
  local numeroVidas = 3
  local vidas = {}
  
  -- Textura do inimigo e do tiro carregados na mem�ria, para o Corona n�o ter que carregar toda vez.
  local texturaCache = {}
  texturaCache[1] = display.newImage("imagens/inimigo.png"); texturaCache[1].isVisible = false;
  texturaCache[2] = display.newImage("imagens/tiro.png");  texturaCache[2].isVisible = false;
  local telaJogador = texturaCache[1].contentWidth * .5

  -- Ajuste de volume.
  audio.setMaxVolume( 0.85, { channel=1 } )

  -- Carga dos sons.
  sons = {
    pew = audio.loadSound("sons/pew.wav"),
    boom = audio.loadSound("sons/boom.wav"),
    gameOver = audio.loadSound("sons/gameOver.wav")
  }
  
  
  -- Fundo.
  fundoTela = display.newImageRect( "imagens/Bg.png", display.contentWidth, display.contentHeight )
  fundoTela.x = display.contentCenterX
  fundoTela.y = display.contentCenterY
  camadaJogo:insert(fundoTela)
  
     
  --Adicionando as Vidas
  for i=1,numeroVidas do
    vidas[i] = display.newImageRect("imagens/life.png",45,34)
    vidas[i].x = i*40-20
    vidas[i].y = 18
    camadaVidas:insert(vidas[i])
  end
  
  -- Ordenando as camadas (fundo j� adicionado, adicionando tiros, inimigos, e depois
  -- o jogador e placar - assim os pontos ficar�o acima de tudo).
  camadaJogo:insert(camadaTiro)
  camadaJogo:insert(camadaInimigos)

  -- Colis�es
  local function colisoes(prop, evento)
    -- Tiro acerta o inimigo
    if prop.nome == "bullet" and evento.other.nome == "inimigo" and jogoAtivo then
      -- Aumenta o placar
      placar = placar + 1
      textoPlacar.text = placar

      -- Toca som de explos�o.
      audio.play(sons.boom)

      -- N�o podemos remover um corpo durante um evento de colis�o, ent�o deixamos na fila para remo��o.
      -- Ser� removido no pr�ximo frame, dentro do loop do jogo.
      table.insert(remover, evento.other)


      -- Jogador � acertado - GAME OVER
    elseif prop.nome == "jogador" and evento.other.nome == "inimigo" then
      audio.play(sons.gameOver)

      explosao = display.newImage("imagens/explosao.png")
      explosao.x = jogador.x
      explosao.y = jogador.y

      local textoGameOver = display.newText("Se lascou!", 0, 0, "Arial", 35)
      textoGameOver:setTextColor(255, 255, 255)
      textoGameOver.x = display.contentCenterX
      textoGameOver.y = display.contentCenterY
      camadaJogo:insert(textoGameOver)
      
      -- Fim do loop do jogo.
      jogoAtivo = false
    end        
  end  

  -- Carregando e posicionando o Jogador.
  jogador = display.newImage("imagens/jogador.png")
  jogador.x = display.contentCenterX
  jogador.y = display.contentHeight - jogador.contentHeight

  -- Adicionando a f�sica ao corpo. Ser� "kinematic" para n�o reagir � gravidade.
  physics.addBody(jogador, "kinematic", {bounce = 0})

  -- Isso � necess�rio para sabermos quem acertou quem durante o evento de colis�o.
  jogador.nome = "jogador"

  --Evento "listener" para verificar a colis�o.
  jogador.collision = colisoes
  jogador:addEventListener("collision", jogador)

  -- Adicionando camada principal.
  camadaJogo:insert(jogador)

  -- Salvando metade da tela, usada no loop do jogo.
  telaJogador = jogador.contentWidth * .5

  -- Mostrando o placar.
  textoPlacar = display.newText(placar, 0, 0, "Arial", 35)
  textoPlacar:setTextColor(255, 255, 255)
  textoPlacar.x = 300
  textoPlacar.y = 15
  camadaJogo:insert(textoPlacar)  
  
  --------------------------------------------------------------------------------
  -- Loop do Jogo
  --------------------------------------------------------------------------------
  local tempoUltimoTiro, tempoUltimoInimigo = 0, 0
  local intervaloTiro = 1000

  local function gameLoop(evento)
    if jogoAtivo then
      -- Removendo avi�es explodidos.
      for i = 1, #remover do
        remover[i].parent:remove(remover[i])
        remover[i] = nil
      end

      -- Checando se est� na hora de lan�ar outro inimigo,
      -- de forma aleat�ria e com base no �ltimo inimigo lan�ado.(tempoUltimoInimigo)
      if evento.time - tempoUltimoInimigo >= math.random(600, 1000) then
        -- Posicionando inimigo de forma aleat�ria.
        inimigo = display.newImage("imagens/inimigo.png")
        inimigo.x = math.random(telaJogador, display.contentWidth - telaJogador)
        inimigo.y = -inimigo.contentHeight

        -- Isso deve ser "dynamic", fazendo com que reaja � gravidade, assim
        -- cair� para o fim da tela.
        physics.addBody(inimigo, "dynamic", {bounce = 0})
        inimigo.nome = "inimigo"

        camadaInimigos:insert(inimigo)
        tempoUltimoInimigo = evento.time
      end

      -- Soltando o tiro.
      if evento.time - tempoUltimoTiro >= math.random(250, 300) then
        local tiro = display.newImage("imagens/tiro.png")
        tiro.x = jogador.x
        tiro.y = jogador.y - telaJogador

        -- "Kinematic", para n�o reagir � gravidade.
        physics.addBody(tiro, "kinematic", {bounce = 0})
        tiro.nome = "bullet"

        -- Evento "listener" para verificar se o tiro colidiu com o inimigo.
        tiro.collision = colisoes
        tiro:addEventListener("collision", tiro)

        camadaJogo:insert(tiro)

        -- Som de tiro.
        audio.play(sons.pew)

        -- Movendo para cima.
        -- Quando terminar o movimento, ele ser� removido automaticamente (onComplete event).
        -- Criando fun��o para armazenar a informa��o sobre esse tiro e depois remov�-lo.
        transition.to(tiro, {time = 1000, y = -tiro.contentHeight,
          onComplete = function(prop) prop.parent:remove(prop); prop = nil; end
        })

        tempoUltimoTiro = evento.time
      end
    end
  end

  -- Chamando o loop do jogo acada FRAME,
  -- gameLoop()  ser� chamado 30 vezes por segundo nesse caso.
  Runtime:addEventListener("enterFrame", gameLoop)

  --------------------------------------------------------------------------------
  -- Controles b�sicos
  --------------------------------------------------------------------------------
  local function jogadorMovimento(evento)
    -- Verificando se o jogos terminou.
    if not jogoAtivo then return false end

    -- Condicionando a movimenta��o at� os limites da tela.
    if evento.x >= telaJogador and evento.x <= display.contentWidth - telaJogador then
      -- Atualizando a coordenada x do Jogador.
      jogador.x = evento.x
    end
  end

  -- Evento "listener" para verificar os toque no jogador.
  jogador:addEventListener("touch", jogadorMovimento)
end

function scene:enterScene( event )
  local group = self.view

  -- Iniciando Jogo
  physics.start()

end

scene:addEventListener( "createScene", scene )
scene:addEventListener( "enterScene", scene )


return scene