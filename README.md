# CAM350 15.1 Slim

DownStream CAM350 15.1（build 2142）的精简构建，解压即用。

> 仅用于个人学习与研究环境，商业使用请购买正版授权。

---

## 一、这是什么

| 项目 | 值 |
|---|---|
| 产品 | CAM350 15.1 build 2142（DownStream 2024 套件中的 CAM350 部分，**不含 BluePrint**） |
| 主程序 | `CAM350 15.1\camnt95.exe` |
| 解压后体积 | **624.6 MB / 2130 个文件**（原厂仅 CAM350 为 897.6 MB） |
| 压缩包 | `CAM350_15.1_Slim_Portable.zip`，**255.4 MB** |
| SHA256 | `674A9324D37FDA355E69B6BEAB1A4E800AA948CE20C84BC66BDED0E054C4D596` |
| 安装版 | `CAM350_15.1_Slim_Setup.exe`，255.4 MB，SHA256 `3ED4B2114A04FBA94061EB72248E6CB21443F8BF7DB830D1C3D1E647BD55AFDF` |

## 二、快速开始

```
解压 → 双击「启动 CAM350.bat」
```

启动器内容：

```bat
set "ACT_INC_LICENSE_FILE=%~dp0act_inc.lic"
start "" "%~dp0CAM350 15.1\camnt95.exe" -s -w -Disable3D
```

- `-s` 不显示启动画面
- `-w` 不加载起始页 / 系统消息面板（WebView2 那套 UI）
- `-Disable3D` 跳过 3D 初始化（本构建已无 3D 模块）

## 三、精简了什么

| 内容 | 体积 |
|---|---|
| `HOOPS Bin\` 下 14 个 3D/实体转换器（STEP / SolidWorks / JT / CGR / TfKernel / Qt / ICU / ImageMagick / AdobePDFL / AGM 等） | 210.6 MB |
| `HOOPS Resources\Font`（PDF 出图字体） | 53.6 MB |
| 文档（`newfeatures_*` / `*.doc` / `*.pdf` / `*.chm`） | 14 MB |

**必须保留的两项**（实测删除即不可用）：

- `Microsoft.WebView2.FixedVersionRuntime`（364.6 MB）——许可证等级解析依赖该组件，删除后程序永远停在 `CAM350 Shareware`
- `hps_*.dll`（55.5 MB）——2D 画布同样由 HOOPS 渲染，删除后进程直接退出

## 四、授权

- 1 字节补丁：`CamDLL.dll` 文件偏移 `0x0FFF810`（VA `0x181000810`），`0x75 → 0xEB`
- `act_inc.lic`：94 条 FEATURE，`HOSTID=DEMO`（不含任何网卡 MAC），到期 2030-10-28，20235 字节
- 启动器通过环境变量 `ACT_INC_LICENSE_FILE` 指向同目录 license（不写注册表、不装服务）

## 五、已知限制

- 无 3D 视图 / 3D PDF / Stack-Up 3D
- 无 STEP / 实体模型导入
- 出图 PDF 的中文字体可能回退为系统字体（已移除 HOOPS 自带字体）
- 起始页、在线帮助、新闻、在线支持不可用

## 六、校验

```powershell
Get-FileHash .\CAM350_15.1_Slim_Portable.zip -Algorithm SHA256
# 674A9324D37FDA355E69B6BEAB1A4E800AA948CE20C84BC66BDED0E054C4D596
```

## 七、目录结构

```
CAM350_15.1_Slim_Portable.zip
├─ CAM350 15.1\          2130 个文件 / 624.6 MB
├─ act_inc.lic           20 KB
├─ 启动 CAM350.bat
└─ README.txt
```
