database = dbConnect( "sqlite", "Database.db")

if database then 
	print("Db Conect Success")
else 
	print("Fail ERROR Db Conect")
end	

local ClothesInUsing = {}

addEventHandler("onResourceStart", resourceRoot, 
function()
	if database then
		dbExec(database, "CREATE TABLE IF NOT EXISTS clothes (conta, clothes)")
	end
end
)

createEvent = function(eventname, ...)
	addEvent(eventname, true)
	addEventHandler(eventname, ...)
end

function checkAccountName(element)
	if useGameAccount then
		local acc = getPlayerAccount(element)
		if not isGuestAccount(acc) then
			return getAccountName(acc)
		end
	else
		local id = tonumber(getElementData(element, "ID")) or -1
		if id > -1 then 
			return tostring(id)
		end
	end
end

function getPlayerClothes(element)
	return ClothesInUsing[element]
end



function refeshPlayerClothes(target)
	local user = checkAccountName(target)
	local result = dbPoll(dbQuery(database, "SELECT * FROM clothes WHERE conta = ?", user), -1)
	if type(result) == "table" and #result ~= 0 then
		local clothes = fromJSON(result[1]["clothes"])
		ClothesInUsing[target] = clothes
	end
end

function onLogin(element)
	if element then source = element end
	local user = checkAccountName(source)
	local result = dbPoll(dbQuery(database, "SELECT * FROM clothes WHERE conta = ?", user), -1)
	local clothes
	if type(result) == "table" and #result ~= 0 then
		clothes = fromJSON(result[1]["clothes"])
		ClothesInUsing[source] = clothes
		triggerClientEvent(source, "setPlayersClothes", source, ClothesInUsing)
		triggerClientEvent(root, "setPlayerClothe", root, source, clothes["skin"], ClothesInUsing[source])
	else
		
		local clothes = defaultClothes[getPedSkin(element)]
		if clothes then
			UpdatePlayerClothes(source, clothes)
		end
	end
end

function UpdatePlayerClothes(element, clothes)
	local user = checkAccountName(element)
	local clothes = toJSON(clothes)
	local result = dbPoll(dbQuery(database, "SELECT * FROM clothes WHERE conta = ?", user), -1)
	
	if type(result) == "table" and #result ~= 0 then
		dbExec(database, "UPDATE clothes SET clothes = ? WHERE conta = ?", clothes,  user)
	else
		dbExec(database, "INSERT INTO clothes (conta, clothes) VALUES(?, ?)", user, clothes)
	end
	
	refeshPlayerClothes(element)
	ClothesInUsing[element] = fromJSON(clothes)
	
	setTimer(function()
		triggerClientEvent(root, "setPlayerClothe", root, element, ClothesInUsing[element]["skin"],ClothesInUsing[element])
	end, 500, 1)
end
createEvent("UpdatePlayerClothes", getRootElement(), UpdatePlayerClothes)

addEventHandler("onPlayerLogin", getRootElement(), 
function(_,acc)
	local user = checkAccountName(source)
	local result = dbPoll(dbQuery(database, "SELECT * FROM clothes WHERE conta = ?", user), -1)
	local clothes
	
	if type(result) == "table" and #result ~= 0 then
		clothes = fromJSON(result[1]["clothes"])
		ClothesInUsing[source] = clothes
		triggerClientEvent(source, "setPlayersClothes", source, ClothesInUsing)
		triggerClientEvent(root, "setPlayerClothe", root, source, clothes["skin"], ClothesInUsing[source])
	else
		local clothes = defaultClothes[getPedSkin(source)]
		
		if clothes then
			UpdatePlayerClothes(source, clothes)
		end
	end
end
)

addEventHandler("onPlayerQuit", getRootElement(), 
function()
	ClothesInUsing[source] = nil
end
)

