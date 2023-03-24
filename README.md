
# note

**알아서 하세요 진짜**  
어려울법 한건 아는데 그만큼 좋은거 쓰고 싶다면 구글에 검색하거나 해서 최대한 알아는 봅시다  
정ㅇㅇㅇㅇㅇㅇ말 모르겠으면 디스코드로 물어보세요 물어본다면 상황이 어떤지 구체적으로, 스크린샷 등과 함깨 물어보세요  
https://blog.qwreey.kr 에서 저의 디스코드 id 를 얻을 수 있습니다  
 + 가끔 진짜 안된다 안된다 이러는데 아무것도 안보여주면 어떻게 압니까? 가끔 가릴꺼 다 가려놓고 물어본다던가 아니면 아에 정보도 안주고 물어봐서 어이 없던 경험이 많습니다  

*저는 신이 아닙니다 님이 보는 화면을 몰라요*  

# setup

호스팅은 오라클, 혹은 https://ide.goorm.io/ 를 추천합니다  
오라클은 해외 신용카드를 넣어야 가입이 되므로 불가피하다면 구름ide도 좋습니다  
오라클은 4코어 24기가 ram 에 200 기가 스토리지가 무료이며  
구름 ide 는 항상활성화 컨테이너 1코어 1기가 ram 10 기가 스토리지가 무료입니다  
왠만해서 구름 ide 도 만명정도 데이터는 버틸꺼에요 (다만 동접자가 많으면 힘들어집니다)  

몽고db 랑 node 를 깔아줍니다... 뭐 알아서 될꺼에요 이건  
```
corepack enable
```
해서 yarn 켜주시고  

```
git clone https://github.com/qwreey75/mongoDB_forRBLX
```
해서 리포 받아줍니다  
```
cd mongoDB_forRBLX
```
cd 해서 터미널에서 잘 들어가 주신 다음  
```
yarn
```
yarn 으로 디펜던시를 받아줍니다

그다음 받은 폴더 안에 settings.json 파일 하나 만들어서  
```jsonc
{
    // 시크릿 문자. 서버 소통에 쓰이며 랜덤해야합니다
    // 절대 이 예시의 시크릿을 그대로 사용하지 마시고
    // 랜덤한 문자를 만들어 사용해 주세요.
    // 서버통신에서 사용되는 시크릿은 이 값을 시드로
    // 사용해 계속해서 변화합니다
    "secret": "XjipTfC.hifmGJhOBvXRtrP4wfh4lA6kWu8h",

    // 서버가 오픈될 포트입니다. http 사용하려면 80
    // https 사용하려면 443 해주세요
    // 서버 성능이 낮다면 http 쓰는게 좋을지도...?
    "port": 19721,
    "host": "localhost", // "0.0.0.0"

    // 몽고 db url 입니다. 포트를 맞춰주세요
    // 기본값은 mongodb.sh 파일과 같습니다
    // 바꾸었다면 mongodb.sh 파일도 열어 바꿔주세요
    "mongodbURL": "mongodb://localhost:19722",

    // 사용될 db 명입니다 (use rblxDB)
    "dbName": "rblxDB"
}
```

저렇게 넣어주시고 (주석은 없어야함)  
tmux 에서 mongodb.sh 를 실행해줍니다(창 하나 만들어서)  

```
tmux new -s mongodb
./mongodb.sh
ESC (쉬고) CTRL+b (쉬고) d
```

참고 :
```
tmux 는 세션을 나가도 프로그램이 계속 실행될 수 있도록 가상창을 만들 수 있게 도와줍니다  
유지시키고 싶은 프로그램이 있다면  
tmux new -s 이름  
다음과 같이 이름을 지정한 창을 만들고  
프로그램을 실행한 다음  ESC 쉬고 CTRL+b  쉬고 d 를 순차적으로 눌러 나올 수 있습니다 (나오더라도 실행한 프로그램은 계속 실행됨)  
다시 그 창에 들어가려면 tmux a -t 이름 을 써주면 됩니다. 나가는것은 동일  
tmux 창에 들어가있다면 바닥에 초록색 라인과 창 이름이 표시됩니다. 생성된 창 바깥과 안을 잘 구분해 주세요  
```

이제 mongosh 를 사용해줍니다. --port 로 입력한 포트로 열어줍니다
```
mongosh --port 19722
```

열린 창에 test> 가 뜬다면 정상입니다  
settings.json 안에 dbName 넣었던걸 아래처럼 입력해줍니다 (기본값이면 그냥 따라 쓰면됨)  
```
use rblxDB
```

그런다음 컬랙션을 만들어줍니다  
필요에 따라 컬랙션을 만들어 주시면 됩니다 (예: 유저 데이터, 집 데이터, 등등을 나눠서 카테고리화해서 컬랙션을 만드세요)  
```
db.createCollection("players")
```

이제 CTRL+C 를 두세번 눌러 나와주세요  

그다음 tmux 창 하나 더 만들어서 node 를 켜줍니다  
로그를 저장하고 싶으면 node . 뒤에 > 로 출력을 파이핑하세요  
(예 : node . > ~/rblxdb.log  
      저장된 로그는 less ~/rblxdb.log 로 볼 수 있습니다)  
```
tmux new -s node
node .
ESC (쉬고) CTRL+b (쉬고) d
```

그런다음 이 페이지의 release 부분 찾아 들어가서 rbxmx 받아주시고  
스튜디오로 드래그 엔 드롭 한 후 ServerStorage 로 옮기고  
http 서비스를 켜주세요  
~~빌드해준 저가 불신된다면 rojo 로 직접 빌드하시던가요..~~  
```
스튜디오 하단 커맨드 입력란에
game:GetService("HttpService").HttpEnabled = true
입력후 엔터
```

그런다음 이 저장소의 rblx/test.lua 파일을 복사떠 ServerScriptService 에 대충 script 하나 넣고 붙여넣은 뒤,  
mongodb.new({}) 부분에 설명대로 바꿔주세요  
```lua
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
```

완료입니다. 저장 후 나갔다 들어올 때 마다 출력창에 숫자가 100 씩 오르는게 보인다면 정상입니다  
이제 스크립트를 편집해서 알아서 쓰세요  

# Thanks to

sha1 for rblx lua  
https://gist.github.com/Dekkonot/75d939cbc31fb2f278a3d7d55dc78fd7
used for hasing datas  
