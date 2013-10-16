function rollD(max)
   return math.random(max)
end

maxhealth=10
maxdiff=6
maxlevel=10
endgame=false

health=maxhealth

map = {}
i=0
while (i<maxlevel) do
   map[i] = rollD(maxdiff)
   -- print(i,map[i])
   i=i+1
end

i=0
local answer
while (endgame==false and health>0 and i <maxlevel) do
   print("stage ", i, map[i], "\n")
   repeat
      io.write("keep going (y/n)? ")
      io.flush()
      answer=io.read()
   until answer=="y" or answer=="n"
   if (answer=="y") then
      myroll=rollD(10)
      print("Brave soul. You roll a ", myroll, "\n")
      if (myroll < map[i]) then
         health = health-(map[i]-myroll)
      end
      print("Your health is now: ",health, "\n")
      i=i+1
   else if (answer=="n") then
         print("Aww.")
         endgame=true
      end
   end
end
if (i>=maxlevel) then
   print ("You win!!!")
end
if (health <=0) then
   health = 0
   print("You died!")
   i=i-1
else if (i<maxlevel) then
      print("You lived.")
end end

print("The end. You achieved level ", i, "with",health,"health!")
