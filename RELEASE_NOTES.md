## CAM350 15.1 Slim v15.1-slim

仅 2D 的精简便携构建，断网在程序内完成。

### 资产
| 文件 | 大小 | SHA256 |
|---|---|---|
| `CAM350_15.1_Slim_Portable.zip` | 255.4 MB | `674A9324D37FDA355E69B6BEAB1A4E800AA948CE20C84BC66BDED0E054C4D596` |
| `CAM350_15.1_Slim_Setup.exe` | 255.4 MB | `3ED4B2114A04FBA94061EB72248E6CB21443F8BF7DB830D1C3D1E647BD55AFDF` |

### 用法
1. 下载 zip → 解压到任意目录
2. 双击 `启动 CAM350.bat`

### 特性
- 解压后 624.6 MB / 2130 文件（原厂仅 CAM350 为 897.6 MB）
- 已移除 3D 转换器（STEP/SolidWorks/JT/CGR 等 210.6 MB）、HOOPS 字体（53.6 MB）、文档（14 MB）
- 程序内断网：`cam350.dll` 内 RSS / 帮助 URL 归零，实测 0 条出站连接
- 无 BluePrint、无 license manager、无服务、无网卡绑定（HOSTID=DEMO）
- 启动参数 `-s -w -Disable3D`，冷启动约 4 秒

### 限制
- 无 3D 视图 / 3D PDF / Stack-Up 3D / STEP 导入
- 出图 PDF 中文字体可能回退系统字体
- 起始页 / 在线帮助 / 新闻不可用

仅用于学习研究，商业使用请购买正版。