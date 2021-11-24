local texture = {}
local myShader = {}
local mycharacter = {}

local myShader_raw_data = [[
	texture tex;
	technique replace {
		pass P0 {
			Texture[0] = tex;
		}
	}
]]

createEvent = function(eventname, ...)
	addEvent(eventname, true)
	addEventHandler(eventname, ...)
end

function applyTexture(element, shader, dir)
	texture[element] = dxCreateTexture(dir)
	dxSetShaderValue(shader, "tex", texture[element])
	destroyElement(texture[element])
end

function clearShaderClothe(element, skin, variavel, stylo)
	if not myShader[element] then
		myShader[element] = {}
		texture[element] = {}
	end
	if not myShader[element][variavel] then
		myShader[element][variavel] = {}
	end

	if not myShader[element][variavel]then
		myShader[element][variavel] = {}
	end

	if isElement(myShader[element][variavel]) then
		destroyElement(myShader[element][variavel])
	end

	if stylo then
		myShader[element][variavel] = dxCreateShader(myShader_raw_data, 0, 0, false, "ped")
		engineApplyShaderToWorldTexture(myShader[element][variavel], class_clothes[skin][variavel][stylo], element)
	end
end

function setClothe(element, skin, variavel, stylo, text)
	stylo = tonumber(stylo)
	text = tonumber(text)
	if class_clothes[skin][variavel][stylo] and text > 0 then

		clearShaderClothe(element, skin, variavel, stylo)

		if variavel == "calcado" and stylo == 1 then
			clearShaderClothe(element, skin, "pe", 1)
			applyTexture(element, myShader[element]["calcado"],"assets/"..skin.."/1.png")
		end
		applyTexture(element, myShader[element][variavel],"assets/"..skin.."/"..variavel.."/"..stylo.."/"..text..".png")
		
	elseif variavel and stylo < 1 then
		clearShaderClothe(element, skin, variavel)
	else
		outputChatBox("Nenhuma variável encontrada."..variavel,255,0,0,true)
	end
end

function setPlayerClothe(element, skin, clothes)
	for clothe, _ in pairs(clothes) do
		if clothe ~= "skin" then
			setClothe(element, skin, clothe, clothes[clothe][1], clothes[clothe][2])
		end
	end
end
createEvent("setPlayerClothe", getRootElement(),setPlayerClothe)

createEvent("setPlayersClothes", getRootElement(), 
	function(clothe)
		local inTable = {}
		inTable = clothe
		for i, player in ipairs(getElementsByType("player")) do
			if inTable[player] then
				setPlayerClothe(player, clothe[player]["skin"], clothe[player])
			end
		end
	end
)

addEventHandler("onClientPlayerQuit", getRootElement(), 
	function()
		for variavel, _ in pairs(class_clothes[getPedSkin(source)])do
			clearShaderClothe(source, getPedSkin(source), variavel)
		end
		myShader[source] = nil
	end
)

