./skynet test_base/stm_test/stm_config

------------------------------------------------------------------
https://github.com/cloudwu/skynet/discussions/1474
https://blog.codingnow.com/2014/08/stm.html

1.传给 stm.newcopy 的指针不能由别的地方释放 。而 skynet 的消息分发框架默认会释放指针，所以在传给它时，必须复制这个指针，比如用 skynet.tostring 先把 copy,i 转换为 string 。
2.skynet.forward_type 可以阻止框架释放一类消息。
3.鉴于 stm 模块使用不多，容易用错，我打算下个版本移出 skynet 主仓库，放到单独仓库里。

作者建议
stm 不维护了，不再建议使用。
如果找不到非此不可的理由，不要用数据内存共享的方式同步数据。发消息。

lua gc
对于长期服务，可以用主动调用 gc 的 step 加快循环周期，空闲时更应调用。因为单个 lua vm 的 gc 是由分配驱动的，你不创建新对象，老的就不会回收。
对于短期服务，可以尽快退出，利用 close vm 关闭彻底回收。
-------------------------------------------------------
做测试
service1 创建数据并用共享内存通过call将指针传给 service3，service3 读取数据可能会是空。
创建多个service3 service2 不停的 call service1
service3会报解析失败，应该是共享内存被释放了。

service3 call service2, service2 call service1
service3 call service1

直接用共享内存会报 nil
分析应该是stm_obj被释放了。测试保存句柄就不会报nil
