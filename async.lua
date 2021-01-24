if Citizen and Citizen.CreateThread then
	CreateThread = Citizen.CreateThread
end
Async = {}
debuglog = true 

function Async.parallel(tasks, cb)

	if #tasks == 0 then
		cb({})
		return
	end

	local remaining = #tasks
	local results   = {}

	for i=1, #tasks, 1 do
		
		CreateThread(function()
			
			tasks[i](function(result)
				
				table.insert(results, result)
				
				remaining = remaining - 1;

				if remaining == 0 then
					cb(results)
				end

			end)

		end)

	end

end

function Async.parallelLimit(tasks, limit, cb)

	if #tasks == 0 then
		cb({})
		return
	end

	local remaining = #tasks
	local running   = 0
	local queue     = {}
	local results   = {}

	for i=1, #tasks, 1 do
		table.insert(queue, tasks[i])
	end

	local function processQueue()

		if #queue == 0 then
			return
		end

		while running < limit and #queue > 0 do
			
			local task = table.remove(queue, 1)
			
			running = running + 1

			task(function(result)
				
				table.insert(results, result)
				
				remaining = remaining - 1;
				running   = running - 1

				if remaining == 0 then
					cb(results)
				end

			end)

		end

		CreateThread(processQueue)

	end

	processQueue()

end

function Async.series(tasks, cb)
	Async.parallelLimit(tasks, 1, cb)
end

local unpack = unpack or table.unpack

function Async.waterfall(tasks, cb)
	local nextArg = {}
	for i, v in pairs(tasks) do
		local error = false
		v(function(err, ...)
			local arg = {...}
		    nextArg = arg;
		    if err then
				error = true
			end
		end, unpack(nextArg))
		if error then return cb("error") end
	end
	cb(nil, unpack(nextArg))
end



--debug 
if debuglog then 
local thisname = "async"

Citizen.CreateThread(function()
	if IsDuplicityVersion() then 

		if GetCurrentResourceName() ~= thisname then 
			print('\x1B[32m[server-utils]\x1B[0m'..thisname..' is used on '..GetCurrentResourceName().." \n\x1B[32m[\x1B[33m"..thisname.."\x1B[32m]\x1B[33m"..GetResourcePath(GetCurrentResourceName())..'\x1B[0m')
		end 
		
		RegisterServerEvent(thisname..':log')
		AddEventHandler(thisname..':log', function(strings,sourcename)
			
			print(strings.." player:"..GetPlayerName(source).." \n\x1B[32m[\x1B[33m"..thisname.."\x1B[32m]\x1B[33m"..GetResourcePath(sourcename)..'\x1B[0m')
			
		end)
		
	else 
		if GetCurrentResourceName() ~= thisname then 
			TriggerServerEvent(thisname..':log','\x1B[32m[client-utils]\x1B[0m'..thisname..'" is used on '..GetCurrentResourceName(),GetCurrentResourceName())
		end 
	end 
end)
end 


