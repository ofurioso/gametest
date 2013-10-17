BaseSys=100
--the maximum difficulty of anything
player={}

totalbots=12
--how many monsters are in the game
bottypes=5
--how many kinds of monsters are there
botdifgradient=.1
--a weird thing which is how much more difficult the next monster is compared to the previous one. 0 is flat, larger numbers will make bots/monsters very difficult. I reccomend 0-2

gametools=require "gameDBtools"
maptools=require "mapDBtest"
bottools=require "monstersDB"
bonustools=require "bonusDB"

entitystruct={"name","hp","attack","defense","escape","bonus","gold"}
local st={} --this will be an easy(?) way to get the index of the stat
for lookup,stat in pairs(entitystruct) do
   st[stat]=lookup
end

mapstruct={"north","east","south","west","name","bot"}
oppdir={}
oppdir[1]=3
oppdir[2]=4
oppdir[3]=1
oppdir[4]=2

totalsections=26
inithealth=100
initattack=1
initdefense=1
initescape=10
initgold=0

handicap= .5
maxlevel=50
endgame=false

function flee()
   if player.escape>0 then
      player.escape=player.escape-1
      goodpaths=getvalidpaths("number",thissection.sectionid)
      whichdir=(rollD(#goodpaths))
      where=thissection[whichdir]
      local enemyesc=getbotstat((getmapbot(thissection.sectionid)),st.escape)
      if (player.escape+rollD(BaseSys)<enemyesc) then
         feedback=string.format("%s lashes out after you",getbotname(getmapbot(thissection.sectionid)))
         displaythis(feedback)
         calcbotcombat()
      end
      feedback=string.format("You have fled. You have %s escapes remaining.\n",player.escape)
      displaythis(feedback)
      success=true
   end
   return where
end

function resolvecombat(botnum)
   local enemy=getbottable(botnum)

   function calcplayercombat()
      local damagedealt=(player.attack+rollD(BaseSys))-enemy.defense
      if (damagedealt > 0) then
         local feedback=string.format("you hit for %d damage\n", damagedealt)
         displaythis(feedback)
         enemy.hp=enemy.hp-damagedealt
         if (enemy.hp<0) then enemy.hp=0 end
      else
         local feedback=string.format("You swing but miss! %d\n", damagedealt)
         displaythis(feedback)
      end
   end

   function calcbotcombat()
      local damagedealt=enemy.attack-(player.defense+rollD(BaseSys))
      if (damagedealt > 0) then
         local feedback=string.format("%s hits you for %d damage\n", enemy.name,damagedealt)
         displaythis(feedback)
         player.hp=player.hp-damagedealt
      else
         feedback=string.format("%s misses you by %d\n", enemy.name,damagedealt)
      end
   end

   -- while (thisbot.healt >0 and player.health>0) do
   if (enemy.hp > player.hp) then
      print("bot  has initiative")
      calcbotcombat()
      calcplayercombat()
   else
      print("You  have initiative")
      calcplayercombat()
      if (enemy.hp>0) then
         calcbotcombat()
      end
   end
   setbotstat(botnum,st.hp,enemy.hp)
   if (enemy.hp<=0) then
      loot=enemy.gold
      setbotstat(botnum,"gold",0)
      player.gold=player.gold+loot
      saythis=string.format("You have slain %s and looted %s gold\n",enemy.name,loot)
      displaythis(saythis)
      applybonus(enemy.bonus)
   end
   return enemy.hp
end

function initializeplayer()
   player.name="Player"
   player.hp=inithealth
   player.attack=initattack
   player.defense=initdefense
   player.escape=initescape
   player.gold=initgold
end

function distributebots()
   local i,n,botstogo
   local density=totalbots/totalsections
   if (density>=1) then
      --bots, bots everywhere!
      for i=1,totalsections do
         setmapbot(i,i)
         -- print("setmapbot",botDB[i]) debug
      end
   else
      --bots are distributed through sections using math
      n=totalsections/totalbots
      for i=1,totalbots do
         factor=((1+(1/i))^i)/2.7182818459
         num=math.ceil(i*n*factor)
         setmapbot(num,i)
         --print(i,">", num) --debug
      end
   end
end

function allfoesgone()
   local i,botid,bothp
   local flag=true
   for i=1,totalsections do
      botid=getmapbot(i)
      if botid~=nothing then
         flag=false
         break
      end
      return flag
   end
end

function showsection()
   -- displays the current section in a diamond pattern with n,e,s,w
   local display

   local function tileme(thingy)
      local tile
      if thingy==nothing then
         tile="."
      else if type(thingy)=="number"then
            if getmapbot(thingy)~=nothing then
               tile="*" --bot here
            else
               tile="O" --no bot
            end
         end
      end
      return tile
   end --function tileme

   local name=thissection.name
   local north=tileme(thissection[mst.north])
   local east=tileme(thissection[mst.east])
   local south=tileme(thissection[mst.south])
   local west=tileme(thissection[mst.west])
   local here= tileme(thissection.sectionid)

   display=string.format("  %s            \n",north,name)
   display=display..string.format("%s %s %s\n",west,here,east)
   display=display..string.format("  %s    \n",south)
   displaythis(display)
end

-- MAIN GAME LOOP ********************

level=1
initializeplayer()
createmap()
print("Inventing bots...") --debug
inventbots()
print("Instancing bots...") --debug
makeallbots()
--listbots() --debug
print("Placing bots...") --debug
distributebots()
listmap() --debug
--showgrid()
gotosection(1)
local commands,action,saythis
local localbotid
repeat
   feedback=string.format("HP: %s ATK: %s DEF :%s   gold: :%s\n",player.hp,player.attack,player.defense,player.gold)
   displaythis(feedback)
   localbotid=thissection.bot
   --print(botDB[localbotid]) --debug
   showsection()
   commands={}
   --only if the enemies have been killed is the player allowed to leave
   --print("Localbotid=",localbotid) --debug
   --print("Thats the same as",botDB[localbotid]) --debug
   if localbotid~=nil and localbotid~=nothing then
      botname=getbotname(localbotid)
      feedback=string.format("There is a %s here\n",botname)
      displaythis(feedback)
      displaybot(localbotid)
      table.insert(commands,"a")
      if player.escape>0 then
         table.insert(commands,"f")
      end
   else
      --print("Checking for paths")
      goodpaths=getvalidpaths("number",thissection.sectionid)
      for num,path in pairs(goodpaths) do
         table.insert(commands,dirtocom[path])
      end --paths into commands
   end
   table.insert(commands,"q")
   saythis="Enter a command "
   action=getcommand(saythis,commands)

   print ("Okie Dokie") --debug
   if (action=="q") then
      endgame=true
   else if action=="a" then
         print("Brave soul.")
         local bothp=resolvecombat(localbotid)
         feedback=string.format("Your health is now %d\n",player.hp)
         displaythis(feedback)

         if (bothp<=0) then
            --print("Removing corpse")
            setmapbot(thissection.sectionid,nothing)
         end --foe vanquished
         gotosection(thissection.sectionid) --resets section
      else if action=="f" then
            gotosection(flee())
         else
            --this will be a direction command
            print(action, pathcommands[action], thissection[pathcommands[action]]) --debug
            gotosection(thissection[pathcommands[action]])
         end --else
      end --escape
   end --attack
until (endgame==true or player.hp<=0 or level>maxlevel)

-- GAME OVER ***********************

if action=="q" then
   print("Thanks for playing!")
end
if (allfoesgone()) then
   print ("You win!!!")
end
if (player.hp <=0) then
   player.hp = 0
   print("You died!")
   level=level-1
else
   print(string.format("You lived. And  have %d gold!",player.gold))
end
feedback=string.format("The end. You achieved level %d with %d health\n",level,player.health)
displaythis(feedback)


