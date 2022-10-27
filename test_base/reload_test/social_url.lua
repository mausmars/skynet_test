-- outer_social_urls = {[服务器id] = url} 使用内网ip
local social_url = {
    outer_china_social_urls = { [101] = "http://10.19.10.5:6677", [200] = "http://10.19.10.2:6677" },
    outer_abroad_social_urls = { [151] = "http://10.19.11.12:6677", [200] = "http://10.19.11.7:6677" },
    intra_social_urls = { [101] = "http://127.0.0.1:6677", [102] = "http://127.0.0.1:6677", [103] = "http://127.0.0.1:6677" }
}
return social_url


