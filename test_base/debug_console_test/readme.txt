./skynet test_base/debug_console_test/config

-----------------------------------------------------------
/etc/profile
export MALLOC_CONF="prof:true,prof_active:false,prof_prefix:jeprof.out"

开始不激活，通过
bool active = true;
mallctl("prof.active", NULL, NULL, &active, sizeof(bool));
对应skynet里的 profactive on 指令

打印
mallctl("prof.dump", NULL, NULL, NULL, 0);
对应skynet里的 dumpheap 指令

启动脚本需要带上一下
# LD_PRELOAD=/usr/local/jemalloc-5.1.0/lib/libjemalloc.so.2

nc 127.0.0.1 33101
profactive on
dumpheap

profactive off

-----------------------------------
nc 127.0.0.1 4444
新版新加的jmem
jmem

stats.active       15347712     14.64 Mb
stats.allocated    14923576     14.23 Mb
stats.mapped       34344960     32.75 Mb
stats.resident     20246528     19.31 Mb
stats.retained      9695232      9.25 Mb

并不能看到具体信息，还是需要
dumpheap
配置好 malloc_conf_config
会在skynet_test 同级目录生成 .heap文件

查看内存细节
jeprof skynet test_base/debug_console_test/jeprof.18179.0.i0.heap
(jeprof) top

生成pdf
jeprof --show_bytes --pdf skynet test_base/debug_console_test/jeprof.18179.0.i0.heap > test_base/debug_console_test/show.pdf


-----------------------------------------------------------
apt update
apt -y install ghostscript
apt install graphviz

生成pdf
jeprof --show_bytes --pdf mem_leak_test1 jeprof.17853.2.m2.heap > show2.pdf

对比2个文件
jeprof --dot mem_leak_test1 -base=jeprof.17853.2.m2.heap jeprof.17853.3.m3.heap