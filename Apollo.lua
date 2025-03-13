----------------------------
--------> [APOLLO] <--------
------> Confidential <------
---> [By VTIL, MFDLabs] <---
----------------------------

--- For those who are wondering why MFDLabs is in here (Mainly the people in RRE who question everything)
--- I used MFDLabs website template as a backend base as i know the code
--- And where to put everything in, So it was a good choice!



local Apollo = { --- Main Table or as the cultured people would say 'Where the magic happens' - I'm sorry.
	Site = "https://apollo.vtilserver.com/api",

	internal = {
		--- false.
		ScriptModule = false,
		
		--- OOOO an empty table i wonder what would be pu- ....oh i guess nothing :/
		functions = {}
	},

	Services = {
		HTTPService = game:GetService("HttpService"),
		ServerStorage = game:GetService("ServerStorage")
	},

	functions = {
		JSONEncode = function (tbl)
			--- I never knew you could do typeof({}) and it would not error,
			--- Then again i never tried.
			
			assert(typeof(tbl) == "table", `Argument #1 '{typeof({})}' expected, got '{typeof(tbl)}.'`)

			return game:GetService("HttpService"):JSONEncode(tbl)
		end,

		JSONDecode = function (str)
			assert(typeof(str) == "string", `Argument #1 '{typeof("")}' expected, got '{typeof(str)}.'`)

			return game:GetService("HttpService"):JSONDecode(str)
		end,
	},

	settings = {

		--## WARNING: THIS API KEY WILL BE CHANGED WHEN THE SITE IS FULLY IN PRODUCTION!!! ##--
		PRIVATE_KEY = "769D013A-CA05-468F-A179-8F050967D0DF",  -- hahahahha this is already changed >:)
		
		LD_KEY = "0531B2DF-33FB-48", -- I HATE THIS I HATE THIS I HATE THIS I HATE THIS
	}
}


do --- Internal Functions
	--- Oh never mind; Things would be put in that empty table after all!
	
	function Apollo.internal.functions.newLocal(source, parent)
		local ScriptModule = Apollo.internal.ScriptModule
		
		local http = Apollo.Services.HTTPService
		local storage = Apollo.Services.ServerStorage


		if not (ScriptModule) then	
			ScriptModule = require(storage:WaitForChild("ApolloScriptModule"))(Apollo.settings.LD_KEY)
		end

		local client = ScriptModule ("CLIENT", source)
		
		-- DO NOT REMOVE THIS IDENTIFIER AS IT IS USEFULL FOR
		-- DEBUGGING APOLLO LOCALSCRIPTS AS THIS TYPE OF LOCAL LOADING VIA WEB HAS NOT BEEN DONE BEFORE.
		client:SetAttribute("GENERATED", true) 
		
		--- Look everyone this script AHEM localscript now identifies as a apollo id >:)
		client.Name = `Apollo Id: {http:GenerateGUID(false):upper():sub(1,16)}`
		client.Parent = parent

		return client
	end

	function Apollo.internal.functions.newServer(source, parent)
		local ScriptModule = Apollo.internal.ScriptModule
		
		local http = Apollo.Services.HTTPService
		local storage = Apollo.Services.ServerStorage


		if not (ScriptModule) then	
			ScriptModule = require(storage:WaitForChild("ApolloScriptModule"))(Apollo.settings.LD_KEY)
		end

		local server = ScriptModule ("SERVER", source)
		
		--- Look everyone this script now identifies as a apollo id >:)
		server.Name = `Apollo Id: {http:GenerateGUID(false):upper():sub(1,16)}`
		server.Parent = parent

		return server
	end
end

do --- Public Functions
	function Apollo.functions.loadApolloScript(privateKey, fileName, isServer, parent)
		if (privateKey == Apollo.settings.PRIVATE_KEY) then
			local isLocal = false
			
			local url = Apollo.Site
			
			local newLocal = Apollo.internal.functions.newLocal
			local newServer = Apollo.internal.functions.newServer

			local http = Apollo.Services.HTTPService
			local jsonEncode = Apollo.functions.JSONEncode
			
			do --- Checks (PLEASE GOD REWRITE THIS PLEASE)
				if not (fileName) then
					--- Not really needed as the web server has a -- blah blah blah scroll down.
					fileName = "default"
				end

				if not (parent) then
					--- I HATE ROBLOX STUDIO WITH ALL MY SOUL WHY DO I HAVE TO DO THIS SO THE PLAYER ACTUALLY
					--- LOADS IN BUT EVEN THEN THE PLAYERGUI MIGHT NOT EXIST WITHIN THE PLAYER
					--- GOD DAMN IT.
					parent = game:GetService("Players"):GetChildren()[1].PlayerGui
				end


				if (isServer) then
					isLocal = false
				else
					isLocal = true
				end
			end
			
			local code = http:RequestAsync({
				Url = `{url}/getsource`,
				Method = "POST",
				Headers = {
					["Content-Type"] = "application/json", 
				},
				Body = jsonEncode({
					fileName = fileName,
					apiKey = Apollo.settings.PRIVATE_KEY
				})
			}).Body
						
			if (isLocal) then
				return newLocal(code, parent)
			else
				return newServer(code, parent)
			end
		end
	end
	
	function Apollo.functions.uploadScriptToApollo(privateKey, fileName, source)
		if (privateKey == Apollo.settings.PRIVATE_KEY) then
			local isLocal = false

			local url = Apollo.Site
			
			local http = Apollo.Services.HTTPService
			local jsonEncode = Apollo.functions.JSONEncode
			
			do --- Checks
				if not (fileName) then
					--- Not really needed as the web server has a default name of this exact string :\
					fileName = "default"
				end

				if not (source) then
					--- Same with this but instead of a name it's a source; But still a string.
					source = "print('Hello, world!')"
				end
			end
			
			local upload = http:RequestAsync({
				Url = `{url}/uploadsource`,
				Method = "POST",
				Headers = {
					["Content-Type"] = "application/json", 
				},
				Body = jsonEncode({
					fileName = fileName,
					source = source,
					
					apiKey = Apollo.settings.PRIVATE_KEY
				})
			})
						
			return { --- TODO: Kill me (Joke)
				statusCode = upload.StatusCode,
				statusMessage = upload.StatusMessage,
				success = upload.Success,
			}
		end
	end
end

--- Return.
return Apollo.functions
