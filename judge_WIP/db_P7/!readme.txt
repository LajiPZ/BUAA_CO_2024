这是一个只测试异常的，跟MARS对拍的脚本。

使用前，请确保自己的系统已经配置好了%xilinx%环境变量；具体配置方法见本人的命令行跑ISE办法：http://cscore.buaa.edu.cn/#/discussion_area/1461/1777/posts
(20250204:请见repo中/misc的留档)

这仍然是一个对拍脚本，不包含数据生成部分。

由于中断没有什么好的测试方法，我们索性在构造数据的时候，规避所有可能产生中断的情况，即打死不让CP0.SR写入内容，使之恒为32'b0，只测异常；

MARS来自罗春宇同学修改的课程组MARS，谨此致谢。

在运行之前，请在testCode.asm里完成测试程序的编写（包括中断处理程序）；split.py会自动完成.text和.ktext的划分。

自己的源码请放在./src内；注意，本对拍脚本只测异常，请使用./src中已提供的无中断testbench。

准备好后，运行方法很简单，点点run.bat，即可跟MARS自动对拍。

运行之后会留下code.txt，是实际运行的机器码；code_text.txt，code_ktext.txt对应用户程序和中断程序的机器码，*_out.txt为ISIM/MARS的输出结果。

如果对cmd的fc的比较结果不放心，可以自行使用其他方法比较输出结果。

对于本脚本中的.py：
fillTo0x4180.py正如其名，起到把用户程序填充nop到0x4180-4的作用；
cat_ktext.py将处理程序的机器码接到填充后的用户程序中，生成实际的机器码code.txt；
t.py, t1.py分别对ISIM/MARS的输出进行过滤，去除对$0的写操作输出。

