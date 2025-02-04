>本仓库中，包含了本人于北航2024年“计算机组成”课程中各Project的设计，以及产生的设计文档、MARS自动对拍脚本等文件，欢迎各位借鉴学习。 🥰
>
>This repo contains my project designs for course "Computer Organization (or Architecture IMHO?)" at Beihang University. Miscellaneous files such as design documentation and judging batches (using MARS as ref.) are included as well. It's my pleasure were it to be helpful for you. 🥰


声明：
- 本仓库之所有内容**仅供学习交流使用**。直接将本仓库之文件（源码，设计文档，辅助工具等）提交至课程设计的提交窗口，将被课程组认定为**作弊**，**勿谓言之不预。**
- 本仓库中的HDL设计整体面向结果，并未充分考虑硬件实现的效果，也从未进行FPGA验证。切勿将本仓库之HDL设计直接用于硬件实现。

DISCLAIMER:
- The contents of the repo is **for reference only**. Direct use of the files from the repo (codes, docs, tools, etc.) for your project submission would be regarded as **CHEATING**. **You have been warned.**
- The HDL design in this repo is result-oriented, and is not intended to be implemented on hardware (including FPGA). DO NOT use the design for hardware implementation without thorough revision.

---

# 内容

- `./docs`：P3-P7的设计文档。
- `./judge_WIP`：本人使用`cmd`搭建的简易对拍脚本，需配合有输出的修改版MARS使用。
- `./src`：本人各Project的课程设计源码。
- `./misc`：一些小工具，详见介绍。
- `./memo.md`：一点课程进行过程的回忆。

## `./docs`

自P3开始，各位同学将开始搭建简易CPU。在每次进行提交时，课程组会要求上传CPU设计文档，其中需包含需要回答的思考题，以及进行CPU设计时的思路。本部分因此而生。

自P6开始，整体设计基本定型，故内容较为简略，且大量引用了先前Project的设计文档。

# `./judge_WIP`

自P4开始，课程开始使用Verilog进行简易CPU的设计，课程组鼓励各位自行构建评测机（数据生成，对拍）。由于本人能力有限，我使用`cmd`，仅完成了同带输出的修改版MARS，进行自动对拍的脚本的编写。

其中包含三个版本：
- `no_db`：关闭延迟槽功能版本，适用于P4
- `db`：带延迟槽功能版本，适用于P5-P6
- `db_P7`：适用于P7的特殊版本。

前两者使用了[MARS-with-BUAA-CO-extension](https://github.com/Toby-Shi-cloud/Mars-with-BUAA-CO-extension)，而P7部分使用了lcy同学修改的MARS。如有版权问题，请即时在Issue中提出，感谢。

# `./src`

本部分存放了本人P0-P7的设计源码。

- `./P0-P1`：Logisim的`.circ`文件。
- `./P2_controlPatterns`：用MIPS汇编实现的一些简单语句，仅供参考。
- `./P2`：完成课程题目时，产生的汇编代码。
- `./P5_noPause'n'Forward`：完成了数据通路搭建，但**没有构建转发和暂停**的P5设计源码。将其直接运行，出现数据冒险时必出问题。
- 其它`./P[4-7].`：P4-P7的设计源码。请见下文说明。

自P4开始，本人开始使用本人自行研究的命令行调用ISE方法，完成各Project任务。因此，这里的各文件夹，其实是working directory，真正的源码在`./P[4-7]./src`内。

该方法经过数次修改，最稳定的实现在`./P7`内。之前的版本由于`cmd`并行执行的性质，运行可能不稳定。

**有关这一方法的进一步说明，详见`./misc`中内容。**

# `./misc`

主要有三个好玩的东西：

- `experiment_parallel`：一个实验性的并行评测机。存在严重的问题，请务必先看完README！！
- `ISE_cmd`：使用命令行调用ISE。里面的例子就是我P7的工作目录。具体实现已在README中阐明。
- `p7_asmSplitter`：将对P7设计进行测试的`.asm`分割为`.text`与`.ktext`两部分，绕开MARS输出机器码不能输出`.ktext`的限制。已经整合在了P7评测机内。


# `./memo.md`

主观回忆，仅供茶余饭后之谈资。

---

# 版权信息

本仓库中由本人开发的部分（即，除使用的修改版MARS外之所有部分），均使用MIT协议。

对于修改版MARS，请务必遵循[原版MARS之版权声明](MARSlicense.txt)。P7对拍脚本中使用的修改版，亦已获得了该修改版作者的同意。

若有版权问题，请即时在Issue中提出，或[电邮联系](mailto:lajipz@qq.com)，感谢。




