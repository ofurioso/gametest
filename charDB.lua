if DEFAULT==nil then
DEFAULT={} end

DEFAULT.BaseSys=20
DEFAULT.xpskillratio=0.15
--this is a positive number, I like ranges from 0.01-0.5 lower values mean it takes more xp to get to the next skill level
DEFAULT.initgold=0
DEFAULT.inithealth=100
DEFAULT.startattrib=10
DEFAULT.maxattrib=20
DEFAULT.startskill=0
DEFAULT.maxskill=5
DEFAULT.damagebonuspercent=150
DEFAULT.damagebonusratio=1.5
DEFAULT.charname="blank"
DEFAULT.entitystruct= {"name","health","attribute","skill","bonus","gold"}
DEFAULT.entity={}
DEFAULT.entity.name="blank"
DEFAULT.entity.health="100"
DEFAULT.entity.attribute={["str"]=DEFAULT.startattrib,["dex"]=DEFAULT.startattrib,["con"]=DEFAULT.startattrib,["int"]=DEFAULT.startattrib,["wis"]=DEFAULT.startattrib,["cha"]=DEFAULT.startattrib}
DEFAULT.entity.equip={["head"]=true,["chest"]=true,["rightarm"]=true,["leftarm"]=true,["legs"]=true,["feet"]=true}
DEFAULT.attribute={"str","dex","con","int","wis","cha"}
DEFAULT.skill={"melee","edged","sword","broadsword","ranged","ballistic","bow","longbow","defend"}
DEFAULT.handtohandskills={"karate","kungfu","judo","aikido","boxing","kickboxing","grapling"}
DEFAULT.equip={["head"]=nil,["chest"]=nil,["rightarm"]=nil,["leftarm"]=nil,["legs"]=nil,["feet"]=nil}
DEFAULT.startinventory={}

--if gametools==nil then
--gametools=require "gametools3" end
if skilltools==nil then
skilltools=require "skillDB" end
if itemtools==nil then
itemtools=require "itemDB" end

charDB={}

function getblankchar()
   local char={}
   char.name=GAMESYS.charname
   local charattrib={}
   local charskills={}
   for i,attribname in pairs(GAMESYS.attribute) do
      charattrib[attribname]=GAMESYS.startattrib
      --prt("%s -> %s",attribname,charskills[skillname]) --debug
   end
   for i,skillname in pairs(GAMESYS.skill) do
      charskills[skillname]=GAMESYS.startskill
      --prt("%s -> %s",skillname,playerskills.[skillname]) --debug
   end
   char.attribute=instancize(charattrib)
   char.skill=instancize(charskills)
   char.inventory=instancize(GAMESYS.startinventory)
   char.equip=instancize(GAMESYS.equip)
   char.gold=GAMESYS.initgold
   char.health=char.attribute.str*char.attribute.con
   return instancize(char)
end

function displaychar(charid)
   local sp
   local achar={}
   achar=charDB[charid]
   prt("name: %s",achar.name)
   prt("health: %s",achar.health)
   prt("ATTRIBUTES:")
   for attribname,value in pairs(achar.attribute) do
      prt("%s : %s",attribname,value)
   end
   prt("Skills:")
   for skill,xp in pairs(achar.skill) do
      sp=convertxptoskill(xp)
      prt("%s : %s",skill,sp)
   end
end

function getcharname(charid)
   return getcharinfo(charid,"name")
end

function setcharname(charid,newname)
   charDB[charid].name=newname
end

function getcharattribute(charid,attrib)
   local charattrib={}
   charattrib=charDB[charid].attribute
   return charattrib[attrib]
end

function setcharattribute(charid,attrib,newvalue)
   charDB[charid].attribute[attrib]=newvalue
end

function getcharskill(charid,skillname)
   local skillxp=getcharskillxp(charid,skillname)
   charskill=convertxptoskill(skillxp)
   return charskill
end

function getcharskillxp(charid,skillname)
   local charskill={}
   charskill=charDB[charid].skill
   return charskill[skillname]
end

function setcharskill(charid,skillname,newvalue)
   if newvalue==nil then
   newvalue=GAMESYS.startskill end
   newvalue=convertskilltoxp(newvalue)
   charDB[charid].skill[skillname]=newvalue
end

function setcharskillxp(charid,skillname,newvalue)
   if newvalue==nil then
   newvalue=GAMESYS.startskill end
   --charskills=charDB[charid].skill
   charDB[charid].skill[skillname]=newvalue
end

function increasecharskill(charid,skill)
   --prt("%s's %s skillxp currently %s",getcharname(charid),skill,getcharskillxp(charid,skill)) --debug
   local currskill=getcharskill(charid,skill)
   local newskillxp=getcharskillxp(charid,skill)+1
   --prt("%s's %s skillxp increases to %s",getcharname(charid),skill,newskillxp) --debug
   setcharskillxp(charid,skill,newskillxp)
   if getcharskill(charid,skill)>currskill then
      prt("%s's %s has increased to %s",getcharname(charid),skill,currskill+1)
   end
   return newskillxp
end

function maxcharhealth(charid)
   return (getcharattribute(charid,"str")*getcharattribute(charid,"con"))
end

function getcharhealth(charid)
   --prt("Attempting to get health (%s) for %s, %s",charDB[charid].health,charid, getcharname(charid)) --debug
   return getcharinfo(charid,"health")
end

function equipitem(charid,itemid,loc)
   local itemequiptree=getiteminfo(itemid,"equiptree")
   if itemequiptree[loc]~=false then
      char=charDB[charid]
      if char.equip[loc]~=nil then
         table.insert(char.inventory,char.equip[loc])
         --swaps item to inventory if theres already something in there
      end
      char.equip[loc]=itemid
   else
      prt("cannot equip %s to %s",getitemname(itemid),loc)
   end
end

function useitem(charid,itemid)
   local thisitem=getitemspecial(itemid)

end

function setcharhealth(charid,newvalue)
   local maxhealth=maxcharhealth(charid)
   charDB[charid].health=newvalue
end

function getchartable(charid)
   return charDB[charid]
end

function getcharinfo(charid,statname)
   return charDB[charid][statname]
end

function killchar(deadcharid,killerid)
   sys.alert('vib')
   if killerid==nil then
      prt("%s has died.",getcharname(deadcharid))
   else
      prt("%s has killed %s.",getcharname(killerid),getcharname(deadcharid))
      --do bonus awarding maybe
   end
end

--*****************FIGHTING STUFF



-- ******************************

itemspresent={1,2,3,4}

examplexp={-1,0,1,2,3,4,5,6,7,8,9,10,11,12,13,18,25,30,45,55,64,89,105,178,205,349,500,640,700,900,1000}

examplesp={0,1,2,3,4,5,6,7,8,9,10,11,12}

table.insert(charDB,getblankchar())
heroid=#charDB
displaychar(heroid)
setcharname(heroid,"frank")
setcharattribute(heroid,"str",12)
--setcharskillxp(heroid,"melee",150)
equipitem(heroid,1,"rightarm")

--testskillconv(examplexp,examplesp)
table.insert(charDB,getblankchar())
setcharname(heroid+1,"buster")

setcharattribute(heroid+1,"dex",13)

equipitem(heroid+1,4,"head")

for count,char in pairs(charDB) do
   prt("\n\nDisplaying charDB[ %s ]",count)
   displaychar(count)
end

--prt("\nSuccess is %s",calcsuccess(99,100)) --debug

repeat
   displaychar(heroid)
   prompt="Please enter a command: "
   commands={"f","d","r","q"}
   action=getcommand(prompt,commands)
   if action=="f" then melee(heroid,"f",(heroid+1),"d")
   else
      if action=="d" then defend(heroid,heroid+1)
      else
         if action=="r" then runaway(heroid,heroid+1)
         else if action=="q" then endgame=true
            end
         end
      end
   end
until endgame==true
prt("the end")






























