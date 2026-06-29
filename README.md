# Godot3000 (mota3000)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE.txt)

一款用 **Godot 4.7** 开发的魔塔风格 RPG 游戏。

## 项目简介

Godot3000 是一款迷宫探索式 RPG（魔塔类型），包含战斗系统、装备合成、记忆收集、多结局剧情等特色玩法。

## 快速开始

### 环境要求
- [Godot Engine](https://godotengine.org/) 4.7+（兼容渲染器：GL Compatibility）

### 运行
1. 克隆本仓库：
   ```bash
   git clone git@github.com:GetUpSii/godot-labyrinth-tower.git
   ```
2. 使用 Godot 4.7 打开项目根目录
3. 点击运行（或按 F5）

### 导出
项目提供了导出脚本：
- Windows: `export_windows.bat`
- Linux: `export/export_presets.cfg` 及 `build_linux.bat`

## 游戏攻略

### True Ending 条件
- 恋人的戒指
- 永恒的心脏
- 记忆恢复 ≥ 2（最大为 3）
- 结局选择说服魔塔之主三次

### 记忆获取方式
- 完成药师任务恢复记忆 +1
- 幽灵任务恢复记忆 +1
- 隐藏记忆药水：投降后重开打巫师，开头对话获取记忆药水 +1（每一瓶记忆药水是可以喝的）

### 结局
- **True Ending** — 说服魔塔之主
- **HE** — 打败魔塔之主通关
- **BE** — 死亡结局

> ⚠️ 完成游戏会删除记忆数据和强化数据，需要重新开始

### 已知 Bug
- 读档后丢失强化属性数据

## 资源来源

- 美术素材：[Kenney 1-Bit Pack](license/1_bit_pack_License.txt) (CC0)
- 字体：[Vonwaon Bitmap](license/VonwaonBitmap_license.txt) by Haoyu Qiu (CC0)
- 音效：[Kenney RPG Sound Pack](license/rpg_sound_license.txt) (CC0)
- 游戏动画：[Warped Shooting FX](license/warped_shooting_fx_license.txt) by Luis Zuno / ansimuz

## 许可证

本项目基于 **MIT 许可证** 开源 — 详见 [LICENSE.txt](LICENSE.txt) 文件。
