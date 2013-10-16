-- some general purpose functions for storing more complex data with strings. I'm 100% certain the better way to do this is using SQLlite or whatever, but this iOS app doesnt really seem to have that. Yes. Coding on iphone... Silly

foolsgold="Pandas are fuzzy"

function stringget(haystack,chunk,dl)
   --passed a string, a number, and a delimiter, this function hands back just the part you want
   --print(haystack,chunk,dl)--debug
   local gold,i,pattern
   i=1
   if dl==nil then dl=";" end
   pattern="([^"..dl.."]+)" --looks around the separator dl
   if haystack~=nil and type(chunk)=="number" then
      for item in string.gmatch(haystack, pattern) do
         --print(i,item) --debug
         if (i==chunk) then
            gold=item
            --print("gold=",gold) --debug
            break
         end
         i=i+1
      end
   else
      print("Just what the fuck am I gonna do with",haystack,chunk)
      gold=foolsgold
   end
   return gold
end

function stringput(haystack,where,what,dl)
   --returns a string with what replacing whatever was in the position where before. Position here being a relative term as in how many separators in.
   --print(haystack,where,what,dl)--debug
   local i, pattern
   local temp={} --holds the string as a table
   i=1
   if dl==nil then dl=";" end
   pattern="([^"..dl.."]+)"
   if haystack~=nil and type(where)=="number" then
      temp=stringtotable(haystack,dl)
      --print("replace",item,"with",what) --debug
      temp[where]=what
      gold=table.concat(temp,dl)
   else
      print("Just what the fuck am I gonna do with",haystack,what,where)
      gold=foolsgold
   end
   return gold
end

function stringtotable(haystack,dl)
   --passed a string and a delimeter, this function hands back a table
   --print(haystack,dl)--debug
   local pattern
   local temp={}
   pattern="([^"..dl.."]+)" --looks around the separator dl
   for item in string.gmatch(haystack, pattern) do
      table.insert(temp,item)
   end
   return temp
end

local function teststringdb()
   local stringa="13;19;3333;5;3.564;Dracula;a hammer;;pine;xxyyzz;t"
   local stringb="Von Helsing"
   local sep=";"

   local num,i,temp
   output=string.format("stringa=%s\n",stringa)
   io.write(output)
   output=string.format("stringb=%s\n",stringb)
   io.write(output)
   for i=1,5 do
      temp=stringget(stringa,i,sep)
      print(i,temp)
   end
   for i=1,5 do
      num=math.random(10)
      temp=stringget(stringa,num,sep)
      print(num,temp)
   end
   num=math.random(10)
   temp=stringput(stringa,num,stringb,sep)
   print(temp)
   output=string.format("stringa=%s\n",stringa)
   io.write(output)
   output=string.format("stringb=%s\n",stringb)
   io.write(output)
end

--teststringdb() --debug































































