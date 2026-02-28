local connection = exports.cr_mysql:getConnection(resource)

function getDB()
    return connection
end

function hashPassword(username, password)
    return hash("sha256", username .. ":" .. password)
end
