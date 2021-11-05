
-- spellcaster's !!
base64str='0123456789abcdefghijklmnopqrstuvwxyz!@#$%^&*()_-+=[]}{;:<>,./?~|'

function explode_hex(s, delimiter)
 local retval,i=split(s,delimiter,false)
  
 for i=1,#retval do
  retval[i] =("0x"..retval[i])+0
 end
 return retval
end


function explode64(s)
 local retval,lastpos,i = {},1,2
 
 while i <= #s do
  add(retval,base64decode(sub(s, lastpos, i)))
  
  lastpos = i+1
  i += 2
 end
 return retval
end


function base64decode(str)
 val=0
 for i=1,#str do
  c=sub(str,i,i)
  for a=1,#base64str do
   v=sub(base64str,a,a)
   if c==v then
    val *= 64
    val += a-1
    break
   end
  end
 end
 return val
end

-- optimized rle drawing functions
-- big thanks to frederic souchu
-- ( @fsouchu on twitter )
-- for the help

function spr_rle_flip(table,_x,_y)
 local w=table[1]
 local x,y,i,x2=_x+w,_y,3,_x+w

 for i =3,#table do
  local t=table[i]
  local col,rle = (t& 0xff00)>>8
                  ,t& 0xff 
  if col!=0 then
   rectfill(x-rle+1,y,x,y,col)
  end
  x-=rle
  if x <=_x then
   x = x2
   y += 1
  end
 end
end

function draw_rle(table,_x,_y)
    local x,y,i,w=_x,_y,3,table[1]+_x

    for i=3,#table do
        local t=table[i]
        local col,rle = (t& 0xff00)>>8
                        ,t& 0xff

        rectfill(x,y,x+rle-1,y,col)
        x+=rle
        if x >=w then
            x = _x
            y += 1
            end
    end
end

function store_rle(table, store)
    local x,y,i,w=0,0,3,table[1]
    local temp = {}

    for s=0, table[1]-1 do
        temp[s] = {}
    end

    for i=3,#table do
        local t=table[i]
        local col,rle = (t& 0xff00)>>8
                        ,t& 0xff

        for p=0, rle-1 do
            temp[y][x+p] = col
        end
        --rectfill(x,y,x+rle-1,y,col)
        
        x+=rle
        
        if x >=w then
            x = 0
            y += 1
        end
    end

    return temp
end

--[[
function spr_rle(table,_x,_y)
 local x,y,i,w=_x,_y,3,table[1]+_x
 for i=3,#table do		
  local t=table[i]
  local col,rle = (t& 0xff00)>>8
                  ,t& 0xff
  if col!=0 then
   rectfill(x,y,x+rle-1,y,col)
  end
  x+=rle
  if x >=w then
   x = _x
   y += 1
  end
 end
end


function setpal(palstr)
 local i,palindex
 palindex=explode_hex(palstr,",")
 for i=1,#palindex do
  pal(i-1,palindex[i],1)
 end
end


function pal2()
 local i
 for i=0,15 do
  pal(i,128+i,1)
 end
end

function cprint(txt,x,y,cols)
 local len,org=#txt*4+4,clip() 
 local a
 x=x and x or 64-len/2
 for a=1,3 do
  print(txt,x,y,cols[a])    
  clip(x,y+a*2,len,2)
 end
 clip(org)
end
--]]