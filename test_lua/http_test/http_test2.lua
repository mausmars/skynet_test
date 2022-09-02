package.cpath = "../../luaclib/?.so;" .. package.cpath

local cjson = require "cjson"

local request = require "http.request"

local uri = "http://dctestv3.happyelements.cn/collect"
local req_body = "[]"
local req_timeout = 10

req_body = "[{\"sub_category\":\"140\",\"uid\":\"2555299\",\"is_online\":0,\"get_info\":\"[{\"resource_amount\":100,\"resource_type\":22,\"resource_id\":5,\"resource_total\":200}]\",\"use_info\":\"{}\",\"category\":\"\",\"event_id\":\"resource_change\",\"appid\":\"combo_qa_prod\",\"user_level\":1,\"user_platform\":\"\",\"server_area\":\"CHN\",\"client_time\":\"2022-08-05 10:00:56\"}]"

local req = request.new_from_uri(uri)
if req_body then
    req.headers:upsert(":method", "POST")
    req.headers:upsert("content-type", "application/octet-stream")
    req:set_body(req_body)
end

print("## HEADERS")
for k, v in req.headers:each() do
    print(k, v)
end

local headers, stream = req:go(req_timeout)
if headers == nil then
    io.stderr:write(tostring(stream), "\n")
    os.exit(1)
end

local body, err = stream:get_body_as_string()

if not body and err then
    io.stderr:write(tostring(err), "\n")
    os.exit(1)
end

print("## HEADERS")
for k, v in headers:each() do
    print(k, v)
end

print("body ", body)
local t = cjson.decode(body)
print(t.code)
