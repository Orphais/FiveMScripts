local joueursEnregistres = {}

RegisterNetEvent("onJoin")

AddEventHandler("onJoin", function()
    local _src = source
    print("^2[JOIN] ^7 Le joueur ^1"..GetPlayerName(_src).." ^7vient de se connecter.")

    MySQL.Async.fetchAll("SELECT userId FROM User WHERE userId = @a", {["a"] = _src}, function(result)
        if result[1] then
            print("^2[DB] ^7Joueur déjà enregistré.")
        else 
            print("^2[DB] ^7Première connexion (joueur non enregistrée).")
            MySQL.Async.execute("INSERT INTO User (userId, userName, userRole) VALUES (@a, @b, @c)", {['a'] = _src, ['b'] = GetPlayerName(_src), ['c'] = "ROLE_USER"}, function() 
                print("^2[DB] Requête insertion into 'User' effectuée.")
            end)
        end
    end)

    MySQL.Async.execute("INSERT INTO IdHistory (idPlayer, namePlayer) VALUES (@a, @b)", {["a"] = _src, ["b"] = GetPlayerName(_src)}, function()
        print("^2[JOIN] Requête insertion effectuée.")
    end)
end)