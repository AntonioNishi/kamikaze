-- Incluindo módulo "storyboard" do Corona
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

-- Incluindo "widget" da biblioteca Corona
local widget = require "widget"

function scene:createScene( event )

  local group = self.view
  
  -- Incluindo física do Jogo
  local physics = require "physics"
  physics.start(); physics.pause(); physics.setGravity(0, 9)


  -- Jogo divido em camadas (grupos)
  -- Objetos do mesmo grupo, renderizam juntos.
  camadaJogo = display.newGroup()
  camadaTiro = display.newGroup()
  camadaInimigos = display.newGroup()
  camadaVidas = display.newGroup()

  -- Declaração de variáveis.
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
  
  -- Textura do inimigo e do tiro carregados na memória, para o Corona não ter que carregar toda vez.
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
  
  -- Ordenando as camadas (fundo já adicionado, adicionando tiros, inimigos, e depois
  -- o jogador e placar - assim os pontos ficarão acima de tudo).
  camadaJogo:insert(camadaTiro)
  camadaJogo:insert(camadaInimigos)

  -- Colisões
  local function colisoes(prop, evento)
    -- Tiro acerta o inimigo
    if prop.nome == "bullet" and evento.other.nome == "inimigo" and jogoAtivo then
      -- Aumenta o placar
      placar = placar + 1
      textoPlacar.text = placar

      -- Toca som de explosão.
      audio.play(sons.boom)

      -- Não podemos remover um corpo durante um evento de colisão, então deixamos na fila para remoção.
      -- Será removido no próximo frame, dentro do loop do jogo.
      table.insert(remover, evento.other)


      -- Jogador é acertado - GAME OVER
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

  -- Adicionando a física ao corpo. Será "kinematic" para não reagir à gravidade.
  physics.addBody(jogador, "kinematic", {bounce = 0})

  -- Isso é necessário para sabermos quem acertou quem durante o evento de colisão.
  jogador.nome = "jogador"

  --Evento "listener" para verificar a colisão.
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
      -- Removendo aviões explodidos.
      for i = 1, #remover do
        remover[i].parent:remove(remover[i])
        remover[i] = nil
      end

      -- Checando se está na hora de lançar outro inimigo,
      -- de forma aleatória e com base no último inimigo lançado.(tempoUltimoInimigo)
      if evento.time - tempoUltimoInimigo >= math.random(600, 1000) then
        -- Posicionando inimigo de forma aleatória.
        inimigo = display.newImage("imagens/inimigo.png")
        inimigo.x = math.random(telaJogador, display.contentWidth - telaJogador)
        inimigo.y = -inimigo.contentHeight

        -- Isso deve ser "dynamic", fazendo com que reaja à gravidade, assim
        -- cairá para o fim da tela.
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

        -- "Kinematic", para não reagir à gravidade.
        physics.addBody(tiro, "kinematic", {bounce = 0})
        tiro.nome = "bullet"

        -- Evento "listener" para verificar se o tiro colidiu com o inimigo.
        tiro.collision = colisoes
        tiro:addEventListener("collision", tiro)

        camadaJogo:insert(tiro)

        -- Som de tiro.
        audio.play(sons.pew)

        -- Movendo para cima.
        -- Quando terminar o movimento, ele será removido automaticamente (onComplete event).
        -- Criando função para armazenar a informação sobre esse tiro e depois removê-lo.
        transition.to(tiro, {time = 1000, y = -tiro.contentHeight,
          onComplete = function(prop) prop.parent:remove(prop); prop = nil; end
        })

        tempoUltimoTiro = evento.time
      end
    end
  end

  -- Chamando o loop do jogo acada FRAME,
  -- gameLoop()  será chamado 30 vezes por segundo nesse caso.
  Runtime:addEventListener("enterFrame", gameLoop)

  --------------------------------------------------------------------------------
  -- Controles básicos
  --------------------------------------------------------------------------------
  local function jogadorMovimento(evento)
    -- Verificando se o jogos terminou.
    if not jogoAtivo then return false end

    -- Condicionando a movimentação até os limites da tela.
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