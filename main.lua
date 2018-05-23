-- Cette ligne permet d'afficher des traces dans la console pendant l'éxécution
io.stdout:setvbuf('no')

-- Création d'un objet pad correspondant à la raquette
local pad = {}
pad.x = 0
pad.y = 0
pad.largeur = 80
pad.hauteur = 20

--Création d'un objet balle
local balle = {}
balle.x = 0
balle.y = 0
balle.rayon = 10
balle.colle = false
balle.vx = 0
balle.vy = 0

--Creation de l'objet brique
local brique = {}
--Creation de l'objet niveau pour le tableau des briques
local niveau = {}

-- Cette ligne permet de déboguer pas à pas dans ZeroBraneStudio
if arg[#arg] == "-debug" then require("mobdebug").start() end

--Fonction demarre qui contient les instructions pour commencer une nouvelle partie/changer de niveau
function Demarre()
  --On colle la balle sur la raquette
  balle.colle = true
  --On créé une variable complexe niveau
  niveau = {}
  --On créé deux variables l et c pour lignes et colonnes de chaque tableau niveau
  local l,c
  --On créé un tableau de briques contenant la variable niveau initialisée à 1
  for l=1,6 do
    niveau[l] = {}
    for c=1,15 do
      niveau[l][c] = 1
    end
  end
end
--La fonction load qui se charge au démarrage de l'appli
function love.load()
  --On récupère hauteur et largeur de la fenêtre
  largeur = love.graphics.getWidth()
  hauteur = love.graphics.getHeight()
  --On fixe la hauteur et largeur des briques
  brique.hauteur = 25
  brique.largeur = largeur/15
  --On fixe la hauteur de la raquette
  pad.y = hauteur - (pad.hauteur/2)
  --On initialise la fonction demarre
  Demarre()
end
--La fonction update qui s'initialise environ 60x par seconde
function love.update(dt)
  --On lie la souris au pad en horizontal
  pad.x = love.mouse.getX()
  --Si la balle est collé, on réinitialise sa position au départ
  if balle.colle == true then
    balle.x = pad.x
    balle.y = pad.y - pad.hauteur/2 - balle.rayon
  --Sinon on la fait se déplacer (on fait varier sa position en x et en y en fonction de sa vitesse en x et en y)
  else
    balle.x = balle.x + (balle.vx*dt)
    balle.y = balle.y + (balle.vy*dt)
  end
  
  --Gestion des collisions
  
  --Collision avec les briques
  --On créé des variables c et l correspondant à la position de la balle dans une grille virtuelle
  local c = math.floor(balle.x / brique.largeur) + 1
  local l = math.floor(balle.y / brique.hauteur) + 1
  --On vérifie que l et c soit des valeurs correspondant au tableau des briques ( 1 <= l <= 6 et 1 <= c <= 15)
  if l >= 1 and l <= #niveau and c >= 1 and c <= 15 then
    --Si la case contient une brique
    if niveau[l][c] == 1 then
      --on inverse la vitesse en y
      balle.vy = 0 - balle.vy
      --on détruit la brique
      niveau[l][c] = 0
    end
  end
  
  --Collision avec le mur droit
  if balle.x > largeur - balle.rayon then
    balle.vx = 0 - balle.vx
    balle.x = largeur - balle.rayon 
  end
  
  --Collision avec le mur gauche
  if balle.x < 0 + balle.rayon then
    balle.vx = 0 - balle.vx
    balle.x = 0 + balle.rayon
  end
  
  --Collision mur du haut
  if balle.y < 0 + balle.rayon then
    balle.vy = 0 - balle.vy
    balle.y = 0 + balle.rayon
  end
  
  --Si la balle passe sous la raquette
  if balle.y > hauteur - pad.hauteur/2 - balle.rayon then
    balle.colle = true
  end
  
  --Tester collision avec la raquette
  local posCollisionPad = pad.y - pad.hauteur/2 - balle.rayon
  if balle.y > posCollisionPad then
    local dist = math.abs(pad.x - balle.x)
    if dist < pad.largeur/2 then
      balle.vy = 0 - balle.vy
      balle.y = posCollisionPad
    end
  end
  
end
--Fonction d'affichage des éléments
function love.draw()
  local bx,by = 0,0
  local l,c
  
  for l=1,6 do
    bx = 0
      for c=1,15 do
        if niveau[l][c] == 1 then
        --On dessine une brique
          love.graphics.rectangle("fill", bx + 1, by + 1, brique.largeur - 2, brique.hauteur - 2)      
        end
    --On avance en x d'une largeur de brique
    bx = bx + brique.largeur
      end
    by = by + brique.hauteur
  end

  
  love.graphics.rectangle("fill", pad.x - (pad.largeur/2), pad.y - (pad.hauteur/2), pad.largeur, pad.hauteur)
  love.graphics.circle("fill", balle.x, balle.y, balle.rayon)
end
--Fonction lorsqu'un bouton de souris est pressé
function love.mousepressed(x, y, n)
  if balle.colle == true then
    balle.colle = false
    balle.vx = 200
    balle.vy = -200
  end
end