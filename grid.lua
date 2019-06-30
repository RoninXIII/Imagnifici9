--[[
require "grid"
G = grid.Grid()

  Metodi pubblici

  get_cell(x, y)             Ritorna il dato nella cella con coordinata x,y.
  set_cell(x, y, obj)        Sets the cell's data to the given object.
  populate()                 Popola la griglia con operazioni e numeri casuali.
  get_contents(no_default)   Returns a flat table of data suitable for populate().
  get_row(x)                 Ritorna una table con gli elementi della riga selezionata.
  get_column(y)              Ritorna una table con gli elementi della colonna selezionata.
]]

--[[ La griglia che conterrà le celle ]]
grid = {}

-- Serve per avere numeri randomici ogni volta differenti
math.randomseed(os.time())

--[[ Definizione classe Grid ]]
function grid.Grid()
  local g = {}

  -- Operazioni disponibili
  g._operations = {"+","-","*"}

  --[[Table della grilgia interna]]
  g._grid = {{"","+","","*","",21},
             {"+","","-","","+",""},
             {"","-","","*","",1},
             {"*","","+","","+",""},
             {"","+","","-","",3},
             {15,"",8,"",13,""}}

  g.size_x = 5
  g.size_y = 5
  g.axis_x = 90
  g.axis_y = 90
 

  --[[DEFINIZIONE METODI ]]


  --[[ Gets the data in a given x,y cell. ]]
  function g:get_cell(x, y)
    return self._grid[x][y] 
  end


  --[[ Sets a given x,y cell to the data object. ]]
  function g:set_cell(x, y, obj)
  
       self._grid[x][y] = obj

    return true
  end

 function g:populate()
  local x,y = 1,1
   return self:populateB(x,y),self:computeGrid()
 end

  function g:populateB(x,y)
  -- Se le coordinate sono dispari allora ci troviamo in una casella che contiene un numero ([1,1][1,3][1,5][3,1][3,3][3,5] ecc.)

if self:isOdd(x) and self:isOdd(y)  then
  -- Si inserisce un numero nella casella e si controlla che il numero non sia stato già inserito nella riga o nella colonna

  local number = math.random(1,9) 
  while self:isAllowed(x,y,number) == false do
    number = math.random( 1,9 )
  end
  self._grid[x][y] = number
  -- Le caselle con coordinate pari sono le caselle che non contengono né numeri né operazioni

elseif self:isOdd(x) == false and self:isOdd(y) == false then   

  -- Le caselle con una coordinata pari e una dispari è preposta per le operazioni
elseif x ~= 6 and y ~=6 then  self._grid[x][y] = self:getOp()

end
     

    if self._grid[x][y+1] ~= nil then

     return self:populateB(x,y+1)
  
    elseif self._grid[x+1] ~= nil then return self:populateB(x+1,1)
      
 
end

  return true

end
-- Sceglie randomicamente un' operazione tra le tre possibili
function g:getOp()
  return self._operations[math.random(1,3)]
end

-- Controlla se la riga o la colonna selezionata è pari o dispari.
-- I numeri saranno sempre collocati nelle colonne dispari, le operazioni in quelle pari
function g:isOdd(el)
  if el == 1 or el == 3 or el == 5 then return true
  else return false
  end   
end

  --[[
  -- This method returns the entire grid's contents in a
  -- flat table suitable for feeding to populate() above.
  -- Useful for recreating a grid layout.
  -- If the 'no_default' argument is non-nil, then the
  -- returned data table only contains elements who's 
  -- cells are not the default value.
  --]]
  function g:get_contents(no_default)
    local x, y
    local data     = {}
    local cell_obj = nil


   for x=1, self.size_x do
      for y=1, self.size_y do
        cell_obj = self._grid[x][y]

        if no_default == true and cell_obj == self.def_value then
          -- Do nothing, ignore default values.
        else
          table.insert(data, {x, y, cell_obj})
        end
      end
    end 

    return data
  end


 
  --[[
  -- This method returns a table of all values in a given 
  -- row 'x' value.
  --]]
  function g:get_row(x)
    local row = {}

    if type(x) == "number" and (x > 0 and x <= self.size_x) then
      row = self._grid[x]
    end

    return row
  end

  --[[
  -- This method returns a table of all values in a given
  -- column 'y' value.
  --]]
  function g:get_columnB(x,y,col)
   

    table.insert(col,self._grid[x][y])

    if self._grid[x+1] ~= nil and x+1 ~= 6 then col = self:get_columnB(x+1,y,col)

    end

    return col
  end

  function g:get_column(y)
    local col = {}
    return self:get_columnB(1,y,col)

  end

 
  function g:compute(list)
    
     
    local result = 0


    local num1,op1,num2,op2,num3 = table.unpack(list)

    if op1 == "*" then 
      if op2 == "*" then result = num1 * num2 * num3 
      elseif op2 == "+" then result = num1 * num2 + num3
      elseif op2 == "-" then result = num1 * num2 - num3   
    end

    elseif op1 == "+" then  
      if op2 == "*" then result = num1 + num2 * num3 
      elseif op2 == "+" then result = num1 + num2 + num3
      elseif op2 == "-" then result = num1 + num2 - num3
      end

    elseif op1 == "-" then 
      if op2 == "*" then result = num1 - num2 * num3 
      elseif op2 == "+" then result = num1 - num2 + num3
      elseif op2 == "-"  then result = num1 - num2 - num3
      end
   
    end
    if result < 0 then
      result = -1
    end
    
    return result
  end

  function g:computeGrid()
    
    local resultRow1,resultRow2,resultRow3 = self:compute(self:get_row(1)),self:compute(self:get_row(3)),self:compute(self:get_row(5))

    local resultCol1,resultCol2,resultCol3 = self:compute(self:get_column(1)),self:compute(self:get_column(3)),self:compute(self:get_column(5))

    if resultRow1 == -1 or resultRow2 == -1 or resultRow3 == -1 or resultCol1 == -1 or resultCol2 == -1 or resultCol3 == -1 then
      self:populateB(1,1)
      return self:computeGrid()
    else
      self._grid[1][6],self._grid[3][6],self._grid[5][6] = resultRow1,resultRow2,resultRow3
      self._grid[6][1],self._grid[6][3],self._grid[6][5] = resultCol1,resultCol2,resultCol3
      return true

    end
   
  end
-- Setta i valori delle celle che contengono i numeri in ""
-- Questo metodo imposta la griglia di gioco : si vedranno solo i risultati e le operazioni permettendo
-- la risoluzione del gioco.
  function g:hide(x,y)

    if type(self._grid[x][y]) == "number" then 
    self:set_cell(x,y,"")
    end
    if self._grid[x][y+2] ~= nil then return self:hide(x,y+2)

    elseif self._grid[x+2] ~= nil then return self:hide(x+2,1)
    end
    return true
  end

  function g:hideNumbers()
    local x,y = 1,1

    return self:hide(x,y)
  end

function g:containsInRow(x,y,number)
  
  if self._grid[x][y] == number then return true

  elseif self._grid[x][y+2] ~= nil then return self:containsInRow(x,y+2,number)

  else return false
  end

end

function g:containsInColumn(x,y,number)

  if self._grid[x][y] == number then return true

  elseif self._grid[x+2] ~= nil then return self:containsInColumn(x+2,y,number)

  else return false
  end


end

-- Controlla che non ci sia lo stesso numero nella stessa riga o colonna
function g:isAllowed(x,y,number)

  return not(self:containsInRow(x,1,number) or self:containsInColumn(1,y,number))
end

function g:checkResult(x,y)
  
  if y+1 == 6 and x+1 ~= 6 then 

    local result = self._grid[x][6]

    if self:compute(self:get_row(x)) == result then return true
    else return false  
  
    end
  elseif x+1 == 6 then
    local result = self._grid[6][y]

    if self:compute(self:get_column(y)) == result then return true

    elseif x+1 == 6 and y+1 == 6 then 
      local result1 = self._grid[x][y+1] 
      local result2 = self._grid[x+1][y+1]
      if self:compute(self:get_row(x)) == result1 and self:compute(self:get_column(y)) == result then
        return true
      end
  else return false

    end

  end

end

function g:solve(x,y)

    for number=1,9 do
 
      if self:isAllowed(x,y,number) then
        self._grid[x][y] = number

        if (x+1 == 6 or y+1 == 6)  then

          if self:checkResult(x,y) then
            if self._grid[x+2] ~= nil then

              if self:solve(x+2,1) then
                return true
              end
            elseif self._grid[y+2] ~= nil then 
              if self:solve(x,y+2) then return true end

            else return true 
            end
 

          end  
        elseif self:solve(x,y+2) then return true 
        end 

      end -- Fine if isAllowed
    end -- Fine for

end

  function g:printGrid(x,y)
  
    love.graphics.rectangle("line", y*self.axis_y +70, x*self.axis_x -40, 90, 90)
   
    
    if self:isOdd(x) and self:isOdd(y)  then

   love.graphics.print(self._grid[x][y],y*self.axis_y +90,x*self.axis_x-30) 
  
elseif self:isOdd(x) == false and self:isOdd(y) == false then   

love.graphics.setColor(0.7,0.7,0.7)
love.graphics.rectangle("fill", y*self.axis_y +70, x*self.axis_x -40, 90, 90)
love.graphics.setColor(1,1,1)



else   
love.graphics.setColor(0.7,0.7,0)
love.graphics.print(self._grid[x][y],y*self.axis_y +75,x*self.axis_x-20)
love.graphics.setColor(1,1,1)
end



   if self._grid[x][y+1] ~= null then 
    
    
   return self:printGrid(x,y+1)
  
elseif self._grid[x+1] ~= null then
  
   return self:printGrid(x+1,1)
end

  
end
  --[[ END OF METHODS ]]

  --[[ Our object is formed, return to momma... ]]
  return g
end