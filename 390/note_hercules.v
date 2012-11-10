hercules虚拟主机操作系统笔记(on linux)

########################################
### install:
########################################
1，安装hercules和x3270（linux发行版下可以直接使用包管理工具来安装，或者从官方网站下载代码来安装。gentoo下的x3270安装net-misc/suite3270即可）

2，把镜像文件copy过来，我用的是原来xp下使用的镜像文件，网络上其它镜像文件应该也是同理。在把配置文件copy过来，把其中目录位置修改成linux下路径即可。（我的配置文件附在文后）

3，即可启动：hercules -f xxx.xxx(-f后指定的为配置文件)

4，开两个x3270窗口，并连接127.0.0.1:3270（后续第一个会变成虚拟机系统控制台，一个会变成tso客户端）

5，Initial Program Load／在hercules command下运行：ipl XXX（我的是ipl 1C0，这个我不理解，似乎是配置文件中所有镜像文件第一个／行前四位数字的后面三位，猜可能是类似于指定从第一个盘开始启动初始化吧）

6，这个时候x3270的第一个窗口就开始输出log了，接下来根据log有2个问题要reply一下，如下。

########################################
### startup:
########################################
在log高亮显示一些log信息后，需要回复确认使得虚拟机正常启动。回复正确后，原来的高亮颜色也会变成普通颜色。
1.
*20.20.32 DEMOPKG          *01 $HASP426 SPECIFY OPTIONS - JES2 OS 2.10 
*       SSNAME=JES2                                                    

输出以上信息时，输入：R 01,cold,noreq （REPLY 01,COLD,NOREQ 同样可以）。linux下x3270回车即是输入，xp下右键ctrl才是输入。当然你可以在客户端修改。

2.
00 *20.23.45 DEMOPKG          *$HASP479 UNABLE TO OBTAIN CKPT DATA SET LOCK - 
   * MEMBER=3090                                                              
   *20.23.45 DEMOPKG          *02 $HASP454 SHOULD JES2 BYPASS THE             
   * MULTI-MEMBER INTEGRITY LOCK? ('Y' OR 'N')                                

输出以上信息时，输入：R 02,y

3.
*20.24.22 DEMOPKG          *$HASP436 CONFIRM COLD START ON            
* CKPT1 - VOLSER=DMTCAT DSN=SYS1.HASPCKDP                             
* CKPT2 - NOT IN USE                                                  
* SPOOL - PREFIX=DMTCA  DSN=SYS1.HASPACE                              
*20.24.22 DEMOPKG          *03 $HASP441 REPLY 'Y' TO CONTINUE         
* INITIALIZATION OR 'N' TO TERMINATE IN RESPONSE TO MESSAGE HASP436   
输出以上信息时，输入：R 03,y


# 此时另一个x3270窗口应该就会显示，让输入tso或其它来进入客户端。
！！！提示：可能会出现不让登录tso的情况，原因是某设备没有启用，在第一个x3270控制台下激活：V NET,ACT,ID=L470（ID后面的是设备名，在你第二个x3270窗口输入tso报错时有提示显示的）。

4.
IST664I REAL  OLU=DALVM101.L470       REAL  DLU=DALVM101.TSTTSO   
IST889I SID = E19BA4F5964D9B75                                    
IST264I REQUIRED RESOURCE TSTTSO NOT ACTIVE                       
IST314I END                                                       

-->  S TSO

5. USER : SYSPRG1,LJC
   PWD  : SYSPRG1,LJC

6. ADD USER ID: P.U.U
   INITIAL PWD : NEW2DAY

7. LIST SYSTEM ADMINISTRATOR ID:
   1) OPTION 6
   2£©LG SYSPROG


########################################
### shutdown:
########################################
1，在第一个x3270控制台下输入
S SHUTDWN
等待log提示shutdown － ended － time＝xxxx

### 过程中有log高亮问题，参考如下回复
4.
*21.22.37 DEMOPKG          *04 BPXF032D FILESYSTYPE NFS TERMINATED.  REPLY
* 'R' WHEN READY TO RESTART. REPLY 'I' TO IGNORE.                         

输入：R 04,I

2，用以下命令查看仍在运行的任务
D A,L

3，如果VTAM没有自动停掉，使用命令关掉：
Z NET,QUICK

4，关闭其它仍在运行的任务
CANCEL xxxx

5，关闭jes2：
$P JES2(OR $JES2,TERM)

6，在hercules上输入stopall，
控制台窗口输入
先E (即exit)
再W (power off)
再Y (yes)

7，最后退出hercules：
exit

# 以上有些关闭过程可能多余，自行跳过即可，但是不要直接就在hercules下退出，或者kill掉hercules进程。


########################################
### others:
########################################
1.  首先在控制台(console)输入以下命令查看LU是否激活：
 D NET,ID=LCL701

2.   如果没有LCL701没有激活，使用下面命令激活LU：
 V NET,ACT,ID=LCL701

3.  启动TSO:
 S TSO
 
4.  强制退出某用户:
 C U＝ID
 CANCEL U=ID

########################################
### 我的配置文件内容:
########################################
# Hercules Emulator Control file...
# Description: OS390
# MaxShutdownSecs: 30
#
#
# System parameters
#

CPUSERIAL 000611
CPUMODEL  3090
MAINSIZE  1024
XPNDSIZE  64
CNSLPORT  3270
NUMCPU    1
ARCHMODE  ESA/390
LOADPARM  01C1DP.1
SYSEPOCH  1900
TZOFFSET  +0008
OSTAILOR  OS/390
PANRATE   50
DEVTMAX   25
PGMPRDOS  LICENSED

# Display Terminals

0463    3270
0470    3270
0471    3270
0472    3270
0473    3270

# DASD Devices

01C0    3390    /home/andersen/390/volume_os390/DMTRES.1C0 sf=/home/andersen/390/volume_os390/DMTRES_1.1C0
01C1    3390    /home/andersen/390/volume_os390/DMTCAT.1C1 sf=/home/andersen/390/volume_os390/DMTCAT_1.1C1
01C2    3390    /home/andersen/390/volume_os390/DMTOS1.1C2 sf=/home/andersen/390/volume_os390/DMTOS1_1.1C2
01C3    3390    /home/andersen/390/volume_os390/DMTOS2.1C3 sf=/home/andersen/390/volume_os390/DMTOS2_1.1C3
01C4    3390    /home/andersen/390/volume_os390/DMTOS3.1C4 sf=/home/andersen/390/volume_os390/DMTOS3_1.1C4
01C5    3390    /home/andersen/390/volume_os390/DMTD01.1C5 sf=/home/andersen/390/volume_os390/DMTD01_1.1C5
01C6    3390    /home/andersen/390/volume_os390/DMTD02.1C6 sf=/home/andersen/390/volume_os390/DMTD02_1.1C6
01C7    3390    /home/andersen/390/volume_os390/DMTD03.1C7 sf=/home/andersen/390/volume_os390/DMTD03_1.1C7
01C8    3390    /home/andersen/390/volume_os390/DMTD04.1C8 sf=/home/andersen/390/volume_os390/DMTD04_1.1C8
01C9    3390    /home/andersen/390/volume_os390/DMTD05.1C9 sf=/home/andersen/390/volume_os390/DMTD05_1.1C9
