tutorial = {}

tutMap = {}
tutMap.width = 5
tutMap.height = 4

for i = 0, tutMap.width+1 do
	tutMap[i] = {}
end

tutMap[1][3] = "C"
tutMap[2][3] = "C"
tutMap[2][4] = "C"
tutMap[3][4] = "C"
tutMap[4][4] = "C"
tutMap[5][4] = "C"
tutMap[1][2] = "PS"

tutorialSteps = {}
currentStep = 1

currentStepTitle = ""

currentTutBox = nil

local CODE_printHelloTrains = parseCode([[
print( "Bonjour trAIns !" )
]])

local CODE_trainPlacing = parseCode([[
function ai.init()
	buyTrain( 1, 3 )
end
]])

local CODE_eventExamples = parseCode([[
-- called at every round start:
function ai.init( map, money )

-- called when a train arrives at a junction:
function ai.chooseDirection(train, possibleDirections)

-- called when a train has reached a passenger's location:
function ai.foundPassengers(train, passengers)
]])

local CODE_pickUpPassenger1 = parseCode([[
-- code to pick up passengers:
function ai.foundPassengers( train, passengers )
	-- function body will go here later.
end
]])

local CODE_pickUpPassenger2 = parseCode([[
-- code to pick up passengers:
function ai.foundPassengers( train, passengers )
	return passengers[1]
end
]])
local CODE_dropOffPassenger = parseCode([[
-- code to drop off passengers:
function ai.foundDestination(train)
	-- drop off train's passenger:
	dropPassenger(train)
end
]])

function nextTutorialStep()
	tutorialBox.succeedOff()
	currentStep = currentStep + 1
	showCurrentStep()
end
function prevTutorialStep()
	currentStep = currentStep - 1
	showCurrentStep()
end

function showCurrentStep()
	if cBox then
		codeBox.remove(cBox)
		cBox = nil
	end
	if additionalInfoBox then
		tutorialBox.remove(additionalInfoBox)
		additionalInfoBox = nil
	end
	if tutorialSteps[currentStep].event then
		tutorialSteps[currentStep].event()
	end
	if currentTutBox then
		TUT_BOX_X = currentTutBox.x
		TUT_BOX_Y = currentTutBox.y
		tutorialBox.remove(currentTutBox)
	end
	
	if tutorialSteps[currentStep].stepTitle then
		currentStepTitle = tutorialSteps[currentStep].stepTitle
	else
		local l = currentStep - 1
		while l > 0 do
			if tutorialSteps[l] and tutorialSteps[l].stepTitle then
				currentStepTitle = tutorialSteps[l].stepTitle
				break
			end
			l = l - 1
		end
	end
		
	currentTutBox = tutorialBox.new( TUT_BOX_X, TUT_BOX_Y, tutorialSteps[currentStep].message, tutorialSteps[currentStep].buttons )
end

function startThisTutorial()

	--define buttons for message box:
	print("tutorialSteps[1].buttons", tutorialSteps[1].buttons[1].name)
	if currentTutBox then tutorialBox.remove(currentTutBox) end
	currentTutBox = tutorialBox.new( TUT_BOX_X, TUT_BOX_Y, tutorialSteps[1].message, tutorialSteps[1].buttons )
	
	STARTUP_MONEY = 50
	timeFactor = 0.5
end

function tutorial.start()
	
	aiFileName = "TutorialAI1.lua"
	
	--ai.backupTutorialAI(aiFileName)
	ai.createNewTutAI(aiFileName, fileContent)

	stats.start( 1 )
	tutMap.time = 0
	map.print()
	
	loadingScreen.reset()
	loadingScreen.addSection("Nouvelle carte")
	loadingScreen.addSubSection("Nouvelle carte", "Taille: " .. tutMap.width .. "x" .. tutMap.height)
	loadingScreen.addSubSection("Nouvelle carte", "Heure: Jour")
	loadingScreen.addSubSection("Nouvelle carte", "Tutoriel 1: Mes premiers pas !")

	train.init()
	train.resetImages()
	
	ai.restart()	-- make sure aiList is reset!
	
	
	print("AI DIR:",AI_DIRECTORY)
	print("AI NAME:",aiFileName)
	
	ok, msg = pcall(ai.new, AI_DIRECTORY .. aiFileName)
	if not ok then
		print("Err: " .. msg)
	else
		stats.setAIName(1, aiFileName:sub(1, #aiFileName-4))
		train.renderTrainImage(aiFileName:sub(1, #aiFileName-4), 1)
	end
	
	tutorial.noTrees = true		-- don't render trees!
	
	map.generate(nil,nil,1,tutMap)
	
	tutorial.createTutBoxes()
	
	tutorial.mapRenderingDoneCallback = startThisTutorial	
	
	menu.exitOnly()
end


function tutorial.endRound()
	tutorial.placedFirstPassenger = nil
end

local codeBoxX, codeBoxY = 0,0
local tutBoxX, tutBoxY = 0,0

--[[
function additionalInformation(text)
	return function()
		if not additionalInfoBox then
			if currentTutBox then
				TUT_BOX_X = currentTutBox.x
				TUT_BOX_Y = currentTutBox.y
			end
			if TUT_BOX_Y + TUT_BOX_HEIGHT + 50 < love.graphics.getHeight() then		-- only show BELOW the current box if there's still space there...
				additionalInfoBox = tutorialBox.new(TUT_BOX_X, TUT_BOX_Y + TUT_BOX_HEIGHT +10, text, {})
			else		-- Otherwise, show it ABOVE the current tut box!
				additionalInfoBox = tutorialBox.new(TUT_BOX_X, TUT_BOX_Y - 10 - TUT_BOX_HEIGHT, text, {})
			end
		end
	end
end]]--


function tutorial.createTutBoxes()

	CODE_BOX_X = love.graphics.getWidth() - CODE_BOX_WIDTH - 30
	CODE_BOX_Y = (love.graphics.getHeight() - TUT_BOX_HEIGHT)/2 - 50
	
	local k = 1
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Comment tout a commencé..."
	tutorialSteps[k].message = "Bienvenue à trAInsported !"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Lancer le tutoriel", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "L'avenir proche:\nIl y a quelques années, un nouveau produit a été introduit sur le marché international: Le RER AI contrôlé, également connu sous le nom de 'trAIn'."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Suivant", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Il y a trois différences majeures entre les 'trAIns' et leurs sœurs plus âgées, les trains. D'une part, ils ne jamais ramasser un passager à la fois. Deuxièmement, ils vont exactement où leurs passagers veulent qu'ils aillent. Troisièmement, ils sont contrôlés par l'intelligence artificielle."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Suivant", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "En théorie, ce nouveau système de trafic pourrait faire des merveilles. La pollution a diminué, la nécessité pour les véhicules privés est parti et il n'y a pas plus d'accidents dus à une technologie très avancée. \n\nIl y a juste un problème ... "
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Suivant", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Là où il y a profit, la concurrence est jamais loin. Les nouvelles entreprises tentent de prendre le contrôle du marché. Et vous devez intervenir. Votre travail ici est de contrôler les trAIns de votre entreprise, en écrivant la meilleure intelligence artificielle pour eux\n\nAssez parlé, nous allons commencer !"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Suivant", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Contrôles"
	tutorialSteps[k].message = "Dans ce tutoriel, vous apprendrez:\n1) Les contrôles du jeu\n2) Achetez des trains\n3) Transporter vos premiers passagers" 
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Suivant", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Vous pouvez cliquez et faire glissez la vue partout sur la carte pour déplacez la vue. Utilisez la molette de la souris (ou Q et E) pour zoomez et dézoomez.\nEn tout temps, vous pouvez appuyez sur F1 pour obtenir un écran d'aide vous montrant les contrôles. Essayez-le !"
	tutorialSteps[k].event = setF1Event(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Bien continuons !\nOuvrez le dossier dans lequel tous vos scripts seront stockés en appuyant sur le bouton 'Ouvrir le dossier'. Dans ce document, vous trouverez le fichier TutorialA1.lua. Ouvrez-le avec un éditeur de texte pour le lire.\nSi le bouton ne fonctionne pas, vous pouvez également trouvez le dossier ici: " .. AI_DIRECTORY
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	if love.filesystem.getWorkingDirectory() then
		tutorialSteps[k].buttons[2] = {name = "Plus d'informations", event = additionalInformation("Si vous ne trouvez pas le dossier, il se peut qu'il soit caché. Tapez le chemin du dossier dans votre navigateur de fichier ou effectuez une recherche sur Internet pour «Afficher les fichiers cachés [nom de votre système d'exploitation]». Par exemple: 'Afficher les fichiers cachés sous Windows 7 '\nEn outre, un éditeur de texte normal devrait le faire, mais il y en a certains qui vous aidera lors de l'écriture du code.\n\nLes bons éditeurs libres à utilisez sont: Gedit, Vim(Linux) \ Notepad++(Windows)"), inBetweenSteps = true}
		tutorialSteps[k].buttons[3] = {name = "Suivant", event = nextTutorialStep}
	else
		tutorialSteps[k].buttons[2] = {name = "Suivant", event = nextTutorialStep}
	end
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "La communication"
	tutorialSteps[k].message = "Maintenant, nous allons écrire un peu de code !\nLa première chose que vous devez apprendre est comment communiquer avec le jeu. Tapez le code affiché sur la droite en bas de TutorialA1.lua. Une fois terminé, enregistrez-le et appuyez sur le bouton 'Rechargez' au bas de cette fenêtre."
	tutorialSteps[k].event = firstPrint(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Plus d'informations", event = additionalInformation("La fonction d'impression vous permet d'imprimez tout textes (Ce qui signifie quelque chose entre "("guillemets")" ou des variables à la console dans le jeu. Cela vous permettra de déboguer facilement votre code plus tard. Essayez-le tout de suite, vous verrez ce que je veux dire."), inBetweenSteps = true}
	--tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Bien joué !\n\n..."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Suivant", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Fonctionnalité d'IA générale"
	tutorialSteps[k].message = "Il y a certaines fonctions que votre IA aura besoin. Au cours de chaque tour, quand certaines choses se produisent, ces fonctions seront appelés. Il y a quelques exemples présentés dans la zone de code. Votre travail sera de remplir ces fonctions avec le contenu."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event = setCodeExamples
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Suivant", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Acheter le premier train !"
	tutorialSteps[k].message = "Maintenant, ajoutez le code en bas à droite de votre appel d'impression. Cela va acheter votre premier train et le placer à la position x = 1, y = 3. La carte est divisée en carrés (vous pourriez avoir à zoomer pour les voir).\nX va de gauche à droite (c'est l'axe de l'abscisse) et Y de haut en bas (c'est l'axe de l'ordonnée) sont les coordonnées.\n(Appuyez et maintenez 'M' pour voir toutes les coordonnées !)\nLorsque vous avez terminé, enregistrez et cliquez sur «Rechargez»."
	tutorialSteps[k].event = setTrainPlacingEvent(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Plus d'informations", event = additionalInformation("Remarque:\n--les coordonnées (X et Y) va de 1 à la largeur (ou hauteur) de la carte. Vous en apprendrez plus sur la largeur et la hauteur maximum de la carte plus tard.\n--Si Vous appelez buyTrain avec des coordonnées qui ne décrivent pas un rail, le jeu placera le train sur le rail le plus proche qu'il peut trouver."), inBetweenSteps = true}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Oui, vous venez de placer votre premier train sur la carte ! Il continura à avancez automatiquement."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Suivant", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Vous avez programmé une fonction de ai.init simple.\nLa fonction 'ai.init() est la fonction dans votre script qui sera toujours appelé quand le tour commence. Dans cette fonction, vous serez en mesure de planifier vos déplacements en train et- Comme vous venez de le faire - Achetez vos premiers trains et les placer sur la carte."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Plus d'informations", event = additionalInformation("La fonction ai.init() est généralement appelé avec l'argument 2, comme suit:\nfunction ai.init( map, money )\nLe premier tient la carte actuelle (plus tard) et le second contient le montant d'argent que vous possédez actuellement. De cette façon, vous pouvez vérifier combien de trains vous pouvez acheter. Vous aurez toujours assez d'argent pour acheter au moins un train au démarrage tour.\nPour l'instant, nous ne pouvons ignorer ces arguments, cependant."), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Suivant", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Ramassez un passager"
	tutorialSteps[k].message = "Je viens de placer un passager sur la carte, son nom est GLaDOS. Maintenez la barre d'espace de votre clavier pour voir une ligne indiquant où elle veut aller !\n\nLes passagers seront toujours engendré près d'un rail. Leur destination est également toujours à proximité d'un rail."
	tutorialSteps[k].event = setPassengerStart(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Plus d'informations", event = additionalInformation("GLaDOS veut aller au magasin de tartes. Elle a promis à quelqu'un de très spécial, un gâteau.\n\n...\nEt elle veut tenir cette promesse."), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Suivant", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Votre travail est maintenant de ramasser le passager et l'emmener où elle veut aller. Pour cela, nous avons besoin de définir une fonction 'ai.foundPassengers' pour le TutorialAI1. Cette fonction est déclenchée dès que l'un de vos trains atteint un carré sur lequel un ou plusieurs passagers sont debout."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Suivant", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "La fonction ai.foundPassengers aura deux arguments: La première, 'train', vous dit qu'un de vos trains ont trouvé le passager. Le second, 'passengers', vous dit sur les passagers qui sont sur la position actuelle du train et pourrait être ramassés. En utilisant ceux-ci, vous pouvez dire qu'elle train utilisez pour ramassez un passager."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Suivant", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Tout d'abord, nous allons définir notre fonction. Tapez le code affiché dans la zone de code dans votre fichier.lua. Vous ne devez pas copiez les commentaires (tout ce qui suit le '--'), ils sont juste là pour clarifier les choses, mais sont ignorées par le jeu."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event = pickUpPassengerStep1
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Suivant", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Vous devez savoir deux choses\n1. 'passengers' est une liste de tous les passagers.\nPour accéder à des passagers individuels, utilisez passengers[1], passengers[2], passengers[3] etc.\n2. Si la fonction ai.foundPassengers retourne un de ces passagers à l'aide de la déclaration 'return', alors le jeu sait que vous voulez prendre ce passager et le fera pour vous, si possible."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event = pickUpPassengerStep1
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Plus d'informations", event = additionalInformation("Cela signifie que le passager sera SEULEMENT ramassé si le train ne détient pas actuellement un autre passager."), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Suivant", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Puisque nous avons un seul passager à l'heure actuelle, il ne peut y avoir un passager dans la liste, qui sera représenté par passengers[1] (S'il y avait un deuxième passager sur le carreau, ce passager serait passengers[2]). Donc, si nous retournons passengers[1], GLaDOS sera ramassé.\nAjouter la nouvelle ligne de code dans la fonction que nous venons de définir, comme indiqué dans la zone de code.\nUne fois fait, cliquez sur Rechargez et regardez votre train ramasser GLaDOS!"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event = pickUpPassengerStep2(k)
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Vous avez ramassé avec succès GLaDOS !\nNotez que l'image du train a changé pour montrer qu'il détient maintenant un passager.\n\nNous avons presque terminé, maintenant nous avons juste besoin de la placer vers le bas près du magasin de tartes.."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Suivant", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Déposez la !"
	tutorialSteps[k].message = "Vous pouvez déposez votre passager à tout moment en appelant la fonction dropPassenger(train) quelque part dans votre code. Pour rendre les choses plus facile pour vous, chaque fois qu'un train arrive à la place du passager actuel veut aller à une destination, nous utiliserons la fonction ai.foundDestination() dans votre code, si vous l'avez écrit. \nFaisons ça !"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Suivant", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Ajouter la fonction affichée dans la zone de code en bas de votre TutorialAI1.lua.\nRechargez ensuite à nouveau le code et attendre jusqu'à ce que le train ramasse GLaDOS et atteignent le magasin de tartes."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event = dropOffPassengerEvent(k)
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Terminé !"
	tutorialSteps[k].message = "Vous avez terminé le premier tutoriel, bien joué !\n\nCliquez sur 'Plus d'idées' pour avoir quelques idées de ce que vous pouvez faire avant d'entamez le prochain tutoriel."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Plus d'idées", event = additionalInformation("1. Essayez d'imprimer quelque chose à la console en utilisant la fonction d'impression lorsque le train prend le passager et quand il la dépose (par exemple: 'Bienvenue !' Et 'Au revoir !').\n2. Acheter deux trains au lieu d'un, en appelant buyTrain deux fois dans ai.init()\n3. Faire démarrage le train en bas à droite au lieu de la partie supérieure gauche."), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Suivant", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Aller directement au tutoriel suivant ou revenir au menu."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Quit", event = endTutorial}
	tutorialSteps[k].buttons[3] = {name = "Tutoriel suivant", event = nextTutorial}
	k = k + 1
end

function firstPrint(k)
	return function()
		setFirstPrintEvent(k)
		cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_printHelloTrains)
		console.setVisible(true)
		quickHelp.setVisibility(false)
	end
end

function endTutorial()
	map.endRound()
	mapImage = nil
	curMap = nil
	tutorial = {}
	menu.init()
end

function nextTutorial()
	map.endRound()
	mapImage = nil
	curMap = nil
	tutorial = {}
	menu.init()
	menu.executeTutorial("Tutorial2.lua")
end

function setF1Event(k)
	return function()
		tutorial.f1Event = function ()
					tutorial.f1Event = nil
					if currentStep == k then
						nextTutorialStep()
						tutorialBox.succeed()	--play succeed sound!
					end
				end
			end
end


function setFirstPrintEvent(k)
	tutorial.consoleEvent = function (str)
					if str:sub(1, 13) == "[TutorialAI1]" then
						if str:upper() == string.upper("[TutorialAI1]\tBonjour trAIns!") then
							tutorialSteps[k+1].message = "Bien joué.\n\nLe texte que vous avez imprimée devrait maintenant apparaître dans la console dans le jeu sur la gauche. La console montre aussi que l'IA imprimé le texte, dans ce cas, TutorialAI1. Cela jouera un rôle lorsque vous défirez d'autres IA plus tard.\n\n(Si vous ne pouvez pas voir le texte, déplacez cette info-fenêtre en cliquant dessus et en le faisant glisser quelque part ailleurs.)"
						else
							tutorialSteps[k+1].message = "Pas tout à fait le bon texte, mais vous voyez l'idée.\n\nLe texte que vous avez imprimée devrait maintenant apparaître dans la console dans le jeu sur la gauche. La console montre aussi que l'IA imprimé le texte, dans ce cas, TutorialAI1. Cela jouera un rôle lorsque vous défirez d'autres IA plus tard.\n\n(Si vous ne pouvez pas voir le texte, déplacez cette info-fenêtre en cliquant dessus et en le faisant glisser quelque part ailleurs.)"
						end
						tutorial.consoleEvent = nil
						if currentStep == k then
							nextTutorialStep()
							tutorialBox.succeed()
						end
					end
				end
end

function setCodeExamples()
	cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_eventExamples)
end

function setTrainPlacingEvent(k)
	return function()
		cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_trainPlacing)
		tutorial.trainPlacingEvent = function()
				tutorial.trainPlacingEvent = nil
				tutorial.trainPlaced = true
				tutorial.numPassengers = 0
				if currentStep == k then
					nextTutorialStep()
					tutorialBox.succeed()
				end
			end
		end
end

function setPassengerStart(k)
	return function()
		if not tutorial.placedFirstPassenger then
			passenger.new(5,4, 1,3, "Il y aura un gâteau à la fin. Et une fête. Pas vraiment !") 	-- place passenger at 3, 4 wanting to go to 1,3
			tutorial.placedFirstPassenger = true
			tutorial.restartEvent = function()
				print(currentStep, k)
					if currentStep >= k then	-- if I haven't gone back to a previous step
						passenger.new(5,4, 1,3, "Il y aura un gâteau à la fin. Et une fête. Pas vraiment !") 	-- place passenger at 3, 4 wanting to go to 1,3
						tutorial.placedFirstPassenger = true
					end
				end
		end
	end
end

function pickUpPassengerStep1()
	cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_pickUpPassenger1)
end

function pickUpPassengerStep2(k)
	return function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_pickUpPassenger2)
			tutorial.passengerPickupEvent = function()
				tutorial.passengerPickupEvent = nil
				if currentStep == k then
					nextTutorialStep()
					tutorialBox.succeed()
				end
			end
		end
end

function dropOffPassengerEvent(k)
	return function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_dropOffPassenger)
			tutorial.passengerDropoffCorrectlyEvent = function()
				tutorial.passengerDropoffCorrectlyEvent = nil
				if currentStep == k then
					nextTutorialStep()
					tutorialBox.succeed()
				end
			end
			tutorial.passengerDropoffWronglyEvent = function()		-- called when the passenger is dropped off elsewhere
				if currentTutBox then
					currentTutBox.text = "Vous avez dépossez le passager à un mauvais endroit !\n\nAjouter la fonction affichée dans la zone de code en bas de votre Tutorial.lua"
				end
			end
		end
end

function tutorial.roundStats()
	love.graphics.setColor(255,255,255,255)
	x = love.graphics.getWidth()-roundStats:getWidth()-20
	y = 20
	love.graphics.draw(roundStats, x, y)
	
	love.graphics.print("Tutoriel 1: Mes premiers pas !", x + roundStats:getWidth()/2 - FONT_STAT_MSGBOX:getWidth("Tutoriel 1: Mes premiers pas !")/2, y+10)
	love.graphics.print(currentStepTitle, x + roundStats:getWidth()/2 - FONT_STAT_MSGBOX:getWidth(currentStepTitle)/2, y+30)
end


function tutorial.handleEvents(dt)

	newTrainQueueTime = newTrainQueueTime + dt*timeFactor
	if newTrainQueueTime >= .1 then
		train.handleNewTrains()
		newTrainQueueTime = newTrainQueueTime - .1
	end
end

fileContent = [[
-- Tutoriel 1: Mes premiers pas !
-- Ce que vous devriez savoir:
--	a) Les lignes commençant par deux tirets (signe moins) sont des commentaires, ils seront ignorés par le jeu.
--	b) Toutes vos instructions seront écrites dans le langage de script Lua.
--	c) Les bases de Lua sont très faciles à apprendre, et ce jeu est fait pour vous les apprendres étape par étape.
--	d) Lua est extrêmement rapide ainsi. En bref:
--	e) Lua n'est pas nul.
-- Maintenant que vous avez trouvé le fichier et lire ceci, revenir au jeu et appuyez sur le bouton "Suivant" avec succès !
-- Remarque: Il existe des éditeurs de texte qui mettent en évidence les mots-clés pour la language Lua. Il suffit de chercher les éditeurs Lua sur Internet. Cela rend plus facile à scripter mais ne sont pas nécessaires - Tout ancien éditeur de texte devrait fonctionner.
]]
