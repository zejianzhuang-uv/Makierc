# Makierc

[English](README.md) | 中文

Makierc 为 [Makie](https://docs.makie.org) 提供一套现成的绘图样式。只需调用一个函数，图就会有四边朝内的刻度、虚线网格、衬线字体和简洁的图例。样式的任何部分都可以用关键字参数修改。

## 安装

```julia
using Pkg
Pkg.add(url = "https://github.com/zejianzhuang-uv/Makierc.git")
Pkg.add("CairoMakie")
```

Makierc 只负责设置样式。绘制和保存图形还需要一个 Makie 后端，例如 CairoMakie。

## 教程

### 1. 画第一张图

加载这些包，并在创建任何图形之前调用一次 `load_makie_config!()`：

```julia
using CairoMakie, Makierc

load_makie_config!()

x = 0:0.1:2π
fig = Figure()
ax = Axis(fig[1, 1]; xlabel = "x", ylabel = "y", title = "My first figure")
lines!(ax, x, sin.(x); label = "sin(x)")
lines!(ax, x, cos.(x); label = "cos(x)")
axislegend(ax)
fig
```

### 2. 保存图形

用 `savefig` 保存图形，文件格式由文件名决定：

```julia
savefig("first_figure.pdf", fig)
```

背景默认是透明的，适合用于幻灯片和网页。如果要保留背景，请使用 `transparent = false`。其他关键字参数会传给 Makie 的 `save`：

```julia
savefig("first_figure.png", fig; transparent = false, px_per_unit = 3)
```

### 3. 修改样式

传入想修改的设置即可，其余设置保持默认值：

```julia
load_makie_config!(lw = 2.5, fontsize = 18, markersize = 10)
```

新样式只对这次调用之后创建的图形生效，所以需要重新创建图形：

```julia
fig = Figure()
ax = Axis(fig[1, 1]; xlabel = "x", ylabel = "y")
lines!(ax, x, sin.(x); label = "sin(x)")
scatter!(ax, 0:6, sin.(0:6); label = "samples")
axislegend(ax)
savefig("custom_style.pdf", fig)
```

每次调用都会从默认值重新开始。在下面的例子中，第二次调用会重置 `lw`，所以线宽回到 1.8：

```julia
load_makie_config!(lw = 2.5)
load_makie_config!(fontsize = 18)
```

关键字拼写错误时会报 `MethodError`，所以拼写错误不会被悄悄忽略。

### 4. 使用可选的颜色和边距

除非另外指定，否则使用 Makie 默认的颜色和图形边距。Makierc 自带一套 16 色调色板：

```julia
load_makie_config!(palette = Makierc.MPL_PALETTE, figure_padding = 15)
```

也可以传入自己的调色板：

```julia
load_makie_config!(palette = (color = [:black, :red, :blue], patchcolor = [:gray, :pink, :lightblue]))
```

### 5. 选择字体

默认字体是 CMU Serif。**请先把它安装到电脑上**：如果缺少这个字体，Makie 会改用另一种字体，并继续运行。要使用其他字体：

```julia
load_makie_config!(font_regular = "Times New Roman")
```

这里只设置常规字体。Makie 用粗体绘制的文字（例如图例标题）仍然使用 Makie 自带的粗体字体。

### 6. 恢复 Makie 的默认样式

```julia
set_theme!()
```

## 所有设置

下表列出 `load_makie_config!` 的全部关键字参数。也可以在 Julia REPL 中输入 `?load_makie_config!` 查看。

| 类别 | 关键字 | 默认值 |
|---|---|---|
| 线条 | `lw`（用于 `Lines`、`Errorbars` 和 `VLines`） | `1.8` |
| 字体 | `fontsize` | `16` |
| | `font_regular` | `"CMU Serif"` |
| 标记 | `markersize` | `15` |
| 网格 | `xgridstyle`、`ygridstyle` | `Linestyle([0, 3.7, 5.3])` |
| | `xgridcolor`、`ygridcolor` | `"#b0b0b0"` |
| | `xgridwidth`、`ygridwidth` | `0.8` |
| 刻度数量 | `k_ideal`、`k_min`、`k_max` | `5`、`4`、`10` |
| 刻度 | `xtickalign`、`ytickalign` | `1` |
| | `xminortickalign`、`yminortickalign` | `1` |
| | `xticksmirrored`、`yticksmirrored` | `true` |
| | `xminorticksvisible`、`yminorticksvisible` | `true` |
| | `xminorticks`、`yminorticks` | `IntervalsBetween(5)` |
| 图例 | `legend_backgroundcolor` | `(:white, 0.6)` |
| | `legend_framecolor` | `(:black, 0.3)` |
| | `legend_framewidth` | `1.5` |
| 图形 | `figure_padding` | `nothing`（Makie 默认值） |
| | `palette` | `nothing`（Makie 默认值） |

刻度数量设置同时作用于两个坐标轴。`k_ideal` 是期望的刻度数量，`k_min` 和 `k_max` 是它的下限和上限。

## 运行测试

```julia
using Pkg
Pkg.test("Makierc")
```
