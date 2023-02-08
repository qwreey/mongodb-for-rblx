-- 모듈 불러오기 (luaU 타입까지)
local mongodbModule = game.ServerStorage.roMongoDB
local mongodbTypes = require(mongodbModule.types)
local mongodb:mongodbTypes.mongodb = require(mongodbModule)

-- db 연결설정
local db = mongodb.new({
	-- http 혹은 https (설정한거 따라서) 넣고 아이피를 넣어주세요
	-- 혹은 도메인 설정해서 도메인을 넣어주세요
	-- 예 : https://111.111.111.111
	url="https://111.111.111.111",
	-- 사용한 시크릿 값을 넣어주세요 (settings.json 에 넣었던거와 동일하게)
	secret="",
	debug = true -- 디버그 메시지 표시. 끄면 주황색 통신 내용이 뜨지 않습니다
})

-- 문서모음 가져오기
local playersDB = db:getCollection("players")

-- 플레이어 데이터 캐시 (플레이어 나가면 사라지도록 __mod = "k" 부여)
local playerDatas = setmetatable({},{__mode="k"})

local function saveUserData(id,data)
	data._id = nil -- _id 값은 mongodb 가 자동생성해서 설정불가능함
	local updateResult = playersDB:update(
		{id=id},
		{ ["$set"] = data }
	)

	return updateResult
end

-- 플레이어 입장
local function playerAdded(player:Player)
	local userData
	local userID = player.UserId

	-- 찾기
	local findResult = playersDB:find({id=userID})

	-- 서버 오류
	if findResult:hasError() then
		player:Kick("데이터를 불러오지 못했습니다. 보호를 위해 강제 퇴장합니다.")
		error(findResult:hasError())
	end

	-- 새로운 유저라 값 없음
	if findResult:isNull() then
		userData = {id=player.UserId}
		local insertResult = playersDB:insert(userData)
		if insertResult:hasError() then
			error(insertResult:hasError())
		end
	else
		userData = findResult:getResult()
	end
	playerDatas[player] = userData

	-- 2 분마다 업데이트
	task.spawn(function()
		while wait(60*2) do
			-- 고정밀한 시간측정 필요없으므로 wait 넣는게 괜찮음
			-- task.wait 은 매 서버 프레임마다 확인하기에 정확하지만
			-- 그정도까지 서버가 노력하게 만들 필요는 없음
			local updateResult = saveUserData(userID,userData)
	
			if updateResult:hasError() then
				warn(updateResult:hasError())
			end
		end
	end)

	-- 테스트
	print(userData)
	if not userData.money then userData.money = 1 end
	userData.money += 100
	print(userData.money)
end

-- 플레이어 나감
local function playerRemoving(player:Player)
	local userData = playerDatas[player]
	playerDatas[player] = nil
	local updateResult = saveUserData(player.UserId,userData)

	if updateResult:hasError() then
		error(updateResult:hasError())
	end
end

-- 커넥션
game.Players.PlayerAdded:Connect(playerAdded)
for _,player in game.Players:GetPlayers() do
	playerAdded(player)
end
game.Players.PlayerRemoving:Connect(playerRemoving)
game:BindToClose(function()
	for _,player in game.Players:GetPlayers() do
		playerRemoving(player)
	end
end)
