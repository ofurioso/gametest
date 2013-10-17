-- A collection of useful game tools

if stringtools==nil then
stringtools=require "stringdb" end

function rollD(max)
   return math.random(max)
end

function displaythis(text)
   io.write(text)
end

function getcommand(prompt,commandset)
   --formats and displays a prompt
   --only returns valid responses
   local i,com
   local validcom={}
   prompt=prompt.." ( "
   for i,com in pairs(commandset) do
      prompt=prompt..com
      if (i~=#commandset) then
      prompt=prompt.." / " end
      validcom[com]=true
   end
   prompt=prompt.." ) ?"
   io.write(prompt)
   repeat
      io.flush()
      answer=io.read()
      -- print("io read:",answer) --debug
   until (validcom[answer]==true)
   return answer
end
