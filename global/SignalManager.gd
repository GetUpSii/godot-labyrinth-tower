extends Node

## 地图相关函数
signal on_map_mouse_clicked
signal on_map_level_change

## 玩家
signal on_player_ui_update
signal on_player_change_inventory
signal on_player_learn_skill

## ui
signal on_inventory_ui_change
signal on_craft_at_plot



## 商店相关
signal on_npc_shop_open

## 剧情
signal on_change_plot_p

## 音乐
signal on_change_audio_background
signal on_change_audio_effect

## 战斗
signal on_auto_battle_start
signal on_auto_battle_finished
signal on_battle_start
signal on_battle_player_finished
signal on_battle_ui_focus

signal on_battle_ui_update

## 资源
signal on_resource_invent_update

## 对话
signal play_dialogue_with
signal on_set_dialogue_texture

## 开始
signal start_game
signal load_game
signal end_game

## 星星导航
signal on_tilemap_astar_update_map
signal on_tilemap_astar_navigation
signal on_tilemap_astart_get_path_completed(id: int, path: PackedVector2Array)

## 效果
signal on_revealing_potion_use
