# Lora-Tagger

训练Lora的素材图片打标工具，分为好几个板块，后续可以继续添加。

## 功能特性

- 🗺️ **高度图模块** - 专门用于地形高度图的标注
- 👤 **肖像模块** - 针对人物角色的精细化标注
- 🏷️ **丰富的标签预设** - 内置多种常用标签分类
- 💾 **多格式导出** - 支持JSON、TXT、CSV格式
- 🔒 **数据库支持** - 使用Supabase安全存储标注数据

## 快速开始

### 启动服务器

双击运行 `Server.Bat` 或在命令行中运行：

```bash
python Server.py
```

服务器将在 http://localhost:8000 启动

### 使用方法

1. 打开浏览器访问 http://localhost:8000
2. 选择需要的模块（高度图或肖像）
3. 上传图片（支持拖拽）
4. 选择或输入标签
5. 导出标签文件

## 项目结构

```
Lora-Tagger/
├── Server.py              # Python HTTP服务器
├── Server.Bat             # Windows启动脚本
├── Index.html             # 主页
├── Assets/                # 资源文件
│   ├── Height_Map/       # 高度图配置
│   └── Portrait/         # 肖像配置
├── UI/                    # 用户界面
│   ├── components/       # UI组件
│   └── pages/            # 页面文件
└── supabase/             # 数据库迁移文件
```

## 技术栈

- 前端: HTML5 + CSS3 + JavaScript
- 后端: Python 3 HTTP Server
- 数据库: Supabase

## 数据库

项目使用Supabase数据库存储图片和标签数据。数据库架构包括：

- `images` - 存储上传的图片信息
- `tags` - 存储图片标签
- `presets` - 存储用户的预设配置

## 开发说明

### 添加新模块

1. 在 `Assets/` 目录下创建模块配置文件
2. 在 `UI/pages/` 创建对应的页面文件
3. 更新导航链接

### 自定义标签

编辑 `Assets/[模块名]/Strings.json` 文件添加标签类别和预设。

## 许可证

本项目仅供学习和研究使用。
