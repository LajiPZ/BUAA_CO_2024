这不是一个完整的评测机，只是完成了对拍部分的编写。（半自动评测机？2333

文件内作为示例，放了本人的P6代码。

使用前，请确保自己的系统已经配置好了%xilinx%环境变量；具体配置方法见本人的命令行跑ISE办法：http://cscore.buaa.edu.cn/#/discussion_area/1461/1777/posts
(20250204:请见repo中/misc的留档)

修改版MARS来自：https://github.com/Toby-Shi-cloud/Mars-with-BUAA-CO-extension

最初本打算纯利用cmd+powershell完成这部分的编写，但是这两玩意的正则表达式匹配实在难用，故还是引入了python进行输出文本的过滤，源码见t.py

运行前，请确保python环境已正确配置。本可以打包成.exe来略掉这句话的，但是打包下来体积太大，只能这么干了

用法很简单，把测试程序放入.\mars\testCode.asm，随后点击make.bat即可完成程序与Mars的对拍；

可能会出现算术溢出，导致MARS报错的情况，此时请运行make_noArithOvfl.bat

若仅输出一空白行，则说明跟Mars对拍完全一致，反之则与Mars有差异。

若中途make.bat被打断，导致生成的缓存文件未被清除，请点击clear.bat进行清理。

保险起见，对拍过程中生成的机器码code.txt，以及运行结果*_out.txt在结束后仍然保留；如不希望保留，则在clear.bat的rm命令中手动将其加入删除列表即可。

